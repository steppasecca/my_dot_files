#!/usr/bin/env bash
# install.sh — deploy this repo into ~/.config with backup and rollback.
#
#   ./install.sh check                      validate the repo files (no changes made)
#   ./install.sh apply [--safe[=SEC]] [MODULE...]
#                                           back up, then symlink modules into place and reload them
#                                           --safe: after reloading, ask for confirmation; no answer
#                                           within SEC seconds (default 30) = automatic rollback
#   ./install.sh rollback [BACKUP_DIR]      undo the last apply (or the given backup)
#   sudo ./install.sh lidm                  install lidm/lidm.ini to /etc (backup: /etc/lidm.ini.pre-rice)
#   sudo ./install.sh rollback-lidm         restore /etc/lidm.ini from that backup
#
# MODULES: foot rofi swaylock waybar mako yazi fish sway xdg   (default: all of them)
set -euo pipefail

DOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CFG=${XDG_CONFIG_HOME:-$HOME/.config}
DATA=${XDG_DATA_HOME:-$HOME/.local/share}
BIN=$HOME/.local/bin
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-rice
ALL=(foot rofi swaylock waybar mako yazi fish sway xdg)

say()  { printf '\033[1;36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# ------------------------------------------------------------------ backup bookkeeping
BK=; N=0
begin_backup() {
    BK=$STATE/backup-$(date +%Y%m%d-%H%M%S)
    mkdir -p "$BK/orig"; : >"$BK/manifest"
    mkdir -p "$STATE"; printf '%s\n' "$BK" >"$STATE/latest"
    say "backup directory: $BK"
}
record() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >>"$BK/manifest"; }   # TYPE DST BACKUP

link_path() {      # link_path SRC DST : DST becomes a symlink to SRC (original moved to the backup)
    local src=$1 dst=$2 chk=$1
    [[ $src == /* ]] || chk=$(dirname "$dst")/$src          # relative link targets are relative to DST
    [[ -e $chk ]] || die "missing in repo: $chk"
    if [[ -e $dst || -L $dst ]] && [[ $(readlink -f "$dst") == "$(readlink -f "$chk")" ]]; then
        echo "   ok       $dst (already points to the repo)"; return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e $dst || -L $dst ]]; then
        N=$((N+1)); mv -- "$dst" "$BK/orig/$N"; record swap "$dst" "$BK/orig/$N"
    else
        record swap "$dst" -
    fi
    ln -s -- "$src" "$dst"; echo "   link     $dst -> $src"
}

snapshot() {       # snapshot FILE : remember a file that will be edited in place
    local f=$1
    if [[ -e $f ]]; then N=$((N+1)); cp -a -- "$f" "$BK/orig/$N"; record copy "$f" "$BK/orig/$N"
    else record copy "$f" -; fi
}

rollback_run() {
    local dir=${1:-}
    [[ -n $dir ]] || dir=$(cat "$STATE/latest" 2>/dev/null || true)
    [[ -f $dir/manifest ]] || die "no backup found (looked in ${dir:-$STATE})"
    say "rolling back from $dir"
    local type dst bak
    tac "$dir/manifest" | while IFS=$'\t' read -r type dst bak; do
        case $type in
            swap)
                if [[ -L $dst ]]; then rm -f -- "$dst"
                elif [[ -e $dst ]]; then warn "$dst is not a symlink any more, leaving it alone"; continue; fi
                if [[ $bak != - ]]; then mv -- "$bak" "$dst"; echo "   restored $dst"; else echo "   removed  $dst"; fi ;;
            copy)
                if [[ $bak != - ]]; then cp -a -- "$bak" "$dst"; echo "   restored $dst"; else rm -f -- "$dst"; echo "   removed  $dst"; fi ;;
            new)
                rm -f -- "$dst"; echo "   removed  $dst" ;;
        esac
    done
}

# ------------------------------------------------------------------ reload helpers
sway_running() { [[ -n ${SWAYSOCK:-} ]] && command -v swaymsg >/dev/null 2>&1; }

reload_modules() {
    local m
    for m in "$@"; do
        case $m in
            sway)   sway_running && { swaymsg reload >/dev/null && say "sway reloaded"; } ;;
            waybar) pgrep -x waybar >/dev/null && { pkill -SIGUSR2 -x waybar; say "waybar reloaded"; } ;;
            mako)   if command -v mako >/dev/null 2>&1 && [[ -n ${WAYLAND_DISPLAY:-} ]]; then
                        pkill -x swaync 2>/dev/null || true
                        if pgrep -x mako >/dev/null; then makoctl reload; else setsid -f mako >/dev/null 2>&1; fi
                        say "notifications: mako running, swaync stopped"
                    fi ;;
        esac
    done
    return 0
}

# ------------------------------------------------------------------ module installers
mod_simple()  { link_path "$DOT/$1" "$CFG/$1"; }
mod_fish()    { link_path "$DOT/fish/conf.d/steppa-env.fish" "$CFG/fish/conf.d/steppa-env.fish"; }

mod_sway() {
    link_path "$DOT/sway" "$CFG/sway"
    [[ -d $CFG/swaync ]] && warn "swaync config still exists ($CFG/swaync): unused now, remove it when you are happy"
    return 0
}

mod_xdg() {
    local n
    mkdir -p "$BIN" "$DATA/applications"
    link_path "$DOT/bin/xdg-tools" "$BIN/xdg-tools"
    for n in launch run pick term; do link_path "xdg-tools" "$BIN/xdg-$n"; done
    if [[ -x $HOME/programs/LibreWolf.x86_64.AppImage && ! -e $DATA/applications/librewolf-appimage.desktop ]]; then
        sed "s|@HOME@|$HOME|g" "$DOT/applications/librewolf-appimage.desktop.in" >"$DATA/applications/librewolf-appimage.desktop"
        record new "$DATA/applications/librewolf-appimage.desktop" -
        echo "   created  $DATA/applications/librewolf-appimage.desktop"
    fi
    if ! find /usr/share/applications /usr/local/share/applications "$DATA/applications" -name yazi.desktop 2>/dev/null | grep -q .; then
        cp "$DOT/applications/yazi.desktop" "$DATA/applications/yazi.desktop"
        record new "$DATA/applications/yazi.desktop" -
        echo "   created  $DATA/applications/yazi.desktop"
    fi
    snapshot "$CFG/mimeapps.list"; snapshot "$CFG/xdg-terminals.list"
    say "seeding XDG defaults (only roles that have no default yet):"
    PATH=$BIN:$PATH XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-sway} "$BIN/xdg-pick" --init || warn "xdg-pick --init failed (xdg-utils installed?)"
}

# ------------------------------------------------------------------ check
cmd_check() {
    local rc=0 f
    say "tools"
    for t in sway waybar foot rofi mako swaylock yazi fish kanshi swayidle grim slurp wl-copy jq notify-send xdg-mime; do
        if command -v "$t" >/dev/null 2>&1; then printf '   %-12s %s\n' "$t" "$(command -v "$t")"
        else printf '   %-12s MISSING\n' "$t"; fi
    done
    say "scripts (bash -n)"
    for f in "$DOT"/bin/xdg-tools "$DOT"/sway/scripts/*.sh "$DOT"/sway/screenshot_selector.sh "$DOT"/waybar/*.sh "$DOT"/waybar/scripts/*.sh "$DOT"/install.sh; do
        if bash -n "$f"; then echo "   ok  ${f#"$DOT"/}"; else echo "   BAD ${f#"$DOT"/}"; rc=1; fi
    done
    if command -v sway >/dev/null 2>&1; then
        say "sway -C (config syntax)"
        if WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 timeout 20 sway -C -c "$DOT/sway/config" 2>&1 | grep -E 'ERROR.*(config|Error)'; then rc=1; else echo "   ok"; fi
    fi
    if command -v foot >/dev/null 2>&1; then
        # an invalid foot config makes foot refuse to start, so this one is blocking
        say "foot --check-config"
        if foot --check-config -c "$DOT/foot/foot.ini" 2>&1 | grep -v 'UTF-8 locale' | grep -E 'err:'; then rc=1; else echo "   ok"; fi
    fi
    if command -v python3 >/dev/null 2>&1; then
        say "TOML / JSON"
        python3 - "$DOT" <<'PY' || rc=1
import json, sys, tomllib
d = sys.argv[1]
for f in ("yazi/yazi.toml", "yazi/keymap.toml"):
    tomllib.load(open(f"{d}/{f}", "rb")); print("   ok ", f)
json.load(open(f"{d}/waybar/config.jsonc")); print("    ok  waybar/config.jsonc")
PY
    fi
    return $rc
}

# ------------------------------------------------------------------ apply
cmd_apply() {
    local safe=0 secs=30 a; local -a mods=()
    for a in "$@"; do
        case $a in
            --safe)   safe=1 ;;
            --safe=*) safe=1; secs=${a#--safe=} ;;
            *)        mods+=("$a") ;;
        esac
    done
    (( ${#mods[@]} )) || mods=("${ALL[@]}")
    local m; for m in "${mods[@]}"; do [[ " ${ALL[*]} " == *" $m "* ]] || die "unknown module: $m (valid: ${ALL[*]})"; done

    say "validating before touching anything"
    cmd_check >/dev/null 2>&1 || { cmd_check || true; die "validation failed, nothing was changed"; }
    if git -C "$DOT" rev-parse >/dev/null 2>&1 && [[ -n $(git -C "$DOT" status --porcelain) ]]; then
        warn "the dotfiles repo has uncommitted changes: commit them first so that 'git' is also a fallback"
    fi

    begin_backup
    for m in "${mods[@]}"; do
        say "module: $m"
        case $m in
            foot|rofi|swaylock|waybar|mako|yazi) mod_simple "$m" ;;
            fish) mod_fish ;;
            sway) mod_sway ;;
            xdg)  mod_xdg ;;
        esac
    done
    reload_modules "${mods[@]}"
    say "done. Undo with: $DOT/install.sh rollback"

    if (( safe )); then
        local ans=n
        read -r -t "$secs" -p "Everything looks right? Type y within ${secs}s to keep it (anything else = rollback): " ans || ans=n
        echo
        if [[ $ans == y || $ans == Y ]]; then say "kept."
        else warn "rolling back"; rollback_run "$BK"; reload_modules "${mods[@]}"; fi
    fi
}

# ------------------------------------------------------------------ lidm (root)
cmd_lidm() {
    [[ $EUID -eq 0 ]] || die "run with sudo: sudo $0 lidm"
    [[ -f /etc/lidm.ini && ! -f /etc/lidm.ini.pre-rice ]] && cp -a /etc/lidm.ini /etc/lidm.ini.pre-rice
    install -m 644 "$DOT/lidm/lidm.ini" /etc/lidm.ini
    say "installed /etc/lidm.ini (previous one: /etc/lidm.ini.pre-rice). Takes effect at the next login screen."
}
cmd_lidm_rollback() {
    [[ $EUID -eq 0 ]] || die "run with sudo"
    [[ -f /etc/lidm.ini.pre-rice ]] || die "/etc/lidm.ini.pre-rice not found"
    cp -a /etc/lidm.ini.pre-rice /etc/lidm.ini; say "restored /etc/lidm.ini"
}

case ${1:-} in
    check)         cmd_check ;;
    apply)         shift; cmd_apply "$@" ;;
    rollback)      shift; rollback_run "${1:-}" ;;
    lidm)          cmd_lidm ;;
    rollback-lidm) cmd_lidm_rollback ;;
    *)             sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
