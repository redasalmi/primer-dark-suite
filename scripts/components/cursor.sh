#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

CURSOR_VSIX_TMP=""
CURSOR_VSIX=""

cleanup_cursor_temps() {
    [ -z "$CURSOR_VSIX_TMP" ] || rm -rf -- "$CURSOR_VSIX_TMP"
    CURSOR_VSIX_TMP=""
}

preflight_cursor() {
    # Cursor only adopts extension directories it did not install itself while
    # it is creating a new extensions.json. Once that file exists, a copied
    # directory is ignored, so the extension must then be packaged as a VSIX
    # and installed through Cursor's own command line, which records it there.
    CURSOR_VSIX=""
    if ! command -v cursor >/dev/null 2>&1; then
        if [ -e "$CURSOR_EXT_ROOT/extensions.json" ]; then
            cat >&2 <<'EOF'
The cursor command-line launcher is required to register the Cursor theme extension,
because Cursor ignores copied extensions once extensions.json exists. Run
"Shell Command: Install 'cursor' command" from the Cursor command palette, then retry.
EOF
            exit 1
        fi
        return 0
    fi

    # Package the VSIX before any component is installed, so a packaging
    # failure cannot leave a partial installation.
    require_command python3 "python3 is required to package the Cursor theme extension."
    CURSOR_VSIX_TMP=$(mktemp -d)
    CURSOR_VSIX="$CURSOR_VSIX_TMP/$CURSOR_EXT_ID-$CURSOR_EXT_VERSION.vsix"
    python3 - "$CURSOR_VSIX" "$CURSOR_EXT_SOURCE" <<'PY'
import os
import sys
import zipfile

target, source = sys.argv[1:]
with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
    for directory, _, files in os.walk(source):
        for name in sorted(files):
            path = os.path.join(directory, name)
            archive.write(path, "extension/" + os.path.relpath(path, source))
PY
}

install_cursor() {
    if [ -z "$CURSOR_VSIX" ]; then
        # No extensions.json exists yet, so Cursor adopts a copied directory
        # when it creates one. Replace any previous version of this extension
        # instead of leaving a stale duplicate beside it.
        for existing in "$CURSOR_EXT_ROOT"/"$CURSOR_EXT_ID"-*; do
            [ -d "$existing" ] || continue
            rm -rf -- "$existing"
        done
        mkdir -p -- "$CURSOR_EXT_DEST"
        cp -R -- "$CURSOR_EXT_SOURCE/." "$CURSOR_EXT_DEST/"
    elif ! cursor --extensions-dir "$CURSOR_EXT_ROOT" --install-extension "$CURSOR_VSIX" --force >"$CURSOR_VSIX_TMP/install.log" 2>&1; then
        echo "Cursor could not install the Primer Dark theme extension:" >&2
        cat -- "$CURSOR_VSIX_TMP/install.log" >&2
        exit 1
    fi
    printf 'Installed the Cursor theme extension at %s\n' "$CURSOR_EXT_DEST"
    echo 'Reload Cursor, then select "Primer Dark" in Preferences: Theme: Color Theme.'
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
    if command -v cursor >/dev/null 2>&1 && ls -d -- "$CURSOR_EXT_ROOT"/"$CURSOR_EXT_ID"-* >/dev/null 2>&1; then
        cursor --extensions-dir "$CURSOR_EXT_ROOT" --uninstall-extension "$CURSOR_EXT_ID" >/dev/null 2>&1 || true
    fi
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

    # The installed directory name is built from CURSOR_EXT_VERSION, so it
    # must match the version Cursor reads from package.json.
    package_version=$(jq -r '.version' "$CURSOR_EXT_SOURCE/package.json")
    if [ "$package_version" != "$CURSOR_EXT_VERSION" ]; then
        printf 'The Cursor package.json version %s does not match CURSOR_EXT_VERSION %s.\n' "$package_version" "$CURSOR_EXT_VERSION" >&2
        exit 1
    fi
}
