#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_bat() {
    :
}

install_bat() {
    install -Dm644 "$ROOT/cli/bat/Primer Dark.tmTheme" "$BAT_THEME_DEST"
    printf 'Installed the bat theme at %s\n' "$BAT_THEME_DEST"
    echo 'Run "bat cache --build" to make it selectable, then choose "Primer Dark".'
}

bat_config_uses_primer_dark() {
    # bat splits each config line into shell words; never evaluate those words.
    awk '
        function argument(value) {
            if (pending != "") {
                themes[pending] = value
                pending = ""
            } else if (value ~ /^--theme(-dark|-light)?$/) {
                pending = value
            } else if (value ~ /^--theme(-dark|-light)?=/) {
                name = value
                sub(/=.*/, "", name)
                sub(/^[^=]*=/, "", value)
                themes[name] = value
            }
        }
        /^[[:space:]]*(#|$)/ { next }
        {
            word = quote = ""
            started = 0
            for (i = 1; i <= length($0); i++) {
                char = substr($0, i, 1)
                if (char == "\\" && quote != "\047") {
                    next_char = substr($0, ++i, 1)
                    if (next_char == "") { bad = 1; break }
                    if (quote == "\"" && next_char !~ /^[\\"$`]$/)
                        word = word char
                    word = word next_char
                    started = 1
                } else if (quote != "") {
                    if (char == quote) quote = ""
                    else word = word char
                } else if (char == "\"" || char == "\047") {
                    quote = char
                    started = 1
                } else if (char == "#" && !started) {
                    break
                } else if (char ~ /[[:space:]]/) {
                    if (started) argument(word)
                    word = ""
                    started = 0
                } else {
                    word = word char
                    started = 1
                }
            }
            if (quote != "") bad = 1
            if (started) argument(word)
        }
        END {
            if (bad || pending != "") exit 2
            for (name in themes)
                if (themes[name] == "Primer Dark") exit 0
            exit 1
        }
    ' "$BAT_CONFIG_FILE"
}

guard_bat() {
    if [ -f "$BAT_THEME_DEST" ]; then
        active_bat_theme=0
        case "${BAT_THEME:-}" in "Primer Dark") active_bat_theme=1 ;; esac
        case "${BAT_THEME_DARK:-}" in "Primer Dark") active_bat_theme=1 ;; esac
        case "${BAT_THEME_LIGHT:-}" in "Primer Dark") active_bat_theme=1 ;; esac
        if [ "$active_bat_theme" -eq 0 ] && [ -f "$BAT_CONFIG_FILE" ]; then
            if bat_config_uses_primer_dark; then
                active_bat_theme=1
            else
                bat_config_status=$?
                if [ "$bat_config_status" -ne 1 ]; then
                    echo 'Cannot parse the bat configuration safely; no files were removed.' >&2
                    exit 1
                fi
            fi
        fi
        if [ "$active_bat_theme" -eq 1 ]; then
            cat >&2 <<'EOF'
The Primer Dark bat theme is currently active. Select another bat theme before uninstalling it.
No files were removed.
EOF
            exit 1
        fi
    fi
}

uninstall_bat() {
    rm -f -- "$BAT_THEME_DEST"
}

check_bat() {
    xmllint --noout "$ROOT/cli/bat/Primer Dark.tmTheme"
}
