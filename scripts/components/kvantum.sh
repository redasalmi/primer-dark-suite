#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_kvantum() {
    :
}

install_kvantum() {
    # The installed theme directory is wholly owned by Primer Dark, so replace
    # it instead of merging files that an older release may have left behind.
    rm -rf -- "$KVANTUM_THEME_DEST"
    mkdir -p -- "$KVANTUM_THEME_DEST"
    install -m644 "$KVANTUM_THEME_SOURCE/$KVANTUM_THEME_ID.kvconfig" \
        "$KVANTUM_THEME_DEST/$KVANTUM_THEME_ID.kvconfig"
    printf 'Installed the Kvantum theme at %s\n' "$KVANTUM_THEME_DEST"
    echo 'Select "PrimerDark" in Kvantum Manager, or set theme=PrimerDark in ~/.config/Kvantum/kvantum.kvconfig.'
}

kvantum_selection_file() {
    # Kvantum looks for kvantum.kvconfig in the XDG config home and, when that
    # file does not exist, in Qt's standard configuration locations, which are
    # the XDG_CONFIG_DIRS entries (defaulting to /etc/xdg).
    if [ -n "${XDG_CONFIG_HOME:-}" ]; then
        config_home=$XDG_CONFIG_HOME
    elif [ -n "${HOME:-}" ]; then
        config_home="$HOME/.config"
    else
        config_home=""
    fi
    if [ -n "$config_home" ] && [ -f "$config_home/Kvantum/kvantum.kvconfig" ]; then
        printf '%s\n' "$config_home/Kvantum/kvantum.kvconfig"
        return 0
    fi

    # XDG_CONFIG_DIRS is a colon-separated list; empty entries do not name a
    # configuration directory.
    config_dirs=${XDG_CONFIG_DIRS:-/etc/xdg}
    old_ifs=$IFS
    IFS=:
    for config_dir in $config_dirs; do
        IFS=$old_ifs
        if [ -n "$config_dir" ] && [ -f "$config_dir/Kvantum/kvantum.kvconfig" ]; then
            printf '%s\n' "$config_dir/Kvantum/kvantum.kvconfig"
            return 0
        fi
        IFS=:
    done
    IFS=$old_ifs
    return 1
}

kvantum_uses_primer_dark() {
    # Kvantum selects a theme from its QSettings INI file in two ways, and a
    # per-application assignment overrides the global one. Only the theme side
    # is compared here: any assignment of this theme means it is in use, so
    # application names and patterns are never evaluated.
    #
    # The parsing mirrors Qt rather than matching raw text. Qt ignores a leading
    # UTF-8 byte order mark, decodes %XX escapes in section and key names,
    # strips one surrounding pair of double quotes, decodes "\"" inside
    # quotes, treats ";" as a comment only outside quotes, unwraps one
    # "@Type(...)" value wrapper, and decodes backslash escapes in values. A
    # "#"-suffixed name is not folded into this theme: Kvantum resolves it in
    # its own directory, so removing this theme cannot break it.
    #
    # The remaining Qt behavior is not reimplemented. When a construct cannot be
    # decoded with certainty, including a line without "=", a backslash escape,
    # or a malformed "@Type(...)" value, the theme counts as active so that
    # removal stops instead of deleting a theme that may be in use.
    config_file=$(kvantum_selection_file) || return 1
    awk -v theme="$KVANTUM_THEME_ID" '
        function hex_value(character) {
            return index("0123456789abcdef", tolower(character)) - 1
        }
        function decode_escapes(text,   i, character, out, high, low) {
            out = ""
            for (i = 1; i <= length(text); i++) {
                character = substr(text, i, 1)
                if (character == "%" && i + 2 <= length(text)) {
                    high = hex_value(substr(text, i + 1, 1))
                    low = hex_value(substr(text, i + 2, 1))
                    if (high >= 0 && low >= 0) {
                        out = out sprintf("%c", high * 16 + low)
                        i += 2
                        continue
                    }
                }
                out = out character
            }
            return out
        }
        function unquote(text,   changed) {
            # Qt removes repeated surrounding quoting but unwraps only one
            # "@Type(...)" value wrapper, whatever the type name is.
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
            changed = 1
            while (changed) {
                changed = 0
                while (length(text) >= 2 && substr(text, 1, 1) == "\"" && substr(text, length(text), 1) == "\"") {
                    text = substr(text, 2, length(text) - 2)
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
                    changed = 1
                }
                if (changed) continue
                if (text ~ /^@[A-Za-z0-9_]*\(.*\)$/ && index(text, "(") > 1) {
                    text = substr(text, index(text, "(") + 1)
                    text = substr(text, 1, length(text) - 1)
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
                    while (length(text) >= 2 && substr(text, 1, 1) == "\"" && substr(text, length(text), 1) == "\"") {
                        text = substr(text, 2, length(text) - 2)
                        gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
                    }
                }
            }
            return text
        }
        function decode_value(text,   i, character, out, quoted) {
            out = ""
            for (i = 1; i <= length(text); i++) {
                character = substr(text, i, 1)
                if (quoted && character == "\\" && substr(text, i + 1, 1) == "\"") {
                    out = out "\""
                    i++
                    continue
                }
                if (character == "\"") {
                    quoted = !quoted
                    out = out character
                    continue
                }
                if (character == ";" && !quoted) break
                out = out character
            }
            return unquote(out)
        }
        NR == 1 { sub(/^\357\273\277/, "") }
        /^[[:space:]]*[;#]/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\[/ {
            section = $0
            sub(/^[[:space:]]*\[/, "", section)
            # Qt ends the section name at the first "]" and ignores the rest of
            # the header line, and it trims the spaces inside the brackets.
            sub(/\].*$/, "", section)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", section)
            section = decode_escapes(section)
            # Qt decodes the documented "%General" section name to "General".
            sub(/^%/, "", section)
            next
        }
        {
            position = index($0, "=")
            if (position == 0) {
                uncertain = 1
                next
            }
            key = substr($0, 1, position - 1)
            value = substr($0, position + 1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
            if (index(key, "\\") > 0) {
                uncertain = 1
                next
            }
            if (section == "Applications") {
                if (decode_escapes(key) == theme) found = 1
                next
            }
            if (section == "" || section == "General") {
                if (decode_escapes(key) != "theme") next
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                if (index(value, "\\") > 0) {
                    uncertain = 1
                    next
                }
                if (substr(value, 1, 1) == "@" && value !~ /^@[A-Za-z0-9_]*\(.*\)$/) {
                    uncertain = 1
                    next
                }
                if (decode_value(value) == theme) found = 1
            }
        }
        END { exit (found || uncertain) ? 0 : 1 }
    ' "$config_file"
}

guard_kvantum() {
    [ -d "$KVANTUM_THEME_DEST" ] || return 0

    if kvantum_uses_primer_dark; then
        cat >&2 <<'EOF'
The Primer Dark Kvantum theme is currently active, either as the selected theme or through a per-application assignment. Select another Kvantum theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_kvantum() {
    rm -rf -- "$KVANTUM_THEME_DEST"
}

check_kvantum() {
    theme_file="$KVANTUM_THEME_SOURCE/$KVANTUM_THEME_ID.kvconfig"
    if [ ! -f "$theme_file" ]; then
        printf 'The Kvantum theme asset is missing: %s\n' "$theme_file" >&2
        exit 1
    fi

    # Kvantum copies these keys verbatim into its color spec, so a missing key
    # becomes an empty color instead of inheriting a default.
    kvantum_color_keys="window.color inactive.window.color base.color inactive.base.color \
alt.base.color inactive.alt.base.color button.color light.color mid.light.color \
dark.color mid.color shadow.color highlight.color inactive.highlight.color \
tooltip.base.color text.color inactive.text.color window.text.color \
inactive.window.text.color button.text.color disabled.text.color tooltip.text.color \
highlight.text.color inactive.highlight.text.color link.color link.visited.color \
progress.indicator.text.color progress.inactive.indicator.text.color"
    palette=$(jq -r '[.tokens[][] | ascii_upcase] | join(" ")' "$ROOT/palette/primer-dark.json")

    awk -v color_keys="$kvantum_color_keys" -v palette="$palette" -v file="$theme_file" '
        BEGIN {
            count = split(color_keys, keys, /[[:space:]]+/)
            for (i = 1; i <= count; i++)
                if (keys[i] != "") expected[keys[i]] = 1
            count = split(palette, colors, /[[:space:]]+/)
            for (i = 1; i <= count; i++)
                if (colors[i] != "") allowed[colors[i]] = 1
        }
        function fail(message) {
            printf "%s: %s\n", file, message > "/dev/stderr"
            bad = 1
        }
        /^[[:space:]]*[;#]/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\[/ {
            section = $0
            sub(/^[[:space:]]*\[/, "", section)
            sub(/\].*$/, "", section)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", section)
            # Qt decodes the documented "%General" section name to "General".
            if (substr(section, 1, 1) == "%") section = substr(section, 2)
            if (section != "General" && section != "GeneralColors")
                fail("unexpected section [" section "]")
            next
        }
        {
            line = $0
            # Qt starts a value comment at ";" but keeps "#", because colors
            # and modified theme names may contain it.
            sub(/;.*$/, "", line)
            position = index(line, "=")
            if (position == 0) {
                fail("not a key=value line: " $0)
                next
            }
            key = substr(line, 1, position - 1)
            value = substr(line, position + 1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            if (section == "GeneralColors") {
                seen[key] = 1
                if (!(key in expected))
                    fail("unknown GeneralColors key: " key)
                if (value ~ /^#[0-9A-Fa-f]{8}$/) {
                    # An alpha variant is allowed only when its color is canonical.
                    rgb = toupper(substr(value, 1, 7))
                } else if (value ~ /^#[0-9A-Fa-f]{6}$/) {
                    rgb = toupper(value)
                } else {
                    fail(key " is not a #RRGGBB or #RRGGBBAA color: " value)
                    rgb = ""
                }
                if (rgb != "" && !(rgb in allowed))
                    fail(key " is not derived from a canonical palette color: " value)
            } else if (section == "General") {
                if (key == "author" || key == "comment") {
                    if (value == "") fail(key " is empty")
                } else {
                    fail("unknown General key: " key)
                }
            } else {
                fail("key outside a section: " key)
            }
        }
        END {
            for (key in expected)
                if (!(key in seen)) fail("missing GeneralColors key: " key)
            if (bad) exit 1
        }
    ' "$theme_file"
}
