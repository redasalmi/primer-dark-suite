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

## Implemented foundation: KDE Plasma 6 v1

- Complete KDE/Qt color scheme.
- Native Breeze window decoration driven by Primer titlebar colors, borders, and shadows; Aurorae assets remain optional.
- Strict Plasma 6 Look-and-Feel KPackage.
- Breeze application and Plasma styles driven by Primer colors.
- Breeze Dark icons and Breeze cursors.
- Logo-free splash screen and System Settings previews.
- Offline install, uninstall, update, and release packaging scripts.
- No panel layout, wallpaper, font, or window-button-order changes.

## Suite roadmap

### 1. Konsole and Ghostty

Create the terminal foundation first so every terminal-based tool inherits a consistent base palette.

- **Konsole:** native `.colorscheme` plus an optional profile that references it without replacing shell or font preferences.
- **Ghostty:** native theme file using the same foreground, background, cursor, selection, and ANSI 16-color mapping.
- Validate normal, bright, and dim ANSI colors, selections, links, prompts, diffs, and long-running TUI sessions in both terminals.

### 2. Zed, Cursor and Pi

Create native editor and coding-agent themes from the shared syntax and UI roles.

- **Zed:** JSON theme covering workbench, editor, terminal, diagnostics, diffs, syntax, collaboration colors, and all interaction states.
- **Cursor:** VS Code-compatible color theme and extension metadata covering workbench, editor, integrated terminal, semantic highlighting, diagnostics, and Git decorations.
- **Pi:** native JSON theme covering all required TUI, markdown, tool, diff, syntax, thinking-level, search, and bash-mode tokens.
- Keep syntax colors aligned with the installed Zed GitHub Dark reference unless contrast or application semantics require an adjustment.

### 3. bat, btop, fzf, eza, fastfetch, Fish and tmux

Build focused CLI/TUI ports that compose cleanly inside the terminal themes.

- **bat:** TextMate/Sublime syntax theme and cache-install instructions.
- **btop:** native theme file for graphs, process states, meters, highlights, and selected rows.
- **fzf:** shell-safe color option set for borders, prompts, matches, selections, and previews.
- **eza:** `EZA_COLORS`/`LS_COLORS` mapping for file types, permissions, Git state, and metadata.
- **fastfetch:** restrained logo and output color configuration.
- **Fish:** syntax, autosuggestion, completion, prompt, error, command, parameter, and operator colors.
- **tmux:** status bar, pane borders, messages, copy mode, and active-window styling.

### 4. Firefox, Chrome and Helium

Create browser chrome ports without attempting to force a universal website theme.

- **Firefox:** browser theme manifest; keep deeper `userChrome.css` changes optional and versioned separately.
- **Chrome and Helium:** shared Chromium theme manifest with application-specific packaging where needed.
- Cover active/inactive tabs, toolbar, omnibox, bookmarks, new-tab chrome, window states, private browsing, and focus visibility.

### 5. Blender, Krita, GIMP, Inkscape and Godot

Create native creative/development application ports.

- **Blender:** native XML theme for editors, panels, selections, node graphs, timelines, and syntax.
- **Krita:** native color-scheme package that remains consistent with the KDE palette.
- **GIMP:** application theme resources coordinated with the GTK port.
- **Inkscape:** application preferences and GTK integration without overriding document colors.
- **Godot:** editor and script-editor color configuration covering nodes, docks, inspectors, selections, diagnostics, and syntax.

### 6. GTK 3/4

Create shared GTK foundations for installed GTK applications.

- Provide GTK 3 and GTK 4 variants from the same semantic palette.
- Cover controls, menus, popovers, tooltips, lists, headers, selections, focus, disabled states, and destructive actions.
- Document Flatpak overrides separately.
- Treat libadwaita limitations honestly; do not claim unsupported applications are fully themed.

### 7. Optional third-party Discord, Spotify and Steam integrations

Keep unsupported application patching isolated, explicit, and reversible.

- **Discord:** optional Vencord/BetterDiscord-compatible CSS.
- **Spotify:** optional Spicetify theme with Flatpak-aware installation guidance.
- **Steam:** optional Millennium/custom CSS integration.
- Never install third-party patchers automatically.
- Require explicit component selection, version checks, backups, and clear restore instructions.
- A failure in an optional integration must not block installation of supported theme ports.

## Installation architecture

As the suite grows, the root installer should become a component orchestrator rather than installing everything automatically.

Planned behavior:

- `./install.sh` installs the stable KDE foundation.
- Explicit flags select additional ports, such as `--terminal`, `--editors`, `--cli`, `--browsers`, `--creative`, or individual applications.
- `--all-supported` installs supported native ports only.
- Third-party integrations always require separate explicit flags.
- Every installed component records only files owned by Primer Dark and can be removed without reverting unrelated preferences.

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
