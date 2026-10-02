#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Discord has no theme API. The theme is a Vencord theme file that users place
# in Vencord's themes directory and enable themselves, so it is never installed.
check_discord() {
    theme="$ROOT/integrations/vencord/primer-dark.theme.css"

    # The theme is generated from the palette; a stale file fails the check.
    python3 "$ROOT/scripts/generate-discord-theme.py" --check

    # Vencord lists a theme under the @name in the first /** comment block of
    # the file and falls back to the file name without one.
    if [ "$(head -n 1 "$theme")" != "/**" ] || ! sed -n '2,/\*\//p' "$theme" | grep -qx ' \* @name Primer Dark'; then
        printf '%s must open with a /** block declaring @name Primer Dark.\n' "$theme" >&2
        exit 1
    fi
}
