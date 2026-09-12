#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_fastfetch() {
    :
}

install_fastfetch() {
    install -Dm644 "$ROOT/cli/fastfetch/primer-dark.jsonc" "$FASTFETCH_DEST"
    printf 'Installed the Fastfetch preset at %s\n' "$FASTFETCH_DEST"
    echo 'Run "fastfetch --config primer-dark" to use it.'
}

guard_fastfetch() {
    # Fastfetch has no persistent active-theme state; the preset is selected per
    # invocation with --config, so removing it cannot strand the application.
    :
}

uninstall_fastfetch() {
    rm -f -- "$FASTFETCH_DEST"
}

check_fastfetch() {
    jq -e . "$ROOT/cli/fastfetch/primer-dark.jsonc" >/dev/null
}
