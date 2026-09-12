#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_cursor() {
    :
}

install_cursor() {
    # Cursor scans its extensions directory for installed extensions, so
    # replace any previous version of this owned extension instead of leaving
    # a stale duplicate beside it.
    for existing in "$CURSOR_EXT_ROOT"/"$CURSOR_EXT_ID"-*; do
        [ -d "$existing" ] || continue
        rm -rf -- "$existing"
    done
    mkdir -p -- "$CURSOR_EXT_DEST"
    cp -R -- "$CURSOR_EXT_SOURCE/." "$CURSOR_EXT_DEST/"
    printf 'Installed the Cursor theme extension at %s\n' "$CURSOR_EXT_DEST"
    echo 'Restart Cursor, then select "Primer Dark" in Preferences: Theme: Color Theme.'
}

cursor_settings_uses_primer_dark() {
    settings_file=$1
    [ -f "$settings_file" ] || return 1
    grep -Eq '"workbench\.colorTheme"[[:space:]]*:[[:space:]]*"Primer Dark"' "$settings_file"
}

guard_cursor() {
    [ -d "$CURSOR_EXT_DEST" ] || return 0

    active_cursor_theme=0
    if cursor_settings_uses_primer_dark "$CURSOR_SETTINGS_FILE"; then
        active_cursor_theme=1
    fi
    # Cursor profiles keep their own settings file, so a theme selected inside
    # a non-default profile is active state too.
    for profile_settings in "$CONFIG_HOME/Cursor/User/profiles"/*/settings.json; do
        if cursor_settings_uses_primer_dark "$profile_settings"; then
            active_cursor_theme=1
        fi
    done
    if [ "$active_cursor_theme" -eq 1 ]; then
        cat >&2 <<'EOF'
The Primer Dark Cursor theme is currently active. Select another color theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_cursor() {
    for existing in "$CURSOR_EXT_ROOT"/"$CURSOR_EXT_ID"-*; do
        [ -d "$existing" ] || continue
        rm -rf -- "$existing"
    done
}

check_cursor() {
    jq -e . "$CURSOR_EXT_SOURCE/package.json" >/dev/null

    theme_path=$(jq -r '.contributes.themes[] | select(.label == "Primer Dark" and .uiTheme == "vs-dark") | .path' "$CURSOR_EXT_SOURCE/package.json")
    theme_file="$CURSOR_EXT_SOURCE/${theme_path#./}"
    if [ -z "$theme_path" ] || [ ! -f "$theme_file" ]; then
        printf 'The Cursor extension does not declare a readable dark theme path: %s\n' "${theme_path:-none}" >&2
        exit 1
    fi

    jq -e '.name == "Primer Dark" and .type == "dark"' "$theme_file" >/dev/null
}
