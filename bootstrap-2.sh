#!/usr/bin/env sh

# Exit on any error
set -e

# Create .age directory
echo "Creating .age directory..."
mkdir ~/.age/ || {
  echo "Error: Failed to create .age directory" >&2
  exit 1
}