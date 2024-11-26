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

if [ "${LINUX_TYPE}" == "nix" ]; then
    # Check if we can access /etc/nixos
    cd /etc/nixos || {
        echo "Failed to change directory to /etc/nixos" 1>&2
        exit 1
    }

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


    # Get hostname from command line argument or prompt
    hostname=$1
    if [ -z "$hostname" ]; then
        echo -n "Enter hostname (default: newnix): "
        read -r hostname
        hostname=${hostname:-newnix}
    fi

    if ! sed -i "s/networking.hostName = \"fake-hostname\"/networking.hostName = \"$hostname\"/" configuration.nix; then
        echo "Failed to update hostname in configuration.nix" 1>&2
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
    for config_file in graphics-configuration.nix nas-configuration.nix; do
        if [ -f "$config_file" ]; then
            if ! sed -i '/\.\/luks-configuration.nix/a\      \.\/'"$config_file" configuration.nix; then
                echo "Failed to add $config_file import" 1>&2
                exit 1
            fi
            echo "Added $config_file import"
        fi
    done


    # Add nix channel
    echo "Adding nixos-24.05 channel..."
    nix-channel --add https://nixos.org/channels/nixos-24.05 nixos || {
    echo "Error: Failed to add nixos-24.05 channel" >&2
    exit 1
    }

    # Add nix channel
    echo "Adding nixos-unstable channel..."
    nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable || {
    echo "Error: Failed to add nixos-unstable channel" >&2
    exit 1
    }

    # Add home-manager channel
    echo "Adding home-manager channel..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager || {
    echo "Error: Failed to add home-manager channel" >&2
    exit 1
    }

    # Update nix channels
    echo "Updating nix channels..."
    nix-channel --update || {
    echo "Error: Failed to update nix channels" >&2
    exit 1
    }


    # Rebuild NixOS configuration
    if ! nixos-rebuild switch --upgrade; then
        echo "Failed to rebuild NixOS configuration" 1>&2
        exit 1
    fi

    echo "Successfully completed NixOS configuration update"
fi

if [ "${LINUX_TYPE}" == "arch" ]; then
    echo "Installing dependencies"
    pacman -Sy \
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
        pnpm \
        python-pynvim \
        uv \
        jq \
        pulumi \
        docker \
        docker-compose

    if [ ! -d /tmp/asdf-vm ]; then
        git clone https://aur.archlinux.org/asdf-vm.git /tmp/asdf-vm && cd /tmp/asdf-vm && makepkg -si
    fi
    
    # Check if ASDF config already exists before adding it
    if [ ! -f /home/matt/.config/nushell/env.nu ] || ! grep -q "ASDF_DIR = '/opt/asdf-vm/'" /home/matt/.config/nushell/env.nu; then
        echo "" >> /home/matt/.config/nushell/env.nu
        echo "\$env.ASDF_DIR = '/opt/asdf-vm/'" >> /home/matt/.config/nushell/env.nu
        echo "source /opt/asdf-vm/asdf.nu" >> /home/matt/.config/nushell/env.nu
        echo "" >> /home/matt/.config/nushell/env.nu
        chown matt: /home/matt/.config/nushell/env.nu
    fi

    echo "Handling docker nonsense..."
    groupadd docker || true
    usermod -aG docker $USER || true
    newgrp docker || true

    echo "Updating shell"
    usermod --shell /usr/bin/nu matt || {
        echo "Error: Failed to update shell" >&2
        exit 1
    }
fi

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}
