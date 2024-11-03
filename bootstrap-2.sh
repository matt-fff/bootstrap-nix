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


cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}