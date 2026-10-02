#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Slack stores its theme in account preferences, so the theme is published as
# a string users paste into Slack's Import theme dialog and never installed.
check_slack() {
    theme="$ROOT/chat/slack/primer-dark.txt"

    # Slack's import dialog removes whitespace, uppercases the text, splits it
    # on commas, and applies exactly four hex colors as custom colors in the
    # order System navigation, Selected items, Presence indication, and
    # Notifications. Eight- and ten-color legacy strings are reduced to those
    # four slots and may snap to Slack's own palette instead.
    expected=$(jq -r '.tokens | [.surface.inset, .accent.emphasis, .status.success, .status.dangerEmphasis] | join(",")' \
        "$ROOT/palette/primer-dark.json")
    if [ "$(wc -l < "$theme")" -ne 1 ] || [ "$(cat "$theme")" != "$expected" ]; then
        printf '%s must be the single line %s\n' "$theme" "$expected" >&2
        exit 1
    fi
}
