#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINUX_TYPE="${LINUX_TYPE:-nix}"

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

rm -rf ~/.config/chezmoi 2>/dev/null || true

# Clone repositories
echo "Cloning dotfiles repository..."
git clone https://github.com/matt-fff/.chezmoi.git ~/.config/chezmoi || {
  echo "Error: Failed to clone chezmoi repository" >&2
  exit 1
}

if [ "${LINUX_TYPE}" == "nix" ]; then
  rm -rf ~/.config/nixpkgs 2>/dev/null || true


  echo "Cloning nixpkgs repository..."
  git clone https://github.com/matt-fff/my-nixpkgs.git ~/.config/nixpkgs || {
    echo "Error: Failed to clone nixpkgs repository" >&2
    exit 1
  }
fi

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}
