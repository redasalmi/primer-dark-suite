#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Spotify has no theme API. The theme is a Spicetify theme folder that users
# copy into Spicetify's Themes directory and apply themselves, because applying
# it patches the Spotify installation, so it is never installed.
check_spotify() {
    theme_dir="$ROOT/integrations/spicetify/PrimerDark"

    # The theme is generated from the palette; stale files fail the check.
    python3 "$ROOT/scripts/generate-spotify-theme.py" --check

    # Spicetify reads color.ini case-insensitively, uses its first section when
    # no color_scheme is configured, and parses each value as hexadecimal.
    # Every color user.css reads must be a key of that section.
    python3 - "$theme_dir/color.ini" "$theme_dir/user.css" <<'PY'
import configparser
import re
import sys

ini_path, css_path = sys.argv[1:]
config = configparser.ConfigParser(interpolation=None)
config.read(ini_path)
base = {
    "text", "subtext", "main", "main-elevated", "highlight", "highlight-elevated", "sidebar",
    "player", "card", "shadow", "selected-row", "button", "button-active", "button-disabled",
    "tab-active", "notification", "notification-error", "misc",
}
errors = []
if config.sections() != ["Dark"]:
    errors.append(f"{ini_path}: expected the single section [Dark], found {config.sections()}")
else:
    scheme = config["Dark"]
    errors += [f"{ini_path}: missing base key {key}" for key in sorted(base - set(scheme))]
    errors += [
        f"{ini_path}: {key} = {value} is not a six-digit hex color"
        for key, value in scheme.items()
        if not re.fullmatch(r"[0-9A-F]{6}", value)
    ]
    used = set(re.findall(r"var\(--spice-(?:rgb-)?([a-z-]+)\)", open(css_path).read()))
    errors += [f"{css_path}: reads --spice-{key}, which color.ini does not define" for key in sorted(used - set(scheme))]
for error in errors:
    print(error, file=sys.stderr)
sys.exit(1 if errors else 0)
PY
}
