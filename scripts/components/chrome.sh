#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

package_chrome() {
    require_command zip "zip is required to package the Google Chrome theme."
    jq -e . "$ROOT/browsers/chrome/primer-dark/manifest.json" >/dev/null
    (
        cd "$ROOT/browsers/chrome/primer-dark"
        zip -q -X "$DIST/Primer-Dark-Chrome.zip" manifest.json
    )
    register_artifact Primer-Dark-Chrome.zip
}
