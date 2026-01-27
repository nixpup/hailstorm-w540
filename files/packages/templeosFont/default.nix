# fonts/my-custom-font.nix
{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "TempleOS";
  version = "1.0";

  # Option 1: local file in your repo
  src = ./files; # directory or archive with .ttf/.otf/.woff2

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype

    # install all supported formats if present
    cp -v *.ttf $out/share/fonts/truetype 2>/dev/null || true
  '';

  meta = with lib; {
    description = "TempleOS Font";
    license = licenses.gpl3; # or the correct license
    platforms = platforms.all;
  };
}
