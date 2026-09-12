# Primer Dark Suite

An unofficial GitHub Primer Dark-inspired theme suite for KDE Plasma 6, Konsole, Ghostty, Mozilla Firefox, Google Chrome, Herdr, Pi, Zed, Cursor, Fastfetch, bat, btop, eza, fzf, Fish, tmux, and GTK 3/4.

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
- native Cursor/VS Code-compatible color theme extension covering the workbench, editor, syntax, semantic highlighting, diagnostics, Git decorations, integrated terminal, and ANSI colors;
- complete Fastfetch preset covering the logo, keys, title, output, separator, bars, and status colors;
- complete bat syntax-highlighting theme covering Markdown, diffs, comments, keywords, strings, numbers, types, functions, variables, and diagnostics;
- complete btop theme covering boxes, dividers, graphs, meters, process states, and pause/follow/banner colors;
- complete Fish theme with dark and unknown-terminal variants covering syntax, pager, selection, and completion colors;
- native GTK 3 and GTK 4 theme package covering windows, header bars, controls, entries, menus, popovers, tooltips, lists, selections, focus, disabled states, and destructive actions, plus a documented libadwaita color override;
- ready-to-merge eza `theme.yml` covering file kinds, permissions, sizes, users, Git states, SELinux contexts, and file types;
- shell-safe fzf color option set covering borders, prompts, matches, selections, and previews;
- ready-to-source tmux snippet covering the status bar, window states, pane borders, messages, copy mode, menus, and popups;
- native Manifest V3 Mozilla Firefox static theme covering every effective color exposed by Firefox's current theme API, published as [Primer Dark on addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/);
- native Manifest V3 Chromium theme covering every color exposed by Chromium's current theme API, usable in Chrome and other Chromium-based browsers;
- System Settings previews and offline validation scripts.

Primer Dark does **not** replace your panel layout, wallpaper, fonts, or window-button order. KDE Plasma Login theming is intentionally outside the v1 scope because login-manager integration is system-level and requires separate packaging and safety work.

## Requirements

- KDE Plasma 6
- `kpackagetool6`
- `plasma-apply-lookandfeel` when using `--apply`
- Konsole when installing the optional KDE terminal theme
- Ghostty when installing the optional terminal theme
- Herdr 0.8.2 or newer when installing the TUI theme
- Pi when installing the optional CLI coding-agent theme
- Zed 1.19.2 or newer when installing the optional editor theme
- Cursor 3.20.17, whose bundled VS Code 1.128.0 theme registry defines the validated color keys, when installing the optional editor theme extension
- Fastfetch 2.66.0 or newer (the currently validated target) when using the Fastfetch preset
- bat 0.26.x (the currently validated target) when using the bat theme
- btop 1.4.x (the currently validated target) when using the btop theme
- Fish 4.0 or newer when using the Fish theme
- GTK 3.24 or GTK 4.22 (the currently validated targets) when using the GTK themes
- eza 0.23.x (the currently validated target) when using the eza theme
- fzf 0.74.x (the currently validated target) when using the fzf color set
- tmux 3.7 (the currently validated target) when using the tmux snippet
- Mozilla Firefox 155.0 (the currently validated target) when using the Firefox theme
- Google Chrome 152.0.7977.75 (the currently validated target) when using the Chrome theme

The validation helper additionally uses `jq`, `xmllint`, and `python3` with PyGObject and the GTK 3 and GTK 4 typelibs.

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

Herdr does not currently discover standalone theme files, so this opt-in installation safely merges [`cli/herdr/primer-dark.toml`](cli/herdr/primer-dark.toml) into its shared configuration.

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

To additionally install the Cursor theme extension:

```sh
./install.sh --cursor
```

Restart Cursor, then select **Primer Dark** in **Preferences: Theme: Color Theme**. The extension is installed as an unpacked VS Code-compatible theme extension, so Cursor owns the extension bookkeeping and no settings file is rewritten.

To additionally install the Fastfetch preset:

```sh
./install.sh --fastfetch
```

Then load it per invocation:

```sh
fastfetch --config primer-dark
```

Fastfetch has no persistent active-theme state; presets are selected per invocation and replace the loaded configuration. The preset is therefore installed as a user-local preset under `~/.local/share/fastfetch/presets/primer-dark.jsonc` and selected with `--config`. It is not merged into or used as the default `~/.config/fastfetch/config.jsonc`. To make it permanent without editing the shared config, alias `fastfetch` or add `--config primer-dark` to the invocation.

To additionally install the bat syntax-highlighting theme:

```sh
./install.sh --bat
```

Then build bat's theme cache and select it:

```sh
bat cache --build
bat --theme="Primer Dark" README.md
```

bat uses the theme file name as the theme name, so the installer writes `Primer Dark.tmTheme`. `bat cache --build` must be rerun after every install or update to refresh bat's theme cache. To make it permanent, add `--theme="Primer Dark"` to bat's configuration file or export `BAT_THEME="Primer Dark"`.

To additionally install the btop theme:

```sh
./install.sh --btop
```

Select **primer-dark** in btop's options menu, or set it in `~/.config/btop/btop.conf`:

```ini
color_theme = "primer-dark"
```

To additionally install the Fish theme:

```sh
./install.sh --fish
```

Preview it in the current shell, then save it for future shells (confirm the save prompt):

```sh
fish_config theme choose primer-dark
fish_config theme save primer-dark
```

`choose` loads session-local colors; `save primer-dark` loads the named theme into universal variables. Saved colors remain after the theme file is removed and do not automatically follow terminal light/dark changes. The installed file is only needed for choosing and previewing the theme.

To additionally install the GTK 3 and GTK 4 themes:

```sh
./install.sh --gtk
```

Select **Primer Dark** (`primer-dark`) in your GTK theme settings. On KDE Plasma, apply it to every GTK application through **System Settings → Colors & Themes → Application Style → Configure GNOME/GTK Application Style**, or with:

```sh
gsettings set org.gnome.desktop.interface gtk-theme primer-dark
```

To try it for a single application without changing the session setting:

```sh
GTK_THEME=primer-dark gtk4-demo
```

The installer writes a native theme package to `~/.local/share/themes/primer-dark/` with an `index.theme` and `gtk-3.0/` and `gtk-4.0/` stylesheets. The theme is dark-only, so its light and dark variants are identical. Plain GTK 3 and GTK 4 applications load it directly and it covers windows, header bars, controls, entries, menus, popovers, tooltips, lists, trees, notebooks, sidebars, selections, focus, disabled states, and destructive actions.

**Libadwaita applications ignore user GTK themes by design.** Libadwaita forces GTK's empty theme and adds its own stylesheet, so GNOME applications built with libadwaita keep their bundled appearance no matter which GTK theme is selected. To recolor them, merge [`gtk/libadwaita/gtk-4.0.css`](gtk/libadwaita/gtk-4.0.css) into `~/.config/gtk-4.0/gtk.css`, or copy it there when that file does not exist yet. That override defines only libadwaita's color variables, so it recolors libadwaita without replacing its layout or widget styles. It is not installed automatically because `~/.config/gtk-4.0/gtk.css` is shared GTK configuration that affects every GTK 4 application in the session, it can conflict with an existing override, and upstream does not support recoloring libadwaita.

Flatpak applications do not see `~/.local/share/themes` unless the sandbox is granted access. Themes can be shared with:

```sh
flatpak override --user --filesystem=xdg-data/themes:ro
```

After that, select `primer-dark` inside the sandbox, or test with a per-application override:

```sh
flatpak override --user --env=GTK_THEME=primer-dark <app-id>
```

Flatpak guidance is documented only; it was not verified in this environment.

eza, fzf, and tmux have no safe user-local theme discovery path, so they are intentionally not installed by the root script. Use a repository checkout:

- **eza:** copy `cli/eza/theme.yml` to `$EZA_CONFIG_DIR/theme.yml` or `~/.config/eza/theme.yml`, backing up any existing `theme.yml` first, since eza only reads that single fixed path.
- **fzf:** source `cli/fzf/primer-dark.sh` from your shell startup file, or copy its `FZF_DEFAULT_OPTS_PRIMER_DARK` value into an existing `FZF_DEFAULT_OPTS`. The snippet appends nothing when a `--color` option is already present.
- **tmux:** add `source-file /path/to/primer-dark.conf` to `~/.tmux.conf` and reload with `tmux source-file ~/.tmux.conf`. Only styles are set, so your status format and key bindings are preserved.

Firefox requires Mozilla signing for permanent installation in release and beta builds, so its theme is intentionally not installed by the root script. It is published as [Primer Dark on addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/).

**Install from the store:** open the [listing](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/) and choose **Add to Firefox**. Mozilla signs the theme and Firefox updates it through your profile, so nothing is copied into a user-local theme directory and the install and uninstall scripts never manage it.

**Preview an unreleased change instead** from a repository checkout:

1. Open `about:debugging#/runtime/this-firefox`.
2. Choose **Load Temporary Add-on**.
3. Select `browsers/firefox/primer-dark/manifest.json`.

The temporary theme remains active until it is removed from **This Firefox** or Firefox restarts. Remove it before installing the store version, because both builds share the add-on ID `primer-dark@redasalmi.github.io` and would otherwise appear as two entries in **Add-ons and themes**. `web-ext build --source-dir browsers/firefox/primer-dark` produces the same package as a zip that **Load Temporary Add-on** and the [addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/) submission both accept. The theme covers the frame, tabs, toolbars, address field, buttons, popups, new-tab page, and sidebar, and explicitly requests dark browser and content color schemes. It does not restyle arbitrary website content or DevTools.

Google Chrome requires interactive extension loading, so its theme is intentionally not installed by the root script. From a repository checkout:

1. Open `chrome://extensions`.
2. Enable **Developer mode**.
3. Choose **Load unpacked** and select `browsers/chrome/primer-dark/`.

Loading the package activates **Primer Dark** immediately. To update it, replace the files in the checkout and reload the unpacked extension. The theme styles Chrome's normal-browsing frame, tabs, toolbar, omnibox, bookmarks, and new-tab background. Chrome 152 deliberately retains its native incognito theme; internal pages, DevTools, website content, and the central new-tab search control also retain their own appearance. Other Chromium-based browsers can load the same directory from their equivalent extensions page, with rendering that may differ wherever the browser maps theme colors differently.

The installer preserves your existing Konsole, Ghostty, Herdr, Pi, Zed, Cursor, Fastfetch, bat, btop, Fish, and GTK settings. It writes only theme-owned files, plus the managed Herdr theme section when requested, to the current user's XDG and application directories, normally:

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
- `~/.cursor/extensions/redasalmi.primer-dark-1.0.0/` when using `--cursor`
- `~/.local/share/fastfetch/presets/primer-dark.jsonc` when using `--fastfetch`
- `~/.config/bat/themes/Primer Dark.tmTheme` when using `--bat`
- `~/.config/btop/themes/primer-dark.theme` when using `--btop`
- `~/.config/fish/themes/primer-dark.theme` when using `--fish`
- `~/.local/share/themes/primer-dark/` when using `--gtk`

## Uninstall

First select another Global Theme and, if used, other Konsole, Ghostty, Pi, Zed, Cursor, bat, btop, Fish, and GTK themes. The GTK theme must not be the active `gtk-theme-name` in `~/.config/gtk-3.0/settings.ini` or `~/.config/gtk-4.0/settings.ini`, the active `org.gnome.desktop.interface gtk-theme`, or the current `GTK_THEME` value. Then run:

```sh
./uninstall.sh
```

The script refuses to remove Primer Dark while any installed file-based theme is active. It removes the managed Herdr section and restores the Herdr theme tables saved during installation. The Fastfetch preset is not active state, so it is removed directly and only affects later `fastfetch --config primer-dark` invocations. The bat and btop files are removed only after their active-theme guards pass; bat's cache is left to the application. Fish's theme file is removed directly, leaving session-local and saved universal colors intact. The Cursor extension directory is removed only after its active-theme guard passes in the default profile and in every named profile. The GTK theme package is removed only after its active-theme guard passes; the manually merged libadwaita override in `~/.config/gtk-4.0/gtk.css` is never touched.

The script does not manage Firefox, Chrome, eza, fzf, or tmux. Remove a store-installed or signed Firefox theme from **Add-ons and themes → Themes**, or remove a temporary copy from `about:debugging#/runtime/this-firefox` or by restarting Firefox. To remove the Chrome theme, choose **Reset to default theme** in `chrome://settings/appearance`, then delete its extracted directory. The eza, fzf, and tmux files are manual copies: remove or restore them in your eza theme path, shell startup file, or `~/.tmux.conf`.

## Validate

The finished theme assets are committed and installation does not require a generator. To regenerate button SVGs after changing their source template:

```sh
./scripts/generate-buttons.py
```

Validate the palette and every asset that has an official parser with:

```sh
./scripts/check.sh
```

This checks the KDE package metadata and SVGs, the bat theme, both browser manifests, the Pi, Zed, Cursor, and Fastfetch files, the shell syntax of the fzf snippet, and the GTK 3, GTK 4, and libadwaita stylesheets. It requires `jq`, `xmllint`, and `python3` with PyGObject and the GTK 3 and GTK 4 typelibs, because the GTK stylesheets are validated with GTK's own CSS parser; the GTK 4 check needs GTK 4.20 or newer. [`.github/workflows/verify.yml`](.github/workflows/verify.yml) runs `shellcheck` and this script in a Fedora 44 container that matches the validated GTK target on every push to `main` and every pull request.

## Versioning

This project cuts no GitHub Releases and keeps no suite version. `install.sh` is the distribution channel for every port it can install, so a version number would have nothing to identify.

Versions exist only where the editor or browser format requires them, and only in these manifests:

- `browsers/firefox/primer-dark/manifest.json`
- `browsers/chrome/primer-dark/manifest.json`
- `editors/cursor/primer-dark/package.json`

The Cursor extension version appears twice and must be kept in sync: in `package.json` and in the installed directory name, which the installer builds from the version in `scripts/lib/common.sh`.

`KPlugin.Version` is deliberately absent from the KDE `metadata.json` files: KDE treats it as optional, and kpackagetool6 installs and updates those packages without it. Bump only the manifest of the editor or browser you are publishing to, and bump the two Cursor version locations together.

[`distribution.md`](distribution.md) lists every port's store or upstream channel, its publication status, the artifact to publish, and the requirements each channel imposes.

## Release the Firefox theme

[`.github/workflows/firefox-release.yml`](.github/workflows/firefox-release.yml) lints the Firefox theme, builds the unsigned package, and submits the manifest version to [addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/) with `web-ext sign --channel listed`.

One-time setup:

1. Sign in to addons.mozilla.org and open the [API credentials page](https://addons.mozilla.org/en-US/developers/addon/api/key/).
2. Generate a key and copy its **JWT issuer** (for example `user:12345:67`) and **JWT secret**; the secret is shown only once.
3. In the repository, add them under **Settings → Secrets and variables → Actions** as `WEB_EXT_API_KEY` (issuer) and `WEB_EXT_API_SECRET` (secret). The workflow reads both from the environment, so no other configuration is needed.
4. Keep the manifest add-on ID `primer-dark@redasalmi.github.io` unchanged, because AMO matches every submission to the existing listing by that ID.

To publish a version:

1. Bump `version` in [`browsers/firefox/primer-dark/manifest.json`](browsers/firefox/primer-dark/manifest.json). AMO rejects a version that already exists on any channel, so this is required.
2. Commit the bump to the default branch.
3. Run the workflow from the **Actions** tab (**Release Firefox theme → Run workflow**).

The workflow fails if the manifest version is not newer than the version published on AMO, if `web-ext lint` reports any warning, or if a secret is missing. It reads the published version from the public AMO API, so a forgotten bump is reported before the submission is attempted. It then submits the version and stops without waiting for review, because a review that outlasts the job is not a failure: the submission is already queued on AMO, and the update appears on the listing once it is approved.

To submit from a local checkout instead, install `web-ext` and provide the same credentials in the environment:

```sh
npm install --global web-ext@10.6.0
WEB_EXT_API_KEY=user:12345:67 WEB_EXT_API_SECRET=<secret> \
  web-ext sign --source-dir browsers/firefox/primer-dark --channel listed --approval-timeout 0
```

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
