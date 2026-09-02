#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_ghostty() {
    :
}

install_ghostty() {
    install -Dm644 "$ROOT/terminals/ghostty/Primer Dark" "$GHOSTTY_DEST"
    printf 'Installed the Ghostty theme at %s\n' "$GHOSTTY_DEST"
    echo 'Set "theme = Primer Dark" in your Ghostty configuration to use it.'
}

guard_ghostty() {
    if [ -f "$GHOSTTY_DEST" ] && command -v ghostty >/dev/null 2>&1; then
        active_ghostty=$(ghostty +show-config 2>/dev/null | grep '^theme = ' || true)
        case "$active_ghostty" in
            *"Primer Dark"*)
                cat >&2 <<'EOF'
The Primer Dark Ghostty theme is currently active. Select another Ghostty theme before uninstalling it.
No files were removed.
EOF
                exit 1
                ;;
        esac
    fi
}

uninstall_ghostty() {
    rm -f -- "$GHOSTTY_DEST"
}

package_ghostty() {
    tar -C "$ROOT/terminals/ghostty" -czf "$DIST/Primer-Dark-Ghostty.tar.gz" "Primer Dark"
    register_artifact Primer-Dark-Ghostty.tar.gz
}
