{
  windowsSupport ? true,
  stdenv,
  fetchurl,
  pythonPackages,
  # If true, the dependencies of ansible will be propagated to downstream
  # packages via the PYTHONPATH variable. If false, these will be hidden,
  # used only to wrap the ansible executable files.
  asLibrary ? false
}:

let
  # These are ansible's runtime dependencies.
  depList = with pythonPackages; [
      paramiko jinja2 pyyaml httplib2 boto six
    ] ++ stdenv.lib.optional windowsSupport pywinrm;
  # Propagate the dependencies if we're using ansible as a library.
  propagatedBuildInputs = if asLibrary then depList else [];
  # Otherwise, include them in the pythonPath so that they are used to wrap
  # the generated executables, but don't expose them to downstream packages.
  pythonPath = if asLibrary then [] else depList;
in

pythonPackages.buildPythonPackage (rec {
  inherit propagatedBuildInputs pythonPath;
  buildInputs = pythonPath;

  # Ansible requires python 2.
  disabled = pythonPackages.isPy3k;

  version = "1.9.4";
  name = "ansible-${version}";

  src = fetchurl {
    url = "https://releases.ansible.com/ansible/${name}.tar.gz";
    sha256 = "1qvgzb66nlyc2ncmgmqhzdk0x0p2px09967p1yypf5czwjn2yb4p";
  };

  prePatch = ''
    sed -i "s,/usr/,$out," lib/ansible/constants.py
  '';

  doCheck = false;
  dontStrip = true;
  dontPatchELF = true;
  dontPatchShebangs = true;

  postFixup = ''
      wrapPythonPrograms
  '';

  passthru.pythonPackages = pythonPackages;

  meta = with stdenv.lib; {
    homepage = "http://www.ansible.com";
    description = "A simple automation tool";
    license = licenses.gpl3;
    maintainers = [ maintainers.joamaki ];
    platforms = platforms.linux ++ [ "x86_64-darwin" ];
  };
} // (if asLibrary then {} else {namePrefix = "";}))
