#!/usr/bin/env sh

export HOSTNAME="${HOSTNAME:-work}"
export EXTRA_USER_PACKAGES=""
export CONFIG_EXCLUSIONS="nas-configuration.nix"
export ADDITIONAL_MODULES="nixos-hardware.nixosModules.lenovo-legion-16irx9h"
