{
  # Package metadata
  pname = "urbit",
  version = "4.2",

  # Platform-specific Data
  platforms = {
    "x86_64-linux" = {
      os = "linux",
      arch = "x86_64",
      platform_string = "linux-x86_64",
    },
  },
  
  # Source information
  source = {
    base_url = "https://github.com/urbit/vere/releases/download",
    url_template = "vere-v{version}/{platform}.tgz",
    # SHA256 hashes per platform
    sha256_hashes = {
      "x86_64-linux" = "sha256-UfQJgN1aMMzO1BRm8PZSrIX8EwdQAb4YVB/8tXouM1k=",
    },
  },
  
  # Build/Install phases
  # Note: This is a binary package, so no actual compilation
  phases = {
    # No buildPhase needed - this is a pre-built binary
    buildPhase = null,
    
    # Installation is just copying the binary
    installPhase = 
      "install -m755 -D ./vere* $out/bin/urbit",
    
    # Alternative install phase (commented in original)
    # installPhase_old = fun version platform =>
    #   "install -m755 -D vere-v%{version}-%{platform} $out/bin/urbit",
  },
  
  # Dependencies
  # This package has minimal dependencies since it's a binary
  dependencies = {
    # Runtime dependencies would go here
    # For urbit binary, these are implicit system libs
    buildInputs = [],
    nativeBuildInputs = [],
  },
  
  # Passthru attributes
  passthru = {
    updateScript = "./update-bin.sh",
  },
  
  # Package metadata
  meta = {
    homepage = "https://urbit.org",
    description = "A clean-slate OS and network for the 21st century.",
    
    platforms | Array String = [
      "x86_64-linux"
    ],
    
    maintainers = ["nixpup"],
    license = "mit",
    
    # Source provenance markers
    sourceProvenance = ["binaryNativeCode"],
    mainProgram = "urbit",
  },
}