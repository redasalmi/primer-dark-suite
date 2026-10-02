# Primer Dark Suite plan

## Goal

Build a complete, coherent dark theme suite for the applications, developer tools, terminals, and desktop components installed on this machine. Every port should translate GitHub Primer's semantic dark colors into the application's native theme format while preserving that application's interaction and accessibility conventions.

The KDE Plasma 6 global theme is the implemented foundation. Future work expands from that foundation in the priority order below.

## Principles

- Keep `palette/primer-dark.json` as the canonical source of color roles.
- Prefer official, native theme formats and supported configuration APIs.
- Reuse the same semantic roles for surfaces, text, borders, focus, selection, syntax, diffs, and status colors across ports.
- Preserve unrelated user settings; installers must be user-local, reversible, and opt-in.
- Commit ready-to-use generated assets so installation does not require a build tool. Third-party fonts and icons are the one exception: they are downloaded at install time from pinned upstream releases and verified by SHA-256 checksum instead of being committed (see roadmap section 12).
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

The palette tracks the dark functional tokens of `@primer/primitives` 11.10.0 (checked 2026-09-30), grouped by role:

- `surface`, `foreground`, `border`, `accent`, and `status` are Primer's functional colors. `foreground.subtle` (`#B7BDC8`) is Primer's base neutral step 10, for text that sits between muted and default, such as shimmer highlights. The `*Inset` surfaces are earlier Primer scale steps that the existing ports keep for status fills.
- `overlay.*` holds Primer's translucent `bgColor-*-muted` and `diffBlob` colors as published, and `surface.*Muted` and `diff.*` hold the same colors flattened over `surface.default` for native formats that paint opaque colors. Diff lines use the success and danger muted colors, changed words use the added and removed word colors, and gutter numbers use the added and removed number colors. Zed (editor diff hunks, word diffs, and conflict markers) and Cursor (diff editor) use the `overlay` originals; Claude Code uses the flattened colors. Zed's Git status `.background` colors keep the `*Inset` surfaces for status badges.
- `syntax.*` holds Primer's `prettylights` syntax roles (comment, keyword, constant, entity, entity tag, variable, and string) plus the diff markup text and background pairs. Every editor and CLI port assigns language constructs to these roles with the shared syntax mapping below.
- `terminal.*` is Primer's ANSI set without changes: normal, bright, and the faint blends derived from it in Konsole.

### Shared syntax mapping

The mapping follows GitHub's own editor theme ([primer/github-vscode-theme](https://github.com/primer/github-vscode-theme) 6.3.5, `src/theme.js`), which applies the `prettylights` roles to TextMate scopes, and was applied to every syntax port on 2026-10-01.

| Construct | Role |
| --- | --- |
| Comments and documentation comments; Markdown quotes (italic) | `syntax.comment` |
| Keywords, storage, operators, escape sequences, preprocessor directives, and embedded-code punctuation (`${`) | `syntax.keyword` |
| Constants, numbers, booleans, characters, language variables (`this`, `self`), read-only variables, enum members, attributes, decorators, labels, property and object keys, built-in types, classes, and constants, links, and Markdown headings (bold) | `syntax.constant` |
| Function and method names, constructors, and built-in functions; diff ranges (bold) | `syntax.entity` |
| Class, type, interface, struct, enum, and namespace names, type parameters, function parameters, sigil variables (`$var`), and Markdown list markers | `syntax.variable` |
| HTML, XML, and JSX tags and their delimiters, and JSON and YAML keys | `syntax.entityTag` |
| Strings, regular expressions, and Markdown inline and block code | `syntax.string` |
| Plain variables, properties, punctuation, brackets, and import or package modifiers | `foreground.default` |
| Inserted, deleted, and changed diff lines | `syntax.markup*Text` on `syntax.markup*Background` |
| Invalid code | `status.danger` (bat paints it as a background behind `foreground.onEmphasis`) |

Port limits:

- bat and Codex render TextMate foregrounds only, so the bat theme keeps `status.success`, `status.danger`, and `status.attention` as the diff markup foregrounds; the backgrounds stay in the file for consumers that paint them.
- KSyntaxHighlighting has one `BuiltIn` style for built-in types, functions, and variables, so built-in functions are `syntax.constant` in KWrite and Kate.
- Fish highlights shell input rather than a language grammar: commands keep `accent.foreground`, options use `syntax.entityTag`, and parameters and redirections use `syntax.variable`.

## Implemented foundation

- Complete KDE/Qt color scheme.
- Native Breeze window decoration driven by Primer titlebar colors, borders, and shadows; Aurorae assets remain optional.
- Strict Plasma 6 Look-and-Feel KPackage.
- Breeze application and Plasma styles driven by Primer colors.
- Icon and cursor themes are left to the user: the global theme declares neither, so applying it keeps the current selections. The opt-in `--fonts` and `--icons` components install the recommended fonts and Papirus-Dark without selecting them; Breeze cursors are the recommended cursor theme.
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
- Native Blender interface theme preset covering every theme color of Blender 5.2, installed once per detected Blender version.
- Ready-to-paste Slack custom theme string for its four theme colors.
- Vencord theme for Discord's dark appearances, generated from the palette, that sets Discord's own semantic color properties and its brand and gray color ramps.
- Spicetify theme for Spotify, generated from the palette, whose `color.ini` fills Spicetify's color slots and Primer roles and whose `user.css` redeclares every color set of Spotify's dark Encore design system.
- Millennium theme for the Steam desktop client, generated from the palette and one Steam build, that recolors every color declaration of Steam's style sheets with Primer roles defined in Millennium's editable RootColors file.
- Native LibreOffice theme extension covering every item of LibreOffice 26.2's color scheme, including the application colors, installed through `unopkg`.
- Native micro colorscheme, Godot 4 text editor theme, Claude Code custom theme, Codex syntax theme (the bat TextMate theme), and Atuin theme, each installed as one owned file.
- Ready-to-merge fish fzf snippet, GNU dircolors database, bottom styles, mpv OSD/OSC/console snippet, and MangoHud color snippet.
- No icon theme, cursor theme, panel layout, wallpaper, font, or window-button-order changes.

## Suite roadmap

### 1. Konsole and Ghostty

Continue the terminal foundation so every terminal-based tool inherits a consistent base palette.

- **Konsole:** implemented as a native `.colorscheme` plus an optional profile that references it without changing existing profiles or declaring a shell or font.
- **Ghostty:** implemented as a native theme file using the shared foreground, background, cursor, selection, and ANSI 16-color mapping.
- Normal, bright, and dim ANSI colors, links, prompts, diffs, and long-running `btop` sessions have been visually validated in both terminals; selection was visually inspected in Konsole and Ghostty's selection mapping passed its native parser.
- On 2026-09-30 the ANSI colors were realigned with Primer's official ANSI set in Konsole, Ghostty, Zed, and Cursor: black `#2F3742`, red `#FF7B72`, blue `#58A6FF`, magenta `#BE8FFF`, and white `#F0F6FC`, with bright red `#FFA198`, bright green `#56D364`, and bright yellow `#E3B341` (previously orange). Ghostty's parser accepts the new theme; the realigned colors have not yet been visually re-inspected in either terminal.

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
- **Claude Code:** implemented as a native custom theme (`cli/claude/primer-dark.json`, base `dark`) installed by `--claude` to `$CLAUDE_CONFIG_DIR/themes/` or `~/.claude/themes/`. It overrides the documented text, status, mode, diff, transcript, usage, subagent, rainbow, and shimmer tokens; every token name was confirmed against the installed binary. Diff lines use `surface.successMuted` and `surface.dangerMuted`, and word-level highlights use `diff.addedWord` and `diff.removedWord`, so the theme matches GitHub's pull-request diff colors without any blend of its own; the inactive shimmer uses `foreground.subtle`. Selection is stored as `custom:primer-dark`, which the guard looks for in `settings.json` and the global `.claude.json`.
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

- **Blender:** implemented as an interface theme preset (`creative/blender/Primer_Dark.xml`) that defines all 649 theme colors of Blender 5.2, covering widgets and their animation, keyframe, driver, override, and changed states, panels, regions, editor and header backgrounds, text, selection, focus, report banners, the 3D Viewport, Graph Editor, Dope Sheet, NLA, Sequencer, Clip, Image/UV, node categories and zones, Outliner, Info, Console, and Text Editor syntax, plus the bone color sets, collection colors, and strip colors. `scripts/generate-blender-theme.py` runs inside Blender (`blender --background --factory-startup --python scripts/generate-blender-theme.py`), resets the in-memory theme to Blender's defaults, assigns every color from the canonical palette, refuses to write while any color property is unmapped or a mapped key no longer exists, and writes the file with Blender's own preset writer. Opaque fills that Blender draws under white text (report banners, node headers, strips, bone colors) are palette hues flattened over `surface.default`, in the same way as the palette's muted surfaces. Blender's selection convention is kept: selected items use `status.severe` and the active item `syntax.variable`, Primer's orange roles. The file carries an empty `ThemeStyle` element, which the preset loader requires, so applying it leaves the user's interface font styles untouched; the file name `Primer_Dark.xml` makes Blender display it as **Primer Dark**, like the bundled `Blender_Dark.xml`. `--blender` installs one owned copy to `$XDG_CONFIG_HOME/blender/<version>/scripts/presets/interface_theme/` for the version reported by `blender --version` and for every existing version directory, and preflight fails when it finds neither. Blender skips XML keys a version does not know and keeps its defaults for keys the file lacks, so other versions load the file, but 5.2.2 is the validated target. Selecting a theme copies its colors into Blender's preferences, so uninstall removes every owned copy without an active-theme guard and the applied colors stay until another theme or **Reset** is chosen. A headless Blender 5.2.2 run with an isolated configuration loaded the preset through `script.execute_preset` without skipped types or unknown keys, and a capture of the default scene with the theme applied was inspected. Flatpak Blender keeps its configuration under `~/.var/app/org.blender.Blender/` and is not detected.
- **Godot:** the text editor theme is implemented as `creative/godot/PrimerDark.tet`, installed by `--godot` to `~/.config/godot/text_editor_themes/`, and defines all 49 color keys of Godot 4.7's `text_editor/theme/highlighting/` set, including the GDScript and comment-marker colors. A headless editor run with an isolated configuration confirmed that Godot loads every value. The editor chrome of Godot 4.7 is generated from `interface/theme/base_color`, `accent_color`, and `contrast` with the `Custom` color preset, which live in the shared `editor_settings-4.x.tres`, so those values are documented in the README rather than written by the installer; a full custom editor `Theme` resource remains optional future work.
- Both applications ship their own UI toolkit, so backgrounds, borders, text, focus, selection, disabled, warning, error, and syntax states are mapped in each application's own key set from the canonical palette, and both ports are re-verified against the installed minor version because their theme key sets change between releases.

### 8. LibreOffice

Cover the office suite through its own appearance theme instead of relying only on the desktop integration.

- LibreOffice 26.2 is installed together with `libreoffice-kf6`, so window chrome, dialogs, and file pickers already follow the KDE color scheme. The remaining surface is LibreOffice's own appearance theme.
- **Implemented** as a theme extension in `office/libreoffice/primer-dark/`: `description.xml` (identifier `io.github.redasalmi.primer-dark`, version 1.0.0, minimum LibreOffice 26.2), `META-INF/manifest.xml`, the suite icon, and a `themes.xcu` that replaces a `ColorScheme/ColorSchemes/Primer Dark` node defining all 91 items of LibreOffice 26.2's `ColorScheme` template: document and application background, document and table boundaries, text, links, spelling, grammar, smart tags, shadows, the Writer grid, field and index shadings, direct cursor, section, header and footer, page break, and formatting marks, the HTML source view, every Calc marker, value highlighting, notes, and protected cells, the Draw grid, nine tracked-change author colors, the Basic IDE and SQL syntax with the shared syntax mapping, and the 27 application colors, which follow the KDE color scheme roles.
- LibreOffice 25.2 introduced extension themes with separate `Light` and `Dark` values per item; LibreOffice 26.2's schema defines a single `Color` per item and ignores `Light` and `Dark`, which an isolated-profile test confirmed. The theme therefore stores one decimal RGB `Color` per item, and items keep LibreOffice's own `IsVisible` defaults, so hidden-row and hidden-column markers stay hidden as in the automatic scheme.
- `scripts/generate-libreoffice-theme.py` writes `themes.xcu` from the canonical palette, with each value's hex in a comment, and `./scripts/check.sh` runs it with `--check` so the committed file cannot drift from the palette.
- `--libreoffice` packages the directory as a `.oxt` during preflight and installs it with `unopkg add --force --suppress-license`, which registers it inside the user profile under `$XDG_CONFIG_HOME/libreoffice/4/user/` and replaces an earlier version with the same identifier. Uninstall removes it with `unopkg remove`, and the guard refuses while `CurrentColorScheme` in the profile's `registrymodifications.xcu` still names Primer Dark. LibreOffice itself falls back to the automatic theme when a selected extension theme disappears. unopkg also works while LibreOffice is running. Install, selection, the guard, and removal were verified against an isolated profile.
- Activation stays manual: select **Primer Dark** under **LibreOffice Themes** in Tools → Options → LibreOffice → Appearance, keep **Enable application theming** on for the application colors, and clear **Use white document background**, which is on by default and keeps pages white under every theme. LibreOffice asks for a restart. Captures of Writer and Calc in an offscreen nested KWin session confirmed that the `kf6` VCL plugin applies both the document and the application colors.
- The bundled Breeze Dark icon set (`images_breeze_dark_svg.zip`) already matches the suite's icon direction and is the recommended icon theme, so the port ships no icon set of its own.
- The Flatpak build keeps its profile under `~/.var/app/org.libreoffice.LibreOffice/` and is not detected; its Extension Manager can install a `.oxt` built from the same directory.

### 9. Slack

Document the one appearance surface the Slack desktop client exposes.

- Slack has no theme file format. Its appearance customization is the custom theme in Preferences → Appearance, whose four colors drive the window and navigation frame, the sidebar tint, selected items, presence dots, and notification badges over Slack's own light or dark base. The message pane keeps Slack's base colors.
- **Implemented** as the ready-to-paste string `chat/slack/primer-dark.txt`: `#010409,#1F6FEB,#3FB950,#DA3633`. Slack 4.52's client code confirmed the import path. **Import theme** removes whitespace, uppercases the text, splits it on commas, and accepts 4, 8, or 10 hex colors. Four colors are applied as exact custom colors in the order System navigation, Selected items, Presence indication, and Notifications. Eight- and ten-color legacy strings keep only their sidebar, active item, presence, and badge slots, and each of those snaps to Slack's preset palette when it matches a preset color.
- The slots map to `surface.inset` (the chrome role of the KDE header and window title), `accent.emphasis` (selection, under white text), `status.success`, and `status.dangerEmphasis`. Slack draws badge text in white, which needs the emphasis red rather than `status.danger` for contrast. Importing a string also turns off Slack's window gradient, which keeps the flat chrome of the other ports.
- The theme is account state: Slack saves it as a user preference per workspace and syncs it, so the installer never installs or edits it. Users paste the string themselves and select **Dark** mode, and can share it from **Share** next to Theme Colors, which posts an **Apply Slack theme** button in a conversation. `./scripts/check.sh` checks that the file is the single line derived from the palette.
- The string was not applied to a live Slack account during development, because doing so would change synced account preferences; its format and slot order come from the installed client code and Slack's help center.

### 10. Discord, Spotify, and Steam

Integration ports for clients that have no official theme API. Discord, Spotify, and Steam are implemented. All three require a third-party client mod or patcher, so they stay under `integrations/` per the suite principles, ship as manual assets, and are never installed, activated, or updated by the root installer.

- **Discord (Vencord):** **implemented** as `integrations/vencord/primer-dark.theme.css`, generated by `scripts/generate-discord-theme.py`. Discord ships no theme API; Vencord loads local `.css` files from its themes directory (`~/.config/Vencord/themes/` for the Discord app, `~/.config/vesktop/themes/` for Vesktop), names them from the BetterDiscord-style `@name` header, and imports the enabled ones from a style element placed after Discord's own style sheets.
  - Discord's visual-refresh client draws its dark appearances from semantic custom properties declared on `.theme-dark`, `.theme-darker`, and `.theme-midnight` (the default dark appearance carries both `theme-dark` and `theme-darker`). The theme redeclares 333 of them on the same selectors, so it replaces Discord's values by cascade order alone and uses no generated class name. Discord's high-contrast mode, low-saturation setting, Nitro client themes, and custom profile themes declare the same properties with more specific selectors and keep precedence, which leaves those user and accessibility choices intact.
  - Surfaces follow the KDE port: the app frame and server list use `surface.inset`, the chat, channel list, and member list `surface.default`, and popouts, menus, and modals `surface.muted`, `surface.raised`, and `surface.control` by elevation. Hover, pressed, and selected layers keep Discord's translucency with `border.emphasis` at 10–40% alpha. Filled buttons use `accent.emphasis`, the emphasis reds, and a green darkened from `status.success` until white text reaches 4.5:1; like Discord's, they darken on hover and press. Code blocks use the shared syntax mapping and the ANSI blocks the terminal palette.
  - Older components still read Discord's `--brand-*` and `--primary-*` ramps directly, so both ramps, in their plain and `-hsl` forms, are mapped to Primer's accent blues and to its foreground, border, and surface grays. Nitro, Quests, chips, charts, and other promotional gradients keep Discord's colors, and the theme never changes layout, fonts, or light mode.
  - Validated against the Discord web client CSS fetched on 2026-10-02 (desktop host 1.0.160): every property the theme sets is declared by Discord, no other rule outside the accessibility, client-theme, and profile-theme cases above redeclares one, and with the theme injected the way Vencord loads it into the logged-out client, the computed properties resolve to the palette colors. The logged-in client was not inspected during development, because that requires the user's account; a visual pass with Vencord is the remaining acceptance step. The repository never installs or patches Vencord or Discord.
- **Spotify (Spicetify):** **implemented** as the theme folder `integrations/spicetify/PrimerDark/`, generated by `scripts/generate-spotify-theme.py`, for manual placement in `~/.config/spicetify/Themes/PrimerDark/` and activation with `spicetify config current_theme PrimerDark color_scheme Dark` followed by `spicetify apply`.
  - Spicetify 2.45.1's source fixed the format. `spicetify apply` writes each key of the selected `color.ini` section as `--spice-<key>` and `--spice-rgb-<key>` into `colors.css`, falls back to its defaults for missing base keys, replaces the colors Spotify hardcodes in its style sheets with its eighteen base keys (`replace_colors`), and links `colors.css` and `user.css` at the start of the body, after every style sheet Spotify loads in the head.
  - `color.ini` holds one `[Dark]` section: the eighteen base keys, mapped to Primer roles (`main` is `surface.default`, `sidebar` and `player` the inset frame, `button` and `button-active` `accent.foreground`, the toasts the emphasis blue and red), followed by named Primer role keys. `user.css` reads only those role keys.
  - Spotify 1.2.95 draws its dark appearance from Encore color sets declared on `.encore-dark-theme` and the `.encore-*-set` classes inside it, each with the same 25 background, text, essential, and decorative properties. `user.css` redeclares all of them on the same selectors. The base, app frame, muted accent, and inverted dark sets use Primer surfaces with the full status palette; the bright accent set, which fills the play button, uses `accent.emphasis` under white, replacing Spotify's green; the announcement, positive, and negative sets use the blue, green, and red fills under white, darkening on hover and press, and the warning set `status.attention` under the inset color; the subdued sets use the inset surfaces with their bright text and the diff backgrounds of the same hue for hover; the inverted sets stay light. The over-media set, which darkens artwork behind text, keeps Spotify's translucent black.
  - Validated by loading Spotify 1.2.95's own `xpui-snapshot.css` with the generated `colors.css` and `user.css` in a headless browser: every Encore set resolves to its Primer colors. Spicetify was not installed and Spotify was not patched during development. Spicetify cannot patch the system Flatpak until the user gives their account write access to Spotify's application directory, so that step, the Flatpak `spotify_path` and `prefs_path`, and reapplying after each Spotify update are documented as prerequisites; the suite never runs `spicetify backup` or `spicetify apply` and never modifies the Flatpak installation.
- **Steam (Millennium):** **implemented** as the theme folder `integrations/steam/PrimerDark/` (`skin.json`, `colors.css`, and `primer-dark.css`), generated by `scripts/generate-steam-theme.py`, for manual placement in `~/.local/share/Steam/millennium/themes/PrimerDark/` and selection in Steam's **Settings → Millennium → Themes**. Valve removed the built-in `.styles` skin system in the 2023 client UI update, so current Steam needs a CSS-injection loader; Millennium 3.5.0 reads themes from `<Steam>/millennium/themes/` (it migrates the older `steamui/skins/`) and appends each patch's `TargetCss` to the matching window's head.
  - Steam's desktop UI exposes no color variables: its style sheets in `steamui/css` set hardcoded colors on generated class names. The generator therefore recolors one Steam build. It copies every declaration of a color longhand (`color`, `background-color`, `background-image`, the border, outline, and shadow colors, `fill`, `stroke`, and similar) in Steam's order, writes the background, border, and outline shorthands as their color and image longhands only, and adds one `:root` level of specificity to every selector, so the copy reproduces Steam's own cascade for those properties and wins wherever Steam loads its style sheets. Keyframes with mapped colors are copied under a `primer-dark-` prefix with the animation names that use them. High-contrast and forced-colors blocks are copied unmapped.
  - Steam's neutral grays and blue grays map to the Primer surface, border, and text ramp by lightness (`#0E141B` frame to `surface.inset`, `#23262E` panels to `surface.muted`, `#3D4450` controls to `surface.control`, `#67707B` to `border.emphasis`, `#8B929A` to `foreground.muted`, and white to `foreground.default`); its blue, green, red, orange, and yellow accents map to the accent and status roles, as fills or as text depending on the property. The keyboard and Big Picture theme hues keep Steam's colors.
  - The style sheet reads its colors as `rgb(var(--primer-<role>))`, and `colors.css`, Millennium's RootColors file, defines the 21 roles as raw RGB channels with names and descriptions, so users can adjust them in Millennium's editor and a palette change only regenerates `colors.css` and `skin.json`. `skin.json` patches Millennium's default desktop windows (main window, menus, dialogs, friends list, notifications, overlay browser) and leaves Big Picture mode and its menus on Steam's look.
  - Validated by loading Steam build 1788652215's own style sheets after the theme in a headless browser: Chrome parses every generated rule (ten keep no declaration because Steam's own value there is invalid), and for 600 sampled Steam classes every computed background, text, and border color equals the Primer role for Steam's original color. Millennium was not installed and Steam was not patched during development. Because the class names belong to the Steam build, `./scripts/check.sh` checks the generated file's structure and roles rather than regenerating it, and the theme is regenerated from the installed client when a Steam update leaves parts unthemed. Native (non-CEF) dialogs and the in-game overlay remain outside its reach, and the store and community pages keep their own web styles; the suite never installs or patches Steam.
- Each of these clients rewrites DOM structure and class names on ordinary updates, so the ports are versioned against the verified client and loader releases and are visually re-inspected before any release note claims current support.

### 11. Applications without a supported custom-theme path

Record the installed applications that cannot receive a suite asset, so the roadmap does not imply support the client does not allow.

- **LocalSend:** a Flutter application with only light, dark, and system appearance, and no theme format to target.
- **Electron applications without a theme API:** the ChatGPT desktop app, Proton Pass, Bitwarden, HTTPie, and Bionic expose only an appearance toggle. Theming them would require patching their bundled `app.asar`, which the suite does not do.
- **mpv:** has no theme file. The suite publishes `media/mpv/primer-dark.conf`, an `include`-able snippet for the OSD, on-screen controller, and console colors (mpv options use `#AARRGGBB`), verified with mpv 0.41's own option parser, and provides no installer support.
- **Cloudflare WARP and Jellyfin:** WARP's taskbar client has no appearance settings; Jellyfin's web client accepts custom CSS only through its server dashboard, which is shared server configuration and a possible future snippet.
- Applications that read only the desktop's light/dark preference are not ported, because a suite port would depend on internal styling the application does not promise to keep.

### 12. Icons, cursors, and fonts

Complete the KDE refresh down to the icon, cursor, and typography layer. The global theme deliberately declares no icon or cursor theme so that `--apply` never replaces a user's choice; this layer is therefore a separate, opt-in component with its own activation step.

- **Fonts:** implemented as the opt-in `--fonts` component. The recommended set is two SIL Open Font License families built for screens: Inter for the General, Menu, and window title (10 pt), Toolbar (9 pt), and Small (8 pt) fonts, and JetBrains Mono for fixed-width text, terminals, and editors. The fonts are not committed: committing them would add about 10 MB of binaries to every clone and another copy to the history with every upgrade. `fonts/sources.tsv` pins each file instead, by release tag and SHA-256 checksum, to the static faces of Inter 4.1 (`extras/ttf/Inter-*.ttf` inside the `rsms/inter` release asset `Inter-4.1.zip`, extracted with `unzip`, since the repository does not commit built fonts) and JetBrains Mono 2.304 (`fonts/otf/` in `JetBrains/JetBrainsMono`) with each family's license; static faces give Qt and Konsole exact named weights. The pinned files are byte-identical to Fedora's `rsms-inter-fonts` 4.1 and `jetbrains-mono-fonts` 2.304 packages. Preflight skips a family that fontconfig already resolves from another location (for example an existing `~/.local/share/fonts/inter/` or a distribution package such as Fedora's `rsms-inter-fonts` and `jetbrains-mono-fonts`), downloads only the selected families, and verifies every checksum before any component installs anything; the component then copies the files into the owned directory `~/.local/share/fonts/primer-dark/` and refreshes the user font cache with `fc-cache`. Reinstalling replaces the owned directory as a whole, so a family installed elsewhere later stops being duplicated. Uninstall removes only the owned directory and refuses while a `kdeglobals` font role (General, Fixed width, Small, Toolbar, Menu, or the `[WM]` window title) selects a family that only the owned directory provides; fonts selected inside individual applications are not checked.
- **Terminal icon glyphs:** JetBrains Mono is not patched. `--fonts` also installs Symbols Nerd Font Mono from Nerd Fonts 3.5.1 (`patched-fonts/NerdFontsSymbolsOnly`, MIT), which fontconfig uses automatically for the icon glyphs printed by eza, Fastfetch, and prompt tools in Konsole, Kate, and Zed; Ghostty already embeds the symbols.
- **Icons:** implemented as the opt-in `--icons` component. Papirus-Dark is the recommended icon theme, selected under its own name: it is flat, has a native dark variant, covers KDE, GTK, and Flatpak applications, its default blue folders sit close to the Primer accent, and its `FollowsColorScheme=true` keeps its monochrome icons recolored by the Primer Dark color scheme. The suite never runs a package manager, because that needs administrator access and changes system packages the suite does not own. When Papirus-Dark is found on the icon search path, the component downloads nothing and leaves it alone; a distribution package is preferred because it stays updated with the system. Otherwise it downloads GitHub's archive of Papirus release tag 20260801 (about 33 MB), verifies the pinned SHA-256 checksum, and extracts only `Papirus` and `Papirus-Dark`, which links into `Papirus` through relative links, into `~/.local/share/icons/` (about 235 MB), then refreshes their GTK icon caches. Each directory receives a `.primer-dark-suite` marker; only marked directories are ever replaced or removed, preflight refuses to overwrite an unmarked `Papirus` directory, and a reinstall removes the marked copies once Papirus-Dark is installed elsewhere. The guard blocks uninstall only while `kdeglobals` `[Icons]`, `gtk-icon-theme-name` in the GTK `settings.ini` files, or xsettingsd's `Net/IconThemeName` selects Papirus or Papirus-Dark and no other copy of Papirus-Dark is installed. GitHub archives of a tag have been stable, but if GitHub ever regenerates them the checksum stops matching and the install fails safely before changing anything. Papirus's `papirus-folders` tool is not used.
- **Cursors:** Breeze cursors remain the recommendation: they ship with Plasma, scale for HiDPI, and their neutral black-and-white shapes suit the palette. No cursor asset is planned.
- **Activation:** icon, cursor, and font selection live in shared KDE configuration (`kdeglobals` `[Icons]`, `[General]` fonts, and `[WM]` title font, and `kcminputrc`), so the components install files without selecting them, and the README documents System Settings → Text & Fonts, Icons, and Cursors. A future explicit `--apply-appearance` managed exception may select them instead, provided it records the previous values with `kreadconfig6` before writing through `plasma-changeicons` and `kwriteconfig6`, and restores those exact values on uninstall.
- **Application fonts:** ports whose font setting lives in shared configuration (Ghostty `font-family`, Zed `buffer_font_family`, Cursor `editor.fontFamily`, Kate, and the Konsole profile) document the JetBrains Mono setting as a snippet. Theme files keep defining colors only, and the optional Konsole profile stays color-only.

## Installation architecture

The root install and uninstall commands are small component orchestrators. Shared paths and the component registry live under `scripts/lib/`, while each port's preflight, install, active-state guard, uninstall, and check hooks live under `scripts/components/`.

Current and planned behavior:

- `./install.sh` installs the stable KDE foundation.
- `--konsole`, `--ghostty`, `--pi`, `--zed`, `--cursor`, `--fastfetch`, `--bat`, `--btop`, `--fish`, `--gtk`, `--kvantum`, `--ktexteditor`, `--micro`, `--atuin`, `--codex`, `--claude`, `--godot`, `--blender`, `--libreoffice`, `--fonts`, and `--icons` install their respective application themes without changing application settings. `install.sh --help` builds its flag list from the component registry.
- eza, fzf, and tmux are never installed by the root script: eza reads a single fixed `theme.yml`, and fzf and tmux are configured through shell and tmux configuration files, so the installer never edits shared configuration for them.
- The Discord (Vencord), Spotify (Spicetify), and Steam (Millennium) themes are never installed by the root script: each depends on a third-party client mod or patcher that the suite does not install, so `integrations/` assets are published for manual placement and activation only.
- Native application ports keep the same ownership rule: `--micro`, `--ktexteditor`, `--atuin`, `--codex`, `--claude`, and `--godot` each install one owned file, and `--blender` installs one owned `Primer_Dark.xml` per detected Blender version, leaving settings files, Blender preferences, and every other shared configuration file untouched.
- bottom, LS_COLORS, mpv, MangoHud, and the Godot editor base and accent colors are shared configuration, so they are published as snippets and never installed.
- `--libreoffice` installs the theme as a LibreOffice extension through `unopkg`, which owns its registration inside the user profile, and never writes LibreOffice's theme selection.
- Godot's editor settings, LibreOffice's theme selection, and Slack's synced account preferences are shared or application-owned configuration, so those ports publish ready-to-merge assets and documented activation steps instead of installing automatically unless a bounded managed-section exception is approved for that port.
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
- `--fonts` and `--icons` install only owned paths (`~/.local/share/fonts/primer-dark/`, and `~/.local/share/icons/Papirus/` and `Papirus-Dark/` with their markers) and never select them. They are the only components that download: every file is pinned to an upstream release and SHA-256 checksum, fetched with `curl` or `wget` over HTTPS, cached by checksum in `~/.cache/primer-dark-suite/downloads/` so reinstalls work offline, and can be supplied from a local directory through `PRIMER_DARK_DOWNLOADS`. `./scripts/check.sh` validates the pins offline, and `./scripts/check-downloads.sh` downloads and verifies them after a pin changes.
- Every installed component records only files owned by Primer Dark, except approved bounded managed sections such as Herdr's, and can be removed without reverting unrelated preferences.

## Cross-port acceptance criteria

- Every port is derived from `palette/primer-dark.json` and documents intentional deviations.
- Primary and muted text meet their applicable contrast targets.
- Focus, selection, error, warning, success, disabled, and inactive states remain distinguishable.
- Terminal and editor syntax colors are consistent across applications.
- Installation works offline from committed assets and does not require administrator access, except future Plasma Login integration. The `--fonts` and `--icons` downloads need network access once, then install offline from the verified cache or a `PRIMER_DARK_DOWNLOADS` directory.
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
