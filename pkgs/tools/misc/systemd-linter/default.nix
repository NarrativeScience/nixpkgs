{ stdenv, fetchurl, rustPlatform, rustRegistry, makeWrapper, nix }:

rustPlatform.buildRustPackage rec {
  name = "systemd-linter-${version}";
  version = "0.1.4";

  src = stdenv.mkDerivation {
    name = "${name}-with-cargo-lock";
    tarball = fetchurl {
      url = https://github.com/mackwic/systemd-linter/archive/v0.1.4.tar.gz;
      sha256= "0vj10wh57jb4nl21l8v5mjnp5n19hsvpqcfkp16vlnh0ay2mfq2n";
    };
    inherit rustRegistry;
    buildInputs = [rustPlatform.rust.cargo];
    buildCommand = ''
      tar xf $tarball
      cd systemd-linter-0.1.4
      cp ${./Cargo.lock} Cargo.lock
      patch -p1 < ${./improve_messaging.patch}
      cd ..
      mv systemd-linter-0.1.4 $out
    '';
  };

  depsSha256 = "1cq9ixiffhifzp26xb8jc9y6s7ylc6j29zkri848dhapb3wfg1fh";

  meta = with stdenv.lib; {
    description = "Lint systemd files";
    homepage = https://github.com/mackwic/systemd-linter;
    license = with licenses; [ mpl20 ];
    platforms = platforms.all;
  };
}
