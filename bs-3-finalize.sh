#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Just in case it was left over from a previous run
rm -f ~/.age/github.token 2>/dev/null || true

# Set the remote URLs for the repositories
echo "Fixing remote URLs for the repositories to use SSH..."
git -C ~/.config/chezmoi remote set-url origin git@github.com:matt-fff/.chezmoi.git
git -C ~/.local/share/chezmoi remote set-url origin git@github.com:matt-fff/chez-home.git
git -C ~/Workspaces/matt-fff/bootstrap-nix remote set-url origin git@github.com:matt-fff/bootstrap-nix.git

if [ "${SKIP_NIX:-false}" != "true" ]; then
  git -C ~/.config/nixpkgs remote set-url origin git@github.com:matt-fff/my-nixpkgs.git
fi

echo "Cloning additional repositories..."

# Clone workspaces repositories
for repo in "deepthought" "cutter-templates" "i3blocks-contrib"; do
    target_dir="$HOME/Workspaces/matt-fff/$repo"
    if [ ! -d "$target_dir" ]; then
        git clone "git@github.com:matt-fff/$repo.git" "$target_dir"
    else
        echo "Directory already exists: $target_dir"
    fi
done

repo="i3blocks-contrib"
target_dir="$HOME/Workspaces/oss/$repo"
if [ ! -d "$target_dir" ]; then
    git clone "git@github.com:matt-fff/$repo.git" "$target_dir"
else
    echo "Directory already exists: $target_dir"
fi

# Create OpenSCAD libraries directory
mkdir -p ~/.local/share/OpenSCAD/libraries

# Define OpenSCAD repositories to clone
declare -A scad_repos=(
    ["scadlib"]="matt-fff/scadlib"
    ["BOSL2"]="BelfrySCAD/BOSL2"
    ["cc-scad"]="codefold/cc-scad"
    ["constructive"]="solidboredom/constructive"
    ["bladegen-lib"]="tallakt/bladegen"
)

# Clone OpenSCAD repositories
for dir in "${!scad_repos[@]}"; do
    target_dir="$HOME/.local/share/OpenSCAD/libraries/$dir"
    if [ ! -d "$target_dir" ]; then
        git clone "git@github.com:${scad_repos[$dir]}.git" "$target_dir"
    else
        echo "Directory already exists: $target_dir"
    fi
done

# Create bladegen symlink if it doesn't exist
bladegen_link="$HOME/.local/share/OpenSCAD/libraries/bladegen"
if [ ! -L "$bladegen_link" ]; then
    ln -s ~/.local/share/OpenSCAD/libraries/bladegen-lib/libraries/bladegen "$bladegen_link"
else
    echo "Symlink already exists: $bladegen_link"
fi

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}
