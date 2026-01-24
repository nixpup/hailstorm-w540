# hailstorm-w540

Configuration files of my W540 ThinkPad running NixOS.

## Notice
As always, replace all instances of 'puppy' with your actual username on your own machine.

## Specs
 - WM: NaitreHUD (Wayland/MangoWC Fork)
 - Bar: dms
 - Shell: zsh
  - Editor: NixMacs (emacs)
 - Distro: NixOS
 - Compositor: NaitreHUD (Wayland/MangoWC Fork)
 - Launcher: vicinae

## Nix Specification
This setup comes with **home-manager**, **stylix**, **nix-flatpak**, **nix-index-database**, and much, much more, pre-installed and included in the flake.

## Notice
Remember to make backups of all the files in your `/etc/nixos` directory, and various other `~/.config` directories if you want to use this configuration.

## Installation
1. `git clone https://github.com/nixpup/hailstorm-w540`
2. `cd hailstorm-w540`
3. ```
   cp flake.nix /etc/nixos
   cp home.nix /etc/nixos
   cp -r packages/ /etc/nixos
   cp -r files /etc/nixos
   ```
4. Change the flake.nix (`nixosConfigurations.hailstorm = nixpkgs.lib.nixosSystem {`) to reflect your desired hostname. (Replace `hailstorm`.)
5. Change all instances of `puppy` in the flake.nix and home.nix to your actual username. (Find out by running `whoami`.)
6. `sudo nixos-rebuild switch --flake /etc/nixos#YOURHOSTNAME`
7. Reboot and enjoy!

## Screenshot
![Screenshot 1](https://raw.githubusercontent.com/nixpup/hailstorm-w540/refs/heads/main/fuwa01.png)
![Screenshot 2](https://raw.githubusercontent.com/nixpup/hailstorm-w540/refs/heads/main/fuwa02.png)
![Screenshot 3](https://raw.githubusercontent.com/nixpup/hailstorm-w540/refs/heads/main/fuwa03.png)
