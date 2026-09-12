# Primer Dark Suite plan

## Goal

Build a complete, coherent dark theme suite for the applications, developer tools, terminals, and desktop components installed on this machine. Every port should translate GitHub Primer's semantic dark colors into the application's native theme format while preserving that application's interaction and accessibility conventions.

The KDE Plasma 6 global theme is the implemented foundation. Future work expands from that foundation in the priority order below.

## Principles

- Keep `palette/primer-dark.json` as the canonical source of color roles.
- Prefer official, native theme formats and supported configuration APIs.
- Reuse the same semantic roles for surfaces, text, borders, focus, selection, syntax, diffs, and status colors across ports.
- Preserve unrelated user settings; installers must be user-local, reversible, and opt-in.
- Commit ready-to-use generated assets so installation does not require a build tool.
- Keep unsupported patching integrations separate from the default installer.
- Add ports for tools actually installed and used before expanding to unrelated applications.

## Core palette

| Role | Value |
| --- | --- |
| Inset/chrome | `#010409` |
| Main background | `#0D1117` |
| Muted background | `#151B23` |
| Raised/control background | `#212830` |
| Default border | `#3D444D` |
| Essential boundary | `#656C76` |
| Primary text | `#F0F6FC` |
| Muted text | `#9198A1` |
| Accent text | `#4493F8` |
| Focus/selection | `#1F6FEB` |
| Success | `#3FB950` |
| Warning | `#D29922` |
| Error | `#F85149` |
| Severe | `#DB6D28` |
| Visited/completed | `#AB7DF8` |

## Implemented foundation

- Complete KDE/Qt color scheme.
- Native Breeze window decoration driven by Primer titlebar colors, borders, and shadows; Aurorae assets remain optional.
- Strict Plasma 6 Look-and-Feel KPackage.
- Breeze application and Plasma styles driven by Primer colors.
- Breeze Dark icons and Breeze cursors.
- Logo-free splash screen and System Settings previews.
- Offline install, uninstall, update, and validation scripts.
- Native Konsole color scheme with coordinated normal, bright, and faint ANSI colors plus an optional color-only profile.
- Native Ghostty theme with coordinated foreground, background, cursor, selection, and ANSI colors.
- Complete Pi TUI theme covering messages, tools, Markdown, diffs, syntax, search, thinking levels, and bash mode.
- Complete Herdr TUI palette covering chrome, sidebar states, text hierarchy, and agent statuses through its supported custom-theme configuration.
- Complete Zed theme covering the workbench, editor, syntax, diagnostics, Git states, collaboration, Vim modes, and integrated terminal.
- Native Fastfetch preset covering the logo palette, keys, title, output, separator, percentage and temperature thresholds, bars, and the default module structure.
- Native bat syntax theme covering Markdown, diffs, comments, keywords, strings, numbers, types, functions, variables, links, and diagnostics.
- Native btop theme completing all 48 supported keys for box outlines, dividers, graph text, meters, process gradients, and pause/follow/banner rows.
- Native Fish theme file with dark and unknown-terminal variants covering syntax, pager, selection, and completion colors.
- Ready-to-merge eza `theme.yml`, fzf color option set, and tmux style snippet for tools without a safe user-local theme discovery path.
- Native Manifest V3 Mozilla Firefox static theme covering all 38 effective color keys exposed by Firefox 155, plus explicit dark browser and content color schemes.
- Native Manifest V3 Chromium theme covering all 24 color keys exposed by Chromium 152, with standard Chrome frame, toolbar, active-tab, and omnibox surface mapping and usable in other Chromium-based browsers.
- Native GTK 3 and GTK 4 theme package that imports GTK's bundled Adwaita and Default dark stylesheets and overrides their colors with Primer roles, plus a documented libadwaita color override that libadwaita applications require because they ignore user GTK themes.
- No panel layout, wallpaper, font, or window-button-order changes.

## Suite roadmap

### 1. Konsole and Ghostty

Continue the terminal foundation so every terminal-based tool inherits a consistent base palette.

- **Konsole:** implemented as a native `.colorscheme` plus an optional profile that references it without changing existing profiles or declaring a shell or font.
- **Ghostty:** implemented as a native theme file using the shared foreground, background, cursor, selection, and ANSI 16-color mapping.
- Normal, bright, and dim ANSI colors, links, prompts, diffs, and long-running `btop` sessions have been visually validated in both terminals; selection was visually inspected in Konsole and Ghostty's selection mapping passed its native parser.

### 2. Zed and Cursor

Continue the editor theme family from the shared syntax and UI roles.

- **Zed:** implemented as a JSON theme covering the workbench, editor, terminal, diagnostics, diffs, syntax, collaboration colors, Vim modes, and interaction states.
- **Cursor:** create a VS Code-compatible color theme and extension metadata covering workbench, editor, integrated terminal, semantic highlighting, diagnostics, and Git decorations.
- Keep syntax colors aligned with the installed Zed GitHub Dark reference unless contrast or application semantics require an adjustment.

### 3. Pi, Herdr, bat, btop, fzf, eza, fastfetch, Fish and tmux

Build and maintain focused CLI/TUI ports that compose cleanly inside the terminal themes.

- **Pi:** implemented as a native JSON theme covering all required TUI, Markdown, tool, diff, syntax, thinking-level, search, and bash-mode tokens.
- **Herdr:** implemented as a complete `[theme.custom]` TOML palette. Because Herdr does not discover standalone theme files, the opt-in installer atomically merges managed theme tables into its shared configuration and saves the previous tables for uninstall.
- **bat:** implemented as a native `.tmTheme` installed to bat's theme directory. bat derives the theme name from the file name, so the asset is committed and installed as `Primer Dark.tmTheme`; users run `bat cache --build` and select it with `--theme="Primer Dark"` or `BAT_THEME`. Uninstall refuses while bat has it selected.
- **btop:** implemented as a native `.theme` file completing all 48 supported keys: box outlines, dividers, graph text, meter backgrounds, free/cached/available/used meters, download/upload graphs, process gradients, and pause/follow/banner rows. Users select `primer-dark` in the options menu or `color_theme`; uninstall refuses while it is selected.
- **fzf:** implemented as a shell-safe `FZF_DEFAULT_OPTS` snippet because fzf has no theme file or discovery path. The snippet is append-only and leaves an existing `--color` option untouched, so it is published for manual use instead of editing shell configuration.
- **eza:** implemented as a complete `theme.yml` derived from eza's built-in theme model and covering file kinds, permissions, sizes, users, links, Git states, SELinux contexts, punctuation, dates, and file types. Because eza reads a single fixed path, the file is published for manual merge rather than overwriting a possible existing theme.
- **fastfetch:** implemented as a native JSONC preset discovered from `~/.local/share/fastfetch/presets/` and loaded with `fastfetch --config primer-dark`. It colors the logo, keys, title, output, separator, percentage and temperature thresholds, and bars; the default module structure is preserved because Fastfetch presets replace the whole configuration rather than layering on top of `config.jsonc`.
- **Fish:** implemented as a native `.theme` file with `[dark]` and `[unknown]` variants covering syntax, pager, selection, and completion colors. `fish_config theme choose primer-dark` previews session-local colors; `fish_config theme save primer-dark` loads the named theme into universal variables for future shells. The installed file is safe to remove after loading; saved colors do not automatically follow terminal light/dark changes.
- **tmux:** implemented as a styles-only snippet sourced from `~/.tmux.conf`, covering the status bar, window states, pane borders, messages, copy mode, menus, and popups without overriding user formats or key bindings.

### 4. Firefox and Chrome

Create browser chrome ports without attempting to force a universal website theme.

- **Firefox:** implemented as a color-only Manifest V3 static theme for Firefox 155. It covers all 38 effective current color fields for frames, active/inactive tabs, toolbars, address fields and selection, icons, button states, popups, new-tab surfaces, and sidebars. Deprecated or ignored aliases are intentionally omitted. Dark chrome and content color-scheme properties keep built-in pages and `prefers-color-scheme` behavior coherent; arbitrary website content and DevTools remain outside the theme API. Deeper `userChrome.css` changes remain optional and versioned separately.
- **Chrome:** implemented as a color-only Manifest V3 package for Google Chrome 152.0.7977.75. Its manifest declares all 24 current overwritable Chromium theme colors: active and inactive tab text/backgrounds, toolbar controls, omnibox, bookmarks, new-tab chrome, inactive windows, and the exposed incognito variants. Chrome uses an inset frame around a default-surface toolbar and active tab, with a raised omnibox. Focus, hover, pressed, separators, and other non-overwritable colors continue to use Chrome's derived native states.
- Chromium themes do not style website content, DevTools, every internal page, or the central Google Chrome new-tab search control. Chrome 152's incognito theme provider deliberately ignores custom theme suppliers, so incognito windows retain Chrome's native dark appearance despite the legacy incognito fields remaining in the supported manifest table.

### 5. GTK 3/4

Create shared GTK foundations for installed GTK applications.

- **GTK 3:** implemented as a native `gtk-3.0/gtk.css` theme that imports GTK's bundled Adwaita dark stylesheet through its resource URL and overrides its colors with Primer roles. It covers windows, header bars, controls, entries, menus, popovers, tooltips, lists, trees, notebooks, sidebars, calendar, info bars, selections, focus, disabled states, and destructive actions.
- **GTK 4:** implemented as a native `gtk-4.0/gtk.css` theme that imports GTK's bundled Default dark stylesheet and applies the same Primer overrides, plus the documented libadwaita CSS variables and named colors. Plain GTK 4 applications load it like any other GTK theme.
- Both variants are dark-only, so the `gtk.css` and `gtk-dark.css` entry points resolve to the same stylesheet, and both ship in the single native theme package that `--gtk` owns at `~/.local/share/themes/primer-dark/` (`index.theme`, `gtk-3.0/`, `gtk-4.0/`).
- **Libadwaita:** libadwaita deliberately sets GTK's empty theme and adds its own stylesheet, so it ignores user GTK themes. The suite publishes a documented, manually merged color override for `~/.config/gtk-4.0/gtk.css` and does not claim libadwaita applications are fully themed. The override defines only libadwaita's color variables, is never installed automatically because it is shared GTK user configuration that affects every GTK 4 application, and leaves libadwaita's layout and widget styles in place.
- Flatpak applications only see theme directories that their sandbox is granted, so the required `flatpak override` filesystem permission and the alternative per-application `GTK_THEME` override are documented separately. The Flatpak guidance is documented only and was not verified in this environment.
- Destructive actions use the canonical Primer danger-emphasis scale steps (`#DA3633` at rest, `#B62324` on hover, `#8E1519` when pressed) for their solid background, because the error color itself (`#F85149`) is a text and icon role and only reaches 3.35:1 behind a white label. Those steps keep white labels at 4.61:1, 6.45:1, and 9.25:1, so no blend has to be invented for them. Suggested actions keep the accent color directly. Only the libadwaita status backgrounds are documented blends (25-35% of the inset surface) so that white labels keep a usable contrast.

### 6. Optional third-party Discord, Spotify and Steam integrations

Keep unsupported application patching isolated, explicit, and reversible.

- **Discord:** optional Vencord/BetterDiscord-compatible CSS.
- **Spotify:** optional Spicetify theme with Flatpak-aware installation guidance.
- **Steam:** optional Millennium/custom CSS integration.
- Never install third-party patchers automatically.
- Require explicit component selection, version checks, backups, and clear restore instructions.
- A failure in an optional integration must not block installation of supported theme ports.

## Installation architecture

The root install and uninstall commands are small component orchestrators. Shared paths and the component registry live under `scripts/lib/`, while each port's preflight, install, active-state guard, uninstall, and check hooks live under `scripts/components/`.

Current and planned behavior:

- `./install.sh` installs the stable KDE foundation.
- `--konsole`, `--ghostty`, `--pi`, `--zed`, `--fastfetch`, `--bat`, `--btop`, `--fish`, and `--gtk` install their respective application themes without changing application settings.
- eza, fzf, and tmux are never installed by the root script: eza reads a single fixed `theme.yml`, and fzf and tmux are configured through shell and tmux configuration files, so the installer never edits shared configuration for them.
- Firefox is published as [Primer Dark on addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/) and previewed from a checkout with `web-ext build`, which packages it for `about:debugging` and for upload to that listing. It is store-distributed because normal Firefox release and beta builds require Mozilla signatures for permanent theme installation, so the installer never writes into the profile and cannot collide with a store-installed copy.
- Chrome is loaded interactively from its unpacked directory in a checkout; it is store-distributed because Chromium browsers have no user-local standalone discovery directory and automatic profile preference edits would not be safely theme-owned.
- The Firefox theme is released by `.github/workflows/firefox-release.yml`: a manual run checks the manifest version against the public addons.mozilla.org API, lints the theme, builds the unsigned package, and submits it with `web-ext sign --channel listed` using the `WEB_EXT_API_KEY` and `WEB_EXT_API_SECRET` secrets. The run does not wait for review, and the manifest keeps the add-on ID `primer-dark@redasalmi.github.io` that the listing is bound to.
- Versions are kept only where a browser store requires one: the Firefox and Chrome manifests. There is no suite version, no GitHub Releases, and no `KPlugin.Version` in the KDE metadata, because `install.sh` is the distribution channel for every locally installed port and KDE treats `KPlugin.Version` as optional.
- `--herdr` is an explicit managed-configuration exception: it safely replaces only bounded, validated theme tables in Herdr's shared `config.toml`, preserves unrelated settings, records the previous theme tables for uninstall, and aborts if the source configuration or restore state changes after preflight.
- `--gtk` installs the native GTK 3 and GTK 4 theme package and removes it as a whole directory on uninstall. The optional libadwaita override is a documented shared-config snippet that the installer never writes, because `~/.config/gtk-4.0/gtk.css` is shared GTK configuration.
- The installer preflights every selected component and `--apply` dependency before changing installed files, preventing predictable dependency or configuration failures from leaving a partial installation.
- Uninstall runs every active-theme and restore-state guard before removing or restoring every registered component.
- `./scripts/check.sh` validates the palette and every asset that has an official parser, and `.github/workflows/verify.yml` runs it together with ShellCheck on every push to `main` and every pull request.
- Future component ports extend the shared registry and add an isolated lifecycle module instead of adding implementation blocks to the root scripts.
- Future explicit flags may select groups such as `--terminal`, `--editors`, `--cli`, or `--browsers`.
- A future `--all-supported` flag installs supported native ports only.
- Third-party integrations always require separate explicit flags.
- Every installed component records only files owned by Primer Dark, except approved bounded managed sections such as Herdr's, and can be removed without reverting unrelated preferences.

## Cross-port acceptance criteria

- Every port is derived from `palette/primer-dark.json` and documents intentional deviations.
- Primary and muted text meet their applicable contrast targets.
- Focus, selection, error, warning, success, disabled, and inactive states remain distinguishable.
- Terminal and editor syntax colors are consistent across applications.
- Installation works offline from committed assets and does not require administrator access, except future Plasma Login integration.
- Install and uninstall operations preserve unrelated configuration and provide a safe recovery path.
- Native formats pass the application's parser or discovery mechanism.
- Representative rendered states are visually inspected before a port is marked complete.

## References

- https://develop.kde.org/docs/plasma/
- https://develop.kde.org/docs/plasma/theme/theme-porting-to-plasma6/
- https://develop.kde.org/docs/plasma/theme/theme-details/
- https://develop.kde.org/docs/plasma/theme/theme-colors/
- https://develop.kde.org/docs/plasma/aurorae/
- https://github.com/catppuccin/kde
- https://github.com/primer/primitives
- https://docs.gtk.org/gtk3/class.CssProvider.html
- https://docs.gtk.org/gtk4/class.CssProvider.html
- https://docs.gtk.org/gtk4/css-overview.html
- https://docs.gtk.org/gtk4/css-properties.html
- https://docs.gtk.org/gtk4/class.Settings.html
- https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/css-variables.html
- https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/named-colors.html
- https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/styles-and-appearance.html
- https://gitlab.gnome.org/GNOME/gtk/-/blob/gtk-3-24/gtk/theme/Adwaita/_colors-public.scss
- https://gitlab.gnome.org/GNOME/libadwaita/-/blob/1.9.3/src/adw-style-manager.c
- https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/theme
- https://extensionworkshop.com/documentation/themes/static-themes/
- https://extensionworkshop.com/documentation/develop/web-ext-command-reference/
- https://addons.mozilla.org/en-US/developers/addon/api/key/
- https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Temporary_Installation_in_Firefox
- https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Alternative_distribution_options
- https://hg.mozilla.org/releases/mozilla-release/file/FIREFOX_155_0_RELEASE/toolkit/components/extensions/schemas/theme.json
- https://firefox-source-docs.mozilla.org/remote/webdriver-bidi/Extensions.html
- https://developer.chrome.com/docs/extensions/develop/ui/themes
- https://developer.chrome.com/docs/extensions/get-started/tutorial/hello-world#load-unpacked
- https://chromium.googlesource.com/chromium/src/+/refs/tags/152.0.7977.75/chrome/browser/themes/browser_theme_pack.cc
- https://chromium.googlesource.com/chromium/src/+/refs/tags/152.0.7977.75/chrome/browser/themes/theme_service.cc
- https://chromereleases.googleblog.com/2026/09/stable-channel-update-for-desktop.html
- https://chromium.googlesource.com/chromium/src/+/refs/tags/152.0.7977.64/chrome/browser/themes/browser_theme_pack.cc
- https://github.com/fastfetch-cli/fastfetch/wiki/Configuration
- https://github.com/fastfetch-cli/fastfetch/wiki/Color-Format-Specification
- https://github.com/fastfetch-cli/fastfetch/wiki/Logo-options
- https://github.com/fastfetch-cli/fastfetch/raw/2.66.0/doc/json_schema.json
- https://github.com/sharkdp/bat#adding-new-themes
- https://github.com/sharkdp/bat/blob/v0.26.1/src/bin/bat/config.rs
- https://github.com/aristocratos/btop#themes
- https://github.com/aristocratos/btop/blob/v1.4.7/src/btop_theme.cpp
- https://github.com/aristocratos/btop/blob/v1.4.7/src/btop_config.cpp
- https://github.com/aristocratos/btop/blob/v1.4.7/src/btop_menu.cpp
- https://github.com/eza-community/eza/blob/main/man/eza_colors-explanation.5.md
- https://fishshell.com/docs/current/cmds/fish_config.html
- https://github.com/junegunn/fzf/blob/master/man/man1/fzf.1
- https://man.openbsd.org/tmux.1

## Final phase: visual regression testing

Add automated visual tests only after the planned theme ports are implemented and their native parsers and discovery checks pass. Keeping this as the final phase avoids maintaining unstable baselines while the suite is still expanding.

### 1. Build deterministic fixtures

- Add a `tests/visual/` harness that installs the suite into an isolated temporary home directory and never reads or modifies the developer's active configuration.
- Record the operating-system, desktop, toolkit, application, font, icon, scale, locale, wallpaper, and theme versions used for each baseline.
- Provide stable fixture content for long text, empty states, selections, focus, warnings, errors, diffs, syntax samples, ANSI colors, disabled controls, and scrollable content.
- Freeze animations, timestamps, clipboard history, notifications, network data, and other volatile content during capture.

### 2. Cover representative theme surfaces

- **KDE/Qt:** capture Dolphin, the application launcher, clipboard and system-tray popups, tooltips, desktop widgets, dialogs, window decorations, focus states, and maximized/inactive windows. Use black, light, and colorful wallpapers so outer boundaries and shadows are tested.
- **Terminals and CLI:** capture Konsole and Ghostty with the ANSI 16-color grid, normal/bright/faint text, selections, links, prompts, diffs, and representative Pi and future TUI states.
- **Editors:** capture Zed, Cursor, and future editor ports with syntax, diagnostics, Git states, selections, matching brackets, search results, terminal output, and inactive panes.
- **Browsers and GTK:** add fixtures as each port becomes stable, covering the application-specific chrome and interaction states listed in its roadmap section.
- Capture the default supported size plus one constrained or scaled state where layout, clipping, or one-pixel borders could change.

### 3. Generate and compare baselines

- Prefer each application's native screenshot or automation interface; use a dedicated KDE Plasma VM runner for compositor-dependent popups and window decorations.
- Store lossless PNG baselines with a small manifest linking every image to its fixture, application version, viewport or window size, scale, and expected theme version.
- Compare exact pixels for flat color and border fixtures. Use a documented perceptual threshold only for platform-rendered text, shadows, and antialiasing.
- Produce a diff image and a concise machine-readable report for every mismatch; never update baselines automatically after a failure.

### 4. Run checks in layers

- Run schema, parser, token, and static SVG checks on every change.
- Run fast deterministic image renders for changed components in normal pull-request validation.
- Run native application and Plasma captures on a pinned VM image before release, and whenever shared palette, surface, border, text, focus, or selection tokens change.
- Require a human review of intentional baseline updates, with before, after, and diff images attached to the change.

### 5. Completion criteria

- Every implemented port has at least one representative native rendering and all shared semantic states it supports are covered.
- KDE popup and widget borders remain continuously visible as `#3D444D` against black and non-black backgrounds at every tested scale.
- No baseline shows clipped content, missing assets, unreadable text, broken focus indication, accidental transparency, or inconsistent semantic colors.
- The isolated install, capture, comparison, report, and cleanup flow is documented and reproducible from one repository command.
