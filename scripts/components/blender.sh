#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Blender keeps user presets per minor version, so the theme is installed once
# for the Blender on PATH and once for every existing version directory.
BLENDER_VERSIONS=""

detect_blender_versions() {
    BLENDER_VERSIONS=""
    if command -v blender >/dev/null 2>&1; then
        BLENDER_VERSIONS=$(blender --version 2>/dev/null \
            | sed -n '1s/^Blender \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')
    fi
    for version_dir in "$BLENDER_CONFIG_ROOT"/*; do
        [ -d "$version_dir" ] || continue
        version=${version_dir##*/}
        case "$version" in
            *[!0-9.]*|.*|*.|*.*.*) continue ;;
            *.*) ;;
            *) continue ;;
        esac
        case " $BLENDER_VERSIONS " in
            *" $version "*) ;;
            *) BLENDER_VERSIONS="$BLENDER_VERSIONS $version" ;;
        esac
    done
}

preflight_blender() {
    detect_blender_versions
    if [ -z "$BLENDER_VERSIONS" ]; then
        cat >&2 <<EOF2
No Blender installation was found: neither a blender command on PATH nor a
version directory in $BLENDER_CONFIG_ROOT. Install Blender or start it once.
EOF2
        exit 1
    fi
}

install_blender() {
    for version in $BLENDER_VERSIONS; do
        theme_dest="$BLENDER_CONFIG_ROOT/$version/$BLENDER_THEME_PATH"
        install -Dm644 "$ROOT/creative/blender/Primer_Dark.xml" "$theme_dest"
        printf 'Installed the Blender %s interface theme at %s\n' "$version" "$theme_dest"
    done
    echo 'Select "Primer Dark" in Blender under Edit > Preferences > Themes.'
}

guard_blender() {
    # Selecting a theme copies its colors into Blender's preferences, so the
    # preset file is not needed after it is loaded.
    :
}

uninstall_blender() {
    for theme_file in "$BLENDER_CONFIG_ROOT"/*/"$BLENDER_THEME_PATH"; do
        [ -f "$theme_file" ] || continue
        rm -f -- "$theme_file"
    done
}

check_blender() {
    theme="$ROOT/creative/blender/Primer_Dark.xml"
    xmllint --noout "$theme"

    # Blender's preset loader requires a Theme and a ThemeStyle element, and
    # skips every element whose type is outside its secure theme types.
    for required in '<Theme>' '<ThemeStyle>'; do
        if ! grep -qF -- "$required" "$theme"; then
            printf '%s: missing %s\n' "$theme" "$required" >&2
            exit 1
        fi
    done
    unknown_types=$(grep -oE '<Theme[A-Za-z0-9]*' "$theme" | sed 's/^<//' | sort -u \
        | grep -vxE 'Theme(BoneColorSet|ClipEditor|CollectionColor|Common|CommonAnim|CommonCurves|Console|DopeSheet|FileBrowser|FontStyle|GradientColors|GraphEditor|ImageEditor|Info|NLAEditor|NodeEditor|Outliner|Preferences|Properties|Regions|RegionsAssetShelf|RegionsChannels|RegionsScrubbing|RegionsSidebars|SequenceEditor|SpaceGeneric|SpaceGradient|SpaceListGeneric|Spreadsheet|StatusBar|StripColor|Style|TextEditor|TopBar|UserInterface|View3D|WidgetColors|WidgetStateColors)?' \
        || true)
    if [ -n "$unknown_types" ]; then
        printf '%s: element types Blender skips: %s\n' "$theme" "$unknown_types" >&2
        exit 1
    fi

    # Blender reads a color attribute as #RRGGBB or #RRGGBBAA hexadecimal.
    bad_colors=$(grep -oE '="#[^"]*"' "$theme" | grep -vxE '="#[0-9a-f]{6}([0-9a-f]{2})?"' || true)
    if [ -n "$bad_colors" ]; then
        printf '%s: invalid colors: %s\n' "$theme" "$bad_colors" >&2
        exit 1
    fi
}
