#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_kde() {
    require_command kpackagetool6 "kpackagetool6 is required (KDE Frameworks 6)."
}

install_kde() {
    install -Dm644 "$ROOT/kde/colors/$COLOR_FILE" "$COLOR_DEST"
    rm -rf -- "$AURORAE_DEST" "$PLASMA_STYLE_DEST"
    mkdir -p -- "$AURORAE_DEST" "$PLASMA_STYLE_DEST"
    cp -R -- "$ROOT/kde/aurorae/$AURORAE_ID/." "$AURORAE_DEST/"
    cp -R -- "$PLASMA_STYLE_SOURCE/." "$PLASMA_STYLE_DEST/"

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
}

guard_kde() {
    if command -v kreadconfig6 >/dev/null 2>&1; then
        active=$(kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage 2>/dev/null || true)
        if [ "$active" = "$PACKAGE_ID" ]; then
            cat >&2 <<'EOF'
Primer Dark is currently active. Apply another Global Theme before uninstalling it.
No files were removed.
EOF
            exit 1
        fi

        active_plasma_style=$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null || true)
        if [ "$active_plasma_style" = "$PLASMA_STYLE_ID" ]; then
            cat >&2 <<'EOF'
The Primer Dark Plasma style is currently active. Apply another Plasma style before uninstalling it.
No files were removed.
EOF
            exit 1
        fi
    fi
}

uninstall_kde() {
    if command -v kpackagetool6 >/dev/null 2>&1 && [ -d "$GLOBAL_DEST" ]; then
        kpackagetool6 -t Plasma/LookAndFeel -r "$PACKAGE_ID" || rm -rf -- "$GLOBAL_DEST"
    else
        rm -rf -- "$GLOBAL_DEST"
    fi

    rm -f -- "$COLOR_DEST"
    rm -rf -- "$AURORAE_DEST" "$PLASMA_STYLE_DEST"
}

check_kde() {
    jq -e . "$ROOT/kde/look-and-feel/$PACKAGE_ID/metadata.json" >/dev/null
    jq -e . "$ROOT/kde/aurorae/$AURORAE_ID/metadata.json" >/dev/null
    jq -e . "$ROOT/kde/plasma-style/$PLASMA_STYLE_ID/metadata.json" >/dev/null
    find "$ROOT/kde/aurorae/$AURORAE_ID" -maxdepth 1 -name '*.svg' -exec xmllint --noout {} +
    find "$ROOT/kde/plasma-style/$PLASMA_STYLE_ID" -name '*.svg' -exec xmllint --noout {} +

    if find "$GLOBAL_SOURCE" -type l -print -quit | grep -q .; then
        echo "Global theme packages cannot contain symlinks." >&2
        exit 1
    fi
}
