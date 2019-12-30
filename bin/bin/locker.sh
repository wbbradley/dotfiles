#!/bin/bash

# For older versions of xsecurelock
export XSECURELOCK_PARANOID_PASSWORD=0

# For newer versions of xsecurelock
export XSECURELOCK_PASSWORD_PROMPT=asterisks

# if command -v /usr/lib/xscreensaver/flyingtoasters >/dev/null; then
#   export XSECURELOCK_SAVER=/usr/lib/xscreensaver/flyingtoasters
# fi

# export XSECURELOCK_FONT="Iosevka-21"
export XSECURELOCK_DISCARD_FIRST_KEYPRESS=0

export XSECURELOCK_AUTHPROTO="/usr/local/google/home/wbbradley/bin/authproto_badger"

for cmd in /usr/share/goobuntu-desktop-files/xsecurelock.sh xsecurelock i3lock; do
    if command -v $cmd >/dev/null; then
        exec $cmd
    fi
done
