# bootstrap-nix

## Grab the script
```
mkdir -p ~/Workspaces/matt-fff/
cd ~/Workspaces/matt-fff
nix-shell -p git
git clone https://github.com/matt-fff/bootstrap-nix
cd bootstrap-nix
```

## Run the baseline script
```
./bs-0-baseline.sh
```

## Run the script to update the Nix OS configuration
```
su -c './bs-1-setup-os.sh desired-hostname'
```

If something breaks, you can revert to the backup of the config with:
```
sudo ./reset-config.sh
```

## Get a donor for decrypting Chezmoi data

You need a system with the age symmetric keys already in place.

Login to tailscale on the new system:
```
sudo tailscale up --ssh
```
You'll need to use the donor system and type the link manually.

With the system logged in, you can run the script that bootstraps chezmoi.
You'll be prompted for the donor system name and the password used to encrypt the github token on the donor system.
```
./bs-2-setup-home.sh
```

## Run cleanup script
```
./bs-3-finalize.sh
```

Reboot


## Graphics Configuration

https://wiki.nixos.org/wiki/AMD_GPU
https://nixos.wiki/wiki/Nvidia

Place your changes in `/etc/nixos/graphics-configuration.nix`. You can either add the dependency to `configuration.nix` manually or re-run `bs-1-setup-os.sh`, which will automatically add the import if it detects a graphics config.

If you're using a laptop, check if it's optimized here:
https://github.com/NixOS/nixos-hardware
