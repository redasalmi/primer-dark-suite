#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# Papirus-Dark resolves most of its icons through relative links into
# Papirus, so both themes are installed side by side.
PAPIRUS_THEMES="Papirus Papirus-Dark"
ICONS_SELECTED=0
ICONS_STAGING=""

cleanup_icons_temps() {
    [ -z "$ICONS_STAGING" ] || rm -rf -- "$ICONS_STAGING"
    ICONS_STAGING=""
}

# Succeeds when an icon theme named NAME is installed on the icon search path
# (the user data directory, ~/.icons, and every XDG data directory), ignoring
# a copy that this suite installed.
icon_theme_installed_elsewhere() {
    icon_search_path="$ICONS_ROOT"
    if [ -n "${HOME:-}" ]; then
        icon_search_path="$icon_search_path:$HOME/.icons"
    fi
    old_ifs=$IFS
    IFS=:
    for data_dir in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
        icon_search_path="$icon_search_path:$data_dir/icons"
    done
    found_theme=1
    for icon_root in $icon_search_path; do
        if [ -f "$icon_root/$1/index.theme" ] && [ ! -f "$icon_root/$1/$PAPIRUS_MARKER" ]; then
            found_theme=0
            break
        fi
    done
    IFS=$old_ifs
    return "$found_theme"
}

preflight_icons() {
    ICONS_SELECTED=0
    if icon_theme_installed_elsewhere Papirus-Dark; then
        return 0
    fi

    # Only directories that carry the suite's marker may be replaced.
    for papirus_theme in $PAPIRUS_THEMES; do
        if [ -e "$ICONS_ROOT/$papirus_theme" ] && [ ! -f "$ICONS_ROOT/$papirus_theme/$PAPIRUS_MARKER" ]; then
            printf '%s already exists and was not installed by Primer Dark. Remove it or install Papirus-Dark from your distribution, then retry.\n' "$ICONS_ROOT/$papirus_theme" >&2
            exit 1
        fi
    done
    require_command tar "tar is required to install Papirus-Dark."
    fetch_verified "$PAPIRUS_URL" "$PAPIRUS_SHA256"
    ICONS_SELECTED=1
}

install_icons() {
    if [ "$ICONS_SELECTED" -eq 0 ]; then
        # A copy installed by an earlier run is no longer needed once
        # Papirus-Dark is installed elsewhere, typically by the distribution.
        for papirus_theme in $PAPIRUS_THEMES; do
            if [ -f "$ICONS_ROOT/$papirus_theme/$PAPIRUS_MARKER" ]; then
                rm -rf -- "${ICONS_ROOT:?}/$papirus_theme"
            fi
        done
        echo 'Papirus-Dark is already installed. Select "Papirus-Dark" in System Settings → Colors & Themes → Icons.'
        return 0
    fi

    mkdir -p -- "$ICONS_ROOT"
    ICONS_STAGING=$(mktemp -d "$ICONS_ROOT/.primer-dark-papirus.XXXXXX")
    tar -xzf "$DOWNLOAD_CACHE/$PAPIRUS_SHA256" -C "$ICONS_STAGING" --strip-components=1 \
        "papirus-icon-theme-$PAPIRUS_VERSION/Papirus" "papirus-icon-theme-$PAPIRUS_VERSION/Papirus-Dark"
    for papirus_theme in $PAPIRUS_THEMES; do
        printf '%s\n' "$PAPIRUS_VERSION" > "$ICONS_STAGING/$papirus_theme/$PAPIRUS_MARKER"
        rm -rf -- "${ICONS_ROOT:?}/$papirus_theme"
        mv -- "$ICONS_STAGING/$papirus_theme" "$ICONS_ROOT/$papirus_theme"
        if command -v gtk-update-icon-cache >/dev/null 2>&1; then
            gtk-update-icon-cache -q -f "$ICONS_ROOT/$papirus_theme" >/dev/null 2>&1 || true
        fi
    done
    cleanup_icons_temps

    printf 'Installed Papirus-Dark %s at %s\n' "$PAPIRUS_VERSION" "$ICONS_ROOT"
    echo 'Select "Papirus-Dark" in System Settings → Colors & Themes → Icons.'
}

guard_icons() {
    installed_copy=0
    for papirus_theme in $PAPIRUS_THEMES; do
        if [ -f "$ICONS_ROOT/$papirus_theme/$PAPIRUS_MARKER" ]; then
            installed_copy=1
        fi
    done
    [ "$installed_copy" -eq 1 ] || return 0
    # Papirus-Dark stays available when another copy is installed.
    if icon_theme_installed_elsewhere Papirus-Dark; then
        return 0
    fi

    selected_papirus=0
    if command -v kreadconfig6 >/dev/null 2>&1; then
        selected_icon_theme=$(kreadconfig6 --file kdeglobals --group Icons --key Theme 2>/dev/null || true)
        case "$selected_icon_theme" in
            Papirus|Papirus-Dark) selected_papirus=1 ;;
        esac
    fi
    # Plasma mirrors the icon theme into the GTK settings and xsettingsd.
    for settings_file in "$CONFIG_HOME/gtk-3.0/settings.ini" "$CONFIG_HOME/gtk-4.0/settings.ini"; do
        if [ -f "$settings_file" ] \
            && grep -Eq '^[[:space:]]*gtk-icon-theme-name[[:space:]]*=[[:space:]]*Papirus(-Dark)?[[:space:]]*$' "$settings_file"; then
            selected_papirus=1
        fi
    done
    if [ -f "$CONFIG_HOME/xsettingsd/xsettingsd.conf" ] \
        && grep -Eq '^[[:space:]]*Net/IconThemeName[[:space:]]+"Papirus(-Dark)?"' "$CONFIG_HOME/xsettingsd/xsettingsd.conf"; then
        selected_papirus=1
    fi
    if [ "$selected_papirus" -eq 1 ]; then
        cat >&2 <<'EOF'
Papirus-Dark is selected and only the copy installed by Primer Dark provides it. Select another icon theme, or install Papirus-Dark from your distribution, before uninstalling.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_icons() {
    for papirus_theme in $PAPIRUS_THEMES; do
        if [ -f "$ICONS_ROOT/$papirus_theme/$PAPIRUS_MARKER" ]; then
            rm -rf -- "${ICONS_ROOT:?}/$papirus_theme"
        fi
    done
}

check_icons() {
    # The Papirus pin is checked offline: a dated release tag, a SHA-256
    # checksum, and the GitHub archive URL for exactly that tag.
    case "$PAPIRUS_VERSION" in
        ''|*[!0-9]*) echo "PAPIRUS_VERSION must be a dated Papirus release tag." >&2; exit 1 ;;
    esac
    if [ "${#PAPIRUS_SHA256}" -ne 64 ] || printf '%s' "$PAPIRUS_SHA256" | grep -q '[^0-9a-f]'; then
        echo "PAPIRUS_SHA256 must be a SHA-256 checksum." >&2
        exit 1
    fi
    if [ "$PAPIRUS_URL" != "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/$PAPIRUS_VERSION.tar.gz" ]; then
        echo "PAPIRUS_URL must be the GitHub archive of PAPIRUS_VERSION." >&2
        exit 1
    fi
}
