#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_fish() {
    :
}

install_fish() {
    install -Dm644 "$ROOT/cli/fish/primer-dark.theme" "$FISH_THEME_DEST"
    printf 'Installed the fish theme at %s\n' "$FISH_THEME_DEST"
    echo 'Preview it with "fish_config theme choose primer-dark", then persist it with "fish_config theme save primer-dark".'
}

guard_fish() {
    # Choosing loads colors for the current session; saving persists them in
    # universal variables. Neither needs the theme file after loading it.
    :
}

uninstall_fish() {
    rm -f -- "$FISH_THEME_DEST"
}

package_fish() {
    tar -C "$ROOT/cli/fish" -czf "$DIST/Primer-Dark-Fish.tar.gz" primer-dark.theme
    register_artifact Primer-Dark-Fish.tar.gz
}
