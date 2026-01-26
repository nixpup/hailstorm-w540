#!/usr/bin/env bash
# Guix Manager - Helper Function

gm() {
    arg1="$1"
    [ "$#" -gt 0 ] && shift
    argRest=("$@")
    case "$arg1" in
        u|update|refresh)
            guix refresh
            echo "[ Updeated/Refreshed Package Cache and Definitions ]"
            ;;
        p|pull|upgrade)
            guix pull
            printf "[ Restart Guix Daemon? ] (y/n) ~> "
            read -r restartGuixService
            if [ "$restartGuixService" = "y" ]; then
                doas systemctl restart guix-daemon.service
            else
                return 1
            fi
            ;;
        l|ls|list)
            echo "[ Installed Packages ]:"
            guix package --list-installed
            ;;
        i|install)
            if  [ "${#argRest[@]}" -eq 0 ]; then
                echo "[ Please provide Packages to Install ]"
                return 1
            fi
            guix install "${argRest[@]}"
            echo -e "[ Successfully Installed Packages ]\n(Packages: ${argRest[@]})"
            ;;
        m|manifest)
            if [ "${#argRest[@]}" -eq 0 ]; then
                echo "[ Please provide a Manifest File ]"
                echo "example:"
                echo "  gm m /etc/manifest.scm"
                return 1
            fi
            guix package --manifest="${argRest[@]}"
            echo -e "[ Successfully Installed Packages from Manifest ]\n(File: ${argRest[@]})"
            ;;
        r|rm|remove)
            if [ "${#argRest[@]}" -eq 0 ]; then
                echo "[ Please provide Packages to Remove ]"
                return 1
            fi
            guix remove "${argRest[@]}"
            ;;
        s|shell)
            if [ "${#argRest[@]}" -eq 0 ]; then
                echo "[ Please provide Packages for the Shell ]"
                return 1
            fi
            guix shell "${argRest[@]}"
            ;;
        rmo|rmg|rmog)
            guix package --delete-generations
            echo "[ Deleted Old Generations ]"
            ;;
        *|h|help|"")
            cat <<EOF
gm - guix manager

Usage:
  gm s|shell <packages>                     Create Guix Shell with Packages
  gm r|rm|remove <packages>                 Remove Packages
  gm m|manifest <path/to/manifest.scm>      Install from Manifest
  gm i|install <packages>                   Install Packages
  gm p|pull|upgrade                         Upgrade/Pull latest Guix and Guix Packages
  gm u|update|refresh                       Update/Refresh Package Definitions
  gm l|ls|list                              List Installed Packages
  gm rmo|rmg|rmog                           Delete Old Generations
EOF
            ;;
    esac
}
