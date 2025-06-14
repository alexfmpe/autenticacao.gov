
let
  pins = {
    # merge of https://github.com/NixOS/nixpkgs/pull/401526
    nixpkgs = builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/6afe187897bef7933475e6af374c893f4c84a293.tar.gz";
      sha256 = "sha256:1x3yas2aingswrw7hpn43d9anlb08bpyk42dqg6v8f3p3yk83p1b";
    };
  };
  pkgs = import pins.nixpkgs {};
in
 pkgs.mkShell {
   packages = with pkgs; [
     cjson
     curl
     libzip
     openjdk11
     openjpeg
     openpace
     pcsclite
     pkg-config
     swig
     xercesc
     xml-security-c
   ] ++ (with libsForQt5; [
     poppler.dev
     qmake
     qtquickcontrols2
   ]);
}
