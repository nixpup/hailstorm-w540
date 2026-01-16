# hailstorm-w540

Configuration files of my W540 ThinkPad running NixOS.

## Notice
As always, replace all instances of 'puppy' with your actual username on your own machine.

## Specs
 - WM: MangoWC
 - Bar: noctalia-shell
 - Shell: zsh
 - Editor: emacs
 - Distro: NixOS
 - Compositor: MangoWC/Wayland
 - Launcher: vicinae

## Nix Specification
This setup comes with **home-manager**, **stylix**, **nix-flatpak**, **nix-index-database**, and much, much more, pre-installed and included in the flake.

## Installation
!!! Remember to make BACKUPS of your current/old configuration files beforehand. !!!
1. `git clone https://codeberg.org/nixpup/hailstorm-w540`
2. `cd hailstorm-w540`
3. `cp flake.nix /etc/nixos && cp home.nix /etc/nixos && cp -r packages/ /etc/nixos`
4. `cp -r config/niri ~/.config`
5. `mkdir ~/.git-clone && cp -r git-clone/wofi-emoji ~/.git-clone`
6. Change Line 82 of the flake.nix (`nixosConfigurations.hailstorm = nixpkgs.lib.nixosSystem {`) to reflect your desired hostname. (Replace `hailstorm`.)
7. Change all instances of `puppy` in the flake.nix and home.nix to your actual username. (Find out by running `whoami`.)
8. `sudo nixos-rebuild switch --flake /etc/nixos#YOURHOSTNAME`
9. Reboot and enjoy!

## Screenshot
![Screenshot](https://raw.githubusercontent.com/nixpup/hailstorm-w540/refs/heads/main/hailstorm.png)
