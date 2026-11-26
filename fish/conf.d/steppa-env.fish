# Environment shared with the sway session. Loaded automatically by fish (conf.d).
fish_add_path -g $HOME/.local/bin

# sway starts ssh-agent on this fixed socket (sway/scripts/session-services.sh)
if set -q XDG_RUNTIME_DIR
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
end

# default editor/terminal used by tools that read these variables
set -q EDITOR; or set -gx EDITOR vim
set -gx TERMINAL xdg-term
