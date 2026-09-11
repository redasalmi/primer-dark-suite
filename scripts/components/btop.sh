#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_btop() {
    :
}

install_btop() {
    install -Dm644 "$ROOT/cli/btop/primer-dark.theme" "$BTOP_THEME_DEST"
    printf 'Installed the btop theme at %s\n' "$BTOP_THEME_DEST"
    echo 'Select "primer-dark" in btop options, or set color_theme = "primer-dark" in btop.conf.'
}

guard_btop() {
    if [ ! -f "$BTOP_THEME_DEST" ] || [ ! -f "$BTOP_CONFIG_FILE" ]; then
        return
    fi

    # btop saves the full path when a theme is selected through its menu.
    active_btop_theme=$(awk '
        /^[[:space:]]*color_theme[[:space:]]*=/ {
            value = $0
            sub(/^[^=]*=[[:space:]]*/, "", value)
            if (sub(/^"/, "", value)) sub(/".*/, "", value)
            else sub(/[[:space:]].*/, "", value)
            theme = value
        }
        END { print theme }
    ' "$BTOP_CONFIG_FILE") || {
        echo 'Cannot read the btop configuration safely; no files were removed.' >&2
        exit 1
    }
    case "$active_btop_theme" in
        primer-dark|primer-dark.theme|"$BTOP_THEME_DEST")
            cat >&2 <<'EOF'
The Primer Dark btop theme is currently active. Select another btop theme before uninstalling it.
No files were removed.
EOF
            exit 1
            ;;
    esac
}

uninstall_btop() {
    rm -f -- "$BTOP_THEME_DEST"
}

package_btop() {
    tar -C "$ROOT/cli/btop" -czf "$DIST/Primer-Dark-Btop.tar.gz" primer-dark.theme
    register_artifact Primer-Dark-Btop.tar.gz
}
