#!/usr/bin/env sh

# User
export NIXUSER="${NIXUSER:-matt}"

# Hostname
export HOSTNAME="${HOSTNAME:-newnix}"

# Exclude certain configuration files from being auto-imported into flake.nix
export CONFIG_EXCLUSIONS=""

# For setting up specific nixos-hardware imports in flake.nix
export ADDITIONAL_MODULES=""

# System locale
export LOCALE="
  i18n = {
    # Select internationalisation properties.
    defaultLocale = \"ru_RU.UTF-8\";

    extraLocaleSettings = {
      LC_ADDRESS = \"ru_RU.UTF-8\";
      LC_IDENTIFICATION = \"ru_RU.UTF-8\";
      LC_MEASUREMENT = \"ru_RU.UTF-8\";
      LC_MONETARY = \"ru_RU.UTF-8\";
      LC_NAME = \"ru_RU.UTF-8\";
      LC_NUMERIC = \"ru_RU.UTF-8\";
      LC_PAPER = \"ru_RU.UTF-8\";
      LC_TELEPHONE = \"ru_RU.UTF-8\";
      LC_TIME = \"ru_RU.UTF-8\";
      LANGUAGE = \"ru_RU.UTF-8\";
      LC_ALL = \"ru_RU.UTF-8\";
      LC_CTYPE = \"ru_RU.UTF-8\";
      LC_COLLATE = \"ru_RU.UTF-8\";
      LC_MESSAGES = \"ru_RU.UTF-8\";
    };
  };
  "