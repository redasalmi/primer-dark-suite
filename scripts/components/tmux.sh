#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# tmux has no theme discovery path; it loads this file from ~/.tmux.conf, so the
# installer does not edit shared tmux configuration.
package_tmux() {
    cp "$ROOT/cli/tmux/primer-dark.conf" "$DIST/Primer-Dark-Tmux.conf"
    register_artifact Primer-Dark-Tmux.conf
}
