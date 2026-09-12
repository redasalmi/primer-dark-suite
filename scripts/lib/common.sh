#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# The *_DEST, *_SOURCE, and HERDR_* variables below are read by the component
# modules that source this file, so ShellCheck reports them as unused here.
# shellcheck disable=SC2034

: "${ROOT:?ROOT must be set before loading common.sh}"

PACKAGE_ID=io.github.redasalmi.primerdark.desktop
AURORAE_ID=PrimerDark
PLASMA_STYLE_ID=PrimerDark
COLOR_FILE=PrimerDark.colors
# ALL_COMPONENTS are safe for the root install and uninstall lifecycle.
ALL_COMPONENTS="kde konsole ghostty herdr pi zed fastfetch bat btop fish gtk"
# CHECK_COMPONENTS validate their own assets in a check_* hook.
CHECK_COMPONENTS="kde bat fastfetch pi zed firefox chrome fzf gtk"
# COMPONENT_MODULES are every module sourced by the install, uninstall, and
# check entry points.
COMPONENT_MODULES="$ALL_COMPONENTS firefox chrome fzf"
PLASMA_STYLE_SOURCE="$ROOT/kde/plasma-style/$PLASMA_STYLE_ID"
GLOBAL_SOURCE="$ROOT/kde/look-and-feel/$PACKAGE_ID"
HERDR_BEGIN='# BEGIN Primer Dark Herdr theme (managed by primer-dark-suite)'
HERDR_END='# END Primer Dark Herdr theme (managed by primer-dark-suite)'

initialize_user_paths() {
    if [ -n "${XDG_DATA_HOME:-}" ]; then
        DATA_HOME=$XDG_DATA_HOME
    elif [ -n "${HOME:-}" ]; then
        DATA_HOME="$HOME/.local/share"
    else
        echo "HOME or XDG_DATA_HOME is required for user installation paths." >&2
        exit 1
    fi

    if [ -n "${XDG_CONFIG_HOME:-}" ]; then
        CONFIG_HOME=$XDG_CONFIG_HOME
    elif [ -n "${HOME:-}" ]; then
        CONFIG_HOME="$HOME/.config"
    else
        echo "HOME or XDG_CONFIG_HOME is required for user configuration paths." >&2
        exit 1
    fi

    if [ -n "${PI_CODING_AGENT_DIR:-}" ]; then
        PI_AGENT_DIR=$PI_CODING_AGENT_DIR
    elif [ -n "${HOME:-}" ]; then
        PI_AGENT_DIR="$HOME/.pi/agent"
    else
        echo "HOME or PI_CODING_AGENT_DIR is required for the Pi theme path." >&2
        exit 1
    fi

    COLOR_DEST="$DATA_HOME/color-schemes/$COLOR_FILE"
    AURORAE_DEST="$DATA_HOME/aurorae/themes/$AURORAE_ID"
    PLASMA_STYLE_DEST="$DATA_HOME/plasma/desktoptheme/$PLASMA_STYLE_ID"
    GLOBAL_ROOT="$DATA_HOME/plasma/look-and-feel"
    GLOBAL_DEST="$GLOBAL_ROOT/$PACKAGE_ID"
    KONSOLE_SCHEME_DEST="$DATA_HOME/konsole/PrimerDark.colorscheme"
    KONSOLE_PROFILE_DEST="$DATA_HOME/konsole/PrimerDark.profile"
    GHOSTTY_DEST="$CONFIG_HOME/ghostty/themes/Primer Dark"
    HERDR_CONFIG=${HERDR_CONFIG_PATH:-"$CONFIG_HOME/herdr/config.toml"}
    HERDR_DIR=$(dirname -- "$HERDR_CONFIG")
    HERDR_BACKUP="$HERDR_DIR/.primer-dark-theme-backup.toml"
    HERDR_STATE="$HERDR_DIR/.primer-dark-theme-state"
    PI_DEST="$PI_AGENT_DIR/themes/primer-dark.json"
    ZED_DEST="$CONFIG_HOME/zed/themes/primer-dark.json"
    FASTFETCH_DEST="$DATA_HOME/fastfetch/presets/primer-dark.jsonc"
    BAT_CONFIG_ROOT=${BAT_CONFIG_DIR:-"$CONFIG_HOME/bat"}
    BAT_THEME_DEST="$BAT_CONFIG_ROOT/themes/Primer Dark.tmTheme"
    BAT_CONFIG_FILE="$BAT_CONFIG_ROOT/config"
    BTOP_THEME_DEST="$CONFIG_HOME/btop/themes/primer-dark.theme"
    BTOP_CONFIG_FILE="$CONFIG_HOME/btop/btop.conf"
    FISH_THEME_DEST="$CONFIG_HOME/fish/themes/primer-dark.theme"
    GTK_THEME_SOURCE="$ROOT/gtk/primer-dark"
    GTK_THEME_DEST="$DATA_HOME/themes/primer-dark"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '%s\n' "$2" >&2
        exit 1
    fi
}

component_is_known() {
    case " $ALL_COMPONENTS " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

load_components() {
    for component in $COMPONENT_MODULES; do
        # shellcheck source=/dev/null
        . "$ROOT/scripts/components/$component.sh"
    done
}

run_component_hook() {
    hook=$1
    component=$2
    hook_name="${hook}_${component}"
    "$hook_name"
}
