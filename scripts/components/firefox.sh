#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

package_firefox() {
    require_command zip "zip is required to package the Firefox theme."
    jq -e . "$ROOT/browsers/firefox/primer-dark/manifest.json" >/dev/null
    (
        cd "$ROOT/browsers/firefox/primer-dark"
        # The online listing icon is uploaded to addons.mozilla.org, but the
        # package also ships the icon for the installed add-on.
        zip -q -X "$DIST/Primer-Dark-Firefox.zip" manifest.json icon128.png
    )
    register_artifact Primer-Dark-Firefox.zip
}
