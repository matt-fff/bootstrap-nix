#!/usr/bin/env sh

# Exit on any error
set -e

# Create workspace directories
echo "Creating workspace directories..."
echo "oss matt-fff scratch" \
  | sed 's/ /\n/g' \
  | xargs -I{} mkdir -p ~/Workspaces/{} || {
    echo "Error: Failed to create workspace directories" >&2
    exit 1
  }

# Change to Workspaces directory
cd ~/Workspaces || {
  echo "Error: Failed to change to Workspaces directory" >&2
  exit 1
}

# Enter nix-shell with git
echo "Installing git via nix-shell..."
nix-shell -p git || {
  echo "Error: Failed to enter nix-shell with git" >&2
  exit 1
}

# Clone repositories
echo "Cloning dotfiles repository..."
git clone https://github.com/matt-fff/.chezmoi.git ~/.config/chezmoi || {
  echo "Error: Failed to clone chezmoi repository" >&2
  exit 1
}

echo "Cloning nixpkgs repository..."
git clone https://github.com/matt-fff/my-nixpkgs.git ~/Workspaces/matt-fff/my-nixpkgs || {
  echo "Error: Failed to clone nixpkgs repository" >&2
  exit 1
}
