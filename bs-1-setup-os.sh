#! /usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

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

# Extract LUKS configuration to new file
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


# Replace configuration.nix with the one from SCRIPT_DIR
if ! cp "$SCRIPT_DIR/configuration.nix" configuration.nix; then
    echo "Failed to replace configuration.nix" 1>&2
    exit 1
fi

# Prompt for hostname and update configuration
echo -n "Enter hostname (default: newnix): "
read -r hostname
hostname=${hostname:-newnix}

if ! sed -i "s/networking.hostName = \"work\"/networking.hostName = \"$hostname\"/" configuration.nix; then
    echo "Failed to update hostname in configuration.nix" 1>&2
    exit 1
fi

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

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}