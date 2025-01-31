#!/usr/bin/env sh

# Exit on any error
set -e

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "nixos" ]; then
        LINUX_TYPE="nix"
    elif [ "$ID" = "arch" ]; then
        LINUX_TYPE="arch"
    elif [ "$ID" = "endeavouros" ]; then
        LINUX_TYPE="arch"
    else
        echo "Warning: Unsupported Linux distribution: $ID" >&2
        LINUX_TYPE="nix"  # Default to nix if unknown
    fi
else
    echo "Warning: Could not detect Linux distribution" >&2
    LINUX_TYPE="nix"  # Default to nix if detection fails
fi

echo "$LINUX_TYPE"
