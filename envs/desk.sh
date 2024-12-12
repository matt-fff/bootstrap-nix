#!/usr/bin/env sh

export NIXUSER="${NIXUSER:-matt}"
export HOSTNAME="${HOSTNAME:-newnix}"
export EXTRA_PACKAGES="nixpkgs.monero-gui nixpkgs.monero-cli nixpkgs.ledger-live-desktop nixpkgs.wally-cli"
