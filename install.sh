#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
set -eu

ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"

APPLY=0
SELECTED_COMPONENTS="kde"

usage() {
    cat <<'EOF'
Usage: ./install.sh [--apply] [--konsole] [--ghostty] [--herdr] [--pi] [--zed] [--cursor] [--fastfetch] [--bat] [--btop] [--fish] [--gtk] [--kvantum]

Install the Primer Dark KDE theme into the current user's XDG data directory.
The KDE theme is not applied unless --apply is provided.
Use --konsole, --ghostty, --herdr, --pi, --zed, --cursor, --fastfetch, --bat, --btop, --fish, --gtk, or --kvantum to additionally install those application themes.
EOF
}

select_component() {
    case " $SELECTED_COMPONENTS " in
        *" $1 "*) ;;
        *) SELECTED_COMPONENTS="$SELECTED_COMPONENTS $1" ;;
    esac
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        -h|--help) usage; exit 0 ;;
        --*)
            requested_component=${1#--}
            if component_is_known "$requested_component" && [ "$requested_component" != "kde" ]; then
                select_component "$requested_component"
            else
                printf 'Unknown option: %s\n' "$1" >&2
                usage >&2
                exit 2
            fi
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

initialize_user_paths
load_components

cleanup_install_temps() {
    cleanup_herdr_temps
}
trap cleanup_install_temps 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# Validate every requested component before changing installed files so a missing
# optional dependency cannot leave an unexpected partial installation.
for component in $SELECTED_COMPONENTS; do
    run_component_hook preflight "$component"
done
if [ "$APPLY" -eq 1 ]; then
    require_command plasma-apply-lookandfeel "plasma-apply-lookandfeel is required to apply the theme."
fi

for component in $SELECTED_COMPONENTS; do
    run_component_hook install "$component"
done

if [ "$APPLY" -eq 1 ]; then
    plasma-apply-lookandfeel -a "$PACKAGE_ID"
    echo "Applied Primer Dark. Log out and back in if the cursor or decoration does not refresh immediately."
else
    echo "Open System Settings → Colors & Themes → Global Theme, or rerun with --apply."
fi
