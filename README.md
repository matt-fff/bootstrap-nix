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
```
sudo ./bootstrap-1.sh
```
If something breaks, you can revert to the backup of the config with:
```
sudo ./reset-config.sh
```
