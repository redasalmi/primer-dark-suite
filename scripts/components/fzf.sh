#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# fzf has no theme discovery path; it is configured through FZF_DEFAULT_OPTS in
# the user's shell, so the installer does not edit shared shell configuration.
package_fzf() {
    sh -n "$ROOT/cli/fzf/primer-dark.sh"
    cp "$ROOT/cli/fzf/primer-dark.sh" "$DIST/Primer-Dark-Fzf.sh"
    register_artifact Primer-Dark-Fzf.sh
}
