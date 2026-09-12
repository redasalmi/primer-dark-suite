#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"
load_components

require_command jq "jq is required."
require_command xmllint "xmllint is required."

# Every port derives from the palette, so validate it before the components.
jq -e . "$ROOT/palette/primer-dark.json" >/dev/null

# Each checked component owns the validation for its own asset format. The
# theme files without a parser (Konsole, Ghostty, btop, Fish, eza, tmux, Herdr)
# are covered by install.sh's own handling and the parsers of the applications
# that consume them.
for component in $CHECK_COMPONENTS; do
    run_component_hook check "$component"
done

echo "Validated the palette and every checked component."
