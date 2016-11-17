{ stdenv, buildPythonPackage, fetchurl, isPy3k, pythonPackages
, version ? "0.9.1"
, sha256 ? "0zmssp41cgb5sz1jym7rxy6mamb64dxq3wra1bn6snna9v653pyj"
}:

let
  inherit (stdenv.lib) optionals versionAtLeast;
in

buildPythonPackage rec {
  name = "twill-${version}";

  disabled = isPy3k;

  src = fetchurl {
    url = "mirror://pypi/t/twill/${name}.tar.gz";
    inherit sha256;
  };

  buildInputs = with pythonPackages; [ nose ];
  propagatedBuildInputs = optionals (versionAtLeast "1.8.0" version) [
    pythonPackages.lxml
    pythonPackages.requests2
    pythonPackages.cssselect
  ];

  doCheck = false; # pypi package comes without tests, other homepage does not provide all verisons

  meta = with stdenv.lib; {
    homepage = http://twill.idyll.org/;
    description = "a simple scripting language for Web browsing";
    license     = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ mic92 ];
  };
}
