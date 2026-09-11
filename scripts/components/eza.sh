#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# eza reads a single fixed theme path, so the installer never touches a user's
# existing theme.yml. The ready-to-merge file is published for manual use.
package_eza() {
    cp "$ROOT/cli/eza/theme.yml" "$DIST/Primer-Dark-Eza.yml"
    register_artifact Primer-Dark-Eza.yml
}
