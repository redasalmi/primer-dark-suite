#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

package_helium() {
    require_command zip "zip is required to package the Helium theme."
    jq -e . "$ROOT/browsers/helium/primer-dark/manifest.json" >/dev/null
    (
        cd "$ROOT/browsers/helium/primer-dark"
        zip -q -X "$DIST/Primer-Dark-Helium.zip" manifest.json
    )
    register_artifact Primer-Dark-Helium.zip
}
