{ stdenv, fetchurl, fetchpatch }:

stdenv.mkDerivation rec {
  name = "jbig2dec-0.14";

  src = fetchurl {
    url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs922/${name}.tar.gz";
    sha256 = "0k01hp0q4275fj4rbr1gy64svfraw5w7wvwl08yjhvsnpb1rid11";
  };

  # patches =
  #   [ (fetchpatch {
  #       url = "http://git.ghostscript.com/?p=jbig2dec.git;a=patch;h=e698d5c11d27212aa1098bc5b1673a3378563092";
  #       sha256 = "1fc8xm1z98xj2zkcl0zj7dpjjsbz3vn61b59jnkhcyzy3iiczv7f";
  #       name = "CVE-2016-9601.patch";
  #     })
  #   ];

  doCheck = false;

  meta = {
    homepage = https://www.ghostscript.com/jbig2dec.html;
    description = "Decoder implementation of the JBIG2 image compression format";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.unix;
  };
}
