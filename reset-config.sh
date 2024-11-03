#! /usr/bin/env sh

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

cd /etc/nixos || exit 1

# Create backup if it doesn't exist
if [ -f configuration.nix.bak ]; then
    mv configuration.nix configuration.nix.bak-$(date +%Y-%m-%d-%H-%M-%S)
    mv luks-configuration.nix luks-configuration.nix.bak-$(date +%Y-%m-%d-%H-%M-%S)
    cp configuration.nix.bak configuration.nix
fi
