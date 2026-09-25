#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_gtk() {
    :
}

install_gtk() {
    # The installed directory is wholly owned by Primer Dark, so replace it
    # instead of merging files that an older release may have left behind.
    rm -rf -- "$GTK_THEME_DEST"
    mkdir -p -- "$GTK_THEME_DEST"
    cp -R -- "$GTK_THEME_SOURCE/." "$GTK_THEME_DEST/"
    printf 'Installed the GTK theme at %s\n' "$GTK_THEME_DEST"
    echo 'Select "primer-dark" in your GTK theme settings, or set GTK_THEME=primer-dark.'
}

gtk_settings_ini_uses_primer_dark() {
    settings_file=$1
    [ -f "$settings_file" ] || return 1
    awk '
        /^[[:space:]]*gtk-theme-name[[:space:]]*=/ {
            value = $0
            sub(/^[^=]*=[[:space:]]*/, "", value)
            sub(/[[:space:]]+$/, "", value)
            if (value == "primer-dark") found = 1
        }
        END { exit found ? 0 : 1 }
    ' "$settings_file"
}

guard_gtk() {
    [ -d "$GTK_THEME_DEST" ] || return 0

    active_gtk_theme=0
    case "${GTK_THEME:-}" in primer-dark|primer-dark:*) active_gtk_theme=1 ;; esac
    for settings_file in "$CONFIG_HOME/gtk-3.0/settings.ini" "$CONFIG_HOME/gtk-4.0/settings.ini"; do
        if gtk_settings_ini_uses_primer_dark "$settings_file"; then
            active_gtk_theme=1
        fi
    done
    # Plasma also publishes the GTK theme to X11 GTK applications through
    # xsettingsd, whose configuration keeps its own copy of the theme name.
    if [ -f "$CONFIG_HOME/xsettingsd/xsettingsd.conf" ] \
        && grep -Eq '^[[:space:]]*Net/ThemeName[[:space:]]+"primer-dark"' "$CONFIG_HOME/xsettingsd/xsettingsd.conf"; then
        active_gtk_theme=1
    fi
    if [ "$active_gtk_theme" -eq 0 ] && command -v gsettings >/dev/null 2>&1; then
        gsettings_gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || true)
        case "$gsettings_gtk_theme" in
            "'primer-dark'"|'"primer-dark"') active_gtk_theme=1 ;;
        esac
    fi
    if [ "$active_gtk_theme" -eq 1 ]; then
        cat >&2 <<'EOF'
The Primer Dark GTK theme is currently active. Select another GTK theme before uninstalling it.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_gtk() {
    rm -rf -- "$GTK_THEME_DEST"
}

check_gtk() {
    require_command python3 "python3 with PyGObject is required to validate the GTK stylesheets."

    python3 - "$ROOT/gtk/primer-dark/gtk-3.0/gtk.css" "$ROOT/gtk/primer-dark/gtk-3.0/gtk-dark.css" <<'PY'
import sys

try:
    import gi

    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk
except (ImportError, ValueError) as error:
    sys.exit(f"PyGObject with the Gtk 3.0 typelib is required: {error}")

if (Gtk.get_major_version(), Gtk.get_minor_version()) < (3, 24):
    sys.exit(
        "GTK 3.24 or newer is required to validate the GTK 3 stylesheet; "
        f"found {Gtk.get_major_version()}.{Gtk.get_minor_version()}"
    )

import contextlib
import os


@contextlib.contextmanager
def muted_stderr():
    # Loading a theme without a display makes GTK log icon-theme criticals that
    # are irrelevant here. Parse failures are raised as exceptions instead, so
    # muting GTK's own logging keeps the output limited to actionable messages.
    saved = os.dup(2)
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, 2)
    os.close(devnull)
    try:
        yield
    finally:
        os.dup2(saved, 2)
        os.close(saved)


for path in sys.argv[1:]:
    provider = Gtk.CssProvider()
    try:
        with muted_stderr():
            provider.load_from_path(path)
    except Exception as error:  # noqa: BLE001 - surface the native parser message
        sys.exit(f"{path}: {error}")
PY

    python3 - "$ROOT/gtk/primer-dark/gtk-4.0/gtk.css" "$ROOT/gtk/primer-dark/gtk-4.0/gtk-dark.css" "$ROOT/gtk/libadwaita/gtk-4.0.css" <<'PY'
import sys

try:
    import gi

    gi.require_version("Gtk", "4.0")
    from gi.repository import Gtk
except (ImportError, ValueError) as error:
    sys.exit(f"PyGObject with the Gtk 4.0 typelib is required: {error}")

if (Gtk.get_major_version(), Gtk.get_minor_version()) < (4, 20):
    sys.exit(
        "GTK 4.20 or newer is required to validate the GTK 4 stylesheet; "
        f"found {Gtk.get_major_version()}.{Gtk.get_minor_version()}"
    )

import contextlib
import os


@contextlib.contextmanager
def muted_stderr():
    # Loading a theme without a display makes GTK log icon-theme criticals that
    # are irrelevant here. Parsing errors are reported through the provider's
    # parsing-error signal instead, so muting GTK's own logging keeps the output
    # limited to actionable messages.
    saved = os.dup(2)
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, 2)
    os.close(devnull)
    try:
        yield
    finally:
        os.dup2(saved, 2)
        os.close(saved)


failed = False

for path in sys.argv[1:]:
    errors = []
    provider = Gtk.CssProvider()
    provider.connect(
        "parsing-error",
        lambda _provider, section, error, errors=errors: errors.append(
            f"{section.to_string()}: {error.message}"
        ),
    )
    with muted_stderr():
        provider.load_from_path(path)
    for message in errors:
        print(f"{path}: {message}", file=sys.stderr)
        failed = True

if failed:
    sys.exit(1)
PY
}
