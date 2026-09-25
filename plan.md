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
- Native Kvantum theme that defines Kvantum's complete documented `GeneralColors` color spec (window, inactive window, base, inactive base, alternate base, button, bevel, frame, grid, highlight, inactive highlight, tooltip, text, disabled, link, visited link, and progress colors) with the same semantic roles as the KDE color scheme, and leaves Kvantum's artwork, geometry, and behavior keys at their built-in defaults.
- Native KSyntaxHighlighting color theme for KWrite, Kate, and other KTextEditor applications, using the shared editor syntax mapping.
- Native micro colorscheme, Godot 4 text editor theme, Claude Code custom theme, Codex syntax theme (the bat TextMate theme), and Atuin theme, each installed as one owned file.
- Ready-to-merge fish fzf snippet, GNU dircolors database, bottom styles, mpv OSD/OSC/console snippet, and MangoHud color snippet.
- No panel layout, wallpaper, font, or window-button-order changes.

## Suite roadmap

### 1. Konsole and Ghostty

Continue the terminal foundation so every terminal-based tool inherits a consistent base palette.

- **Konsole:** implemented as a native `.colorscheme` plus an optional profile that references it without changing existing profiles or declaring a shell or font.
- **Ghostty:** implemented as a native theme file using the shared foreground, background, cursor, selection, and ANSI 16-color mapping.
- Normal, bright, and dim ANSI colors, links, prompts, diffs, and long-running `btop` sessions have been visually validated in both terminals; selection was visually inspected in Konsole and Ghostty's selection mapping passed its native parser.

### 2. Zed, Cursor, and KWrite/Kate

Continue the editor theme family from the shared syntax and UI roles.

- **Zed:** implemented as a JSON theme covering the workbench, editor, terminal, diagnostics, diffs, syntax, collaboration colors, Vim modes, and interaction states.
- **Cursor:** implemented as a VS Code-compatible extension package (`package.json` with a `contributes.themes` entry plus `themes/primer-dark-color-theme.json`). It is a dark theme covering 465 workbench colors, TextMate syntax rules, semantic token rules, diagnostics, diffs, Git decorations, the integrated terminal including the shared ANSI 16-color mapping, and bracket pair colorization. The installer packages the extension as a VSIX in a temporary directory and installs it with `cursor --install-extension`, which writes `~/.cursor/extensions/<publisher>.<name>-<version>/` and records it in Cursor's `extensions.json`. Copying the unpacked directory is not enough: Cursor 3.22 adopts unrecorded extension directories only while it creates a new `extensions.json`, and ignores them once that file exists, which it does on any machine where Cursor has run. Uninstall runs `cursor --uninstall-extension` and then removes the owned directory, after its active-theme guard passes in the default profile and every named profile. Workbench and syntax colors come from the canonical palette; fully transparent values are used only where VS Code requires a transparent border or overlay slot, and `editorUnnecessaryCode.opacity` uses an alpha-only value because VS Code reads that field as an opacity.
- **KWrite/Kate:** implemented as a native KSyntaxHighlighting JSON theme (`kde/ktexteditor/primer-dark.theme`) installed by `--ktexteditor` to `~/.local/share/org.kde.syntax-highlighting/themes/`, where every KTextEditor application and `ksyntaxhighlighter6` discover it. It defines all 31 default text styles and all 28 editor colors, plus custom styles for the Alerts levels (which otherwise carry hard-coded colors), HTML and XML elements, and JSON keys. KTextEditor paints selection and search highlights opaquely, so those four colors are documented solid blends of the Cursor translucent values over `surface.default`: selection `#14376C` (accent emphasis at 40%), search `#4F3E1B` (attention at 33%), replace `#1E492A` (success at 33%), and bracket match `#182B44` (accent at 20%). The guard reads the `Color Theme` key in `kwriterc`, `katerc`, and `kdeveloprc`.
- Keep syntax colors aligned with the installed Zed GitHub Dark reference unless contrast or application semantics require an adjustment. The two ports share one syntax mapping, and the VS Code-only surfaces that Zed has no equivalent for (`symbolIcon.*`, `debugTokenExpression.*`, `editorBracketHighlight.*`) follow the mapping published by GitHub's own VS Code theme.

### 3. Terminal tools: Pi, Herdr, Claude Code, Codex, bat, btop, bottom, Atuin, fzf, eza, LS_COLORS, fastfetch, Fish, tmux, micro, and MangoHud

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
- **micro:** implemented as a native `.micro` colorscheme installed by `--micro` to `~/.config/micro/colorschemes/primer-dark.micro` (or `$MICRO_CONFIG_HOME`), covering every documented group and the built-in syntax subgroups, the status line, tab bar, gutter, diff, search, brace-match, and whitespace-error states. micro resolves the `colorscheme` option from `settings.json` or the `-colorscheme` flag, so the component owns only the colorscheme file and the guard reads `settings.json` read-only. micro has no offline parser, so the check hook validates its `color-link` line grammar; rendering was verified in a true-color headless tmux session.
- **Claude Code:** implemented as a native custom theme (`cli/claude/primer-dark.json`, base `dark`) installed by `--claude` to `$CLAUDE_CONFIG_DIR/themes/` or `~/.claude/themes/`. It overrides the documented text, status, mode, diff, transcript, usage, subagent, rainbow, and shimmer tokens; every token name was confirmed against the installed binary. Diff lines use the success and danger inset surfaces; the word-level removed highlight uses `status.dangerEmphasisActive`, and the added highlight `#1C6129` is the only blend (success at 40% over the success inset), because the palette has no strong green surface. Selection is stored as `custom:primer-dark`, which the guard looks for in `settings.json` and the global `.claude.json`.
- **Codex:** Codex CLI loads custom TextMate themes from `$CODEX_HOME/themes/` for syntax highlighting, so `--codex` installs the bat `.tmTheme` there as `primer-dark.tmTheme` instead of committing a second copy. Selection lives in `[tui] theme` in `config.toml`, which the guard reads. The theme was not exercised inside an authenticated Codex session.
- **Atuin:** implemented as a native theme (`cli/atuin/primer-dark.toml`) installed by `--atuin` to `$ATUIN_THEME_DIR` or `~/.config/atuin/themes/`. Atuin deserializes `[colors]` into a closed enum and drops the whole theme on an unknown key, so only the nine Atuin 18.x meanings are set and `Base` stays unset so text keeps the terminal foreground. Rendering was verified with `atuin search -i` in headless tmux against an isolated configuration.
- **bottom:** published as ready-to-merge `[styles]` tables (`cli/bottom/primer-dark.toml`) because bottom has no theme directory and its styles live in the shared `bottom.toml`; `btm -C` loads the file directly for trying it. The ramps match the btop theme.
- **LS_COLORS:** published as a GNU dircolors database (`cli/dircolors/primer-dark.dircolors`) using 24-bit SGR colors and the eza file kinds, for ls, tree, fd, and shell completion. It is loaded from shell startup files, so it is never installed automatically.
- **fzf in fish:** the POSIX snippet cannot be sourced by fish, so `cli/fzf/primer-dark.fish` carries the same color set; the check hook parses it with fish and fails if the two color sets diverge.
- **MangoHud:** published as a color snippet (`gaming/mangohud/primer-dark.conf`) for `MangoHud.conf`, which is shared with GOverlay and therefore never written by the installer. The keys come from the installed MangoHud 0.8.3 example configuration; the overlay itself was not rendered in this environment.
- **TUI tools without a theme format:** nvtop only exposes enabling or disabling color, and duf, dust, tokei, zoxide, xh, and ripgrep's defaults follow the ANSI palette of the terminal themes, so they need no asset. nano's syntax files use ANSI names and follow the terminal palette; only its interface colors could be set through a `nanorc` snippet, which is a low-priority candidate.

### 4. Firefox, Chrome and Helium

Create browser chrome ports without attempting to force a universal website theme.

- **Firefox:** implemented as a color-only Manifest V3 static theme for Firefox 155. It covers all 38 effective current color fields for frames, active/inactive tabs, toolbars, address fields and selection, icons, button states, popups, new-tab surfaces, and sidebars. Deprecated or ignored aliases are intentionally omitted. Dark chrome and content color-scheme properties keep built-in pages and `prefers-color-scheme` behavior coherent; arbitrary website content and DevTools remain outside the theme API. Deeper `userChrome.css` changes remain optional and versioned separately.
- **Chrome:** implemented as a color-only Manifest V3 package for Google Chrome 152.0.7977.75. Its manifest declares all 24 current overwritable Chromium theme colors: active and inactive tab text/backgrounds, toolbar controls, omnibox, bookmarks, new-tab chrome, inactive windows, and the exposed incognito variants. Chrome uses an inset frame around a default-surface toolbar and active tab, with a raised omnibox. Focus, hover, pressed, separators, and other non-overwritable colors continue to use Chrome's derived native states.
- Chromium themes do not style website content, DevTools, every internal page, or the central Google Chrome new-tab search control. Chrome 152's incognito theme provider deliberately ignores custom theme suppliers, so incognito windows retain Chrome's native dark appearance despite the legacy incognito fields remaining in the supported manifest table.
- **Helium:** the installed Helium 0.17 build is Chromium-based and can therefore load a Chromium theme package through its own extension surface, but it publishes no theme documentation, store listing, or version range of its own, so the Chrome manifest is documented as a load-unpacked candidate only. Helium support stays unverified until the installed build is tested with the theme loaded, and no installer step targets Helium.

### 5. GTK 3/4 and libadwaita applications

Create shared GTK foundations for installed GTK applications.

- **GTK 3:** implemented as a native `gtk-3.0/gtk.css` theme that imports GTK's bundled Adwaita dark stylesheet through its resource URL and overrides its colors with Primer roles. It covers windows, header bars, controls, entries, menus, popovers, tooltips, lists, trees, notebooks, sidebars, calendar, info bars, selections, focus, disabled states, and destructive actions.
- **GTK 4:** implemented as a native `gtk-4.0/gtk.css` theme that imports GTK's bundled Default dark stylesheet and applies the same Primer overrides, plus the documented libadwaita CSS variables and named colors. Plain GTK 4 applications load it like any other GTK theme.
- Both variants are dark-only, so the `gtk.css` and `gtk-dark.css` entry points resolve to the same stylesheet, and both ship in the single native theme package that `--gtk` owns at `~/.local/share/themes/primer-dark/` (`index.theme`, `gtk-3.0/`, `gtk-4.0/`).
- **Libadwaita:** libadwaita deliberately sets GTK's empty theme and adds its own stylesheet, so it ignores user GTK themes. The suite publishes a documented, manually merged color override for `~/.config/gtk-4.0/gtk.css` and does not claim libadwaita applications are fully themed. The override defines only libadwaita's color variables, is never installed automatically because it is shared GTK user configuration that affects every GTK 4 application, and leaves libadwaita's layout and widget styles in place.
- Flatpak applications only see theme directories that their sandbox is granted, so the required `flatpak override` filesystem permission and the alternative per-application `GTK_THEME` override are documented separately. The Flatpak guidance is documented only and was not verified in this environment.
- Destructive actions use the canonical Primer danger-emphasis scale steps (`#DA3633` at rest, `#B62324` on hover, `#8E1519` when pressed) for their solid background, because the error color itself (`#F85149`) is a text and icon role and only reaches 3.35:1 behind a white label. Those steps keep white labels at 4.61:1, 6.45:1, and 9.25:1, so no blend has to be invented for them. Suggested actions keep the accent color directly. Only the libadwaita status backgrounds are documented blends (25-35% of the inset surface) so that white labels keep a usable contrast.
- **Installed GTK 3 applications** inherit the theme package directly and need no per-application asset: Inkscape 1.4, Xournal++ 1.3, xpad, firewall-config, the IBus setup dialogs, and the GTK dialogs drawn by Yad, Zenity, Winetricks, Protontricks, and Orca. They are used as the visual verification set for the GTK port.
- **GIMP 3.2** does not inherit the GTK theme by default: it ships its own **Default** theme (dark, gray, and light variants) and only follows the user GTK theme when its **System** theme is selected in Preferences → Interface → Theme. The README documents that selection. A dedicated GIMP theme would have to import GIMP's GPL `common.css` from the installed data directory, whose path differs between distribution packages and the Flatpak, so it is not planned.
- **Installed libadwaita applications** are Flatpak builds that ignore the GTK theme and depend on the documented libadwaita override plus the Flatpak theme-directory permission: Flatseal 2.4, Bottles, ProtonPlus, and Gear Lever. The suite documents both steps and does not claim full theming for them.

### 6. Qt and KDE applications

Verify and document application coverage for the installed Qt and KDE applications, which inherit the color scheme instead of needing their own theme files.

- Installed KDE applications inherit the KDE color scheme and the selected Breeze or Kvantum widget style directly: Dolphin, Ark, Gwenview, Okular, KCalc, KWrite, KFind, KHelpCenter, KInfoCenter, KolourPaint, Spectacle, Skanpage, Filelight, QRCA, KRDC, KRFB, KCharSelect, KMouth, KDebugSettings, KDE Connect, KMenuEdit, Partition Manager, System Monitor, Media Writer, and Plasma Vault, in addition to Konsole, which is covered by its own color scheme port. They need verification and representative captures, not new assets.
- Installed Qt applications follow the same color scheme: Krita 6.0.2, qBittorrent 5.2.3, MegaSync 6.6.1, the Epson Printer Utility, the shadPS4 Qt Launcher, and DuckStation's window chrome from its AppImage. Qt 5 applications (MegaSync and the Epson Printer Utility) resolve Primer colors only while Plasma's Qt platform theme is active, and every Qt application draws its widgets from the selected Qt style rather than from the color scheme alone, so coverage is documented as a dependency on the platform theme and on selecting Breeze or Kvantum instead of as a per-application port.
- Two installed applications accept no external theme file and are recorded as coverage limits rather than ports: DuckStation selects only from fixed built-in FullscreenUI and Qt theme lists, and GOverlay is a GTK 2/LCL application whose only styling control is its built-in style option.

### 7. Blender and Godot

Add the first creative-tool ports, both built on native per-application theme formats.

- **Blender:** planned as an interface theme XML file that covers the same key set as the bundled `/usr/share/blender/<version>/scripts/presets/interface_theme/Blender_Dark.xml`, including editor backgrounds, region headers, widgets, text, selection, focus, statuses, and the per-editor 3D Viewport, Graph Editor, and node colors. It installs to `~/.config/blender/<version>/scripts/presets/interface_theme/PrimerDark.xml`, from where Blender lists it as a theme preset; Blender's **Install** action also loads a standalone Blender XML theme file. Because the path is versioned per Blender minor release, `--blender` has to detect installed versions and install one owned file per version, and the user still selects the theme in Preferences → Themes.
- **Godot:** the text editor theme is implemented as `creative/godot/PrimerDark.tet`, installed by `--godot` to `~/.config/godot/text_editor_themes/`, and defines all 49 color keys of Godot 4.7's `text_editor/theme/highlighting/` set, including the GDScript and comment-marker colors. A headless editor run with an isolated configuration confirmed that Godot loads every value. The editor chrome of Godot 4.7 is generated from `interface/theme/base_color`, `accent_color`, and `contrast` with the `Custom` color preset, which live in the shared `editor_settings-4.x.tres`, so those values are documented in the README rather than written by the installer; a full custom editor `Theme` resource remains optional future work.
- Both applications ship their own UI toolkit, so backgrounds, borders, text, focus, selection, disabled, warning, error, and syntax states are mapped in each application's own key set from the canonical palette, and both ports are re-verified against the installed minor version because their theme key sets change between releases.

### 8. LibreOffice

Cover the office suite through its own appearance theme instead of relying only on the desktop integration.

- LibreOffice 26.2 is installed together with `libreoffice-kf6`, so window chrome, dialogs, and file pickers already follow the KDE color scheme. The remaining surface is LibreOffice's own appearance theme.
- The planned port ships an appearance theme extension (`.oxt`) whose `themes.xcu` defines a `ColorScheme/ColorSchemes/Primer Dark` node with the canonical palette mapped onto LibreOffice's color items: document background, text, links, selections, field shading, comments, tracked changes, and the Writer, Calc, and Impress-specific entries. LibreOffice registers the theme under Tools → Options → LibreOffice → Appearance → LibreOffice Themes, and the user selects it there.
- `themes.xcu` stores decimal RGB values with separate light and dark variants, and items that are not defined fall back to LibreOffice's automatic values, so the port defines the dark variant explicitly for every item it depends on.
- Extensions are installed per user through the Extension Manager or `unopkg add`, which writes inside the LibreOffice user profile rather than into shared configuration. A `--libreoffice` component may therefore own that installed extension once install and removal are verified against an isolated user profile; until then the `.oxt` is published for manual installation and the selection step stays manual.
- The bundled Breeze Dark icon set (`images_breeze_dark_svg.zip`) already matches the suite's icon direction and is documented as the recommended icon theme, so the port ships no icon set of its own.

### 9. Slack

Document the one appearance surface the Slack desktop client exposes.

- Slack has no theme file format. Its only appearance customization is the custom theme color list in Preferences → Appearance → Custom theme, where a comma-separated hex string (eight or ten entries, nine of which are used) drives the sidebar, channel list, presence dots, and mention badges over the selected dark base theme.
- The planned port publishes a ready-to-paste Primer Dark theme string together with the slot order and the paste, share, and import steps from Slack's help center, so users apply and share it themselves. The exact slot order is confirmed against the current dialog before the asset is published, because Slack changed the customizable surface in its 2023 redesign.
- The installer never edits Slack's local preferences, which store the theme per workspace inside the client's data directory, and the plan records that current Slack versions restrict the custom theme to sidebar and navigation surfaces rather than the message pane.

### 10. Discord, Spotify, and Steam

Planned integration ports for clients that have no official theme API. All three require a third-party client mod or patcher, so they stay under `integrations/` per the suite principles, ship as manual assets, and are never installed, activated, or updated by the root installer.

- **Discord (Vencord):** Discord ships no theme API; Vencord loads local BetterDiscord-compatible `.theme.css` files with a JSDoc metadata header. Planned as one Primer Dark CSS theme published for manual placement in Vencord's local themes directory (`~/.config/Vencord/themes/` on Linux) and enabled from Vencord's Themes → Local list. The port targets Vencord's own CSS variables and Discord's stable class aliases, and leaves plugin surfaces it cannot address by a stable selector unstyled rather than guessing at generated class names. The repository never installs or patches Vencord or Discord.
- **Spotify (Spicetify):** planned as a Spicetify theme folder holding `color.ini` (canonical roles mapped onto Spicetify's CSS variables) and `user.css` (surface, border, control, and state overrides). It is published for manual placement in `~/.config/spicetify/Themes/PrimerDark/` and activation with `spicetify config current_theme PrimerDark` followed by `spicetify apply`. The local Spotify client is a Flatpak (`com.spotify.Client`), so Spicetify's application-directory patch step and Spotify's data path under `~/.var/app/com.spotify.Client/` are documented as prerequisites and limitations; the suite never runs `spicetify backup` or `spicetify apply` and never modifies the Flatpak installation.
- **Steam:** planned as a client-mod theme because Valve removed the built-in `.styles` skin system in the 2023 client UI update, so current Steam cannot load a native skin. The port targets a third-party CSS-injection loader (Millennium reads themes from `~/.steam/steam/steamui/skins/<name>/skin.json` on Linux), is published for manual installation, and documents the loader release it was verified against. Native (non-CEF) dialogs, the in-game overlay, and the Big Picture shell remain outside its reach; the suite never installs or patches Steam.
- Each of these clients rewrites DOM structure and class names on ordinary updates, so the ports are versioned against the verified client and loader releases and are visually re-inspected before any release note claims current support.

### 11. Applications without a supported custom-theme path

Record the installed applications that cannot receive a suite asset, so the roadmap does not imply support the client does not allow.

- **LocalSend:** a Flutter application with only light, dark, and system appearance, and no theme format to target.
- **Electron applications without a theme API:** the ChatGPT desktop app, Proton Pass, Bitwarden, HTTPie, and Bionic expose only an appearance toggle. Theming them would require patching their bundled `app.asar`, which the suite does not do.
- **mpv:** has no theme file. The suite publishes `media/mpv/primer-dark.conf`, an `include`-able snippet for the OSD, on-screen controller, and console colors (mpv options use `#AARRGGBB`), verified with mpv 0.41's own option parser, and provides no installer support.
- **Cloudflare WARP and Jellyfin:** WARP's taskbar client has no appearance settings; Jellyfin's web client accepts custom CSS only through its server dashboard, which is shared server configuration and a possible future snippet.
- Applications that read only the desktop's light/dark preference are not ported, because a suite port would depend on internal styling the application does not promise to keep.

## Installation architecture

The root install and uninstall commands are small component orchestrators. Shared paths and the component registry live under `scripts/lib/`, while each port's preflight, install, active-state guard, uninstall, and check hooks live under `scripts/components/`.

Current and planned behavior:

- `./install.sh` installs the stable KDE foundation.
- `--konsole`, `--ghostty`, `--pi`, `--zed`, `--cursor`, `--fastfetch`, `--bat`, `--btop`, `--fish`, `--gtk`, `--kvantum`, `--ktexteditor`, `--micro`, `--atuin`, `--codex`, `--claude`, and `--godot` install their respective application themes without changing application settings. `install.sh --help` builds its flag list from the component registry.
- eza, fzf, and tmux are never installed by the root script: eza reads a single fixed `theme.yml`, and fzf and tmux are configured through shell and tmux configuration files, so the installer never edits shared configuration for them.
- The planned Discord (Vencord), Spotify (Spicetify), and Steam integration ports are never installed by the root script: each depends on a third-party client mod or patcher that the suite does not install, so `integrations/` assets are published for manual placement and activation only.
- Native application ports keep the same ownership rule: `--micro`, `--ktexteditor`, `--atuin`, `--codex`, `--claude`, and `--godot` each install one owned file, and the planned `--blender` installs one owned `PrimerDark.xml` per detected Blender version, leaving settings files, Blender preferences, and every other shared configuration file untouched.
- bottom, LS_COLORS, mpv, MangoHud, and the Godot editor base and accent colors are shared configuration, so they are published as snippets and never installed.
- Godot's editor settings, LibreOffice's theme selection, and Slack's local preferences are shared or application-owned configuration, so those ports publish ready-to-merge assets and documented activation steps instead of installing automatically unless a bounded managed-section exception is approved for that port.
- Firefox is published as [Primer Dark on addons.mozilla.org](https://addons.mozilla.org/en-US/firefox/addon/primer-dark/) and previewed from a checkout with `web-ext build`, which packages it for `about:debugging` and for upload to that listing. It is store-distributed because normal Firefox release and beta builds require Mozilla signatures for permanent theme installation, so the installer never writes into the profile and cannot collide with a store-installed copy.
- Chrome is loaded interactively from its unpacked directory in a checkout; it is store-distributed because Chromium browsers have no user-local standalone discovery directory and automatic profile preference edits would not be safely theme-owned.
- The Firefox theme is released by `.github/workflows/firefox-release.yml`: a manual run checks the manifest version against the public addons.mozilla.org API, lints the theme, builds the unsigned package, and submits it with `web-ext sign --channel listed` using the `WEB_EXT_API_KEY` and `WEB_EXT_API_SECRET` secrets. The run does not wait for review, and the manifest keeps the add-on ID `primer-dark@redasalmi.github.io` that the listing is bound to.
- Versions are kept only where a browser store requires one: the Firefox and Chrome manifests. There is no suite version, no GitHub Releases, and no `KPlugin.Version` in the KDE metadata, because `install.sh` is the distribution channel for every locally installed port and KDE treats `KPlugin.Version` as optional.
- `--herdr` is an explicit managed-configuration exception: it safely replaces only bounded, validated theme tables in Herdr's shared `config.toml`, preserves unrelated settings, records the previous theme tables for uninstall, and aborts if the source configuration or restore state changes after preflight.
- `--gtk` installs the native GTK 3 and GTK 4 theme package and removes it as a whole directory on uninstall. The optional libadwaita override is a documented shared-config snippet that the installer never writes, because `~/.config/gtk-4.0/gtk.css` is shared GTK configuration.
- `--kvantum` installs the native Kvantum theme into `~/.config/Kvantum/PrimerDark/`, which is the user theme path Kvantum resolves first, and removes that whole owned directory on uninstall. Kvantum stores its selection in `~/.config/Kvantum/kvantum.kvconfig`, so the installer never rewrites that shared file and the guard reads it read-only, mirroring Kvantum's config lookup order, Qt's INI value, key, and section decoding, and the per-application `[Applications]` assignments. A selection file that cannot be decoded with certainty blocks removal instead of risking an active theme.
- The installer preflights every selected component and `--apply` dependency before changing installed files, preventing predictable dependency or configuration failures from leaving a partial installation.
- Uninstall runs every active-theme and restore-state guard before removing or restoring every registered component. The KDE guard covers the global theme, Plasma style, color scheme, Aurorae decoration, and splash screen, because each can stay selected after another global theme is applied; the GTK guard also reads xsettingsd's `Net/ThemeName`.
- Store and upstream publication is tracked separately in `distribution.md`; the installer and uninstaller never contact a store.
- `./scripts/check.sh` validates the palette and every asset that has an official parser, and `.github/workflows/verify.yml` runs it together with ShellCheck on every push to `main` and every pull request.
- Future component ports extend the shared registry and add an isolated lifecycle module instead of adding implementation blocks to the root scripts.
- Future explicit flags may select groups such as `--terminal`, `--editors`, `--cli`, or `--browsers`.
- A future `--all-supported` flag installs supported native ports only.
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
- https://code.visualstudio.com/api/references/theme-color
- https://code.visualstudio.com/api/references/contribution-points
- https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
- https://github.com/microsoft/vscode/tree/1.128.0/extensions/theme-defaults
- https://github.com/primer/github-vscode-theme
- https://github.com/tsujan/Kvantum
- https://github.com/tsujan/Kvantum/blob/master/Kvantum/doc/Theme-Config
- https://github.com/tsujan/Kvantum/blob/master/Kvantum/style/themeconfig/default.kvconfig
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
- https://github.com/Vendicated/Vencord/blob/main/src/main/utils/constants.ts
- https://spicetify.app/docs/development/themes.html
- https://spicetify.app/docs/customization/themes.html
- https://docs.steambrew.app/themes/basics/structure
- https://docs.steambrew.app/users/getting-started/structure
- https://developer.valvesoftware.com/wiki/Steam_Skins
- https://store.steampowered.com/news/195171/
- https://docs.blender.org/manual/en/latest/editors/preferences/themes.html
- https://docs.godotengine.org/en/stable/classes/class_editorsettings.html
- https://help.libreoffice.org/latest/en-US/text/shared/optionen/01012000.html
- https://design.blog.documentfoundation.org/2024/12/20/libreoffice-themes-will-replace-the-color-customization/
- https://wiki.documentfoundation.org/images/b/b0/LibreOffice_config_extension_writing.pdf
- https://git.libreoffice.org/core/+/refs/heads/master/vcl/README.themes.md
- https://slack.com/help/articles/205166337-Change-your-Slack-theme
- https://github.com/micro-editor/micro/blob/master/runtime/help/colors.md
- https://github.com/stenzek/duckstation/blob/master/src/core/fullscreen_ui.cpp
- https://github.com/benjamimgois/goverlay/issues/151
- https://invent.kde.org/frameworks/syntax-highlighting/-/tree/master/data/themes
- https://docs.kde.org/stable_kf6/en/kate/katepart/color-themes.html
- https://github.com/micro-editor/micro/blob/v2.0.15/runtime/help/colors.md
- https://code.claude.com/docs/en/terminal-config#create-a-custom-theme
- https://learn.chatgpt.com/docs/cli-customization
- https://docs.atuin.sh/guide/theming/
- https://github.com/atuinsh/atuin/blob/v18.12.1/crates/atuin-client/src/theme.rs
- https://clementtsang.github.io/bottom/stable/configuration/config-file/styling/
- https://github.com/mpv-player/mpv/blob/v0.41.0/player/lua/osc.lua
- https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf
- https://www.gnu.org/software/coreutils/manual/html_node/dircolors-invocation.html

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
- **Desktop applications:** capture one representative application per port family and per inheritance path: a Qt/KDE application, a GTK 3 application, a libadwaita application, and each creative, office, and chat client once its theme is applied, including focus, selection, disabled, warning, and error states and one inactive window.
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
