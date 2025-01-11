#!/usr/bin/env sh

export HOSTNAME="${HOSTNAME:-work}"
export CONFIG_EXCLUSIONS="nas-configuration.nix"
export ADDITIONAL_INPUTS="nixos-hardware.url = \"nixos-hardware/master\";"
export ADDITIONAL_OUTPUTS="nixos-hardware"
export ADDITIONAL_MODULES="nixos-hardware.nixosModules.lenovo-legion-16irx9h"
