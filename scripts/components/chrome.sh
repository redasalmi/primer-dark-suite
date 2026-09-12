#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

check_chrome() {
    jq -e . "$ROOT/browsers/chrome/primer-dark/manifest.json" >/dev/null
}
