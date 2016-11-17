{ lib, stdenv, fetchurl, fetchpatch, pkgconfig, libtool
, bzip2, zlib, libX11, libXext, libXt, fontconfig, freetype, ghostscript, libjpeg
, lcms2, openexr, libpng, librsvg, libtiff, libxml2, openjpeg, libwebp
, ApplicationServices
, hostPlatform
  # Freeze version on mingw so we don't need to port the patch too often.
  # FIXME: This version has multiple security vulnerabilities
, version ? if (stdenv.cross.libc or null) == "msvcrt"
            then "6.9.2-0" else "6.9.6-2"
# Set to true if you want a single-output derivation.
, binOnly ? false
}:

let
  arch =
    if stdenv.system == "i686-linux" then "i686"
    else if stdenv.system == "x86_64-linux" || stdenv.system == "x86_64-darwin" then "x86-64"
    else if stdenv.system == "armv7l-linux" then "armv7l"
    else throw "ImageMagick is not supported on this platform.";

  cfgs = {
    "6.9.6-2" = {
      sha256 = "139h9lycxw3lszn052m34xm0rqyanin4nb529vxjcrkkzqilh91r";
      patches = [];
    };
    "6.9.2-0" = {
      sha256 = "17ir8bw1j7g7srqmsz3rx780sgnc21zfn0kwyj78iazrywldx8h7";
      patches = [(fetchpatch {
        name = "mingw-build.patch";
        url = "https://raw.githubusercontent.com/Alexpux/MINGW-packages/"
          + "01ca03b2a4ef/mingw-w64-imagemagick/002-build-fixes.patch";
        sha256 = "1pypszlcx2sf7wfi4p37w1y58ck2r8cd5b2wrrwr9rh87p7fy1c0";
      })];
    };
    "6.9.7-0" = {
      sha256 = "0c6ff1am2mhc0dc26h50l78yx6acwqymwpwgkxgx69cb6jfpwrdx";
      patches = [];
    };
    "7.0.3-7" = {
      sha256 = "1mvi8nm12134jn2ccr10aviacqp99q2wv9rj47csw9ik7brrj2ql";
      patches = [];
    };
    "7.0.4-7" = {
      sha256 = "119pkwhp0r1f40vwr9gz41plm9035kr3mxj4gydfkpiswnksa8n4";
      patches = [];
    };
  };
  cfg = cfgs."${version}" or (throw "No info recorded for version ${version}");
  atleast7 = stdenv.lib.versionAtLeast version "7";
in

stdenv.mkDerivation rec {
  name = "imagemagick-${version}";
  inherit version;

  src = fetchurl {
    urls = [
      "mirror://imagemagick/releases/ImageMagick-${version}.tar.xz"
      # the original source above removes tarballs quickly
      "http://distfiles.macports.org/ImageMagick/ImageMagick-${version}.tar.xz"
      "https://bintray.com/homebrew/mirror/download_file?file_path=imagemagick-${version}.tar.xz"
    ];
    inherit (cfg) sha256;
  };

  patches = cfg.patches;

  # bin/ isn't really big
  outputs = if binOnly then ["out"] else [ "out" "dev" "doc" ];
  outputMan = "out"; # it's tiny

  enableParallelBuilding = true;

  configureFlags =
    [ "--with-frozenpaths" ]
    ++ [ "--with-gcc-arch=${arch}" ]
    ++ lib.optional (librsvg != null) "--with-rsvg"
    ++ lib.optionals (ghostscript != null)
      [ "--with-gs-font-dir=${ghostscript}/share/ghostscript/fonts"
        "--with-gslib"
      ]
    ++ lib.optionals (hostPlatform.isMinGW)
      [ "--enable-static" "--disable-shared" ] # due to libxml2 being without DLLs ATM
    ;

  nativeBuildInputs = [ pkgconfig libtool ];

  buildInputs =
    [ zlib fontconfig freetype ghostscript
      libpng libtiff libxml2
    ]
    ++ lib.optionals (!hostPlatform.isMinGW)
      [ openexr librsvg openjpeg ]
    ++ lib.optional stdenv.isDarwin ApplicationServices;

  propagatedBuildInputs =
    [ bzip2 freetype libjpeg lcms2 ]
    ++ lib.optionals (!hostPlatform.isMinGW)
      [ libX11 libXext libXt libwebp ]
    ;

  postInstall = lib.optionalString (!binOnly) ''
    (cd "$dev/include" && ln -s ImageMagick* ImageMagick)
    moveToOutput "bin/*-config" "$dev"
    moveToOutput "lib/ImageMagick-*/config-Q16" "$dev" # includes configure params
    for file in "$dev"/bin/*-config; do
      substituteInPlace "$file" --replace pkg-config \
        "PKG_CONFIG_PATH='$dev/lib/pkgconfig' '${pkgconfig}/bin/pkg-config'"
    done
  '' + lib.optionalString (ghostscript != null) ''
    for la in $out/lib/*.la; do
      sed 's|-lgs|-L${lib.getLib ghostscript}/lib -lgs|' -i $la
    done
  '';

  meta = with stdenv.lib; {
    homepage = http://www.imagemagick.org/;
    description = "A software suite to create, edit, compose, or convert bitmap images";
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ the-kenny wkennington ];
  };
}
