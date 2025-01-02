#!/usr/bin/env sh

export HOSTNAME="${HOSTNAME:-work}"
export EXTRA_PACKAGES=""
export CONFIG_EXCLUSIONS="nas-configuration.nix"
export NIX_HARDWARE="nixos-hardware.nixosModules.lenovo-legion-16irx9h"
