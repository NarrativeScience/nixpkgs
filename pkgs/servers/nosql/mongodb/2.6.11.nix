# This derivation was resurrected from 4c8ec5e12e187347fd97b1a1a9a43eb19e009ed0
# by elitak for use with the Ubiquiti mFi Controller package, which breaks at
# runtime on mongodb3+ and jre8+. We will need to pull in sufficiently old
# versions of boost and v8 to build this, as well.
{ stdenv, fetchurl, scons, boost155, v8_3_14, gperftools, pcre-cpp, snappy,
  libpcap }:
with stdenv.lib;
let
  version = "2.6.11";
  system-libraries = ["pcre" "boost" "snappy" "v8"]
                     ++ optional stdenv.isLinux "tcmalloc";
in
stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "http://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "0byip39vl6001yjg59d1awmhxqzzjx7amb67sf73wkqiywg4m9p1";
  };

  nativeBuildInputs = [
    scons boost155 v8_3_14 gperftools pcre-cpp snappy
    libpcap
  ];

  postPatch = ''
    substituteInPlace SConstruct \
        --replace "Environment( BUILD_DIR" "Environment( ENV = os.environ, BUILD_DIR" \
        --replace 'CCFLAGS=["-Werror", "-pipe"]' 'CCFLAGS=["-pipe"]'
  '';

  NIX_CFLAGS_COMPILE = [
    "-Wno-unused-local-typedefs"
    "-Wno-unused-variable"
    "-Wno-unused-result"
  ];

  buildPhase = ''
    export SCONSFLAGS="-j$NIX_BUILD_CORES"
    scons all ${toString (map (l: "--use-system-${l}") system-libraries)}
  '';

  installPhase = ''
    mkdir -p $out/lib
    scons install --use-system-all --full --prefix=$out
  '';

  meta = {
    description = "A scalable, high-performance, open source NoSQL database";
    homepage = http://www.mongodb.org;
    license = licenses.agpl3;
    maintainers = with maintainers; [ bluescreen303 elitak ];
    platforms = platforms.linux;
  };
}
