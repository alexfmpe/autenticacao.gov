let
  pkgs = import ./nix/nixpkgs {};
in
 pkgs.mkShell {
   packages = with pkgs;
     with libsForQt5; [
       poppler
       qmake
       qtquickcontrols2
     ] ++ [
       curl
       libzip
       openjdk11
       openjpeg_2
       pcsclite
       pkgconfig
       swig4
       xercesc
       xml-security-c
     ];
}
