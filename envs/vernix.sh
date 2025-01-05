#!/usr/bin/env sh

export HOSTNAME="${HOSTNAME:-vernix}"
export EXTRA_SYSTEM_PACKAGES="
    stable.gnome-remote-desktop
    stable.gnome-session
"
export EXTRA_USER_PACKAGES="
    stable.deluged
    stable.flood
    stable.audiobookshelf
"