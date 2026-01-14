{ config, pkgs, lib, inputs, ... }:
let
  wineWowPackagesBinary = pkgs.wineWowPackages.full;
  fontSize = 13;
  transOpacity = 0.95;
  fullOpacity = 1.0;
in
{
  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.system}.default;
  };
  home.username = "puppy";
  home.homeDirectory = "/home/puppy";
  home.stateVersion = "25.05";
  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.guix-profile/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS";
  };
  # Nix-Search-TV
  home.file.".config/nix-search-tv/config.toml".text = ''
    [sources]

    [sources.nixpkgs]
    type = "nixpkgs"
    flake = "/etc/nixos"

    [sources.nixos]
    type = "nixos-options"
    flake = "/etc/nixos"

    [sources.home-manager]
    type = "home-manager-options"
    flake = "/etc/nixos"
  '';
  home.file.".config/nix-search-tv/config.json".text = ''
    {
      "indexes": ["nixpkgs", "home-manager", "nixos"],
      "update_interval": "168h",
      "cache_dir": "/home/puppy/.cache/nix-search-tv",
      "enable_waiting_message": true
    }
  '';  
  home.file.".config/television/cable/nix.toml".text = ''
    [metadata]
    name = "nix"
    requirements = ["nix-search-tv"]
    
    [source]
    command = "nix-search-tv print"
    
    [preview]
    command = "nix-search-tv preview {}"
  '';
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "DMZ-White";
    package = pkgs.vanilla-dmz;
    size = 32;
  };
  gtk.cursorTheme = {
    name = "DMZ-White";
    package = pkgs.vanilla-dmz;
    size = 32;
  };
  # NixMacs
  nixMacs = {
    enable = true;
  };
  # NixVim
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    globals.mapleader = " ";
    luaLoader.enable = true;
    extraConfigLua = ''
      -- Set leader key to Space
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      vim.keymap.del("n", "<leader>o")
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }
      -- Tabs
      keymap("n", "<leader>T", ":tabnew<CR>", opts)        -- New tab
      keymap("n", "<leader>W", ":tabclose<CR>", opts)     -- Close tab
      keymap("n", "<leader><Tab>", ":tabnext<CR>", opts)  -- Next tab
      keymap("n", "<leader><S-Tab>", ":tabprevious<CR>", opts) -- Previous tab
      -- Splits
      keymap("n", "<leader>v", ":vsplit<CR>", opts)       -- Vertical split
      keymap("n", "<leader>3", ":vsplit<CR>", opts)       -- Vertical split
      keymap("n", "<leader>h", ":split<CR>", opts)        -- Horizontal split
      keymap("n", "<leader>2", ":split<CR>", opts)        -- Horizontal split
      keymap("n", "<leader>0", ":close<CR>", opts)        -- Close split/window
      -- Pane (window) navigation
      keymap("n", "<leader><Right>", "<C-w>l", opts)      -- Right pane
      keymap("n", "<leader><Left>", "<C-w>h", opts)       -- Left pane
      keymap("n", "<leader><Up>", "<C-w>k", opts)         -- Top pane
      keymap("n", "<leader><Down>", "<C-w>j", opts)       -- Bottom pane
      -- Save file
      keymap("n", "<leader>s", ":write<CR>", opts)
    '';
    plugins = {
      lualine.enable = true;
      telescope.enable = true;
      nvim-autopairs.enable = true;
      which-key.enable = true;
      web-devicons.enable = true;
      rainbow-delimiters.enable = true;
      colorizer.enable = true; # Hex Color Preview
      visual-multi.enable = true;
      # LSP
      cmp.enable = true;
      lsp.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          rust
          nix
          haskell
          markdown
          c
          lua
          html
          css
          json
          javascript
          nix
        ];
      };
      rustaceanvim.enable = true;
      markdown-preview.enable = true;
      treesitter-textobjects.enable = true;
      treesitter-context.enable = true;
    };
    keymaps = [
      { key = "<leader>ff"; action = "require('felescope.builfin').find_files"; mode = "n"; }
      { key = "<leader>ss"; action = ":Telescope live_grep<CR>"; mode = "n"; }
      { key = "<leader>bb"; action = ":Telescope buffers<CR>"; mode = "n"; }
      { key = "<leader>o"; action = "<C-w>w"; mode = "n"; }
    ];
    opts = {
      # Numbers
      number = true;
      relativenumber = true;
      # Tab
      tabstop = 2;
      softtabstop = 2;
      showtabline = 2;
      expandtab = true;
      smartindent = true; # Enable smart indentation.
      shiftwidth = 2; # Number of spaces to use for each step of (auto)indent.
      breakindent = true; # Enable break indent.
      cursorline = true; # Highlight screen line of cursor.
      scrolloff = 8; # Minimum number of screen lines to keep above and below the cursor.
      mouse = "a"; # Enable Mouse
      # Folding
      foldmethod = "manual";
      foldenable = false;
      linebreak = true; # Wrap long lines at a character.
      swapfile = false; # Disable Swap File Creation
      spell = false; # Spellcheck
      timeoutlen = 300; # Timeout for Mapped Squence
      termguicolors = true; # Enable 24-bit RGB Colors in TUI
      showmode = true; # Show mode in the Command Line
      # Splitting
      splitbelow = true;
      splitkeep = "screen";
      splitright = true;
      cmdheight = 0; # Hide cmd line unless needed.
      fillchars = { #
        eob = " ";  # Remove EOB
      };            #
    };
  };
  # Xresources
  xresources.extraConfig = ''
    xterm*locale: true
    xterm*utf8: 2
    XTerm*VT100.Translations: #override \
          Shift Ctrl<Key>V: insert-selection(CLIPBOARD) \n\ 
          Shift Ctrl<Key>V: insert-selection(PRIMARY) \n\ 
          Shift<Btn1Down>: select-start() \n\ 
          Shift<Btn1Motion>: select-extend() \n\ 
          Shift<Btn1Up>: select-end(CLIPBOARD) \n\
  '';
  # Stylix
  stylix = {
    enable = true;
    targets = {
      firefox = {
        enable = true;
      };
    };
    image = pkgs.fetchurl {
      url = "https://codeberg.org/nixpup/NixOS/raw/branch/main/Pictures/gruvbox_pokemon_marnie_wp_dark.png";
      hash = "sha256-cTjyUMHIUMthaCgBITifu34b2+QavX8O8nV/kfuFC/A=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    opacity = {
      terminal = transOpacity;
      popups = fullOpacity;
    };
    fonts = {
      sizes = {
        terminal = fontSize;
        applications = fontSize;
        desktop = fontSize;
        popups = fontSize;
      };
    };
  };
  #home.packages = [ pkgs.OpenTabletDriver ];
  programs.kitty = {
    enable = true;
    extraConfig = ''
      ###########################
      ### Kitty Configuration ###
      ###########################
      ### General Settings
      hide_window_decorations no
      enable_audio_bell no

      ### Colors
      #color0  #1d1f21
      #color1  #cc6666
      #color2  #b5bd68
      #color3  #e6c547
      #color4  #81a2be
      #color5  #b294bb
      #color6  #70c0ba
      #color7  #373b41
      #color8  #666666
      #color9  #ff3334
      #color10 #9ec400
      #color11 #f0c674
      #color12 #81a2be
      #color13 #b77ee0
      #color14 #54ced6
      #color15 #282a2e 
      #foreground            #c5c8c6
      #background            #1d1f21

      selection_foreground    #ebdbb2
      selection_background    #d65d0e
      background              #282828
      foreground              #ebdbb2
      color0                  #3c3836
      color1                  #cc241d
      color2                  #98971a
      color3                  #d79921
      color4                  #458588
      color5                  #b16286
      color6                  #689d6a
      color7                  #a89984
      color8                  #928374
      color9                  #fb4934
      color10                 #b8bb26
      color11                 #fabd2f
      color12                 #83a598
      color13                 #d3869b
      color14                 #8ec07c
      color15                 #fbf1c7
      cursor                  #bdae93
      cursor_text_color       #665c54
      url_color               #458588

      ### Imports
      #include /home/puppy/.config/kitty/themes/CrayonPonyFish.conf
      #include /home/puppy/.config/kitty/themes/Afterglow.conf
      #include /home/puppy/.config/kitty/themes/Arthur.conf
      # Gruvbox Dark Theme
      #include ~/.config/kitty/themes/GruvboxDark.conf

      ### Cursor
      cursor_shape beam
      cursor_blink_interval 0
      #cursor                #ffffff
      #cursor_text_color     #1d1f21
      
      ### Font
      font_family DejaVu Sans Mono
      font_size 13.0

      ### Tabs
      tab_bar_style separator
      tab_separator ""
      tab_bar_min_tabs 2
      tab_title_template "{fmt.fg._282828}{fmt.bg._282828}{fmt.fg._ebdbb2}{fmt.bg._282828} ({index}) {title} {fmt.fg._282828}{fmt.bg._282828} "
      active_tab_title_template "{fmt.fg._ebdbb2}{fmt.bg._282828}{fmt.fg._d65d0e}{fmt.bg._ebdbb2} ({index}) {title} {fmt.fg._ebdbb2}{fmt.bg._282828} "
      active_tab_font_style bold

      map ctrl+1 goto_tab 1
      map ctrl+2 goto_tab 2
      map ctrl+3 goto_tab 3
      map ctrl+4 goto_tab 4
      map ctrl+5 goto_tab 5
      map ctrl+6 goto_tab 6
      map ctrl+7 goto_tab 7
      map ctrl+8 goto_tab 8
      map ctrl+9 goto_tab 9
      map ctrl+t new_tab
      map ctrl+w close_tab
      map ctrl+shift+page_up move_tab_backward
      map ctrl+shift+page_down move_tab_forward

      active_tab_foreground   #d65d0e
      active_tab_background   #282828
      inactive_tab_foreground #ebdbb2
      inactive_tab_background #282828
      tab_bar_background      #282828

      ## Padding
      window_padding_width 3
    '';
  };
  programs.mpv = {
    enable = true;
    config = {
      volume = 100;
      force-window = false;
      "autofit-larger" = "75%x75%";
      "image-display-duration" = "inf";
      "hr-seek" = true;
      "loop-playlist" = "inf";
      "loop-file" = "inf";
    };
    bindings = {
      n = "playlist-next";
      p = "playlist-prev";
      "Shift+Enter" = "playlist-next";
      PGDWN = "playlist-next";
      PGUP = "playlist-prev";
      "Shift+p" = "show-text $\{playlist\}";
      UP = "add volume 5";
      DOWN = "add volume -5";
      WHEEL_UP = "add volume 2";
      WHEEL_DOWN = "add volume -2";
      WHEEL_LEFT = "add volume -2";
      WHEEL_RIGHT = "add volume 2";
      d = "set volume 50";
      RIGHT = "seek 5";
      LEFT = "seek -5";
      "Shift+RIGHT" = "seek 1";
      "Shift+LEFT" = "seek -1";
      "Ctrl+RIGHT" = "add speed 0.1";
      "Ctrl+LEFT" = "add speed -0.1";
      "]" = "add audio-delay 0.100";
      "[" = "add audio-delay -0.100";
      r = "no-osd cycle video-rotate 90";
      R = "no-osd cycle video-rotate -90";
      q = "quit";
      "+" = "add video-zoom 0.1";
      "_" = "add video-zoom -0.1";
      "=" = "set video-zoom 0";
      "," = "frame-back-step";
      "." = "frame-step";
      "META+LEFT" = "add video-pan-x 0.1";
      "META+RIGHT" = "add video-pan-x -0.1";
      "META+UP" = "add video-pan-y 0.1";
      "META+DOWN" = "add video-pan-y -0.1";
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        live_config_reload = true;
      };
      colors = {
        #primary = {
        #  foreground = "#c5c8c6";
        #  background = "#1d1f21";
        #};
        #cursor = {
        #  text = "#1d1f21";
        #  cursor = "#ffffff";
        #};
        #normal = {
        #  black = "#1d1f21";
        #  red = "#cc6666";
        #  green = "#b5bd68";
        #  yellow = "#e6c547";
        #  blue = "#81a2be";
        #  magenta = "#b294bb";
        #  cyan = "#70c0ba";
        #  white = "#373b41";
        #};
        #bright = {
        #  black = "#665c54";
        #  red = "#ff3334";
        #  green = "#9ec400";
        #  yellow = "#f0c674";
        #  blue = "#81a2be";
        #  magenta = "#b77ee0";
        #  cyan = "#54ced6";
        #  white = "#282a2e";
        #};
      };
      font = lib.mkForce {
        offset = {
          x = 0;
          y = 0;
        };
        normal = {
          family = "DejaVu Sans Mono";
          style = "Regular";
        };
        size = 14;
      };
      cursor.style = {
        shape = "Beam";
        blinking = "Off";
      };
      window.padding = {
        x = 5;
        y = 5;
      };
    };
  };
  home.file.".config/picom/picom.conf".text = ''
    # Backend
    backend = "glx";
    # GLX backend
    glx-no-stencil = true;
    glx-copy-from-front = false;
    glx-no-rebind-pixmap = true;
    use-damage = false;
    # Shadows
    shadow = true;
    shadow-radius = 35;
    shadow-offset-x = -35;
    shadow-offset-y = -35;
    shadow-opacity = 0.8;
    shadow-exclude = [
    	"_GTK_FRAME_EXTENTS@:c",
    	# Removed to avoid no-shadow in modal dialog windows.
        "name = 'Notification'",
        "name = 'Plank'",
        "name = 'Docky'",
        "name = 'Kupfer'",
    	"name = 'Pensela'",
    	"name = 'Drawing Board'",
    	#
    	# Workaround for VirtualBox empty window at launching
    	"name = 'VirtualBox'",
    	"name = 'VirtualBoxVM'",
    	#
    	# Avoid shadow in Negatron popups
    	"name = 'Negatron v0.100.1' && argb",
    	#
    	# Avoid shadow for the XFCE alt tab TaskSwitcher
        "name ?= 'xfwm4' && argb",
    	#
        # "name *= 'compton'",
        "class_g = 'Conky'",
        "class_g = 'Kupfer'",
        "class_g = 'Synapse'",
        "class_g ?= 'Notify-osd'",
        "class_g ?= 'Cairo-dock'",
    	"class_g = 'Cairo-clock'",
        "class_g ?= 'Xfce4-notifyd'",
    	#
    	# Exclude special Firefox/Firefox-esr/Thunderbird dropdowns.
      	# Ref: https://github.com/chjj/compton/issues/247
    	 "class_g = 'Thunderbird' && argb",
    	 "class_g = 'Telegram' && argb",
    	 "name ?= 'Thunderbird' && (window_type = 'utility' || window_type = 'popup_menu')",
    	#
    	# Exclude some special popup menu shadows, but Modal Windows.
    	# These are more finetuning thant previous ones:
    	"class_g ?= 'Thunderbird' && class_i = 'Popup' && argb",
    	"class_g = 'firefox' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'Firefox' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'firefox-esr' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'Firefox-esr' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'Tor Browser' && (window_type = 'utility') && argb",
    	"class_g = 'Navegador Tor' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'Thunderbird' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
    	"class_g = 'Mozilla Thunderbird' && (window_type = 'utility' || window_type = 'popup_menu') && argb",
        "class_g ?= 'Xfce4-power-manager'",
    	# 
    	# Exclude Vokoscreen and VokoscreenNG area selector
    	#
    	"class_g ?= 'vokoscreen' && argb",
    	"name = 'Área'",
    	"name *= 'Cuenta regresiva'",
    	"_NET_WM_WINDOW_TYPE:a *= '_KDE_NET_WM_WINDOW_TYPE_OVERRIDE'"
    #	"override_redirect = true"
    ];
    shadow-ignore-shaped = false;
    # Opacity
    inactive-opacity = 1;
    active-opacity = 1;
    frame-opacity = 1;
    inactive-opacity-override = false;
    blur-background = true;
    blur-method = "kernel";
    blur-kern = "9x9gaussian"
    blur-background-exclude = [
        "class_g = 'Peek'",
    	"class_g = 'Pensela'",
    	"name = 'Drawing Board'",
        "window_type = 'dock'",
    	"window_type = 'dropdown_menu'",
    	"window_type = 'combo'",
    	"window_type = 'popup_menu'",
    	"window_type = 'utility'",
        "window_type = 'desktop'",
    	"_GTK_FRAME_EXTENTS@:c"
    ];
    opacity-exclude = [
        "name = 'Stratagus'"
    ];
    opacity-rule = [
        #"95:class_g = 'Alacritty' && focused",
        #"95:class_g = 'Alacritty' && !focused"
        "80:class_g = 'Alacritty'",
        "80:class_g = 'Emacs'",
        "90:class_g = 'kitty'"
    ];
    shadow-exclude = [
     "name = 'Notification'",
     "class_g = 'Conky'",
     "class_g ?= 'Notify-osd'",
     "class_g = 'Cairo-clock'",
     "_GTK_FRAME_EXTENTS@:c",
     "class_g = 'Polybar'",
     "name = 'Polybar'",
     "class_g = 'Rofi'",
     "name = 'osu!'"
    ];
    # Fading
    fading = true;
    fade-in-step = 0.07;
    fade-out-step = 0.07;
    fade-exclude = [ ];
    # OTHER CONFIG
    log-level = "warn";
    mark-wmwin-focused = true;
    mark-ovredir-focused = true;
    detect-rounded-corners = true;
    detect-client-opacity = true;
    refresh-rate = 0;
    focus-exclude = [ "class_g = 'Cairo-clock'" ];
    detect-transient = true;
    detect-client-leader = true;
    invert-color-include = [ ];
    resize-damage = 2;
    # Window type settings
    wintypes:
    {
    	dock = { shadow = true; }
    	dnd = { shadow = false; }
    	popup_menu = { opacity = 1; }
    	dropdown_menu = { opacity = 1; }
    
    };
  '';
  home.file.".scripts/polybar.sh" = {
    text = ''
      if type "xrandr"; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
          MONITOR=$m polybar --reload example &
        done
      else
        polybar --reload example &
      fi
    '';
    executable = true;
  };
  home.file.".scripts/viewScreenshot.sh" = {
    text = ''
      #!/usr/bin/env bash
      # View Screenshots from your Clipboard
      
      # Define randomized Filename
      fileName=$((10000 + $RANDOM % 1000000000))
      
      # If image in clipboard, run process; else send error notification.
      if xclip -selection clipboard -t image/png -o &> /dev/null; then
          # Export clipboard image to /home/$USER/ with a random file name.
          xclip -selection clipboard -t image/png -o > $HOME/"$fileName.png"
          # Open MPV with i3-compatible title to make it automatically float.
          mpv --force-window=yes --title="FLOAT_MP" "$HOME/$fileName.png"
          # Delete temporary image.
          rm "$HOME/$fileName.png"
      else
          # Send notification with context.
          notify-send "Error" "No image found in clipboard!" -i $HOME/Pictures/error.png
      fi
    '';
    executable = true;
  };
  home.file.".config/mako/config" = {
    text = ''
      # Mako Configuration
      # Converted from dunstrc
      # Geometry
      width=300
      height=300
      anchor=top-right
      margin=10,10,50,10
      # Appearance
      font=DejaVu Sans Mono 14
      background-color=#1d1f21
      text-color=#ffffff
      border-size=3
      border-color=#c13f47
      border-radius=4
      padding=8
      markup=1
      max-visible=20
      default-timeout=5000
      # Icons
      icon-path=/usr/share/icons/Adwaita
      icons=1
      max-icon-size=32
      # Progress bar
      progress-color=over #c13f47
      # Grouping
      group-by=app-name
      # Mouse actions
      on-button-left=dismiss
      on-button-middle=invoke-default-action
      on-button-right=dismiss-all
      # Urgency: Low
      [urgency=low]
      background-color=#222222
      text-color=#888888
      border-color=#c13f47
      default-timeout=5000
      # Urgency: Critical
      [urgency=critical]
      background-color=#900000
      text-color=#ffffff
      border-color=#ff0000
      default-timeout=0
      ignore-timeout=1
    '';
    executable = true;
  };
  home.file.".config/dunst/dunstrc".text = ''
    [global]
        ### Display ###
        monitor = 0
        follow = none
        ### Geometry ###
        width = 300
        height = (0, 300)
        origin = top-right
        offset = (10, 50)
        scale = 0
        notification_limit = 20
        ### Progress bar ###
        progress_bar = true
        progress_bar_height = 10
        progress_bar_frame_width = 1
        progress_bar_min_width = 150
        progress_bar_max_width = 300
        progress_bar_corner_radius = 0
        progress_bar_corners = all
        icon_corner_radius = 0
        icon_corners = all
        indicate_hidden = yes
        transparency = 30
        separator_height = 2
        padding = 8
        horizontal_padding = 8
        text_icon_padding = 0
        frame_width = 3
        frame_color = "#c13f47"
        gap_size = 0
        separator_color = frame
        sort = yes
        ### Text ###
        font = DejaVu Sans Mono 14
        line_height = 0
        markup = full
        format = "<b>%s</b>\n%b"
        alignment = left
        vertical_alignment = center
        show_age_threshold = 60
        ellipsize = middle
        ignore_newline = no
        stack_duplicates = true
        hide_duplicate_count = false
        show_indicators = yes
        ### Icons ###
        enable_recursive_icon_lookup = true
        icon_theme = Adwaita
        icon_position = left
        min_icon_size = 32
        max_icon_size = 32
        icon_path = /usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/
        ### History ###
        sticky_history = yes
        history_length = 20
        ### Misc/Advanced ###
        dmenu = /usr/bin/dmenu -p dunst:
        browser = /usr/bin/xdg-open
        always_run_script = true
        title = Dunst
        class = Dunst
        corner_radius = 4
        corners = all
        ignore_dbusclose = false
        ### Wayland ###
        force_xwayland = false
        ### Legacy
        force_xinerama = false
        ### mouse
        mouse_left_click = close_current
        mouse_middle_click = do_action, close_current
        mouse_right_click = close_all

    [experimental]
        per_monitor_dpi = false
    
    [urgency_low]
        background = "#222222"
        foreground = "#888888"
        timeout = 5
        default_icon = dialog-information
    
    [urgency_normal]
        background = "#1d1f21"
        foreground = "#ffffff"
        timeout = 5
        override_pause_level = 30
        default_icon = dialog-information
    
    [urgency_critical]
        background = "#900000"
        foreground = "#ffffff"
        frame_color = "#ff0000"
        timeout = 0
        override_pause_level = 60
        default_icon = dialog-warning
  '';
  home.file.".scripts/screenkey.nix".text = ''
    { pkgs ? import <nixpkgs> {} }:
    pkgs.mkShell {
      buildInputs = with pkgs; [
        screenkey
      ];
      shellHook = '''
        clear;echo "Starting Screenkey"
        screenkey --font "DejaVu Sans Mono" -t 0.65 --vis-shift
        clear;echo "Quitting Screenkey"
        exit
      ''';
    }
  '';
  home.file.".scripts/ncdu.nix".text = ''
    { pkgs ? import <nixpkgs> {} }:
    pkgs.mkShell {
      buildInputs = [
        pkgs.ncdu
      ];
      shellHook = '''
        ncdu
        exit
      ''';
    }
  '';
  #home.file.".emacs".text = ''
  #  (let ((orgfile "~/.e.org")
  #        (elfile "~/.e.el"))
  #    (when (or (not (file-exists-p elfile))
  #  	    (file-newer-than-file-p orgfile elfile))
  #      (require 'org)
  #      (org-babel-tangle-file orgfile elfile))
  #    (load-file elfile))
  #'';
  home.file.".config/wofi/config".text = ''
    width=480
    location=center
    show=drun          # or run / whatever mode you usually use
    prompt=Run         # optional - you can change it
    allow_markup=true
    term=foot          # or your preferred terminal if needed
    lines=8
    columns=1
  '';
  home.file.".config/wofi/style.css".text = ''
    @define-color bg0      #282A2E;
    @define-color bg1      #1D1F21;
    @define-color fg0      #C5C8C6;
    @define-color accent   #FF2A54;
    @define-color urgent   #A54242;
    
    * {
        font-family: "DejaVu Sans Mono", monospace;
        font-size: 14px;
        color: @fg0;
    }
    window {
        margin: 0px;
        padding: 0px;
        background-color: @bg0;
        border-radius: 0px;
    }
    #outer-box {
        margin: 0px;
        padding: 0px;
        background-color: transparent;
    }
    #input {
        margin: 8px;
        padding: 8px;
        border: none;
        border-radius: 0px;
        background-color: @bg1;
        color: @fg0;
    }
    #input image {
        color: @accent;
    }
    #inner-box {
        margin: 4px 0px;
        padding: 0px;
        background-color: transparent;
    }
    #scroll {
        margin: 0px;
    }
    #entry {
        padding: 8px;
        margin: 0px 4px;
        border-radius: 0px;
        background-color: transparent;
        color: inherit;
    }
    #entry:selected {
        background-color: @accent;
        color: @bg0;
        outline: none;
    }
    #entry:selected * {
        color: @bg0;
    }
    #text {
        color: inherit;
    }
    #img {
        margin-right: 8px;
        size: 0.8em;     /* roughly matches rofi element-icon size */
    }
    #entry.urgent {
        color: @urgent;
    }
    #entry:selected.urgent {
        background-color: @urgent;
        color: @bg0;
    }
  '';
  home.file.".config/rofi/config.rasi".text = ''
    configuration {
      font: "DejaVu Sans Mono 12";
      show-icons: true;
      location: 0;
      fullscreen: false;
    }
    
    @theme "squared-loji"
  '';
  home.file.".scripts/wineOsuSetup.sh" = {
    text = ''
      #!/usr/bin/env bash

      echo "Starting Setup..."
      echo "Probing Directory $HOME/.wine-osu..."

      DIR="$HOME/.wine-osu"
      if [ ! -d "$DIR" ]; then
        echo "Creating Directory $HOME/.wine-osu..."
        mkdir $HOME/.wine-osu
      else
        echo "Found Directory $HOME/.wine-osu..."
      fi

      echo "Setting Wineprefix..."
      export WINEPREFIX="$HOME/.wine-osu"
      echo "Booting Wine..."
      wineboot --init
      echo "Installing Winetricks Packages (dotnet40,d3dx9,corefonts,gdiplus,fontsmooth=rgb)..."
      winetricks -q dotnet40 d3dx9 corefonts gdiplus fontsmooth=rgb
      echo "Setup Complete!"
    '';
    executable = true;
  };
    home.file.".scripts/wineThirtytwoSetup.sh" = {
    text = ''
      #!/usr/bin/env bash

      echo "Starting Setup..."
      echo "Probing Directory $HOME/.wine-thirtytwo..."

      DIR="$HOME/.wine-thirtytwo"
      if [ ! -d "$DIR" ]; then
        echo "Creating Directory $HOME/.wine-thirtytwo..."
        mkdir $HOME/.wine-thirtytwo
      else
        echo "Found Directory $HOME/.wine-thirtytwo..."
      fi

      echo "Setting Wineprefix..."
      export WINEPREFIX="$HOME/.wine-thirtytwo"
      echo "Exporting Winearch..."
      export WINEARCH=win32
      echo "Booting Wine..."
      wineboot --init
      echo "Installing Winetricks Packages (dotnet40,d3dx9,corefonts,gdiplus,fontsmooth=rgb,ie8)..."
      winetricks -q dotnet40 d3dx9 corefonts gdiplus fontsmooth=rgb ie8
      echo "Setup Complete!"
    '';
    executable = true;
  };
  home.file.".wine-osu/runOsu.sh" = {
    text = ''
      #!/usr/bin/env bash

      export WINEPREFIX="$HOME/.wine-osu"
      exec ${wineWowPackagesBinary}/bin/wine "$@"
    '';
    executable = true;
  };
  home.file.".wine-thirtytwo/runOsu.sh" = {
    text = ''
      #!/usr/bin/env bash

      export WINEPREFIX="$HOME/.wine-thirtytwo"
      exec ${wineWowPackagesBinary}/bin/wine "$@"
    '';
    executable = true;
  };
  home.file.".config/rofi/squared-nord.rasi".text = ''
    /* Rofi Squared Nord  */
    /* Author: Nixpup (https://codeberg.org/nixpup) */
    /* Original Author: Newman Sanchez (https://github.com/newmanls) */
    
    * {
        /*font:   "FiraCode Nerd Font Medium 12";*/
        font: "DejaVu Sans Mono Regular 14";
        /* New */
        bg0: #282A2E;
        bg1: #1D1F21;
        fg0: #C5C8C6;
        accent-color: #7DB6E2;
        urgent-color: #1D1F21;
        /* Old */
        /*bg0:     #2E3440;*/
        /*bg1:     #3B4252;*/
        /*fg0:     #D8DEE9;*/
        /*accent-color:     #88C0D0;*/
        /*urgent-color:     #EBCB8B;*/
        background-color:   transparent;
        text-color:         @fg0;
        margin:     0;
        padding:    0;
        spacing:    0;
    }
    window {
        location:   center;
        width:      480;
        border-radius: 0px;
    
        background-color:   @bg0;
    }
    inputbar {
        spacing:    8px;
        padding:    8px;
    
        background-color:   @bg1;
    }
    prompt, entry, element-icon, element-text {
        vertical-align: 0.5;
    }
    prompt {
        text-color: @accent-color;
    }
    textbox {
        padding:            8px;
        background-color:   @bg1;
    }
    listview {
        /* Old */
        padding:    4px 0;
        lines:      8;
        columns:    1;
    
        fixed-height:   false;
    }
    element {
        padding:    8px;
        spacing:    8px;
    }
    element normal normal {
        text-color: @fg0;
    }
    element normal urgent {
        text-color: @urgent-color;
    }
    element normal active {
        text-color: @accent-color;
    }
    element alternate active {
        text-color: @accent-color;
    }
    element selected {
        text-color: @bg0;
    }
    element selected normal, element selected active {
        background-color:   @accent-color;
    }
    element selected urgent {
        background-color:   @urgent-color;
    }
    element-icon {
        size:   0.8em;
    }
    element-text {
        text-color: inherit;
    }
  '';
  home.file.".config/rofi/squared-loji.rasi".text = ''
    /* Rofi Squared Loji  */
    /* Author: Nixpup (https://codeberg.org/nixpup) */
    /* Original Author: Newman Sanchez (https://github.com/newmanls) */
    
    * {
        font: "DejaVu Sans Mono Regular 14";
        bg0: #282A2E;
        bg1: #1D1F21;
        fg0: #C5C8C6;
        accent-color: #FF2A54;
        urgent-color: #A54242;
        background-color:   transparent;
        text-color:         @fg0;
        margin:     0;
        padding:    0;
        spacing:    0;
    }
    window {
        location:   center;
        width:      480;
        border-radius: 0px;
    
        background-color:   @bg0;
    }
    inputbar {
        spacing:    8px;
        padding:    8px;
    
        background-color:   @bg1;
    }
    prompt, entry, element-icon, element-text {
        vertical-align: 0.5;
    }
    prompt {
        text-color: @accent-color;
    }
    textbox {
        padding:            8px;
        background-color:   @bg1;
    }
    listview {
        /* Old */
        padding:    4px 0;
        lines:      8;
        columns:    1;
    
        fixed-height:   false;
    }
    element {
        padding:    8px;
        spacing:    8px;
    }
    element normal normal {
        text-color: @fg0;
    }
    element normal urgent {
        text-color: @urgent-color;
    }
    element normal active {
        text-color: @accent-color;
    }
    element alternate active {
        text-color: @accent-color;
    }
    element selected {
        text-color: @bg0;
    }
    element selected normal, element selected active {
        background-color:   @accent-color;
    }
    element selected urgent {
        background-color:   @urgent-color;
    }
    element-icon {
        size:   0.8em;
    }
    element-text {
        text-color: inherit;
    }
  '';
}
