#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_ktexteditor() {
    :
}

install_ktexteditor() {
    install -Dm644 "$ROOT/kde/ktexteditor/primer-dark.theme" "$KTEXTEDITOR_THEME_DEST"
    printf 'Installed the KWrite/Kate editor color theme at %s\n' "$KTEXTEDITOR_THEME_DEST"
    echo 'Restart KWrite or Kate, then select "Primer Dark" in Settings > Configure > Appearance > Color Themes.'
}

ktexteditor_config_uses_primer_dark() {
    config_file=$1
    [ -f "$config_file" ] || return 1
    grep -Eq '^[[:space:]]*Color Theme[[:space:]]*=[[:space:]]*Primer Dark[[:space:]]*$' "$config_file"
}

guard_ktexteditor() {
    [ -f "$KTEXTEDITOR_THEME_DEST" ] || return 0

    # KTextEditor stores the selected theme per application in the [KTextEditor
    # Renderer] group of that application's rc file.
    for config_file in "$CONFIG_HOME/kwriterc" "$CONFIG_HOME/katerc" "$CONFIG_HOME/kdeveloprc"; do
        if ktexteditor_config_uses_primer_dark "$config_file"; then
            cat >&2 <<EOF2
The Primer Dark editor color theme is selected in $config_file. Select another color theme before uninstalling it.
No files were removed.
EOF2
            exit 1
        fi
    done
}

uninstall_ktexteditor() {
    rm -f -- "$KTEXTEDITOR_THEME_DEST"
}

check_ktexteditor() {
    jq -e '
        .metadata.name == "Primer Dark"
        and (.["text-styles"] | type == "object" and has("Normal"))
        and (.["editor-colors"] | has("BackgroundColor") and has("TextSelection"))
    ' "$ROOT/kde/ktexteditor/primer-dark.theme" >/dev/null
}
