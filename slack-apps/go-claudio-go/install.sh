#!/bin/bash
# Usage: ./install.sh systemd|windows|uninstall|clear-cache
#   systemd: user service, for Linux hosts with systemd
#   windows: Windows scheduled task that starts the app in WSL at logon
#   uninstall: removes both, plus the saved variables and logs
#   clear-cache: forgets the cached channel names and restarts the app
# Installing one removes the other, so the app never runs twice.
set -e

WORKDIR=$(cd "$(dirname "$BASH_SOURCE")" && pwd)
UNIT=go-claudio-go.service
UNIT_FILE=$HOME/.config/systemd/user/$UNIT
ENV_FILE=$HOME/.config/go-claudio-go/env
CACHE_DIR=$HOME/.cache/go-claudio-go
REQUIRED_VARS="GO_CLAUDIO_GO_XAPP_TOKEN GO_CLAUDIO_GO_XOXP_TOKEN GO_CLAUDIO_GO_CLAUDE_USER_ID"
OPTIONAL_VARS="GO_CLAUDIO_GO_EXCLUDED_CHANNELS GO_CLAUDIO_GO_EXCLUDED_CHANNEL_PREFIXES GO_CLAUDIO_GO_EMOJI"

# systemd and Task Scheduler don't see the shell's environment, so persist
# the variables to a file both setups load
write_env_file() {
    local var missing=""
    for var in $REQUIRED_VARS; do
        [ -n "${!var}" ] || missing="$missing $var"
    done
    if [ -n "$missing" ]; then
        echo "Set these environment variables first:$missing" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$ENV_FILE")"
    touch "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    for var in $REQUIRED_VARS $OPTIONAL_VARS; do
        if [ -n "${!var}" ]; then
            echo "$var=\"${!var}\""
        fi
    done > "$ENV_FILE"
}

windows_task() {
    powershell.exe -NoProfile -ExecutionPolicy Bypass \
        -File "$(wslpath -w "$WORKDIR/register-task.ps1")" "$@"
}

# Stopping the scheduled task doesn't stop the app it started inside WSL
kill_windows_app() {
    pkill -f "$WORKDIR/app.py" || true
}

remove_windows() {
    if command -v powershell.exe > /dev/null; then
        windows_task -Remove
        kill_windows_app
    fi
}

remove_systemd() {
    if [ -e "$UNIT_FILE" ] || [ -L "$UNIT_FILE" ]; then
        # Stop before disabling: disabling an old symlinked install also
        # deletes the unit file, after which systemd can no longer stop it
        systemctl --user stop "$UNIT"
        systemctl --user disable "$UNIT"
        rm -f "$UNIT_FILE"
        systemctl --user daemon-reload
    fi
}

install_systemd() {
    remove_windows
    mkdir -p "$(dirname "$UNIT_FILE")"
    # Write a copy pointing at this checkout, wherever it was cloned
    rm -f "$UNIT_FILE"
    sed "s|@APP@|$WORKDIR/app.py|" "$WORKDIR/$UNIT" > "$UNIT_FILE"
    systemctl --user daemon-reload
    systemctl --user enable "$UNIT"
    # restart rather than start, so a re-run picks up new variables
    systemctl --user restart "$UNIT"
    echo "Logs: journalctl --user -u $UNIT -f"
}

install_windows() {
    if [ -z "$WSL_DISTRO_NAME" ]; then
        echo "The windows option only works from inside WSL" >&2
        exit 1
    fi
    remove_systemd
    kill_windows_app
    windows_task -Distro "$WSL_DISTRO_NAME" -App "$WORKDIR/app.py"
    echo "Logs: $HOME/.local/state/go-claudio-go/app.log"
}

uninstall() {
    remove_systemd
    remove_windows
    rm -rf "$(dirname "$ENV_FILE")" "$HOME/.local/state/go-claudio-go"
    echo "Removed go-claudio-go, its saved variables and logs (kept the cache)"
}

# The running app keeps the names in memory and would write them back, so
# restart it after deleting the file
clear_cache() {
    rm -rf "$CACHE_DIR"
    if [ -e "$UNIT_FILE" ]; then
        systemctl --user restart "$UNIT"
    elif command -v powershell.exe > /dev/null; then
        kill_windows_app
        windows_task -Restart
    fi
    echo "Cleared the channel name cache"
}

case "$1" in
    systemd) write_env_file; install_systemd ;;
    windows) write_env_file; install_windows ;;
    uninstall) uninstall ;;
    clear-cache) clear_cache ;;
    *) echo "Usage: $0 systemd|windows|uninstall|clear-cache" >&2; exit 1 ;;
esac
