#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

HERDR_CONFIG_TMP=""
HERDR_BACKUP_TMP=""
HERDR_STATE_TMP=""
HERDR_NEW_STATE=0
HERDR_MANAGED=0
HERDR_STATE_VALUE=""
HERDR_SOURCE_FINGERPRINT=""

cleanup_herdr_temps() {
    [ -z "$HERDR_CONFIG_TMP" ] || rm -f -- "$HERDR_CONFIG_TMP"
    [ -z "$HERDR_BACKUP_TMP" ] || rm -f -- "$HERDR_BACKUP_TMP"
    [ -z "$HERDR_STATE_TMP" ] || rm -f -- "$HERDR_STATE_TMP"
    HERDR_CONFIG_TMP=""
    HERDR_BACKUP_TMP=""
    HERDR_STATE_TMP=""
}

herdr_path_fingerprint() {
    fingerprint_label=$1
    fingerprint_path=$2
    if [ -f "$fingerprint_path" ]; then
        fingerprint_value=$(cksum < "$fingerprint_path") || return 1
        printf '%s:file:%s\n' "$fingerprint_label" "$fingerprint_value"
    elif [ -e "$fingerprint_path" ]; then
        printf '%s:other\n' "$fingerprint_label"
    else
        printf '%s:missing\n' "$fingerprint_label"
    fi
}

herdr_source_fingerprint() {
    herdr_path_fingerprint config "$HERDR_CONFIG" || return 1
    herdr_path_fingerprint backup "$HERDR_BACKUP" || return 1
    herdr_path_fingerprint state "$HERDR_STATE" || return 1
}

herdr_source_is_unchanged() {
    current_source_fingerprint=$(herdr_source_fingerprint) || return 1
    [ "$current_source_fingerprint" = "$HERDR_SOURCE_FINGERPRINT" ]
}

herdr_markers_are_ordered() {
    awk -v begin="$HERDR_BEGIN" -v end="$HERDR_END" '
        $0 == begin {
            if (seen_begin || seen_end || managed) bad = 1
            seen_begin = 1
            managed = 1
            next
        }
        $0 == end {
            if (!managed || seen_end) bad = 1
            seen_end = 1
            managed = 0
        }
        END {
            if (bad || !seen_begin || !seen_end || managed) exit 1
        }
    ' "$1"
}

preflight_herdr() {
    require_command herdr "herdr is required to install and validate the Herdr theme."
    require_command cksum "cksum is required to protect the Herdr configuration from concurrent changes."

    mkdir -p -- "$HERDR_DIR"
    HERDR_SOURCE_FINGERPRINT=$(herdr_source_fingerprint) || {
        echo "Cannot read the current Herdr configuration and restore state in $HERDR_DIR" >&2
        exit 1
    }
    begin_count=0
    end_count=0
    if [ -f "$HERDR_CONFIG" ]; then
        begin_count=$(grep -Fxc "$HERDR_BEGIN" "$HERDR_CONFIG" || true)
        end_count=$(grep -Fxc "$HERDR_END" "$HERDR_CONFIG" || true)
    fi
    if { [ "$begin_count" -ne 0 ] || [ "$end_count" -ne 0 ]; } \
        && { [ "$begin_count" -ne 1 ] || [ "$end_count" -ne 1 ]; }; then
        echo "Cannot update the Herdr theme because its managed markers are incomplete or duplicated: $HERDR_CONFIG" >&2
        exit 1
    fi
    if [ "$begin_count" -eq 1 ] && ! herdr_markers_are_ordered "$HERDR_CONFIG"; then
        echo "Cannot update the Herdr theme because its managed markers are out of order: $HERDR_CONFIG" >&2
        exit 1
    fi

    HERDR_CONFIG_TMP=$(mktemp "$HERDR_DIR/.primer-dark-config.XXXXXX")
    HERDR_NEW_STATE=0
    if [ "$begin_count" -eq 1 ]; then
        if [ ! -f "$HERDR_BACKUP" ] || [ ! -f "$HERDR_STATE" ]; then
            echo "Cannot update the managed Herdr theme because its restore state is missing from $HERDR_DIR" >&2
            exit 1
        fi
        herdr_state_value=$(cat "$HERDR_STATE")
        if [ "$herdr_state_value" != "created" ] && [ "$herdr_state_value" != "existing" ]; then
            echo "Cannot update the managed Herdr theme because its restore state is invalid in $HERDR_DIR" >&2
            exit 1
        fi
        awk -v begin="$HERDR_BEGIN" -v end="$HERDR_END" '
            $0 == begin { managed = 1; next }
            $0 == end { managed = 0; next }
            !managed { print }
        ' "$HERDR_CONFIG" > "$HERDR_CONFIG_TMP"
    else
        if [ -e "$HERDR_BACKUP" ] || [ -e "$HERDR_STATE" ]; then
            echo "Cannot install the Herdr theme because stale restore state exists in $HERDR_DIR" >&2
            exit 1
        fi
        HERDR_BACKUP_TMP=$(mktemp "$HERDR_DIR/.primer-dark-backup.XXXXXX")
        HERDR_STATE_TMP=$(mktemp "$HERDR_DIR/.primer-dark-state.XXXXXX")
        HERDR_NEW_STATE=1
        if [ -f "$HERDR_CONFIG" ]; then
            printf 'existing\n' > "$HERDR_STATE_TMP"
            awk -v backup="$HERDR_BACKUP_TMP" -v config="$HERDR_CONFIG_TMP" '
                function theme_header(line, value) {
                    value = line
                    sub(/^[[:space:]]*/, "", value)
                    sub(/[[:space:]]*(#.*)?$/, "", value)
                    return value ~ /^\[theme(\.[A-Za-z0-9_-]+)*\]$/
                }
                function table_header(line, value) {
                    value = line
                    sub(/^[[:space:]]*/, "", value)
                    sub(/[[:space:]]*(#.*)?$/, "", value)
                    return value ~ /^\[\[?[^]]+\]\]?$/
                }
                {
                    is_theme_header = theme_header($0)
                    if (is_theme_header) {
                        theme = 1
                    } else if (table_header($0)) {
                        theme = 0
                    }
                    if (theme) {
                        print > backup
                    } else {
                        print > config
                    }
                }
            ' "$HERDR_CONFIG"
        else
            printf 'created\n' > "$HERDR_STATE_TMP"
        fi
    fi

    {
        printf '%s\n' "$HERDR_BEGIN"
        cat "$ROOT/cli/herdr/primer-dark.toml"
        printf '%s\n' "$HERDR_END"
    } >> "$HERDR_CONFIG_TMP"

    if ! HERDR_CONFIG_PATH="$HERDR_CONFIG_TMP" herdr config check; then
        echo "Herdr rejected the merged Primer Dark configuration; the existing configuration was not changed." >&2
        exit 1
    fi
    if ! herdr_source_is_unchanged; then
        cleanup_herdr_temps
        echo "The Herdr configuration or restore state changed during preflight; rerun the installer." >&2
        exit 1
    fi
}

install_herdr() {
    if ! herdr_source_is_unchanged; then
        cleanup_herdr_temps
        echo "The Herdr configuration or restore state changed after preflight; no Herdr files were replaced. Rerun the installer." >&2
        exit 1
    fi

    if [ "$HERDR_NEW_STATE" -eq 1 ]; then
        mv -- "$HERDR_BACKUP_TMP" "$HERDR_BACKUP"
        HERDR_BACKUP_TMP=""
        mv -- "$HERDR_STATE_TMP" "$HERDR_STATE"
        HERDR_STATE_TMP=""
    fi
    mv -- "$HERDR_CONFIG_TMP" "$HERDR_CONFIG"
    HERDR_CONFIG_TMP=""
    printf 'Installed and enabled the Herdr theme in %s\n' "$HERDR_CONFIG"
    echo 'Run "herdr server reload-config" to update a running Herdr session.'
}

guard_herdr() {
    HERDR_MANAGED=0
    HERDR_STATE_VALUE=""
    if [ -e "$HERDR_BACKUP" ] || [ -e "$HERDR_STATE" ]; then
        if [ ! -f "$HERDR_BACKUP" ] || [ ! -f "$HERDR_STATE" ] || [ ! -f "$HERDR_CONFIG" ]; then
            cat >&2 <<EOF
The managed Herdr theme cannot be safely restored because its configuration or restore state is missing from $HERDR_DIR.
No files were removed.
EOF
            exit 1
        fi
        begin_count=$(grep -Fxc "$HERDR_BEGIN" "$HERDR_CONFIG" || true)
        end_count=$(grep -Fxc "$HERDR_END" "$HERDR_CONFIG" || true)
        HERDR_STATE_VALUE=$(cat "$HERDR_STATE")
        if [ "$begin_count" -ne 1 ] || [ "$end_count" -ne 1 ] \
            || ! herdr_markers_are_ordered "$HERDR_CONFIG" \
            || { [ "$HERDR_STATE_VALUE" != "created" ] && [ "$HERDR_STATE_VALUE" != "existing" ]; }; then
            cat >&2 <<EOF
The managed Herdr theme markers or restore state are invalid in $HERDR_DIR.
No files were removed.
EOF
            exit 1
        fi
        HERDR_MANAGED=1
    elif [ -f "$HERDR_CONFIG" ] \
        && { grep -Fqx "$HERDR_BEGIN" "$HERDR_CONFIG" || grep -Fqx "$HERDR_END" "$HERDR_CONFIG"; }; then
        cat >&2 <<EOF
The managed Herdr theme has no restore state in $HERDR_DIR.
No files were removed.
EOF
        exit 1
    fi
}

uninstall_herdr() {
    [ "$HERDR_MANAGED" -eq 1 ] || return 0

    herdr_config_tmp=$(mktemp "$HERDR_DIR/.primer-dark-config.XXXXXX")
    awk -v begin="$HERDR_BEGIN" -v end="$HERDR_END" '
        $0 == begin { managed = 1; next }
        $0 == end { managed = 0; next }
        !managed { print }
    ' "$HERDR_CONFIG" > "$herdr_config_tmp"
    if [ -s "$HERDR_BACKUP" ]; then
        cat "$HERDR_BACKUP" >> "$herdr_config_tmp"
    fi

    if command -v herdr >/dev/null 2>&1 \
        && ! HERDR_CONFIG_PATH="$herdr_config_tmp" herdr config check; then
        rm -f -- "$herdr_config_tmp"
        cat >&2 <<'EOF'
Herdr rejected the restored configuration. No files were removed.
EOF
        exit 1
    fi

    if [ "$HERDR_STATE_VALUE" = "created" ] \
        && ! grep -Eq '[^[:space:]]' "$herdr_config_tmp"; then
        rm -f -- "$HERDR_CONFIG" "$herdr_config_tmp"
    else
        mv -- "$herdr_config_tmp" "$HERDR_CONFIG"
    fi
    rm -f -- "$HERDR_BACKUP" "$HERDR_STATE"
    printf 'Restored the previous Herdr theme configuration in %s\n' "$HERDR_CONFIG"
}
