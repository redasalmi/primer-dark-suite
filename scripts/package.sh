#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DIST="$ROOT/dist"
PACKAGE_ID=io.github.redasalmi.primerdark.desktop

command -v jq >/dev/null 2>&1 || { echo "jq is required." >&2; exit 1; }
command -v xmllint >/dev/null 2>&1 || { echo "xmllint is required." >&2; exit 1; }

jq -e . "$ROOT/palette/primer-dark.json" >/dev/null
jq -e . "$ROOT/kde/look-and-feel/$PACKAGE_ID/metadata.json" >/dev/null
jq -e . "$ROOT/kde/aurorae/PrimerDark/metadata.json" >/dev/null
jq -e . "$ROOT/kde/plasma-style/PrimerDark/metadata.json" >/dev/null
jq -e . "$ROOT/cli/pi/primer-dark.json" >/dev/null
jq -e . "$ROOT/editors/zed/primer-dark.json" >/dev/null
find "$ROOT/kde/aurorae/PrimerDark" -maxdepth 1 -name '*.svg' -exec xmllint --noout {} +
find "$ROOT/kde/plasma-style/PrimerDark" -name '*.svg' -exec xmllint --noout {} +

if find "$ROOT/kde/look-and-feel/$PACKAGE_ID" -type l -print -quit | grep -q .; then
    echo "Global theme packages cannot contain symlinks." >&2
    exit 1
fi

rm -rf -- "$DIST"
mkdir -p -- "$DIST"

tar -C "$ROOT/kde/look-and-feel" -czf "$DIST/Primer-Dark-Global.tar.gz" "$PACKAGE_ID"
tar -C "$ROOT/kde/aurorae" -czf "$DIST/Primer-Dark-Aurorae.tar.gz" PrimerDark
tar -C "$ROOT/kde/plasma-style" -czf "$DIST/Primer-Dark-Plasma-Style.tar.gz" PrimerDark
tar -C "$ROOT/kde/konsole" -czf "$DIST/Primer-Dark-Konsole.tar.gz" PrimerDark.colorscheme PrimerDark.profile
tar -C "$ROOT/terminals/ghostty" -czf "$DIST/Primer-Dark-Ghostty.tar.gz" "Primer Dark"
cp "$ROOT/cli/pi/primer-dark.json" "$DIST/Primer-Dark-Pi.json"
cp "$ROOT/cli/herdr/primer-dark.toml" "$DIST/Primer-Dark-Herdr.toml"
cp "$ROOT/editors/zed/primer-dark.json" "$DIST/Primer-Dark-Zed.json"
cp "$ROOT/kde/colors/PrimerDark.colors" "$DIST/"
(
    cd "$DIST"
    sha256sum Primer-Dark-Global.tar.gz Primer-Dark-Aurorae.tar.gz Primer-Dark-Plasma-Style.tar.gz Primer-Dark-Konsole.tar.gz Primer-Dark-Ghostty.tar.gz Primer-Dark-Pi.json Primer-Dark-Herdr.toml Primer-Dark-Zed.json PrimerDark.colors > SHA256SUMS
)

echo "Created release artifacts in $DIST"
