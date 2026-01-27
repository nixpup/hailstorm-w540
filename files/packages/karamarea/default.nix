# fonts/my-custom-font.nix
{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "Karamarea";
  version = "1.0";

  # Option 1: local file in your repo
  src = ./files; # directory or archive with .ttf/.otf/.woff2

  # or Option 2: fetch from the web
  # src = fetchzip {
  #   url = "https://example.com/path/to/font.zip";
  #   hash = "sha256-...";
  # };

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/woff2

    # install all supported formats if present
    cp -v *.ttf $out/share/fonts/truetype 2>/dev/null || true
    cp -v *.otf $out/share/fonts/opentype 2>/dev/null || true
    cp -v *.woff2 $out/share/fonts/woff2 2>/dev/null || true
  '';

  meta = with lib; {
    description = "Karamarea Number System Font";
    license = licenses.gpl3; # or the correct license
    platforms = platforms.all;
  };
}
