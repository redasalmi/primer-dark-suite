#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

package_chrome() {
    require_command zip "zip is required to package the Google Chrome theme."
    jq -e . "$ROOT/browsers/chrome/primer-dark/manifest.json" >/dev/null
    (
        cd "$ROOT/browsers/chrome/primer-dark"
        # The Chrome Web Store requires the 128x128 icon in the package.
        zip -q -X "$DIST/Primer-Dark-Chrome.zip" manifest.json icon128.png
    )
    register_artifact Primer-Dark-Chrome.zip
}
