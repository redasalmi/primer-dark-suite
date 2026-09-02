#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"
load_components

FINAL_DIST="$ROOT/dist"
DIST=$(mktemp -d "$ROOT/.dist.XXXXXX")
DIST_BACKUP=""
PACKAGE_ARTIFACTS=""

cleanup_package_dirs() {
    [ -z "$DIST" ] || rm -rf -- "$DIST"
    if [ -n "$DIST_BACKUP" ] && [ -e "$DIST_BACKUP" ] && [ ! -e "$FINAL_DIST" ]; then
        mv -- "$DIST_BACKUP" "$FINAL_DIST"
    fi
}
trap cleanup_package_dirs 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

register_artifact() {
    if [ -z "$PACKAGE_ARTIFACTS" ]; then
        PACKAGE_ARTIFACTS=$1
    else
        PACKAGE_ARTIFACTS="$PACKAGE_ARTIFACTS $1"
    fi
}

require_command jq "jq is required."
require_command xmllint "xmllint is required."
jq -e . "$ROOT/palette/primer-dark.json" >/dev/null

for component in $ALL_COMPONENTS; do
    run_component_hook package "$component"
done

(
    cd "$DIST"
    : > SHA256SUMS
    # Artifact names contain no whitespace and are registered deterministically
    # by the component order in scripts/lib/common.sh.
    for artifact in $PACKAGE_ARTIFACTS; do
        sha256sum "$artifact" >> SHA256SUMS
    done
)

if [ -e "$FINAL_DIST" ]; then
    DIST_BACKUP=$(mktemp -d "$ROOT/.dist-backup.XXXXXX")
    rmdir -- "$DIST_BACKUP"
    mv -- "$FINAL_DIST" "$DIST_BACKUP"
fi
mv -- "$DIST" "$FINAL_DIST"
DIST=""
if [ -n "$DIST_BACKUP" ]; then
    rm -rf -- "$DIST_BACKUP"
    DIST_BACKUP=""
fi

echo "Created release artifacts in $FINAL_DIST"
