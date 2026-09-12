#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

preflight_konsole() {
    :
}

install_konsole() {
    install -Dm644 "$ROOT/kde/konsole/PrimerDark.colorscheme" "$KONSOLE_SCHEME_DEST"
    install -Dm644 "$ROOT/kde/konsole/PrimerDark.profile" "$KONSOLE_PROFILE_DEST"
    printf 'Installed the Konsole color scheme at %s\n' "$KONSOLE_SCHEME_DEST"
    printf 'Installed the optional color-only Konsole profile at %s\n' "$KONSOLE_PROFILE_DEST"
    echo 'Select "Primer Dark" in a Konsole profile or switch to the optional "Primer Dark" profile.'
}

guard_konsole() {
    [ -f "$KONSOLE_SCHEME_DEST" ] || return 0

    active_konsole_profile=""
    if command -v kreadconfig6 >/dev/null 2>&1; then
        active_konsole_profile=$(kreadconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile 2>/dev/null || true)
    fi
    if [ "$active_konsole_profile" = "PrimerDark.profile" ]; then
        cat >&2 <<'EOF'
The Primer Dark Konsole profile is currently the default. Select another default profile before uninstalling it.
No files were removed.
EOF
        exit 1
    fi

    for profile in "$DATA_HOME"/konsole/*.profile; do
        [ -f "$profile" ] || continue
        [ "$profile" = "$KONSOLE_PROFILE_DEST" ] && continue
        if grep -Eq '^[[:space:]]*ColorScheme[[:space:]]*=[[:space:]]*PrimerDark[[:space:]]*$' "$profile"; then
            cat >&2 <<EOF
A Konsole profile still references Primer Dark: $profile
Select another color scheme for that profile before uninstalling Primer Dark.
No files were removed.
EOF
            exit 1
        fi
    done
}

uninstall_konsole() {
    rm -f -- "$KONSOLE_SCHEME_DEST" "$KONSOLE_PROFILE_DEST"
}
