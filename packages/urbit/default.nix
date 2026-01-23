{ pkgs ? import <nixpkgs> {} }:

let
  system = pkgs.stdenv.hostPlatform.system;
  platformConfig = config.platforms.${system};
  nclToJson = pkgs.runCommand "urbit-config.json" {
    nativeBuildInputs = [ pkgs.nickel ];
  } ''
    nickel export ${./urbit.ncl} --format json > $out
  '';
  config = builtins.fromJSON (builtins.readFile nclToJson);
in
pkgs.stdenv.mkDerivation {
  inherit (config) pname version;
  
  src = pkgs.fetchzip {
    url = "${config.source.base_url}/${
      builtins.replaceStrings 
        ["{version}" "{platform}"] 
        [config.version platformConfig.platform_string]
        config.source.url_template
    }";
    sha256 = config.source.sha256_hashes.${system};
  };
  
  installPhase = config.phases.installPhase;
  
  passthru.updateScript = config.passthru.updateScript;
  
  meta = with pkgs.lib; {
    inherit (config.meta) homepage description mainProgram platforms;
    maintainers = [ maintainers.nixpup ];
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
