#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_pi() {
    :
}

install_pi() {
    install -Dm644 "$ROOT/cli/pi/primer-dark.json" "$PI_DEST"
    printf 'Installed the Pi theme at %s\n' "$PI_DEST"
    echo 'Select "Primer Dark" in Pi /settings to use it.'
}

guard_pi() {
    if [ -f "$PI_DEST" ] && [ -f "$PI_AGENT_DIR/settings.json" ] \
        && grep -Eq '"theme"[[:space:]]*:[[:space:]]*"[^"]*Primer Dark[^"]*"' "$PI_AGENT_DIR/settings.json"; then
        cat >&2 <<'EOF'
The Primer Dark Pi theme is currently active. Select another Pi theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_pi() {
    rm -f -- "$PI_DEST"
}

package_pi() {
    jq -e . "$ROOT/cli/pi/primer-dark.json" >/dev/null
    cp "$ROOT/cli/pi/primer-dark.json" "$DIST/Primer-Dark-Pi.json"
    register_artifact Primer-Dark-Pi.json
}
