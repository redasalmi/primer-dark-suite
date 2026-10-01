#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

# Downloads every pinned font and the Papirus archive into a temporary cache,
# verifies their checksums, and confirms that each font reports the family its
# manifest line names and that the archive contains both Papirus themes. Run it
# after changing a pin; ./scripts/check.sh validates the pins offline.

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"

require_command fc-query "fc-query (fontconfig) is required to check the fonts."
require_command tar "tar is required to check the Papirus archive."

DOWNLOAD_CACHE=$(mktemp -d)
trap 'rm -rf -- "$DOWNLOAD_CACHE"' 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

tab=$(printf '\t')
while IFS=$tab read -r font_family font_path font_sha256 font_url; do
    case "$font_family" in '#'*|'') continue ;; esac
    fetch_verified "$font_url" "$font_sha256"
    case "$font_path" in
        *.ttf|*.otf)
            reported_family=$(fc-query -f '%{family[0]}\n' "$DOWNLOAD_CACHE/$font_sha256")
            if [ "$reported_family" != "$font_family" ]; then
                printf '%s reports the family "%s" instead of "%s".\n' "$font_url" "$reported_family" "$font_family" >&2
                exit 1
            fi
            ;;
    esac
done < "$FONTS_MANIFEST"

fetch_verified "$PAPIRUS_URL" "$PAPIRUS_SHA256"
papirus_members=$(tar -tzf "$DOWNLOAD_CACHE/$PAPIRUS_SHA256")
for papirus_theme in Papirus Papirus-Dark; do
    if ! printf '%s\n' "$papirus_members" | grep -qx "papirus-icon-theme-$PAPIRUS_VERSION/$papirus_theme/index.theme"; then
        printf 'The Papirus archive has no %s theme.\n' "$papirus_theme" >&2
        exit 1
    fi
done

echo "Verified every pinned download."
