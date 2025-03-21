#!/usr/bin/env sh

# Exit on any error
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINUX_TYPE="$(source ${SCRIPT_DIR}/get-os.sh)"

# Just in case it was left over from a previous run
rm -f ~/.age/github.token 2>/dev/null || true


# Set the remote URLs for the repositories
echo "Fixing remote URLs for the repositories to use SSH..."
git -C ~/.config/chezmoi remote set-url origin git@github.com:matt-fff/.chezmoi.git
git -C ~/.local/share/chezmoi remote set-url origin git@github.com:matt-fff/chez-home.git
git -C ~/Workspaces/matt-fff/bootstrap-nix remote set-url origin git@github.com:matt-fff/bootstrap-nix.git

echo "Cloning additional repositories..."

# Clone workspaces repositories
for repo in "deepthought" "cutter-templates"; do
    target_dir="$HOME/Workspaces/matt-fff/$repo"
    if [ ! -d "$target_dir" ]; then
        git clone "git@github.com:matt-fff/$repo.git" "$target_dir"
    else
        echo "Directory already exists: $target_dir"
    fi
done

if [ "${LINUX_TYPE}" == "arch" ]; then
  yay -Sy --noconfirm --sudoloop \
    asdf-vm \
    sapling-scm-bin \
    xrdp \
    gnome-remote-desktop \
    cifs-utils

  sudo systemctl enable --now xrdp
  
  # Check if ASDF config already exists before adding it to the shell
  if [ ! -f ~/.config/nushell/env.nu ] || ! grep -q "asdf-completions=" ~/.config/nushell/env.nu; then
    echo "" >> ~/.config/nushell/env.nu
    echo "source ~/.config/nushell/completions/asdf/asdf-completions.nu" >> ~/.config/nushell/env.nu
    echo "" >> ~/.config/nushell/env.nu
  fi

  for plugin in $(awk '{print $1}' ~/.tool-versions); do
    asdf plugin add "$plugin"
  done
  asdf install
fi

cd "$SCRIPT_DIR" || {
  echo "Error: Failed to change to script directory" >&2
  exit 1
}
