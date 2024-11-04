#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create .age directory
echo "Creating .age directory..."
mkdir -p ~/.age/ || {
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

# Decrypt the GitHub token
echo "Decrypting GitHub token..."
echo "You will be prompted for your laptop encryption passphrase to decrypt the GitHub token"
age --decrypt -o ~/.age/github.token ~/.age/gh-token.encr || {
  echo "Error: Failed to decrypt GitHub token" >&2
  exit 1
}

echo "Logging in to GitHub..."
gh auth login --with-token < ~/.age/github.token || {
  echo "Error: Failed to login to GitHub" >&2
  exit 1
}

gh repo clone matt-fff/chez-home ~/.local/share/chezmoi || {
  echo "Error: Failed to clone chez-home repository" >&2
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