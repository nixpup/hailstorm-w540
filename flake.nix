{
  description = "NixOS configuration for hailstorm (flake-based)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.6.0";

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Run 'doas nix flake update nixmacs' after changes to
    # the repository to rebuild with latest changes!
    nixmacs = {
      url = "git+https://codeberg.org/nixpup/NixMacs.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
    };

    nix-search-tv = {
      url = "github:3timeslazy/nix-search-tv";
    };
  
  };

  outputs = inputs@{ self, nixpkgs, home-manager, # Added 'inputs@'
              nix-flatpak, stylix,
              nix-index-database, nixmacs,
              nixvim, noctalia, nix-alien,
              nix-search-tv, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.hailstorm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; }; # Added for Noctalia
        modules = [
          # Your existing configuration.nix (this file must stay in the same directory as flake.nix)
          #./configuration.nix
          stylix.nixosModules.stylix
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          
          ({ config, pkgs, lib, ... }:
            let
              synapsian = pkgs.callPackage ./packages/synapsian/default.nix {};
              karamarea = pkgs.callPackage ./packages/karamarea/default.nix {};
              osuLazerLatest = pkgs.callPackage ./packages/osuLazerLatest.nix {};
            in {
            # Replace the let-bindings in configuration.nix with these, or
            # delete them from configuration.nix entirely and rely on imports here.

              # Use the Home Manager NixOS module from the flake input
              imports = [
                home-manager.nixosModules.home-manager
                nix-flatpak.nixosModules.nix-flatpak
                ./hardware-configuration.nix
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.puppy = import ./home.nix;
                extraSpecialArgs = { 
                  inherit inputs pkgs; # Added 'inputs' for noctalia
                };
                sharedModules = [
                  stylix.homeModules.stylix
                  nixmacs.homeManagerModules.default
                  nixvim.homeModules.nixvim
                  inputs.noctalia.homeModules.default # Noctalia
                ];
                backupFileExtension = "backup";
              };

            # NixOS Configuration
            # Kernel
            boot.kernelPackages = pkgs.linuxPackages;
            boot.kernelParams = [ "nvidia-drm.modeset=1" ];
            # Bootloader
            specialisation.rescue.configuration = {
              boot.kernelParams = [ "systemd.unit=rescue.target" ];
            };
            boot.loader.grub = {
              #extraEntries = ''
              #  menuentry "Rescue" {
              #    set root=(hd0,1)
              #    linux ($drive1)/EFI/nixos/kernel-${config.boot.kernelPackages.kernel.modDirVersion} \
              #      systemd.unit=rescue.target
              #    initrd ($drive1)/EFI/nixos/initrd-${config.boot.kernelPackages.kernel.modDirVersion}
              #  }
              #'';
              device = "/dev/sda";
              theme = pkgs.stdenv.mkDerivation {
                pname = "distro-grub-themes";
                version = "3.1";
                src = pkgs.fetchFromGitHub {
                  owner = "AdisonCavani";
                  repo = "distro-grub-themes";
                  rev = "v3.1";
                  hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
                };
                installPhase = "cp -r customize/nixos $out";
              };
            };
            # networking.wireless.enable = true;  # Enables wireless w/ wpa_supplicant.
            services.udev = {
              packages = [ pkgs.utillinux ];
              extraRules = ''
                # Wacom CTH-480 for OpenTabletDriver (OTD)
                SUBSYSTEM=="hidraw", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", MODE="0666", GROUP="plugdev"
              '';
            };
            # Guix
            services.guix = {
              enable = true;
              substituters = {
                urls = [
                  "https://bordeaux.guix.gnu.org"
                  "https://ci.guix.gnu.org"
                  "https://berlin.guix.gnu.org"
                  "https://substitutes.nonguix.org"
                ];
              };
            };
            # Enable networking
            networking = {
              networkmanager.enable = true;
              hostName = "hailstorm";
            };
            # Set your time zone.
            time.timeZone = "Europe/Berlin";
            # Select internationalisation properties.
            i18n.defaultLocale = "en_US.UTF-8";
            i18n.extraLocaleSettings = {
              LC_ADDRESS = "de_DE.UTF-8";
              LC_IDENTIFICATION = "de_DE.UTF-8";
              LC_MEASUREMENT = "de_DE.UTF-8";
              LC_MONETARY = "de_DE.UTF-8";
              LC_NAME = "de_DE.UTF-8";
              LC_NUMERIC = "de_DE.UTF-8";
              LC_PAPER = "de_DE.UTF-8";
              LC_TELEPHONE = "de_DE.UTF-8";
              LC_TIME = "de_DE.UTF-8";
            };
            hardware.graphics = {
              enable = true;
              enable32Bit = true;
            };

            # Nvidia
            # BEGIN Grok Nvidia Application Profile
            environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text = builtins.toJSON {
              rules = [
                {
                  pattern = { feature = "procname"; matches = [ "niri" ]; };
                  profile = "Limit free buffer pool on Wayland compositors";
                }
              ];
              profiles = [
                {
                  name = "Limit free buffer pool on Wayland compositors";
                  settings = [
                    { key = "GLVidHeapReuseRatio"; value = 0; }
                    { key = "GLUseEGL"; value = 0; }
                  ];
                }
              ];
            };
            # END Grok Nvidia Application Profile
            # BEGIN Perplexity Recommendation Service | Apparently not required when using
            # GDM as your display manager as that would handle Niri and the launch of the session.
            #systemd.user.services.niri = {
            #  enable = true;
            #  unitConfig = {
            #    Description = "Niri compositor";
            #  };
            #  serviceConfig = {
            #    ExecStart = ''
            #      env \
            #        GBM_BACKENDS_PATH=${pkgs.mesa.drivers}/lib/gbm \
            #        niri --session
            #    '';
            #  };
            #  wantedBy = [ "graphical-session.target" ];
            #};
            # END Perplexity Recommendation Service
            # BEGIN Claude Variables
            environment.sessionVariables = {
              LIBVA_DRIVER_NAME = "nvidia";
              GBM_BACKEND = "nvidia-drm";
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              # Uncomment line below to fix potential cursor issues (invisible or
              # glitchy).
              # WLR_NO_HARDWARE_CURSORS = "1"
            };
            # END Claude Variables
            nixpkgs.config.nvidia.acceptLicense = true; # Accept Nvidia License (required)
            hardware.nvidia = {
              open = false; # Use nonfree Drivers 
              modesetting.enable = true;  # Required for Wayland
              nvidiaPersistenced = true; # Recommended by Perplexity AI
              powerManagement.enable = true;  # For laptop battery
              package = config.boot.kernelPackages.nvidiaPackages.legacy_470;  # For Kepler (K2100M)
              # PRIME hybrid setup
              prime = {
                sync.enable = true; # This can be disabled, and replaced by offload.
                # /\ More testing is required.
                intelBusId = "PCI:0:2:0";  # Check with lspci | grep VGA
                nvidiaBusId = "PCI:1:0:0";  # Adjust based on your lspci output
                #offload = {
                #  enable = true;  # Run apps on Nvidia via env vars
                #  enableOffloadCmd = true;
                #};
              };
            };
            # Fingerprint Sensor
            #services.fprintd = {
            #  enable = true;
            #  tod = {
            #    enable = true;
            #    driver = pkgs.libfprint-2-tod1-goodix;
            #  };
            #};
            #security.pam.services = {
            #  login.enable = false;
            #  gdm = {
            #    enable = true;
            #  };
            #  sudo.enable = false;
            #};
            # Enable the X11 windowing system.
            programs.xwayland.enable = true;
            services.xserver = {
              videoDrivers = [ "nvidia" ];
              enable = true;
              xkb.layout = "us";
              displayManager = {
                gdm.wayland = true;
                gdm.enable = true;
              };
              desktopManager = {
                gnome.enable = true;
                xterm.enable = true;
              };
              windowManager.xmonad = {
                enable = true;
                enableContribAndExtras = true;
              };
              windowManager.i3 = {
                enable = true;
                extraPackages = with pkgs; [
                  dmenu
                  i3status
                  i3blocks
                  autotiling
                  polybarFull
                  picom
                  betterlockscreen
                  dunst
                  libnotify
                ];
                package = pkgs.i3-rounded;
              };
            };

           # Fonts
           fonts = {
             packages = with pkgs; [
               synapsian
               karamarea
               noto-fonts
               noto-fonts-cjk-sans
               noto-fonts-emoji-blob-bin
               liberation_ttf
               fira-code
               fira-code-symbols
               dina-font
               proggyfonts
               uw-ttyp0
               terminus_font
               terminus_font_ttf
               tamzen
               powerline-fonts
               twitter-color-emoji
               iosevka
               nerd-fonts.symbols-only
               nerd-fonts.blex-mono
               maple-mono.truetype
               tt2020 # Typewrite Font
               emacs-all-the-icons-fonts # Required for Emacs all-the-icons
             ];
           };
           # Users
           users.users.puppy = {
             isNormalUser = true;
             shell = pkgs.zsh;
             description = "puppy";
             extraGroups = [ "networkmanager" "wheel" "dialout" "plugdev" "guixbuild" ];
             packages = with pkgs; [
               gamescope
               microsoft-edge
               feh
               cmus
               alsa-utils
               hyfetch
               pridefetch
               fastfetch
               pfetch
               discord
               vesktop
               veracrypt
               gimp3-with-plugins
               pciutils
               xdotool
               fd
               xorg.xrandr
               xorg.xprop
               xorg.xwininfo
               flameshot
               redshift
               zathura
               picard # mp3 Tagging
               krita
               microfetch
               imagemagick
               yt-dlp
               rofimoji
               rofi
               ardour
               kdePackages.kdenlive
               signal-desktop-bin
               telegram-desktop
               xclip
               texliveFull
               strawberry
               blahaj
               pavucontrol
               zip
               p7zip
               unzip
               unrar
               appimage-run
               rsync
               zenmap
               gparted
               parted
               jq
               translate-shell
               progress
               openssl
               coreutils-full
               nix-prefetch-scripts
               obs-studio
               libreoffice
               gnome-shell-extensions
               xfce.thunar
               kew # Terminal Music Player with Cover Preview
               hfsprogs # For Apple HFS+ Filesystems
               ntfs3g # NTFS Filesystem Support
               cryptsetup # LUKS Encryption
               testdisk # File Recovery Utilities
               encfs # Create Encrypted Folders
               usbutils
               websocat
               gnome-font-viewer
               fontforge-gtk
               fontpreview
               pamixer
               # Javascipt/NodeJS
               nodejs_24
               # Arduino
               xorg.xkbutils
               arduino-ide
               # Wine
               wineWowPackages.full
               winetricks
               # Games
               ace-of-penguins
               kdePackages.kpat
               azahar # 3DS Emulator
               ryujinx # Switch Emulator
               skyemu # GameBoy Advanced Emulator
               prismlauncher # Minecraft
               # Networks
               urbit
               librewolf-bin # For I2P
               tor-browser # For Tor
               # Rust
               cargo
               rustc
               rustfmt
               clippy
               rust-analyzer
               gcc
               libgcc
               rustlings
               # XMonad
               xmobar
               # Niri
               swaybg
               waybar
               swayidle
               hyprlock
               swaylock-fancy
               wlsunset
               wofi
               wtype
               mako
               xwayland
               xwayland-satellite
               grim
               foot
               grimblast
               sway-contrib.grimshot
               hyprpicker
               wf-recorder
               cliphist
               fuzzel
               wl-clipboard
               brightnessctl
               playerctl
               wireplumber
               gammastep
               xdg-desktop-portal
               xdg-desktop-portal-gtk
               hyprshot
               # Alternative Programs
               eza
               bat
               zoxide
               bottom
               bandwhich
               pokeget-rs
               ripgrep
               ripgrep-all
               clock-rs
             ];
           };
           # Programs
           programs = {
             zsh = {
               enable = true;
               enableCompletion = true;
               autosuggestions.enable = true;
               syntaxHighlighting.enable = true;
               shellAliases = {
                 # Basics
                 cd = "z $@";
                 cdi = "zi $@";
                 q = "exit";
                 ol = "sh -c 'ls $@'";
                 ols = "sh -c 'ls $@'";
                 ola = "sh -c 'ls -r -A $@'";
                 l = "eza --icons $@";
                 ls = "eza --icons $@";
                 la = "eza --icons -l -r -A -T -L=1 $@";
                 ll = "eza --icons -a $@";
                 cls = "clear $@";
                 # Nix Related
                 # Outdated Rebuild and Garbage Commands
                 #garbage = "sudo nix-collect-garbage -d $@";
                 #rebuild = "sudo nixos-rebuild switch $@";
                 # Old Home-Manager Inclusive Aliases
                 #garbage = "doas nix-collect-garbage -d && home-manager expire-generations '-2 days'";
                 #rebuild = "doas nixos-rebuild switch --flake /etc/nixos#snowflake && home-manager switch --flake /etc/nixos#puppy";
                 home-rebuild = "home-manager switch --flake /etc/nixos#puppy $@";
                 home-garbage = "home-manager expire-generations '-1 days'";
                 rebuild = "doas nixos-rebuild switch --flake /etc/nixos#hailstorm $@";
                 garbage = "doas nix-collect-garbage -d $@";
                 ns = "nix-shell --run zsh $@";
                 search = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
                 nixbuild = "echo 'Did you mean `buildnix`?'";
                 repair = "doas nix-store --verify --repair $@";
                 nix-generations = "doas nix-env --list-generations --profile /nix/var/nix/profiles/system $@";
                 #generations = "echo -e 'NixOS Generations:\n' && doas nix-env --list-generations --profile /nix/var/nix/profiles/system && echo -e '\nHome-Manager Generations:\n' && home-manager generations";
                 generations = "echo -e 'NixOS Generations:\n' && doas nix-env --list-generations --profile /nix/var/nix/profiles/system && echo -e '\nHome-Manager Generations:\n' && ls -l ~/.local/state/nix/profiles/ | grep home-manager";
                 #home-generations = "home-manager generations $@";
                 home-generations = "ls -l ~/.local/state/nix/profiles/ | grep home-manager $@";
                 # Fetching
                 fetch = "echo -e 'mf => Microfetch\npf => Pridefetch\nhf => Hyfetch\nff => Fastfetch'";
                 hf = "hyfetch $@";
                 pf = "pridefetch -f trans --width 11 $@";
                 mf = "microfetch $@";
                 ff = "fastfetch $@";
                 pef = "pfetch $@";
                 distro = "cat /etc/*-release | grep 'PRETTY_NAME' | cut -c 13- | sed 's/\"//g'";
                 lsbOsRelease = "lsb_release -sd $@";
                 # Editing
                 e = "nixmacs -nw $@";
                 # Downloading
                 mp3 = "yt-dlp -x --audio-format mp3 -o '%(uploader)s - %(title)s' $@";
                 # Extra
                 grep = "rg $@";
                 oldgrep = "grep $@";
                 cargorun = "RUSTFLAGS='-Awarnings' cargo run";
                 fireswitch = "nix-shell -p firefox --run 'firefox -no-remote -ProfileManager' $@";
                 lsfind = "find . -name '$@'";
                 # Zipping
                 tarShow = "tar tvf $@";
                 tarUnzip = "tar xvf $@";
                 tarZip = "echo 'Arg1: Archive.tar.gz, Arg2: Full Path of the Folder';tar -czvf $@";
                 # Applications
                 poke = "pokeget --hide-name $@";
                 weather = "curl wttr.in/Berlin $@";
                 wetter = "curl wttr.in/Berlin $@";
                 htop = "btm --theme nord $@";
                 iftop = "bandwhich $@";
                 gc = "git clone $@";
                 cat = "bat --style full --theme=TwoDark --pager=less --paging=auto --wrap=auto $@";
                 wp = "feh --bg-fill $@";
                 forcekill = "kill -9 $@";
                 size = "du -sh $@";
                 analogcity = "ssh lowlife@45.79.250.220 $@";
                 shreddy = "shred -z -u -v --iterations=1 $@";
                 wineosu = "WINEPREFIX=$HOME/.wine-osu wine64 $@";
                 winethirtytwo = "WINEPREFIX=$HOME/.wine-thirtytwo wine $@";
                 ipinfo = "curl ipinfo.io | jq .";
                 radminstart = "doas systemctl start zerotierone $@";
                 zerotierstart = "doas systemctl start zerotierone $@";
                 torstart = "doas systemctl start tor $@";
                 radminstop = "doas systemctl stop zerotierone $@";
                 zerotierstop = "doas systemctl stop zerotierone $@";
                 torstop = "doas systemctl stop tor $@";
                 radminstatus = "doas systemctl status zerotierone $@";
                 zerotierstatus = "doas systemctl status zerotierone $@";
                 torstatus = "doas systemctl status tor $@";
                 cp = "rsync -ah --progress $1 $2";
                 encryptunmount = "echo \"encryptunmount /mnt/Decrypted\";fusermount -u $1";
                 encryptmount = "echo \"encryptmount /mnt/Encrypted /mnt/Decrypted\";encfs $1 $2";
                 clock = "clock-rs --color red --hide-seconds --bold --fmt '%A, %d.%m.%Y'";
                 cleanflatpak = "flatpak uninstall --unused";
                 guix-garbage = "guix gc $@";
                 guix-update = "guix pull && guix package --upgrade && guix gc $@";
               };
               shellInit = ''
                 # Open Cargo.toml in the way of your path.
                 cartom() {
                   local dir="$PWD"
                   while [[ "$dir" != "/" ]]; do
                     if [[ -f "$dir/Cargo.toml" ]]; then
                       nixmacs -nw "$dir/Cargo.toml"
                       return 0
                     fi
                     dir=$(dirname "$dir")  # go one directory up
                   done
                   echo "Couldn't find 'Cargo.toml' in any parent directory."
                   return 1
                 }
         
                 # Build Nix Function/Expression (package.nix).
                 buildnix() {
                   if [[ -f "package.nix" ]]; then
                     echo "Found 'package.nix', building now..."
                     nix-build -E 'with import <nixpkgs> {}; callPackage ./package.nix {}'
                   else
                     echo "Could not find 'package.nix'!"
                   fi
                 }
         
                 # Nix and Home Generations
                 nixgens() {
                   NixGens=$(doas nix-env --list-generations --profile /nix/var/nix/profiles/system)
                   HomeGens=$(home-manager generations)
                   echo -e "NixOS Generations:\n$NixGens\nHome-Manager Generations:\n$HomeGens\n"
                 }
         
                 # Get Nix SRI sha256 Hash from URL
                 hashurl() {
                   URL=$@
                   HASH=$(nix-prefetch-url $URL)
                   FINAL=$(nix hash convert --to sri --hash-algo sha256 $HASH)
                   echo -e "\nYour SRI sha256 Hash is:\n$FINAL"
                 }
         
                 # YouTube to mp4
                 mp4() {
                   yt-dlp -f bestvideo+bestaudio -o "%(title)s.%(ext)s" $@
                 }
                 mp4fallback() {
                   yt-dlp -f "bv*+ba/best" --merge-output-format mp4 --user-agent "Mozilla/5.0" --retries 20 -o "%(title)s.%(ext)s" $@
                 }
         
                 # Disks Command
                 disks() {
                   case "$1" in
                     type)
                       watch -n 1 lsblk -f
                       ;;
                     ext)
                       watch -n 1 lsblk -f
                       ;;
                     fdisk)
                       doas watch -n 1 fdisk -l
                       ;;
                     *)
                       watch -n 1 lsblk
                       ;;
                   esac
                 }

                 # Upload Files
                 upload() {
                   case "$1" in
                     1)
                       curl --upload-file $2 https://dropcli.com/upload
                       ;;
                     2)
                       curl -T $2 -s -L -D - xfr.station307.com | grep human
                       ;;
                     *)
                       echo "Please choose either '1' or '2' for a file hoster."
                       ;;
                   esac
                 }
         
                 # Universal Extractor
                 extract() {
                   for archive in "$@"; do
                     case "$archive" in
                       *.tar.bz2)   tar xjf "$archive"   ;;
                       *.tar.gz)    tar xzf "$archive"   ;;
                       *.tar.xz)    tar xJf "$archive"   ;;
                       *.tar.zst)   unzstd "$archive" | tar xf - ;;
                       *.tar)       tar xf "$archive"    ;;
                       *.bz2)       bunzip2 "$archive"   ;;
                       *.gz)        gunzip "$archive"    ;;
                       *.zip)       unzip "$archive"     ;;
                       *.7z)        7z x "$archive"      ;;
                       *.rar)       unrar x "$archive"   ;;
                       *)           echo "Don't know how to extract $archive." ;;
                     esac
                   done
                 }

                 # Nix Clean
                 clean() {
                   doas nix-store --gc
                   doas nix-collect-garbage -d
                   nix store optimise
                 }
         
                 # Ports
                 ports() {
                   doas ss -tulnp | awk '
                     NR==1 {print; next}
                     {printf "%-5s %-20s %-30s %-30s %s\n", $1, $5, $6, $7, $9}'
                 }
         
                 # File Edit Picker
                 edit() {
                   local file
                   file=$(fzf) || return
                   emacs -nw "$file"
                 }
         
                 # Translate Text to English
                 translate() {
                   trans -brief :"en" "$@"
                 }
         
                 # Fuzzy Kill
                 fkill() {
                   local line pid
                   # Pick a process
                   line=$(ps -ef | sed 1d | fzf) || return
                   pid=$(awk '{print $2}' <<< "$line") || return
                   # Ask for confirmation
                   echo "Selected: $line"
                   read -q "REPLY?Kill process $pid? [y/N] "
                   echo  # newline after read -q
                   if [[ "$REPLY" == [yY] ]]; then
                     kill -9 "$pid"
                     echo "Killed process $pid"
                   else
                     echo "Aborted."
                   fi
                 }
         
                 # Random String Generator
                 random() {
                   local len
                   if [ -z "$1" ]; then
                     len=12
                   else
                     len="$1"
                   fi
                   head /dev/urandom | tr -dc A-Za-z0-9 | head -c "$len"
                   echo
                 }
         
                 # Password Generator
                 password() {
                   local len
                   local file="/mnt/Files/Temp/RandomPasswords.DD"
                   if [ -z "$1" ]; then
                     len=24
                     local pass=$(openssl rand -base64 24)
                   else
                     len="$1"
                     local pass=$(openssl rand -base64 "$len")
                   fi
                   if ! [ -e "$file" ]; then
                     touch "$file"
                   fi
                   echo "$pass" >> /mnt/Files/Temp/RandomPasswords.DD
                   echo -e "Printed Password to /mnt/Files/Temp/RandomPasswords.DD.\nPassword: $pass"
                 }
         
                 # LUKS Encryption
                 cryptmount() {
                   if [[ -z "$1" ]]; then
                     echo "Type cryptmount /dev/DRIVE."
                     return 1
                   fi
                   DRIVE="$1"
                   doas cryptsetup --type luks open "$DRIVE" encrypted || {
                     echo " Failed to open encrypted container."
                     return 1
                   }
                   doas mount -t ext4 /dev/mapper/encrypted /mounted || {
                     echo "Failed to mount."
                     return 1
                   }
                 }
                 cryptunmount() {
                   doas umount /mounted
                   doas cryptsetup close encrypted
                 }
         
                 # Extra Crypt
                 extramount() {
                   doas cryptsetup open /dev/sda2 extradisk
                   doas mount /dev/mapper/extradisk /extra
                 }
                 extraunmount() {
                   doas umount /extra
                   doas cryptsetup close extradisk
                 }
         
                 # Progress Bar Move
                 move() {
                   command mv "$@" &
                   pid=$!
                   progress -mp $pid
                   wait $pid
                 }
         
                 # Trash
                 trash() {
                   local file="$1"
                   local dir="$HOME/.local/share/Trash/files"
                   mkdir -p "$dir"
                   mv "$file" "$dir"
                   echo "Moved $file to Trash."
                 }
         
                 # Serve HTTP Server in Current Directory
                 serve() {
                   local port
                   if [ -z "$1" ]; then
                     port=8000
                   else
                     port="$1"
                   fi
                   nix-shell -p python3 --run "python3 -m http.server "$port""
                 }
         
                 # Backup Files
                 backup() {
                   if [ -z "$1" ]; then
                     echo "Usage: backup <File>"
                     return 1
                   fi
                   cp -r "$1" "$1.$(date +%Y%m%d_%H%M%S).backup"
                 }

                 # Guix Initialization and Setup
                 GUIX_PROFILE="$HOME/.config/guix/current"
                 . "$GUIX_PROFILE/etc/profile"
                 GUIX_PROFILE="$HOME/.guix-profile"
                 . "$GUIX_PROFILE/etc/profile"
                 GUIX_PROFILE="/var/guix/profiles/per-user/puppy/guix-profile"
                 . "$GUIX_PROFILE/etc/profile"
                 source "$GUIX_PROFILE/etc/profile"

                 # Initialize Zoxide (cd alternative).
                 eval "$(zoxide init zsh)"
               '';
               ohMyZsh = {
                 enable = true;
                 theme = "";
               };
               promptInit = ''
                 if [[ -n "$IN_NIX_SHELL" ]]; then
                   PROMPT='  nix-shell %~ '
                 else
                   PROMPT='  %~ '
                 fi
               '';
             };
             firefox.enable = true;
             steam = {
               enable = true;
               remotePlay.openFirewall = true;
               dedicatedServer.openFirewall = true;
               localNetworkGameTransfers.openFirewall = true;
               extraCompatPackages = with pkgs; [
                 proton-ge-bin
               ];
             };
             less.enable = true;
             git = {
               enable = true;
             };
             bash = {
               completion.enable = true;
               enableLsColors = true;
               promptInit = ''
                 PS1="\h:\w \u\$ "
               '';
               shellAliases = {
                 q = "exit";
                 l = "ls $@";
                 la = "ls -r -A $@";
                 garbage = "sudo nix-collect-garbage -d $@";
                 rebuild = "sudo nixos-rebuild switch $@";
                 hf = "hyfetch $@";
                 e = "nixmacs -nw $@";
                 size = "du -sh $@";
                 mf = "microfetch $@";
                 wp = "feh --bg-fill $@";
               };
             };
           };

           # XDG
           xdg = {
             mime = {
               enable = true;
               defaultApplications = {
                 "image/png" = "feh.desktop";
                 "image/jpeg" = "feh.desktop";
                 "image/jpg" = "feh.desktop";
                 "image/webp" = "feh.desktop";
                 "video/mp4" = "mpv.desktop";
                 "video/webm" = "mpv.desktop";
                 "video/mkv" = "mpv.desktop";
                 "video/mov" = "mpv.desktop";
                 "application/pdf" = "zathura.desktop";
               };
             };
           };

           # System Packages
           environment.systemPackages = with pkgs; let
             emacs-wayland = pkgs.writeShellScriptBin "emacs-wayland" ''
               exec ${pkgs.emacs.override { withPgtk = true; }}/bin/emacs "$@"
             '';
             emacs-x11 = pkgs.writeShellScriptBin "emacs-x11" ''
               exec ${pkgs.emacs}/bin/emacs "$@"
             '';
             # Nix-Alien
             inherit (self.inputs.nix-alien.packages.${system});
             nix-alien = self.inputs.nix-alien.packages.${system}.default;
           in [
             #vim
             wget
             emacs-wayland
             emacs-x11
             irssi
             home-manager
             osuLazerLatest
             libelf
             gnumake
             gcc
             cabal2nix
             nix-alien
             nix-search-tv.packages.x86_64-linux.default
           ];
           environment.variables = {
             EDITOR = "nixmacs";
             VISUAL = "nixmacs";
             PAGER = "less";
             TERMINAL = "kitty";
           };
         
           programs.fzf.fuzzyCompletion = true;

           programs.nix-ld.enable = true;
           
           # Wayland
           programs = {
             niri = {
               enable = true;
             };
           };
           
           # Services
           services = {
             yggdrasil = {
               enable = false;
               persistentKeys = false;
               settings = {
                 Peers = [
                   "tls://n.ygg.yt:443"
                   "tls://b.ygg.yt:443"
                   "tcp://s-fra-0.sergeysedoy97.ru:65533"
                   "tcp://yggdrasil.su:62486"
                   "tls://yggdrasil.su:62586"
                   "tls://helium.avevad.com:1337"
                   "tcp://ygg.mkg20001.io:80"
                   "tcp://bode.theender.net:42069"
                 ];
               };
             };
             i2pd = {
               enable = false;
               address = "127.0.0.1";
               proto = {
                 # 127.0.0.1:4447 on SOCKS5 Firefox Network settings.
                 # Leave HTTP and HTTPS Proxies blank.
                 http.enable = true;
                 socksProxy.enable = true;
                 httpProxy.enable = true;
                 sam.enable = true;
               };
             };
             tor = {
               enable = true;
               client = {
                 enable = true;
               };
               torsocks = {
                 enable = true;
               };
             };
           };
           systemd.services.tor.wantedBy = lib.mkForce [ ];

            
            services.displayManager.defaultSession = "niri";
            # Enable CUPS to print documents.
            services.printing.enable = true;
            # Enable sound with pipewire.
            services.pulseaudio.enable = false;
            security = {
              rtkit.enable = true;
              doas = {
                enable = true;
                wheelNeedsPassword = true;
                extraRules = [
                  { groups = [ "wheel" ]; noPass = false; keepEnv = true; persist = true; }
                ];
              };
            };
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
              # If you want to use JACK applications, uncomment this
              #jack.enable = true;
              # use the example session manager (no others are packaged yet so this is enabled by default,
              # no need to redefine it in your config for now)
              #media-session.enable = true;
            };
            # Flatpak
            services.flatpak = {
              enable = true;
              #update.onActivation = true;
              remotes = [
                { name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; }
              ];
            };
            # Nix Settings
              nix = {
                settings = {
                  auto-optimise-store = true;
                  experimental-features = [ "nix-command" "flakes" ];
                };
              };

            #systemd.services.zerotierone.wantedBy = lib.mkForce [ ];
            nixpkgs.config.allowUnfree = true;
            # Tmux
            programs.tmux = {
              enable = true;
              clock24 = true;
              extraConfig = ''
                set -g @tmux-gruvbox 'dark'
                set -g status-left '  %H:%M '
                set -g status-right ' 󰭨 %d.%m.%Y '
                unbind C-b
                set-option -g prefix C-c
                bind-key C-c send-prefix
                bind v split-window -v
                bind 2 split-window -v
                bind h split-window -h
                bind 3 split-window -h
                bind 0 kill-pane
                set-option -g default-shell /run/current-system/sw/bin/zsh
              '';
              plugins = [
                pkgs.tmuxPlugins.gruvbox
              ];
            };
            # Ensure the same basic flake options you already enable
            system.stateVersion = "25.05"; # Did you read the comment?
            })
        ];
      };
      # ChatGPT Firefox Stylix Fix BEGIN
      homeConfigurations.puppy = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          stylix.homeModules.stylix
          ./home.nix
        ];
      };
      # ChatGPT Firefox Stylix Fix END
    };
}
