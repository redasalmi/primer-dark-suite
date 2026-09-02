#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

PACKAGE_ID=io.github.redasalmi.primerdark.desktop
PLASMA_STYLE_ID=PrimerDark
DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
PI_AGENT_DIR=${PI_CODING_AGENT_DIR:-"$HOME/.pi/agent"}
KONSOLE_SCHEME_DEST="$DATA_HOME/konsole/PrimerDark.colorscheme"
KONSOLE_PROFILE_DEST="$DATA_HOME/konsole/PrimerDark.profile"
GHOSTTY_DEST="$CONFIG_HOME/ghostty/themes/Primer Dark"
PI_DEST="$PI_AGENT_DIR/themes/primer-dark.json"
ZED_DEST="$CONFIG_HOME/zed/themes/primer-dark.json"
PLASMA_STYLE_DEST="$DATA_HOME/plasma/desktoptheme/$PLASMA_STYLE_ID"

if command -v kreadconfig6 >/dev/null 2>&1; then
    ACTIVE=$(kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage 2>/dev/null || true)
    if [ "$ACTIVE" = "$PACKAGE_ID" ]; then
        cat >&2 <<'EOF'
Primer Dark is currently active. Apply another Global Theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
fi

if command -v kreadconfig6 >/dev/null 2>&1; then
    ACTIVE_PLASMA_STYLE=$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)
    if [ "$ACTIVE_PLASMA_STYLE" = "$PLASMA_STYLE_ID" ]; then
        cat >&2 <<'EOF'
The Primer Dark Plasma style is currently active. Apply another Plasma style before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
fi

if [ -f "$KONSOLE_SCHEME_DEST" ]; then
    ACTIVE_KONSOLE_PROFILE=""
    if command -v kreadconfig6 >/dev/null 2>&1; then
        ACTIVE_KONSOLE_PROFILE=$(kreadconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile 2>/dev/null || true)
    fi
    if [ "$ACTIVE_KONSOLE_PROFILE" = "PrimerDark.profile" ]; then
        cat >&2 <<'EOF'
The Primer Dark Konsole profile is currently the default. Select another default profile before uninstalling it.
No files were removed.
EOF
        exit 1
    fi

    for PROFILE in "$DATA_HOME"/konsole/*.profile; do
        [ -f "$PROFILE" ] || continue
        [ "$PROFILE" = "$KONSOLE_PROFILE_DEST" ] && continue
        if grep -Eq '^[[:space:]]*ColorScheme[[:space:]]*=[[:space:]]*PrimerDark[[:space:]]*$' "$PROFILE"; then
            cat >&2 <<EOF
A Konsole profile still references Primer Dark: $PROFILE
Select another color scheme for that profile before uninstalling Primer Dark.
No files were removed.
EOF
            exit 1
        fi
    done
fi

if [ -f "$GHOSTTY_DEST" ] && command -v ghostty >/dev/null 2>&1; then
    ACTIVE_GHOSTTY=$(ghostty +show-config 2>/dev/null | grep '^theme = ' || true)
    case "$ACTIVE_GHOSTTY" in
        *"Primer Dark"*)
            cat >&2 <<'EOF'
The Primer Dark Ghostty theme is currently active. Select another Ghostty theme before uninstalling it.
No files were removed.
EOF
            exit 1
            ;;
    esac
fi

if [ -f "$PI_DEST" ] && [ -f "$PI_AGENT_DIR/settings.json" ] \
    && grep -Eq '"theme"[[:space:]]*:[[:space:]]*"[^"]*Primer Dark[^"]*"' "$PI_AGENT_DIR/settings.json"; then
    cat >&2 <<'EOF'
The Primer Dark Pi theme is currently active. Select another Pi theme before uninstalling it.
No files were removed.
EOF
    exit 1
fi

if [ -f "$ZED_DEST" ] && [ -f "$CONFIG_HOME/zed/settings.json" ] \
    && grep -Fq '"Primer Dark"' "$CONFIG_HOME/zed/settings.json"; then
    cat >&2 <<'EOF'
The Primer Dark Zed theme is currently active. Select another Zed theme before uninstalling it.
No files were removed.
EOF
    exit 1
fi

GLOBAL_DEST="$DATA_HOME/plasma/look-and-feel/$PACKAGE_ID"
if command -v kpackagetool6 >/dev/null 2>&1 && [ -d "$GLOBAL_DEST" ]; then
    kpackagetool6 -t Plasma/LookAndFeel -r "$PACKAGE_ID" || rm -rf -- "$GLOBAL_DEST"
else
    rm -rf -- "$GLOBAL_DEST"
fi

rm -f -- "$DATA_HOME/color-schemes/PrimerDark.colors"
rm -rf -- "$DATA_HOME/aurorae/themes/PrimerDark"
rm -rf -- "$PLASMA_STYLE_DEST"
rm -f -- "$KONSOLE_SCHEME_DEST"
rm -f -- "$KONSOLE_PROFILE_DEST"
rm -f -- "$GHOSTTY_DEST"
rm -f -- "$PI_DEST"
rm -f -- "$ZED_DEST"
echo "Uninstalled Primer Dark."
