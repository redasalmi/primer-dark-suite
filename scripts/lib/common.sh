#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

# The *_DEST, *_SOURCE, and HERDR_* variables below are read by the component
# modules that source this file, so ShellCheck reports them as unused here.
# shellcheck disable=SC2034

: "${ROOT:?ROOT must be set before loading common.sh}"

PACKAGE_ID=io.github.redasalmi.primerdark.desktop
AURORAE_ID=PrimerDark
PLASMA_STYLE_ID=PrimerDark
COLOR_FILE=PrimerDark.colors
# ALL_COMPONENTS are safe for the root install and uninstall lifecycle.
ALL_COMPONENTS="kde konsole ghostty herdr pi zed cursor fastfetch bat btop fish gtk kvantum ktexteditor micro atuin codex claude godot blender libreoffice fonts icons"
# CHECK_COMPONENTS validate their own assets in a check_* hook.
CHECK_COMPONENTS="kde bat fastfetch pi zed cursor firefox chrome fzf gtk kvantum ktexteditor micro atuin claude godot blender libreoffice fonts icons"
# COMPONENT_MODULES are every module sourced by the install, uninstall, and
# check entry points.
COMPONENT_MODULES="$ALL_COMPONENTS firefox chrome fzf"
PLASMA_STYLE_SOURCE="$ROOT/kde/plasma-style/$PLASMA_STYLE_ID"
GLOBAL_SOURCE="$ROOT/kde/look-and-feel/$PACKAGE_ID"
CURSOR_EXT_SOURCE="$ROOT/editors/cursor/primer-dark"
CURSOR_EXT_ID=redasalmi.primer-dark
CURSOR_EXT_VERSION=1.0.0
KVANTUM_THEME_ID=PrimerDark
KVANTUM_THEME_SOURCE="$ROOT/kde/kvantum/$KVANTUM_THEME_ID"
LIBREOFFICE_EXT_SOURCE="$ROOT/office/libreoffice/primer-dark"
LIBREOFFICE_EXT_ID=io.github.redasalmi.primer-dark
FONTS_MANIFEST="$ROOT/fonts/sources.tsv"
# Papirus is downloaded from this pinned release tag and verified against the
# checksum of GitHub's archive for that tag.
PAPIRUS_VERSION=20260801
PAPIRUS_URL="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/$PAPIRUS_VERSION.tar.gz"
PAPIRUS_SHA256=646f622e9e7e9e65eef9d0ab58999d4920ddb33d98e6a75232627cfe3bd508f9
# Marks a Papirus directory as installed by this suite, so only those copies
# are ever replaced or removed.
PAPIRUS_MARKER=.primer-dark-suite
HERDR_BEGIN='# BEGIN Primer Dark Herdr theme (managed by primer-dark-suite)'
HERDR_END='# END Primer Dark Herdr theme (managed by primer-dark-suite)'

initialize_user_paths() {
    if [ -n "${XDG_DATA_HOME:-}" ]; then
        DATA_HOME=$XDG_DATA_HOME
    elif [ -n "${HOME:-}" ]; then
        DATA_HOME="$HOME/.local/share"
    else
        echo "HOME or XDG_DATA_HOME is required for user installation paths." >&2
        exit 1
    fi

    if [ -n "${XDG_CONFIG_HOME:-}" ]; then
        CONFIG_HOME=$XDG_CONFIG_HOME
    elif [ -n "${HOME:-}" ]; then
        CONFIG_HOME="$HOME/.config"
    else
        echo "HOME or XDG_CONFIG_HOME is required for user configuration paths." >&2
        exit 1
    fi

    if [ -n "${CODEX_HOME:-}" ]; then
        CODEX_DIR=$CODEX_HOME
    elif [ -n "${HOME:-}" ]; then
        CODEX_DIR="$HOME/.codex"
    else
        echo "HOME or CODEX_HOME is required for the Codex theme path." >&2
        exit 1
    fi

    # Claude Code keeps its global .claude.json inside CLAUDE_CONFIG_DIR when
    # that is set, and in the home directory otherwise.
    if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
        CLAUDE_DIR=$CLAUDE_CONFIG_DIR
        CLAUDE_GLOBAL_CONFIG="$CLAUDE_DIR/.claude.json"
    elif [ -n "${HOME:-}" ]; then
        CLAUDE_DIR="$HOME/.claude"
        CLAUDE_GLOBAL_CONFIG="$HOME/.claude.json"
    else
        echo "HOME or CLAUDE_CONFIG_DIR is required for the Claude Code theme path." >&2
        exit 1
    fi

    if [ -n "${PI_CODING_AGENT_DIR:-}" ]; then
        PI_AGENT_DIR=$PI_CODING_AGENT_DIR
    elif [ -n "${HOME:-}" ]; then
        PI_AGENT_DIR="$HOME/.pi/agent"
    else
        echo "HOME or PI_CODING_AGENT_DIR is required for the Pi theme path." >&2
        exit 1
    fi

    COLOR_DEST="$DATA_HOME/color-schemes/$COLOR_FILE"
    AURORAE_DEST="$DATA_HOME/aurorae/themes/$AURORAE_ID"
    PLASMA_STYLE_DEST="$DATA_HOME/plasma/desktoptheme/$PLASMA_STYLE_ID"
    GLOBAL_ROOT="$DATA_HOME/plasma/look-and-feel"
    GLOBAL_DEST="$GLOBAL_ROOT/$PACKAGE_ID"
    KONSOLE_SCHEME_DEST="$DATA_HOME/konsole/PrimerDark.colorscheme"
    KONSOLE_PROFILE_DEST="$DATA_HOME/konsole/PrimerDark.profile"
    GHOSTTY_DEST="$CONFIG_HOME/ghostty/themes/Primer Dark"
    HERDR_CONFIG=${HERDR_CONFIG_PATH:-"$CONFIG_HOME/herdr/config.toml"}
    HERDR_DIR=$(dirname -- "$HERDR_CONFIG")
    HERDR_BACKUP="$HERDR_DIR/.primer-dark-theme-backup.toml"
    HERDR_STATE="$HERDR_DIR/.primer-dark-theme-state"
    PI_DEST="$PI_AGENT_DIR/themes/primer-dark.json"
    ZED_DEST="$CONFIG_HOME/zed/themes/primer-dark.json"
    if [ -n "${CURSOR_EXTENSIONS_DIR:-}" ]; then
        CURSOR_EXT_ROOT=$CURSOR_EXTENSIONS_DIR
    elif [ -n "${HOME:-}" ]; then
        CURSOR_EXT_ROOT="$HOME/.cursor/extensions"
    else
        echo "HOME or CURSOR_EXTENSIONS_DIR is required for the Cursor extension path." >&2
        exit 1
    fi
    CURSOR_EXT_DEST="$CURSOR_EXT_ROOT/$CURSOR_EXT_ID-$CURSOR_EXT_VERSION"
    CURSOR_SETTINGS_FILE="$CONFIG_HOME/Cursor/User/settings.json"
    KVANTUM_THEME_DEST="$CONFIG_HOME/Kvantum/$KVANTUM_THEME_ID"
    FASTFETCH_DEST="$DATA_HOME/fastfetch/presets/primer-dark.jsonc"
    BAT_CONFIG_ROOT=${BAT_CONFIG_DIR:-"$CONFIG_HOME/bat"}
    BAT_THEME_DEST="$BAT_CONFIG_ROOT/themes/Primer Dark.tmTheme"
    BAT_CONFIG_FILE="$BAT_CONFIG_ROOT/config"
    BTOP_THEME_DEST="$CONFIG_HOME/btop/themes/primer-dark.theme"
    BTOP_CONFIG_FILE="$CONFIG_HOME/btop/btop.conf"
    FISH_THEME_DEST="$CONFIG_HOME/fish/themes/primer-dark.theme"
    GTK_THEME_SOURCE="$ROOT/gtk/primer-dark"
    GTK_THEME_DEST="$DATA_HOME/themes/primer-dark"
    KTEXTEDITOR_THEME_DEST="$DATA_HOME/org.kde.syntax-highlighting/themes/primer-dark.theme"
    MICRO_CONFIG_ROOT=${MICRO_CONFIG_HOME:-"$CONFIG_HOME/micro"}
    MICRO_THEME_DEST="$MICRO_CONFIG_ROOT/colorschemes/primer-dark.micro"
    ATUIN_CONFIG_ROOT=${ATUIN_CONFIG_DIR:-"$CONFIG_HOME/atuin"}
    ATUIN_THEME_DEST="${ATUIN_THEME_DIR:-"$ATUIN_CONFIG_ROOT/themes"}/primer-dark.toml"
    CODEX_THEME_DEST="$CODEX_DIR/themes/primer-dark.tmTheme"
    CLAUDE_THEME_DEST="$CLAUDE_DIR/themes/primer-dark.json"
    GODOT_CONFIG_ROOT="$CONFIG_HOME/godot"
    GODOT_THEME_DEST="$GODOT_CONFIG_ROOT/text_editor_themes/PrimerDark.tet"
    # Blender reads XDG_CONFIG_HOME and keeps one directory per minor version.
    BLENDER_CONFIG_ROOT="$CONFIG_HOME/blender"
    BLENDER_THEME_PATH="scripts/presets/interface_theme/Primer_Dark.xml"
    # unopkg resolves the same user profile from XDG_CONFIG_HOME.
    LIBREOFFICE_USER_DIR="$CONFIG_HOME/libreoffice/4/user"
    FONTS_ROOT="$DATA_HOME/fonts"
    FONTS_DEST="$FONTS_ROOT/primer-dark"
    ICONS_ROOT="$DATA_HOME/icons"

    if [ -n "${XDG_CACHE_HOME:-}" ]; then
        DOWNLOAD_CACHE="$XDG_CACHE_HOME/primer-dark-suite/downloads"
    elif [ -n "${HOME:-}" ]; then
        DOWNLOAD_CACHE="$HOME/.cache/primer-dark-suite/downloads"
    else
        echo "HOME or XDG_CACHE_HOME is required for the download cache." >&2
        exit 1
    fi
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum -- "$1" | cut -c1-64
    else
        shasum -a 256 -- "$1" | cut -c1-64
    fi
}

# Downloads URL to DEST, or copies it from PRIMER_DARK_DOWNLOADS, a directory
# of pre-downloaded files named as the last segment of their URL with %20 read
# as a space, for machines without network access.
download_to() {
    download_url=$1
    download_dest=$2
    download_name=$(printf '%s\n' "${download_url##*/}" | sed 's/%20/ /g')
    if [ -n "${PRIMER_DARK_DOWNLOADS:-}" ] && [ -f "$PRIMER_DARK_DOWNLOADS/$download_name" ]; then
        cp -- "$PRIMER_DARK_DOWNLOADS/$download_name" "$download_dest"
    elif command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL --proto '=https' --tlsv1.2 --retry 2 -o "$download_dest" "$download_url"; then
            rm -f -- "$download_dest"
            printf 'Could not download %s; nothing was installed.\n' "$download_url" >&2
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q --https-only -O "$download_dest" "$download_url"; then
            rm -f -- "$download_dest"
            printf 'Could not download %s; nothing was installed.\n' "$download_url" >&2
            exit 1
        fi
    else
        printf 'curl or wget is required to download %s.\n' "$download_name" >&2
        exit 1
    fi
}

# The zip archive that fetch_verified last downloaded, kept until
# cleanup_fetch_archive so its other members are extracted without
# downloading it again.
FETCH_ARCHIVE=""
FETCH_ARCHIVE_URL=""

cleanup_fetch_archive() {
    [ -z "$FETCH_ARCHIVE" ] || rm -f -- "$FETCH_ARCHIVE"
    FETCH_ARCHIVE=""
    FETCH_ARCHIVE_URL=""
}

# Makes a verified copy of URL available at "$DOWNLOAD_CACHE/SHA256".
# Downloads are pinned to an upstream release and kept by checksum, so a
# reinstall works offline. A URL of the form ARCHIVE#MEMBER names one file
# inside a zip release asset: the member is extracted with unzip, and only it
# is verified and cached. A file whose checksum does not match stops the
# installation before anything is installed.
fetch_verified() {
    fetch_url=$1
    fetch_sha256=$2
    fetch_dest="$DOWNLOAD_CACHE/$fetch_sha256"
    if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
        echo "sha256sum or shasum is required to verify downloads." >&2
        exit 1
    fi
    if [ -f "$fetch_dest" ] && [ "$(sha256_of "$fetch_dest")" = "$fetch_sha256" ]; then
        return 0
    fi

    mkdir -p -- "$DOWNLOAD_CACHE"
    fetch_tmp="$fetch_dest.part"
    case "$fetch_url" in
        *'#'*)
            fetch_archive_url=${fetch_url%%#*}
            fetch_member=${fetch_url#*#}
            if [ "$FETCH_ARCHIVE_URL" != "$fetch_archive_url" ]; then
                require_command unzip "unzip is required to extract ${fetch_archive_url##*/}."
                cleanup_fetch_archive
                FETCH_ARCHIVE="$DOWNLOAD_CACHE/archive.part"
                download_to "$fetch_archive_url" "$FETCH_ARCHIVE"
                FETCH_ARCHIVE_URL=$fetch_archive_url
            fi
            if ! unzip -p "$FETCH_ARCHIVE" "$fetch_member" > "$fetch_tmp" 2>/dev/null; then
                rm -f -- "$fetch_tmp"
                printf '%s has no %s; nothing was installed.\n' "$fetch_archive_url" "$fetch_member" >&2
                exit 1
            fi
            ;;
        *)
            download_to "$fetch_url" "$fetch_tmp"
            ;;
    esac

    if [ "$(sha256_of "$fetch_tmp")" != "$fetch_sha256" ]; then
        rm -f -- "$fetch_tmp"
        printf 'The checksum of %s does not match the pinned value; nothing was installed.\n' "$fetch_url" >&2
        exit 1
    fi
    mv -- "$fetch_tmp" "$fetch_dest"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '%s\n' "$2" >&2
        exit 1
    fi
}

# Succeeds when KEY is set to the string VALUE for TABLE in a TOML file, in any
# of the forms TOML allows: a [TABLE] section, a top-level dotted TABLE.KEY, or
# a top-level inline TABLE = { KEY = ... }. A file that exists but cannot be
# read stops the uninstall, because the active theme is then unknown.
toml_table_key_is() {
    toml_file=$1
    [ -e "$toml_file" ] || return 1
    toml_status=0
    [ -r "$toml_file" ] || toml_status=2
    if [ "$toml_status" -eq 0 ]; then
        awk -v table="$2" -v key="$3" -v value="$4" '
            BEGIN {
                sp = "[[:space:]]*"
                assign = key sp "=" sp "[\"\047]" value "[\"\047]"
                section_re = "^" sp "\\[" sp table sp "\\]" sp "(#.*)?$"
                dotted_re = "^" sp table sp "\\." sp assign
                inline_re = "^" sp table sp "=" sp "\\{([^}]*,)?" sp assign
                top_level = 1
            }
            /^[[:space:]]*\[/ { in_table = ($0 ~ section_re); top_level = 0; next }
            in_table && $0 ~ ("^" sp assign) { found = 1 }
            top_level && ($0 ~ dotted_re || $0 ~ inline_re) { found = 1 }
            END { exit found ? 0 : 1 }
        ' "$toml_file" || toml_status=$?
    fi
    case "$toml_status" in
        0|1) return "$toml_status" ;;
    esac
    printf 'Cannot read %s safely; no files were removed.\n' "$toml_file" >&2
    exit 1
}

component_is_known() {
    case " $ALL_COMPONENTS " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

load_components() {
    for component in $COMPONENT_MODULES; do
        # shellcheck source=/dev/null
        . "$ROOT/scripts/components/$component.sh"
    done
}

run_component_hook() {
    hook=$1
    component=$2
    hook_name="${hook}_${component}"
    "$hook_name"
}
