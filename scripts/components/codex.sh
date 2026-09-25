#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Codex highlights code with the same TextMate theme engine as bat, so it
# reuses the bat theme asset under the kebab-case name Codex expects.

preflight_codex() {
    :
}

install_codex() {
    install -Dm644 "$ROOT/cli/bat/Primer Dark.tmTheme" "$CODEX_THEME_DEST"
    printf 'Installed the Codex syntax theme at %s\n' "$CODEX_THEME_DEST"
    echo 'Select "primer-dark" with /theme in Codex, or set theme = "primer-dark" under [tui] in config.toml.'
}

guard_codex() {
    [ -f "$CODEX_THEME_DEST" ] || return 0

    if toml_table_key_is "$CODEX_DIR/config.toml" tui theme primer-dark; then
        cat >&2 <<'EOF2'
The Primer Dark Codex syntax theme is currently active. Select another theme with /theme before uninstalling it.
No files were removed.
EOF2
        exit 1
    fi
}

uninstall_codex() {
    rm -f -- "$CODEX_THEME_DEST"
}
