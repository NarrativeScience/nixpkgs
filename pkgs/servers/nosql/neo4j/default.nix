{ stdenv, fetchurl, makeWrapper, jre, which, gnused, lsof, pythonPackages }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "neo4j-${version}";
  version = "2.1.3";

  src = fetchurl {
    url = "http://dist.neo4j.org/neo4j-community-${version}-unix.tar.gz";
    sha256 = "0gcyy6ayn8qvxj6za5463lgy320mn4rq7q5qysc26fxjd73drrrk";
  };

  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [lsof jre which gnused];

  # Remove the line hard-coding NEO4J_INSTANCE to be where neo4j lives in the
  # nix store. This means that the variable must be set by the user.
  patchPhase = ''
    substituteInPlace "bin/neo4j" --replace "NEO4J_INSTANCE=\$NEO4J_HOME" ""
  '';

  installPhase = ''
    mkdir -p "$out/share/neo4j"
    cp -R * "$out/share/neo4j"

    mkdir -p "$out/bin"
    makeWrapper "$out/share/neo4j/bin/neo4j" "$out/bin/neo4j" \
        --prefix PATH : "${jre}/bin:${which}/bin:${gnused}/bin:${lsof}/bin"
    makeWrapper "$out/share/neo4j/bin/neo4j-shell" "$out/bin/neo4j-shell" \
        --prefix PATH : "${jre}/bin:${which}/bin:${gnused}/bin:${lsof}/bin"

    cat <<EOF > $out/bin/makeinstance
    #!${pythonPackages.python.interpreter}
    import sys
    sys.path.append("${pythonPackages.argparse.sitePackages}")
    import argparse, shutil, subprocess
    parser = argparse.ArgumentParser(prog="makeinstance")
    parser.add_argument("destination", help="Where to put the instance.")
    args = parser.parse_args()

    shutil.copytree("$out/share/neo4j", args.destination)
    subprocess.check_call("chmod -R +w {}".format(args.destination),
                          shell=True)
    print("Created Neo4J instance in {}".format(args.destination))
    EOF

    chmod +x $out/bin/makeinstance
  '';

  meta = with stdenv.lib; {
    description = "a highly scalable, robust (fully ACID) native graph database";
    homepage = "http://www.neo4j.org/";
    license = licenses.gpl3;

    maintainers = [ maintainers.offline ];
    platforms = stdenv.lib.platforms.unix;
  };
}
