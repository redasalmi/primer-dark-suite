#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# fonts/sources.tsv pins every font and license file to an upstream release
# tag and checksum. Its first path segment is the family's directory under the
# owned fonts directory.
FONTS_TAB=$(printf '\t')

# Families that preflight_fonts selects for installation, and the families it
# leaves to an existing installation.
FONTS_SELECTED=""
FONTS_SKIPPED=""

# Prints "directory<TAB>family" once for every family in the manifest.
font_manifest_families() {
    awk -F '\t' '!/^#/ && NF { split($2, path, "/"); if (!seen[path[1]]++) print path[1] "\t" $1 }' "$FONTS_MANIFEST"
}

# Succeeds when fontconfig resolves FAMILY from a file outside the owned
# directory, so a family that is already installed is never registered twice.
font_family_installed_elsewhere() {
    fc-list "$1" file | while IFS= read -r font_line; do
        font_file=${font_line%:*}
        case "$font_file" in
            "$FONTS_DEST"/*) ;;
            *) echo "$font_file" ;;
        esac
    done | grep -q .
}

preflight_fonts() {
    require_command fc-list "fc-list (fontconfig) is required to install the fonts."
    require_command fc-cache "fc-cache (fontconfig) is required to install the fonts."

    FONTS_SELECTED=""
    FONTS_SKIPPED=""
    while IFS=$FONTS_TAB read -r font_dir font_family; do
        if font_family_installed_elsewhere "$font_family"; then
            FONTS_SKIPPED="$FONTS_SKIPPED, $font_family"
        else
            FONTS_SELECTED="$FONTS_SELECTED $font_dir"
        fi
    done <<EOF
$(font_manifest_families)
EOF

    # Download and verify everything before any component changes installed
    # files, so a network or checksum failure leaves no partial installation.
    while IFS=$FONTS_TAB read -r font_family font_path font_sha256 font_url; do
        case "$font_family" in '#'*|'') continue ;; esac
        case " $FONTS_SELECTED " in
            *" ${font_path%%/*} "*) fetch_verified "$font_url" "$font_sha256" ;;
        esac
    done < "$FONTS_MANIFEST"
    cleanup_fetch_archive
}

install_fonts() {
    # The owned directory is replaced as a whole, so a family that is now
    # installed elsewhere stops being registered twice.
    rm -rf -- "$FONTS_DEST"
    while IFS=$FONTS_TAB read -r font_family font_path font_sha256 font_url; do
        case "$font_family" in '#'*|'') continue ;; esac
        case " $FONTS_SELECTED " in
            *" ${font_path%%/*} "*) install -Dm644 "$DOWNLOAD_CACHE/$font_sha256" "$FONTS_DEST/$font_path" ;;
        esac
    done < "$FONTS_MANIFEST"
    if [ -d "$FONTS_ROOT" ]; then
        fc-cache -f "$FONTS_ROOT" >/dev/null
    fi

    if [ -n "$FONTS_SELECTED" ]; then
        printf 'Installed the Primer Dark fonts at %s\n' "$FONTS_DEST"
    fi
    if [ -n "$FONTS_SKIPPED" ]; then
        printf 'Kept the already installed %s.\n' "${FONTS_SKIPPED#, }"
    fi
    echo 'Select them in System Settings → Text & Fonts: Inter 10 for General, Menu, and Window title, Inter 9 for Toolbar, Inter 8 for Small, and JetBrains Mono 10 for Fixed width.'
}

guard_fonts() {
    [ -d "$FONTS_DEST" ] || return 0
    command -v kreadconfig6 >/dev/null 2>&1 || return 0

    # KDE stores each font as "Family,size,...", and the window title font in
    # the [WM] group. A family that is also installed elsewhere stays
    # available after removal, so only families provided by the owned
    # directory alone block the uninstall.
    for font_setting in General:font General:fixed General:smallestReadableFont General:toolBarFont General:menuFont WM:activeFont; do
        selected_font=$(kreadconfig6 --file kdeglobals --group "${font_setting%%:*}" --key "${font_setting#*:}" 2>/dev/null || true)
        selected_family=${selected_font%%,*}
        [ -n "$selected_family" ] || continue
        while IFS=$FONTS_TAB read -r font_dir font_family; do
            [ "$selected_family" = "$font_family" ] || continue
            [ -d "$FONTS_DEST/$font_dir" ] || continue
            if command -v fc-list >/dev/null 2>&1 && font_family_installed_elsewhere "$font_family"; then
                continue
            fi
            cat >&2 <<EOF2
$font_family is selected in System Settings → Text & Fonts and is provided only by Primer Dark. Select another font before uninstalling it.
No files were removed.
EOF2
            exit 1
        done <<EOF
$(font_manifest_families)
EOF
    done
}

uninstall_fonts() {
    [ -d "$FONTS_DEST" ] || return 0
    rm -rf -- "$FONTS_DEST"
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONTS_ROOT" >/dev/null 2>&1 || true
    fi
}

check_fonts() {
    # The manifest is checked offline: every line pins an HTTPS URL on a
    # release tag rather than a moving branch (a raw repository file, or a
    # member of a zip release asset), a SHA-256 checksum, and a relative path,
    # and every family directory ships fonts and a license.
    awk -F '\t' '
        /^#/ || !NF { next }
        {
            where = FILENAME ":" FNR ": "
            if (NF != 4) { print where "expected 4 tab-separated fields" > "/dev/stderr"; bad = 1; next }
            if (length($3) != 64 || $3 ~ /[^0-9a-f]/) { print where "invalid SHA-256 checksum" > "/dev/stderr"; bad = 1 }
            if ($4 !~ /^https:\/\/raw\.githubusercontent\.com\/[^\/]+\/[^\/]+\/v[0-9][^\/]*\/[^#]+$/ && $4 !~ /^https:\/\/github\.com\/[^\/]+\/[^\/]+\/releases\/download\/v[0-9][^\/]*\/[^\/#]+\.zip#[^#]+$/) { print where "URL must be pinned to a release tag" > "/dev/stderr"; bad = 1 }
            if ($2 !~ /^[a-z0-9-]+\/[^\/]+$/ || $2 ~ /\.\./) { print where "invalid installed path" > "/dev/stderr"; bad = 1 }
            split($2, path, "/")
            if ((path[1] in family) && family[path[1]] != $1) { print where "directory " path[1] " mixes families" > "/dev/stderr"; bad = 1 }
            family[path[1]] = $1
            if (path[2] ~ /\.(ttf|otf)$/) fonts[path[1]]++
            if (path[2] == "OFL.txt" || path[2] == "LICENSE") licenses[path[1]]++
        }
        END {
            for (dir in family) {
                if (!fonts[dir]) { print "fonts/sources.tsv: " dir " has no font files" > "/dev/stderr"; bad = 1 }
                if (!licenses[dir]) { print "fonts/sources.tsv: " dir " has no license file" > "/dev/stderr"; bad = 1 }
            }
            exit bad
        }
    ' "$FONTS_MANIFEST"
}
