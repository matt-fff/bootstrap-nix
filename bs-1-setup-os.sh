#! /usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINUX_TYPE="${LINUX_TYPE:-nix}"

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

########################################################
# NixOS
########################################################
if [ "${LINUX_TYPE}" == "nix" ]; then
    # Check if we can access /etc/nixos
    cd /etc/nixos || {
        echo "Failed to change directory to /etc/nixos" 1>&2
        exit 1
    }

    mkdir -p home-manager

    # Get hostname from command line argument or prompt
    export HOSTNAME=$1
    if [ -z "$HOSTNAME" ]; then
        echo -n "Enter hostname (default: newnix): "
        read -r hostname
        export HOSTNAME=${HOSTNAME:-newnix}
    fi

    # Always source the default environment
    . "${SCRIPT_DIR}/envs/default.sh"

    # Source environment overrides based on hostname
    if [ -f "${SCRIPT_DIR}/envs/${HOSTNAME}.sh" ]; then
        . "${SCRIPT_DIR}/envs/${HOSTNAME}.sh"
    fi

    echo "Processing templates..."
    # Process the template
    nix-shell -p gettext --run "envsubst < \"${SCRIPT_DIR}/home-manager/packages.nix.tmpl\" > \"${SCRIPT_DIR}/home-manager/packages.nix\"
                                envsubst < \"${SCRIPT_DIR}/home-manager/home.nix.tmpl\" > \"${SCRIPT_DIR}/home-manager/home.nix\"
                                envsubst < \"${SCRIPT_DIR}/home-manager/shell.nix.tmpl\" > \"${SCRIPT_DIR}/home-manager/shell.nix\"
                                envsubst < \"${SCRIPT_DIR}/home-manager/settings.nix.tmpl\" > \"${SCRIPT_DIR}/home-manager/settings.nix\"
                                envsubst < \"${SCRIPT_DIR}/configuration.nix.tmpl\" > \"${SCRIPT_DIR}/configuration.nix\"
                                envsubst < \"${SCRIPT_DIR}/flake.nix.tmpl\" > \"${SCRIPT_DIR}/flake.nix\"
                                "
    echo "Templates processed"

    # Create backup if it doesn't exist
    if [ ! -f configuration.nix ]; then
        echo "configuration.nix not found" 1>&2
        exit 1
    fi

    if [ ! -f configuration.nix.bak ]; then
        cp configuration.nix configuration.nix.bak || {
            echo "Failed to create backup of configuration.nix" 1>&2
            exit 1
        }
        echo "Created backup at configuration.nix.bak"
    fi

    # Extract LUKS configuration to new file if it doesn't exist
    if [ ! -f luks-configuration.nix ]; then
        if ! echo "{ config, lib, pkgs, ... }:

    {
    boot.initrd.luks.devices = {" > luks-configuration.nix; then
            echo "Failed to create luks-configuration.nix" 1>&2
            exit 1
        fi

        if ! grep "boot.initrd.luks.devices" configuration.nix | sed 's/^.*devices\./    /' >> luks-configuration.nix; then
            echo "Failed to extract LUKS configuration" 1>&2
            exit 1
        fi

        if ! echo "  };
    }" >> luks-configuration.nix; then
            echo "Failed to complete luks-configuration.nix" 1>&2
            exit 1
        fi
        
        echo "Created luks-configuration.nix"
    fi

    # Replace configuration.nix with the one from SCRIPT_DIR
    if ! cp "$SCRIPT_DIR/configuration.nix" configuration.nix; then
        echo "Failed to replace configuration.nix" 1>&2
        exit 1
    fi


    # Copy nas-configuration.nix if hostname is not "work"
    # if [ "$hostname" != "work" ]; then
        if ! cp "$SCRIPT_DIR/nas-configuration.nix" nas-configuration.nix; then
            echo "Failed to copy nas-configuration.nix" 1>&2
            exit 1
        fi
        echo "Copied nas-configuration.nix"
    # fi


    # Add additional configuration imports if they exist
    for config_file in graphics-configuration.nix nas-configuration.nix network-configuration.nix; do
        if [ -f "$config_file" ]; then
            config_import="\.\/$config_file"
            # Check if first line contains unstable or customPkgs
            inherits=""
            should_wrap_import=false
            for item in "pkgs" "unstable" "custom"; do
                if grep -q "$item" "$config_file" 2>/dev/null; then
                    inherits="${inherits}inherit ${item}; "
                    if [ "$item" != "pkgs" ]; then
                        should_wrap_import=true
                    fi
                fi
            done
            inherits="${inherits% }" # Remove trailing space

            if $should_wrap_import; then
                echo "Wrapping $config_file import with { $inherits }"
                config_import="(import $config_import { $inherits })"
            fi

            if ! sed -i '/\.\/luks-configuration.nix/a\          '"$config_import" ${SCRIPT_DIR}/flake.nix; then
                echo "Failed to add $config_file import" 1>&2
                exit 1
            fi
            echo "Added $config_file import"
        fi
    done

    cp -f "${SCRIPT_DIR}/flake.nix" flake.nix
    echo "Copied flake.nix"

    cp -f "${SCRIPT_DIR}/home-manager/"*.nix /etc/nixos/home-manager/
    echo "Copied home-manager files"

    # Rebuild NixOS configuration
    if ! nixos-rebuild switch --upgrade; then
        echo "Failed to rebuild NixOS configuration" 1>&2
        exit 1
    fi

    echo "Successfully completed NixOS configuration update"
fi


########################################################
# Arch Linux
########################################################
if [ "${LINUX_TYPE}" == "arch" ]; then
    echo "Installing dependencies"
    pacman -Sy --noconfirm \
        tailscale \
        curl \
        git \
        age \
        github-cli \
        chezmoi \
        tmux \
        kitty \
        starship \
        nushell \
        atuin \
        zoxide \
        neovim \
        python-pynvim \
        jq \
        docker \
        docker-compose \
        gnome-remote-desktop \
        ttf-sharetech-mono-nerd

    systemctl enable --now gnome-remote-desktop
    systemctl enable --now tailscaled
    systemctl enable --now docker
    tailscale up --ssh

    echo "Handling docker nonsense..."
    getent group docker >/dev/null 2>&1 || groupadd docker
    usermod -aG docker $NIXUSER || true
    newgrp docker || true

    echo "Updating shell"
    usermod --shell /usr/bin/nu $NIXUSER || {
        echo "Error: Failed to update shell" >&2
        exit 1
    }
fi

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}
