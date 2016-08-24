{stdenv, xcodeBaseDir ? "/Applications/Xcode.app"}:

rec {
  xcodewrapper = import ./xcodewrapper.nix {
    inherit stdenv xcodeBaseDir;
  };

  buildApp = import ./build-app.nix {
    inherit stdenv xcodewrapper;
  };

  simulateApp = import ./simulate-app.nix {
    inherit stdenv xcodewrapper;
  };
}
