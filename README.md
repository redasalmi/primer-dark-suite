# Primer Dark Suite

An unofficial GitHub Primer Dark-inspired theme suite for KDE Plasma 6, Konsole, Ghostty, Herdr, Pi, and Zed.

## Included in v1

- complete KDE/Qt color scheme;
- native Breeze window decoration with Primer-colored titlebars, borders, and shadows;
- Plasma 6 Global Theme KPackage;
- Breeze application style plus a custom Plasma style with crisp Primer borders around launchers, tray popups, tooltips, and desktop widgets;
- Breeze Dark icons and Breeze cursors;
- logo-free Plasma splash screen;
- native Konsole color scheme with coordinated normal, bright, and faint ANSI colors;
- optional color-only Konsole profile that does not declare shell or font settings;
- native Ghostty theme with a coordinated ANSI 16-color palette;
- complete Herdr TUI palette covering chrome, sidebar states, text hierarchy, and agent statuses;
- complete Pi TUI theme covering messages, tools, Markdown, diffs, syntax, search, and thinking levels;
- complete Zed theme covering the workbench, editor, syntax, diagnostics, Git states, collaboration, Vim modes, and integrated terminal;
- System Settings previews and offline packaging scripts.

Primer Dark does **not** replace your panel layout, wallpaper, fonts, or window-button order. KDE Plasma Login theming is intentionally outside the v1 scope because login-manager integration is system-level and requires separate packaging and safety work.

## Requirements

- KDE Plasma 6
- `kpackagetool6`
- `plasma-apply-lookandfeel` when using `--apply`
- Konsole when installing the optional KDE terminal theme
- Ghostty when installing the optional terminal theme
- Herdr 0.8.2 or newer when installing the TUI theme
- Pi when installing the optional CLI coding-agent theme
- Zed when installing the optional editor theme

The release and validation helper additionally uses `jq`, `xmllint`, and standard Unix archive tools.

## Install

```sh
./install.sh
```

Then select **Primer Dark** in **System Settings → Colors & Themes → Global Theme**.

To install and apply in one step:

```sh
./install.sh --apply
```

To additionally install the Konsole color scheme and optional color-only profile:

```sh
./install.sh --konsole
```

Select **Primer Dark** under **Settings → Manage Profiles → Appearance** to preserve every setting in your current profile, or switch to the installed **Primer Dark** profile. The optional profile declares only the color scheme and cursor colors; all other behavior inherits from Konsole's fallback profile. Konsole's faint colors are intentional 50% blends of the normal ANSI colors over the main background, matching Ghostty's `faint-opacity = 0.5` behavior.

To additionally install the Ghostty theme:

```sh
./install.sh --ghostty
```

Then add this line to `~/.config/ghostty/config.ghostty`:

```ini
theme = Primer Dark
```

To install and enable the Herdr theme:

```sh
./install.sh --herdr
```

The installer replaces only Herdr's `[theme]` tables, preserves the rest of `~/.config/herdr/config.toml`, and saves the previous theme tables for uninstall. Reload a running session with:

```sh
herdr server reload-config
```

Herdr does not currently discover standalone theme files, so this opt-in installation safely merges [`cli/herdr/primer-dark.toml`](cli/herdr/primer-dark.toml) into its shared configuration. A ready-to-merge copy is also published as `Primer-Dark-Herdr.toml` in release artifacts.

To additionally install the Pi theme:

```sh
./install.sh --pi
```

Select **Primer Dark** from Pi's `/settings` screen, or set it in `~/.pi/agent/settings.json`:

```json
{
  "theme": "Primer Dark"
}
```

To additionally install the Zed theme:

```sh
./install.sh --zed
```

Select **Primer Dark** from Zed's theme selector (`Ctrl+K`, `Ctrl+T`).

The installer preserves your existing Konsole, Ghostty, Herdr, Pi, and Zed settings. It writes only theme-owned files, plus the managed Herdr theme section when requested, to the current user's XDG and application directories, normally:

- `~/.local/share/color-schemes/PrimerDark.colors`
- `~/.local/share/aurorae/themes/PrimerDark/` (optional Aurorae window-decoration assets)
- `~/.local/share/plasma/desktoptheme/PrimerDark/`
- `~/.local/share/plasma/look-and-feel/io.github.redasalmi.primerdark.desktop/`
- `~/.local/share/konsole/PrimerDark.colorscheme` when using `--konsole`
- `~/.local/share/konsole/PrimerDark.profile` when using `--konsole`
- `~/.config/ghostty/themes/Primer Dark` when using `--ghostty`
- `~/.config/herdr/config.toml` plus hidden theme restore state beside it when using `--herdr`
- `~/.pi/agent/themes/primer-dark.json` when using `--pi`
- `~/.config/zed/themes/primer-dark.json` when using `--zed`

## Uninstall

First select another Global Theme and, if used, other Konsole, Ghostty, Pi, and Zed themes. Then run:

```sh
./uninstall.sh
```

The script refuses to remove Primer Dark while any installed file-based theme is active. It removes the managed Herdr section and restores the Herdr theme tables saved during installation.

## Build release artifacts

The finished theme assets are committed and installation does not require a generator. To regenerate button SVGs after changing their source template:

```sh
./scripts/generate-buttons.py
```

Create installable archives and checksums with:

```sh
./scripts/package.sh
```

Artifacts are written to `dist/`.

## Design tokens

[`palette/primer-dark.json`](palette/primer-dark.json) is the canonical palette for this suite. The implemented themes use these core roles as follows:

| Role | Color |
| --- | --- |
| Chrome | `#010409` |
| Main surface | `#0D1117` |
| Muted surface | `#151B23` |
| Raised control | `#212830` |
| Border | `#3D444D` |
| Primary text | `#F0F6FC` |
| Muted text | `#9198A1` |
| Accent text | `#4493F8` |
| Focus and selection | `#1F6FEB` |
| Success | `#3FB950` |
| Warning | `#D29922` |
| Error | `#F85149` |

See [`plan.md`](plan.md) for the researched architecture and scope.

## Attribution

Color values are derived from [Primer Primitives](https://github.com/primer/primitives), licensed under MIT by GitHub, Inc. This independent project is not affiliated with or endorsed by GitHub.

See [`NOTICE`](NOTICE) for details.

## License

MIT
