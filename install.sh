#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PACKAGE_ID=io.github.redasalmi.primerdark.desktop
AURORAE_ID=PrimerDark
COLOR_FILE=PrimerDark.colors
DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
APPLY=0

usage() {
    cat <<'EOF'
Usage: ./install.sh [--apply]

Install Primer Dark into the current user's XDG data directory.
The theme is not applied unless --apply is provided.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
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
GLOBAL_SOURCE="$ROOT/kde/look-and-feel/$PACKAGE_ID"

install -Dm644 "$ROOT/kde/colors/$COLOR_FILE" "$COLOR_DEST"
rm -rf -- "$AURORAE_DEST"
mkdir -p -- "$AURORAE_DEST"
cp -R -- "$ROOT/kde/aurorae/$AURORAE_ID/." "$AURORAE_DEST/"

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

printf 'Installed Primer Dark in %s\n' "$DATA_HOME"

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
