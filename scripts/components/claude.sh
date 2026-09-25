#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_claude() {
    :
}

install_claude() {
    install -Dm644 "$ROOT/cli/claude/primer-dark.json" "$CLAUDE_THEME_DEST"
    printf 'Installed the Claude Code theme at %s\n' "$CLAUDE_THEME_DEST"
    echo 'Select "Primer Dark" with /theme in Claude Code.'
}

guard_claude() {
    [ -f "$CLAUDE_THEME_DEST" ] || return 0

    # Selecting a custom theme stores "custom:<slug>" as the theme preference,
    # either in the user settings or in the global configuration file.
    for config_file in "$CLAUDE_DIR/settings.json" "$CLAUDE_GLOBAL_CONFIG"; do
        [ -f "$config_file" ] || continue
        if grep -Eq '"theme"[[:space:]]*:[[:space:]]*"custom:primer-dark"' "$config_file"; then
            cat >&2 <<EOF2
The Primer Dark Claude Code theme is selected in $config_file. Select another theme with /theme before uninstalling it.
No files were removed.
EOF2
            exit 1
        fi
    done
}

uninstall_claude() {
    rm -f -- "$CLAUDE_THEME_DEST"
}

check_claude() {
    jq -e '
        .name == "Primer Dark" and .base == "dark"
        and (.overrides | type == "object" and length > 0)
        and ([.overrides[] | test("^#[0-9A-Fa-f]{6}$")] | all)
    ' "$ROOT/cli/claude/primer-dark.json" >/dev/null
}
