{ stdenv, fetchurl, fetchgit, openssl, zlib, pcre, libxml2, libxslt, gd, geoip
, perl }:

assert stdenv.isLinux;

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "openresty-${version}";
  version = "1.11.2.5";

  src = fetchurl {
    url = "http://openresty.org/download/openresty-${version}.tar.gz";
    sha256 = "1fapss58v26pja7al83qym2w8zq92ws6ll35dxknkk8gihz21k7q";
  };

  buildInputs = [ openssl zlib pcre libxml2 libxslt gd geoip perl ];

  configureFlags = [
    "--with-pcre-jit"
    "--with-luajit"
    "--with-http_ssl_module"
    "--with-http_realip_module"
    "--with-http_addition_module"
    "--with-http_xslt_module"
    "--with-http_image_filter_module"
    "--with-http_geoip_module"
    "--with-http_sub_module"
    "--with-http_dav_module"
    "--with-http_flv_module"
    "--with-http_mp4_module"
    "--with-http_gunzip_module"
    "--with-http_gzip_static_module"
    "--with-http_auth_request_module"
    "--with-http_random_index_module"
    "--with-http_secure_link_module"
    "--with-http_degradation_module"
    "--with-http_stub_status_module"
    "--with-ipv6"
  ];

  postInstall = ''
    mv $out/nginx/sbin/nginx $out/bin
  '';

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${libxml2.dev}/include/libxml2 $additionalFlags"
    export PATH="$PATH:${stdenv.cc.libc.bin}/bin"
    patchShebangs .
  '';

  meta = {
    description = "A fast web application server built on Nginx";
    homepage    = http://openresty.org;
    license     = licenses.bsd2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ thoughtpolice ];
  };
}
