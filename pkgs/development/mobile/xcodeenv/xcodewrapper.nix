{stdenv, xcodeBaseDir}:

stdenv.mkDerivation {
  name = "xcode-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    cd $out/bin
    ln_fail () {
      if [[ ! -e $1 ]]; then
        echo "Target $1 does not exist" >&2
        return 1
      else
        ln -s $1
      fi
    }
    ln_fail /usr/bin/xcode-select
    ln_fail /usr/bin/security
    ln_fail /usr/bin/codesign
    if [[ -e ${xcodeBaseDir}/Contents/Developer/usr/bin/xcodebuild ]]; then
      ln -s ${xcodeBaseDir}/Contents/Developer/usr/bin/xcodebuild
    else
      ln_fail /usr/bin/xcodebuild
    fi
    if [[ -e "${xcodeBaseDir}/Contents/Developer/usr/bin/xcrun" ]]; then
      ln -s ${xcodeBaseDir}/Contents/Developer/usr/bin/xcrun
    else
      ln_fail /usr/bin/xcrun
    fi
    ln -s "${xcodeBaseDir}/Contents/Developer/Applications/Simulator.app/Contents/MacOS/Simulator"

    cd $out
    ln -s "${xcodeBaseDir}/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs"

    # Make sure xcodebuild works
    $out/bin/xcodebuild -version
  '';
}
