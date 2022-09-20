let
  pkgs = import ./nix/nixpkgs {
    config = {
      packageOverrides = pkgs: {
        openssl = pkgs.openssl_1_1;
      };
    };
  };
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
