#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

check_firefox() {
    jq -e . "$ROOT/browsers/firefox/primer-dark/manifest.json" >/dev/null
}
