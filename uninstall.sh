#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"
initialize_user_paths
load_components

# Run every safety check before removing or restoring anything. This keeps a
# later active-theme guard from leaving an unexpected partial uninstall.
for component in $ALL_COMPONENTS; do
    run_component_hook guard "$component"
done

# Restore shared configuration before removing file-based themes. A failed
# Herdr validation therefore still leaves every installed theme file intact.
uninstall_herdr
for component in $ALL_COMPONENTS; do
    [ "$component" = "herdr" ] && continue
    run_component_hook uninstall "$component"
done

echo "Uninstalled Primer Dark."
