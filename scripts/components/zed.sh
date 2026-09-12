#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_zed() {
    :
}

install_zed() {
    install -Dm644 "$ROOT/editors/zed/primer-dark.json" "$ZED_DEST"
    printf 'Installed the Zed theme at %s\n' "$ZED_DEST"
    echo 'Select "Primer Dark" in the Zed theme selector to use it.'
}

guard_zed() {
    if [ -f "$ZED_DEST" ] && [ -f "$CONFIG_HOME/zed/settings.json" ] \
        && grep -Fq '"Primer Dark"' "$CONFIG_HOME/zed/settings.json"; then
        cat >&2 <<'EOF'
The Primer Dark Zed theme is currently active. Select another Zed theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_zed() {
    rm -f -- "$ZED_DEST"
}

check_zed() {
    jq -e . "$ROOT/editors/zed/primer-dark.json" >/dev/null
}
