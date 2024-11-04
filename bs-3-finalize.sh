#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Just in case it was left over from a previous run
rm -f ~/.age/github.token 2>/dev/null || true

# Set the remote URLs for the repositories
echo "Fixing remote URLs for the repositories to use SSH..."
git -C ~/.config/chezmoi remote set-url origin git@github.com:matt-fff/.chezmoi.git
git -C ~/.config/nixpkgs remote set-url origin git@github.com:matt-fff/my-nixpkgs.git
git -C ~/.local/share/chezmoi remote set-url origin git@github.com:matt-fff/chez-home.git

echo "Cloning additional repositories..."
git clone git@github.com:matt-fff/deepthought.git ~/Workspaces/matt-fff/deepthought
git clone git@github.com:matt-fff/cutter-templates.git ~/Workspaces/matt-fff/cutter-templates

mkdir -p ~/.local/share/OpenSCAD/libraries
git clone git@github.com:matt-fff/openscad-libraries.git ~/.local/share/OpenSCAD/libraries/openscad-libraries
git clone git@github.com:matt-fff/scadlib.git ~/.local/share/OpenSCAD/libraries/scadlib
git clone git@github.com:BelfrySCAD/BOSL2.git ~/.local/share/OpenSCAD/libraries/BOSL2
git clone git@github.com:codefold/cc-scad.git ~/.local/share/OpenSCAD/libraries/cc-scad
git clone git@github.com:solidboredom/constructive.git ~/.local/share/OpenSCAD/libraries/constructive
git clone git@github.com:tallakt/bladegen.git ~/.local/share/OpenSCAD/libraries/bladegen-lib
ln -s ~/.local/share/OpenSCAD/libraries/bladegen-lib/libraries/bladegen ~/.local/share/OpenSCAD/libraries/bladegen

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}