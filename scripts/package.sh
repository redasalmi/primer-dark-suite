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
find "$ROOT/kde/aurorae/PrimerDark" -maxdepth 1 -name '*.svg' -exec xmllint --noout {} +

if find "$ROOT/kde/look-and-feel/$PACKAGE_ID" -type l -print -quit | grep -q .; then
    echo "Global theme packages cannot contain symlinks." >&2
    exit 1
fi

rm -rf -- "$DIST"
mkdir -p -- "$DIST"

tar -C "$ROOT/kde/look-and-feel" -czf "$DIST/Primer-Dark-Global.tar.gz" "$PACKAGE_ID"
tar -C "$ROOT/kde/aurorae" -czf "$DIST/Primer-Dark-Aurorae.tar.gz" PrimerDark
cp "$ROOT/kde/colors/PrimerDark.colors" "$DIST/"
(
    cd "$DIST"
    sha256sum Primer-Dark-Global.tar.gz Primer-Dark-Aurorae.tar.gz PrimerDark.colors > SHA256SUMS
)

echo "Created release artifacts in $DIST"
