#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_godot() {
    :
}

install_godot() {
    install -Dm644 "$ROOT/creative/godot/PrimerDark.tet" "$GODOT_THEME_DEST"
    printf 'Installed the Godot text editor theme at %s\n' "$GODOT_THEME_DEST"
    echo 'Select "PrimerDark" in Editor Settings > Text Editor > Theme > Color Theme.'
}

guard_godot() {
    [ -f "$GODOT_THEME_DEST" ] || return 0

    for settings_file in "$GODOT_CONFIG_ROOT"/editor_settings-*.tres; do
        [ -f "$settings_file" ] || continue
        if grep -Eq '^text_editor/theme/color_theme[[:space:]]*=[[:space:]]*"PrimerDark"' "$settings_file"; then
            cat >&2 <<EOF2
The Primer Dark Godot text editor theme is selected in $settings_file. Select another color theme before uninstalling it.
No files were removed.
EOF2
            exit 1
        fi
    done
}

uninstall_godot() {
    rm -f -- "$GODOT_THEME_DEST"
}

check_godot() {
    # Godot loads a .tet file as a ConfigFile and accepts only HTML colors in
    # the [color_theme] section.
    awk '
        /^[[:space:]]*(;|$)/ { next }
        /^\[color_theme\]$/ { section = 1; next }
        section && /^[a-z_\/]+_color="[0-9a-f]{6}([0-9a-f]{2})?"$/ { next }
        { printf "%s:%d: unexpected line: %s\n", FILENAME, FNR, $0 > "/dev/stderr"; bad = 1 }
        END { if (!section) { print "missing [color_theme] section" > "/dev/stderr"; bad = 1 } exit bad }
    ' "$ROOT/creative/godot/PrimerDark.tet"
}
