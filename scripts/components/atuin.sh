#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_atuin() {
    :
}

install_atuin() {
    install -Dm644 "$ROOT/cli/atuin/primer-dark.toml" "$ATUIN_THEME_DEST"
    printf 'Installed the Atuin theme at %s\n' "$ATUIN_THEME_DEST"
    echo 'Set name = "primer-dark" in the [theme] table of Atuin'"'"'s config.toml to use it.'
}

guard_atuin() {
    [ -f "$ATUIN_THEME_DEST" ] || return 0

    # Atuin reads the theme name from the [theme] table of config.toml.
    if toml_table_key_is "$ATUIN_CONFIG_ROOT/config.toml" theme name primer-dark; then
        cat >&2 <<'EOF2'
The Primer Dark Atuin theme is currently active. Select another Atuin theme before uninstalling it.
No files were removed.
EOF2
        exit 1
    fi
}

uninstall_atuin() {
    rm -f -- "$ATUIN_THEME_DEST"
}

check_atuin() {
    # Atuin rejects the whole theme when [colors] names an unknown meaning, so
    # only the meanings defined by Atuin 18.x are accepted.
    awk '
        BEGIN {
            split("AlertInfo AlertWarn AlertError Annotation Base Guidance Important Title Muted", names, " ")
            for (i in names) known[names[i]] = 1
        }
        /^[[:space:]]*(#|$)/ { next }
        /^\[/ { section = $0; next }
        section == "[theme]" && /^name = "primer-dark"$/ { named = 1; next }
        section == "[colors]" && /^[A-Za-z]+ = "#[0-9A-Fa-f]{6}"$/ {
            if (!($1 in known)) { printf "%s:%d: unknown Atuin meaning %s\n", FILENAME, FNR, $1 > "/dev/stderr"; bad = 1 }
            next
        }
        { printf "%s:%d: unexpected line: %s\n", FILENAME, FNR, $0 > "/dev/stderr"; bad = 1 }
        END { if (!named) { print "missing [theme] name = \"primer-dark\"" > "/dev/stderr"; bad = 1 } exit bad }
    ' "$ROOT/cli/atuin/primer-dark.toml"
}
