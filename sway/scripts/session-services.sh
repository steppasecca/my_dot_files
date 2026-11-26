#!/bin/sh
# Started once per sway session. Everything is sequential on purpose: the environment
# must be exported to D-Bus BEFORE the portals start, otherwise they need a second restart.
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
dbus-update-activation-environment --all

# stop leftovers from a previous session
for p in xdg-desktop-portal-wlr xdg-desktop-portal wireplumber pipewire-pulse pipewire; do
    pkill -x "$p" 2>/dev/null
done
sleep 1

pipewire       >/dev/null 2>&1 & sleep 1
pipewire-pulse >/dev/null 2>&1 & sleep 1
wireplumber    >/dev/null 2>&1 & sleep 1
/usr/libexec/xdg-desktop-portal-wlr >/dev/null 2>&1 & sleep 1
/usr/libexec/xdg-desktop-portal     >/dev/null 2>&1 &

# ssh-agent on a fixed socket (fish/conf.d/steppa-env.fish exports SSH_AUTH_SOCK)
sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"
if ! pgrep -u "$(id -u)" -f "ssh-agent -a $sock" >/dev/null 2>&1; then
    rm -f "$sock"
    ssh-agent -a "$sock" >/dev/null 2>&1
fi
