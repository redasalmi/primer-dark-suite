#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# fzf has no theme discovery path; it is configured through FZF_DEFAULT_OPTS in
# the user's shell, so the installer does not edit shared shell configuration.
check_fzf() {
    require_command fish "fish is required to validate the fish fzf snippet."

    sh -n "$ROOT/cli/fzf/primer-dark.sh"
    fish --no-execute "$ROOT/cli/fzf/primer-dark.fish"

    # The POSIX and fish snippets must carry the same color set.
    sh_colors=$(sed -n "s/^FZF_DEFAULT_OPTS_PRIMER_DARK='\(.*\)'\$/\1/p" "$ROOT/cli/fzf/primer-dark.sh")
    fish_colors=$(sed -n "s/^set -g FZF_DEFAULT_OPTS_PRIMER_DARK '\(.*\)'\$/\1/p" "$ROOT/cli/fzf/primer-dark.fish")
    if [ -z "$sh_colors" ] || [ "$sh_colors" != "$fish_colors" ]; then
        echo "The POSIX and fish fzf snippets define different color sets." >&2
        exit 1
    fi
}
