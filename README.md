# bootstrap-nix

## Grab the script
```
nix-shell -p git
git clone https://github.com/matt-fff/bootstrap-nix
``

## Run the baseline script
```
./bootstrap-0.sh
```

## Run the script to update the Nix OS configuration
You will be prompted for your desired hostname
```
sudo ./bootstrap-1.sh
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
```
./bootstrap-2.sh
```