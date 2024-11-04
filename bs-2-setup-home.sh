#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf ~/.config/home-manager 2>/dev/null || true

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


# Install home-manager
echo "Installing home-manager..."
if ! nix-shell '<home-manager>' -A install; then
    echo "Failed to install home-manager" 1>&2
    exit 1
fi

# Create .age directory
echo "Creating .age directory..."
mkdir -p ~/.age/ || {
  echo "Error: Failed to create .age directory" >&2
  exit 1
}

# Check if we need to copy any files from donor system
if [ ! -f ~/.age/chezmoi.txt ] || [ ! -f ~/.age/gh-token.encr ]; then
  # Prompt for donor hostname only if needed
  echo -n "Enter donor hostname for age key retrieval: "
  read -r donor_hostname

  if [ -z "$donor_hostname" ]; then
    echo "Error: Donor hostname cannot be empty" >&2
    exit 1
  fi

  # Only copy age key if it doesn't already exist
  if [ ! -f ~/.age/chezmoi.txt ]; then
    echo "Copying age key from donor system..."
    scp "matt@${donor_hostname}:.age/chezmoi.txt" ~/.age/chezmoi.txt || {
      echo "Error: Failed to copy age key from donor system" >&2
      exit 1
    }
  else
    echo "Age key already exists, skipping copy..."
  fi

  # Only copy gh token if it doesn't already exist
  if [ ! -f ~/.age/gh-token.encr ]; then
    echo "Copying GitHub token from donor system..."
    scp "matt@${donor_hostname}:.age/gh-token.encr" ~/.age/gh-token.encr || {
      echo "Error: Failed to copy GitHub token from donor system" >&2
      exit 1
    }
  else
    echo "GitHub token already exists, skipping copy..."
  fi
else
  echo "All required files present, skipping donor system copy..."
fi

# Decrypt the GitHub token
if [ ! -f ~/.age/github.token ]; then
  echo "Decrypting GitHub token..."
  echo "You will be prompted for your laptop encryption passphrase to decrypt the GitHub token"
  age --decrypt -o ~/.age/github.token ~/.age/gh-token.encr || {
    echo "Error: Failed to decrypt GitHub token" >&2
    exit 1
  }
else
  echo "GitHub token already decrypted, skipping..."
fi

echo "Logging in to GitHub..."
gh auth login --with-token < ~/.age/github.token || {
  echo "Error: Failed to login to GitHub" >&2
  exit 1
}

rm -f ~/.age/github.token 2>/dev/null || true

rm -rf ~/.local/share/chezmoi 2>/dev/null || true

gh repo clone matt-fff/chez-home ~/.local/share/chezmoi || {
  echo "Error: Failed to clone chez-home repository" >&2
  exit 1
}

echo "Applying chezmoi configuration..."
chezmoi apply --force || {
  echo "Error: Failed to apply chezmoi configuration" >&2
  exit 1
}

echo "Switching home-manager..."
home-manager switch || {
  echo "Error: Failed to switch home-manager" >&2
  exit 1
}

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}