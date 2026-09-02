#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PACKAGE_ID=io.github.redasalmi.primerdark.desktop
AURORAE_ID=PrimerDark
PLASMA_STYLE_ID=PrimerDark
COLOR_FILE=PrimerDark.colors
DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
PI_AGENT_DIR=${PI_CODING_AGENT_DIR:-"$HOME/.pi/agent"}
APPLY=0
INSTALL_KONSOLE=0
INSTALL_GHOSTTY=0
INSTALL_HERDR=0
INSTALL_PI=0
INSTALL_ZED=0

usage() {
    cat <<'EOF'
Usage: ./install.sh [--apply] [--konsole] [--ghostty] [--herdr] [--pi] [--zed]

Install the Primer Dark KDE theme into the current user's XDG data directory.
The KDE theme is not applied unless --apply is provided.
Use --konsole, --ghostty, --herdr, --pi, or --zed to additionally install those application themes.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --konsole) INSTALL_KONSOLE=1 ;;
        --ghostty) INSTALL_GHOSTTY=1 ;;
        --herdr) INSTALL_HERDR=1 ;;
        --pi) INSTALL_PI=1 ;;
        --zed) INSTALL_ZED=1 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

command -v kpackagetool6 >/dev/null 2>&1 || {
    echo "kpackagetool6 is required (KDE Frameworks 6)." >&2
    exit 1
}

COLOR_DEST="$DATA_HOME/color-schemes/$COLOR_FILE"
AURORAE_DEST="$DATA_HOME/aurorae/themes/$AURORAE_ID"
PLASMA_STYLE_SOURCE="$ROOT/kde/plasma-style/$PLASMA_STYLE_ID"
PLASMA_STYLE_DEST="$DATA_HOME/plasma/desktoptheme/$PLASMA_STYLE_ID"
GLOBAL_SOURCE="$ROOT/kde/look-and-feel/$PACKAGE_ID"

install -Dm644 "$ROOT/kde/colors/$COLOR_FILE" "$COLOR_DEST"
rm -rf -- "$AURORAE_DEST" "$PLASMA_STYLE_DEST"
mkdir -p -- "$AURORAE_DEST" "$PLASMA_STYLE_DEST"
cp -R -- "$ROOT/kde/aurorae/$AURORAE_ID/." "$AURORAE_DEST/"
cp -R -- "$PLASMA_STYLE_SOURCE/." "$PLASMA_STYLE_DEST/"

GLOBAL_ROOT="$DATA_HOME/plasma/look-and-feel"
GLOBAL_DEST="$GLOBAL_ROOT/$PACKAGE_ID"
if [ -d "$GLOBAL_DEST" ]; then
    if kpackagetool6 -t Plasma/LookAndFeel -p "$GLOBAL_ROOT" -s "$PACKAGE_ID" >/dev/null 2>&1; then
        kpackagetool6 -t Plasma/LookAndFeel -u "$GLOBAL_SOURCE"
    else
        rm -rf -- "$GLOBAL_DEST"
        kpackagetool6 -t Plasma/LookAndFeel -i "$GLOBAL_SOURCE"
    fi
else
    kpackagetool6 -t Plasma/LookAndFeel -i "$GLOBAL_SOURCE"
fi

printf 'Installed the Primer Dark KDE theme and Plasma style in %s\n' "$DATA_HOME"

if [ "$INSTALL_KONSOLE" -eq 1 ]; then
    KONSOLE_DIR="$DATA_HOME/konsole"
    KONSOLE_SCHEME_DEST="$KONSOLE_DIR/PrimerDark.colorscheme"
    KONSOLE_PROFILE_DEST="$KONSOLE_DIR/PrimerDark.profile"
    install -Dm644 "$ROOT/kde/konsole/PrimerDark.colorscheme" "$KONSOLE_SCHEME_DEST"
    install -Dm644 "$ROOT/kde/konsole/PrimerDark.profile" "$KONSOLE_PROFILE_DEST"
    printf 'Installed the Konsole color scheme at %s\n' "$KONSOLE_SCHEME_DEST"
    printf 'Installed the optional color-only Konsole profile at %s\n' "$KONSOLE_PROFILE_DEST"
    echo 'Select "Primer Dark" in a Konsole profile or switch to the optional "Primer Dark" profile.'
fi

if [ "$INSTALL_GHOSTTY" -eq 1 ]; then
    GHOSTTY_DEST="$CONFIG_HOME/ghostty/themes/Primer Dark"
    install -Dm644 "$ROOT/terminals/ghostty/Primer Dark" "$GHOSTTY_DEST"
    printf 'Installed the Ghostty theme at %s\n' "$GHOSTTY_DEST"
    echo 'Set "theme = Primer Dark" in your Ghostty configuration to use it.'
fi

if [ "$INSTALL_HERDR" -eq 1 ]; then
    command -v herdr >/dev/null 2>&1 || {
        echo "herdr is required to install and validate the Herdr theme." >&2
        exit 1
    }

    HERDR_CONFIG=${HERDR_CONFIG_PATH:-"$CONFIG_HOME/herdr/config.toml"}
    HERDR_DIR=$(dirname -- "$HERDR_CONFIG")
    HERDR_BACKUP="$HERDR_DIR/.primer-dark-theme-backup.toml"
    HERDR_STATE="$HERDR_DIR/.primer-dark-theme-state"
    HERDR_BEGIN='# BEGIN Primer Dark Herdr theme (managed by primer-dark-suite)'
    HERDR_END='# END Primer Dark Herdr theme (managed by primer-dark-suite)'
    mkdir -p -- "$HERDR_DIR"

    BEGIN_COUNT=0
    END_COUNT=0
    if [ -f "$HERDR_CONFIG" ]; then
        BEGIN_COUNT=$(grep -Fxc "$HERDR_BEGIN" "$HERDR_CONFIG" || true)
        END_COUNT=$(grep -Fxc "$HERDR_END" "$HERDR_CONFIG" || true)
    fi
    if { [ "$BEGIN_COUNT" -ne 0 ] || [ "$END_COUNT" -ne 0 ]; } \
        && { [ "$BEGIN_COUNT" -ne 1 ] || [ "$END_COUNT" -ne 1 ]; }; then
        echo "Cannot update the Herdr theme because its managed markers are incomplete or duplicated: $HERDR_CONFIG" >&2
        exit 1
    fi

    HERDR_CONFIG_TMP=$(mktemp "$HERDR_DIR/.primer-dark-config.XXXXXX")
    HERDR_NEW_STATE=0
    if [ "$BEGIN_COUNT" -eq 1 ]; then
        if [ ! -f "$HERDR_BACKUP" ] || [ ! -f "$HERDR_STATE" ]; then
            rm -f -- "$HERDR_CONFIG_TMP"
            echo "Cannot update the managed Herdr theme because its restore state is missing from $HERDR_DIR" >&2
            exit 1
        fi
        awk -v begin="$HERDR_BEGIN" -v end="$HERDR_END" '
            $0 == begin { managed = 1; next }
            $0 == end { managed = 0; next }
            !managed { print }
        ' "$HERDR_CONFIG" > "$HERDR_CONFIG_TMP"
    else
        if [ -e "$HERDR_BACKUP" ] || [ -e "$HERDR_STATE" ]; then
            rm -f -- "$HERDR_CONFIG_TMP"
            echo "Cannot install the Herdr theme because stale restore state exists in $HERDR_DIR" >&2
            exit 1
        fi
        HERDR_BACKUP_TMP=$(mktemp "$HERDR_DIR/.primer-dark-backup.XXXXXX")
        HERDR_STATE_TMP=$(mktemp "$HERDR_DIR/.primer-dark-state.XXXXXX")
        HERDR_NEW_STATE=1
        if [ -f "$HERDR_CONFIG" ]; then
            printf 'existing\n' > "$HERDR_STATE_TMP"
            awk -v backup="$HERDR_BACKUP_TMP" -v config="$HERDR_CONFIG_TMP" '
                function theme_header(line, value) {
                    value = line
                    sub(/^[[:space:]]*/, "", value)
                    sub(/[[:space:]]*(#.*)?$/, "", value)
                    return value ~ /^\[theme(\.[A-Za-z0-9_-]+)*\]$/
                }
                function table_header(line, value) {
                    value = line
                    sub(/^[[:space:]]*/, "", value)
                    sub(/[[:space:]]*(#.*)?$/, "", value)
                    return value ~ /^\[\[?[^]]+\]\]?$/
                }
                {
                    is_theme_header = theme_header($0)
                    if (is_theme_header) {
                        theme = 1
                    } else if (table_header($0)) {
                        theme = 0
                    }
                    if (theme) {
                        print > backup
                    } else {
                        print > config
                    }
                }
            ' "$HERDR_CONFIG"
        else
            printf 'created\n' > "$HERDR_STATE_TMP"
        fi
    fi

    if [ -s "$HERDR_CONFIG_TMP" ]; then
        printf '\n' >> "$HERDR_CONFIG_TMP"
    fi
    printf '%s\n' "$HERDR_BEGIN" >> "$HERDR_CONFIG_TMP"
    cat "$ROOT/cli/herdr/primer-dark.toml" >> "$HERDR_CONFIG_TMP"
    printf '%s\n' "$HERDR_END" >> "$HERDR_CONFIG_TMP"

    if ! HERDR_CONFIG_PATH="$HERDR_CONFIG_TMP" herdr config check; then
        rm -f -- "$HERDR_CONFIG_TMP"
        if [ "$HERDR_NEW_STATE" -eq 1 ]; then
            rm -f -- "$HERDR_BACKUP_TMP" "$HERDR_STATE_TMP"
        fi
        echo "Herdr rejected the merged Primer Dark configuration; the existing configuration was not changed." >&2
        exit 1
    fi

    if [ "$HERDR_NEW_STATE" -eq 1 ]; then
        mv -- "$HERDR_BACKUP_TMP" "$HERDR_BACKUP"
        mv -- "$HERDR_STATE_TMP" "$HERDR_STATE"
    fi
    mv -- "$HERDR_CONFIG_TMP" "$HERDR_CONFIG"
    printf 'Installed and enabled the Herdr theme in %s\n' "$HERDR_CONFIG"
    echo 'Run "herdr server reload-config" to update a running Herdr session.'
fi

if [ "$INSTALL_PI" -eq 1 ]; then
    PI_DEST="$PI_AGENT_DIR/themes/primer-dark.json"
    install -Dm644 "$ROOT/cli/pi/primer-dark.json" "$PI_DEST"
    printf 'Installed the Pi theme at %s\n' "$PI_DEST"
    echo 'Select "Primer Dark" in Pi /settings to use it.'
fi

if [ "$INSTALL_ZED" -eq 1 ]; then
    ZED_DEST="$CONFIG_HOME/zed/themes/primer-dark.json"
    install -Dm644 "$ROOT/editors/zed/primer-dark.json" "$ZED_DEST"
    printf 'Installed the Zed theme at %s\n' "$ZED_DEST"
    echo 'Select "Primer Dark" in the Zed theme selector to use it.'
fi

if [ "$APPLY" -eq 1 ]; then
    command -v plasma-apply-lookandfeel >/dev/null 2>&1 || {
        echo "plasma-apply-lookandfeel is required to apply the theme." >&2
        exit 1
    }
    plasma-apply-lookandfeel -a "$PACKAGE_ID"
    echo "Applied Primer Dark. Log out and back in if the cursor or decoration does not refresh immediately."
else
    echo "Open System Settings → Colors & Themes → Global Theme, or rerun with --apply."
fi
