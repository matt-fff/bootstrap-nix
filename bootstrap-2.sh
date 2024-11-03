#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create .age directory
echo "Creating .age directory..."
mkdir ~/.age/ || {
  echo "Error: Failed to create .age directory" >&2
  exit 1
}

# Prompt for donor hostname
echo -n "Enter donor hostname for age key retrieval: "
read -r donor_hostname

if [ -z "$donor_hostname" ]; then
  echo "Error: Donor hostname cannot be empty" >&2
  exit 1
fi

# Copy age key from donor system
echo "Copying age key from donor system..."
scp "matt@${donor_hostname}:.age/chezmoi.txt" ~/.age/chezmoi.txt || {
  echo "Error: Failed to copy age key from donor system" >&2
  exit 1
}


echo "Initializing chezmoi..."
chezmoi init https://github.com/matt-fff/chez-home.git || {
  echo "Error: Failed to initialize chezmoi" >&2
  exit 1
}

echo "Applying chezmoi configuration..."
chezmoi apply -v --force || {
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