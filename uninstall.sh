#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

PACKAGE_ID=io.github.redasalmi.primerdark.desktop
DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}

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

GLOBAL_DEST="$DATA_HOME/plasma/look-and-feel/$PACKAGE_ID"
if command -v kpackagetool6 >/dev/null 2>&1 && [ -d "$GLOBAL_DEST" ]; then
    kpackagetool6 -t Plasma/LookAndFeel -r "$PACKAGE_ID" || rm -rf -- "$GLOBAL_DEST"
else
    rm -rf -- "$GLOBAL_DEST"
fi

rm -f -- "$DATA_HOME/color-schemes/PrimerDark.colors"
rm -rf -- "$DATA_HOME/aurorae/themes/PrimerDark"
echo "Uninstalled Primer Dark."
