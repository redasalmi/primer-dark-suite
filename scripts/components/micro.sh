#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_micro() {
    :
}

install_micro() {
    install -Dm644 "$ROOT/cli/micro/primer-dark.micro" "$MICRO_THEME_DEST"
    printf 'Installed the micro colorscheme at %s\n' "$MICRO_THEME_DEST"
    echo 'Run "> set colorscheme primer-dark" in micro, or set "colorscheme": "primer-dark" in settings.json.'
}

guard_micro() {
    [ -f "$MICRO_THEME_DEST" ] || return 0

    if [ -f "$MICRO_CONFIG_ROOT/settings.json" ] \
        && grep -Eq '"colorscheme"[[:space:]]*:[[:space:]]*"primer-dark"' "$MICRO_CONFIG_ROOT/settings.json"; then
        cat >&2 <<'EOF2'
The Primer Dark micro colorscheme is currently active. Select another colorscheme before uninstalling it.
No files were removed.
EOF2
        exit 1
    fi
}

uninstall_micro() {
    rm -f -- "$MICRO_THEME_DEST"
}

check_micro() {
    # micro has no offline parser, so check the line grammar it accepts:
    # comments, blank lines, and color-link <group> "<style>".
    awk '
        /^[[:space:]]*(#|$)/ { next }
        /^color-link [a-z][A-Za-z.-]* "((bold|italic|underline|reverse) )*(#[0-9A-Fa-f]{6})?(,#[0-9A-Fa-f]{6})?"$/ { next }
        { printf "%s:%d: unexpected line: %s\n", FILENAME, FNR, $0 > "/dev/stderr"; bad = 1 }
        END { exit bad }
    ' "$ROOT/cli/micro/primer-dark.micro"
}
