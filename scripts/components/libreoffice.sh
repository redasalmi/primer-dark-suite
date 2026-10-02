#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

LIBREOFFICE_OXT_TMP=""
LIBREOFFICE_OXT=""

cleanup_libreoffice_temps() {
    [ -z "$LIBREOFFICE_OXT_TMP" ] || rm -rf -- "$LIBREOFFICE_OXT_TMP"
    LIBREOFFICE_OXT_TMP=""
}

# Succeeds when the user profile holds the Primer Dark extension. A profile
# without uno_packages has no user extensions, and checking it first keeps
# unopkg from creating a profile on a machine that never ran LibreOffice.
libreoffice_extension_installed() {
    [ -d "$LIBREOFFICE_USER_DIR/uno_packages" ] || return 1
    command -v unopkg >/dev/null 2>&1 || return 1
    unopkg list "$LIBREOFFICE_EXT_ID" >/dev/null 2>&1
}

preflight_libreoffice() {
    require_command unopkg "unopkg is required to install the LibreOffice theme extension; install LibreOffice first."
    require_command python3 "python3 is required to package the LibreOffice theme extension."

    # Package the extension before any component is installed, so a packaging
    # failure cannot leave a partial installation.
    LIBREOFFICE_OXT_TMP=$(mktemp -d)
    LIBREOFFICE_OXT="$LIBREOFFICE_OXT_TMP/primer-dark.oxt"
    python3 - "$LIBREOFFICE_OXT" "$LIBREOFFICE_EXT_SOURCE" <<'PY'
import os
import sys
import zipfile

target, source = sys.argv[1:]
with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
    for directory, _, files in os.walk(source):
        for name in sorted(files):
            path = os.path.join(directory, name)
            archive.write(path, os.path.relpath(path, source))
PY
}

install_libreoffice() {
    # unopkg installs into the user profile under XDG_CONFIG_HOME and replaces
    # an installed version of the same extension identifier.
    if ! unopkg add --force --suppress-license "$LIBREOFFICE_OXT" >"$LIBREOFFICE_OXT_TMP/install.log" 2>&1; then
        echo "unopkg could not install the Primer Dark LibreOffice extension:" >&2
        cat -- "$LIBREOFFICE_OXT_TMP/install.log" >&2
        exit 1
    fi
    printf 'Installed the LibreOffice theme extension %s\n' "$LIBREOFFICE_EXT_ID"
    echo 'Select "Primer Dark" in Tools > Options > LibreOffice > Appearance, then restart LibreOffice.'
}

guard_libreoffice() {
    libreoffice_extension_installed || return 0

    if [ -f "$LIBREOFFICE_USER_DIR/registrymodifications.xcu" ] \
        && grep -Eq '<item oor:path="/org\.openoffice\.Office\.UI/ColorScheme"><prop oor:name="CurrentColorScheme"[^>]*><value>Primer Dark</value>' \
            "$LIBREOFFICE_USER_DIR/registrymodifications.xcu"; then
        cat >&2 <<'EOF2'
The Primer Dark LibreOffice theme is currently selected. Select another theme in Tools > Options > LibreOffice > Appearance before uninstalling it.
No files were removed.
EOF2
        exit 1
    fi
}

uninstall_libreoffice() {
    libreoffice_extension_installed || return 0
    if ! unopkg remove "$LIBREOFFICE_EXT_ID" >/dev/null 2>&1; then
        printf 'unopkg could not remove the LibreOffice extension %s.\n' "$LIBREOFFICE_EXT_ID" >&2
        exit 1
    fi
}

check_libreoffice() {
    # The theme is generated from the palette; a stale file fails the check.
    python3 "$ROOT/scripts/generate-libreoffice-theme.py" --check

    for xml_file in themes.xcu description.xml META-INF/manifest.xml; do
        xmllint --noout "$LIBREOFFICE_EXT_SOURCE/$xml_file"
    done

    # LibreOffice registers only the files the manifest lists, and finds the
    # identifier that install and uninstall use in description.xml.
    if ! grep -q 'manifest:full-path="themes.xcu" manifest:media-type="application/vnd.sun.star.configuration-data"' \
        "$LIBREOFFICE_EXT_SOURCE/META-INF/manifest.xml"; then
        echo "The LibreOffice manifest does not register themes.xcu as configuration data." >&2
        exit 1
    fi
    if ! grep -q "<identifier value=\"$LIBREOFFICE_EXT_ID\"/>" "$LIBREOFFICE_EXT_SOURCE/description.xml"; then
        printf 'The LibreOffice description.xml identifier is not %s.\n' "$LIBREOFFICE_EXT_ID" >&2
        exit 1
    fi
    for referenced in icon.png description/description-en.txt; do
        if [ ! -f "$LIBREOFFICE_EXT_SOURCE/$referenced" ]; then
            printf 'The LibreOffice extension is missing %s.\n' "$referenced" >&2
            exit 1
        fi
    done
}
