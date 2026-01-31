{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "groundseg";
  version = "2.4.11";
  src = pkgs.fetchurl {
    url = "https://github.com/Native-Planet/GroundSeg/releases/download/v${version}/groundseg_amd64_latest_v${version}";
    sha256 = "sha256-x2oBVSx2Yig3VnZ4xumnKa6qpUVqR20s36Kl4EZr9rA=";
  };
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];
  sourceRoot = ".";
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 -D $src $out/bin/groundseg
    runHook postInstall
  '';
  passthru.updateScript = ./update-bin.sh;
  meta = with pkgs.lib; {
    homepage = "https://manual.groundseg.app/";
    description = "NativePlanets Urbit Self-Hosting Software";
    maintainers = [ maintainers.nixpup ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "groundseg";
  };
}
