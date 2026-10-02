#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Steam has no theme API. The theme is a Millennium theme folder that users
# copy into Millennium's themes directory and select themselves, because
# Millennium patches the Steam client, so it is never installed.
check_steam() {
    theme_dir="$ROOT/integrations/steam/PrimerDark"

    # colors.css and skin.json are generated from the palette, and the
    # recolored primer-dark.css must read only the roles colors.css defines.
    python3 "$ROOT/scripts/generate-steam-theme.py" --check

    # Millennium requires a name, an author, and a description, and loads the
    # RootColors file and every patch's TargetCss relative to the theme folder.
    if ! jq -e '(.name | type) == "string" and (.author | type) == "string" and (.description | type) == "string"
            and (.Patches | length) > 0' "$theme_dir/skin.json" >/dev/null; then
        printf '%s must declare name, author, description, and Patches.\n' "$theme_dir/skin.json" >&2
        exit 1
    fi
    for referenced in $(jq -r '.RootColors, (.Patches[] | .TargetCss // empty)' "$theme_dir/skin.json" | sort -u); do
        if [ ! -f "$theme_dir/$referenced" ]; then
            printf '%s references the missing file %s.\n' "$theme_dir/skin.json" "$referenced" >&2
            exit 1
        fi
    done
}
