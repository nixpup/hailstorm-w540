{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "epdfinfo";
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    ln -s $(${pkgs.findutils}/bin/find ${pkgs.emacsPackages.pdf-tools}/ -name epdfinfo) $out/bin/
  '';
}
