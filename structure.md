# Primer Dark Suite structure

Implemented directories contain the current Primer Dark ports. Numbered comments map planned directories to the suite roadmap in `plan.md`. Empty future directories do not need placeholder files until work begins.

```text
primer-dark-suite/
├── assets/               # implemented: official suite icon and store listing artwork
├── kde/
│   ├── artwork/          # implemented: preview sources
│   ├── colors/           # implemented: KDE/Qt color scheme
│   ├── look-and-feel/    # implemented: Plasma 6 Global Theme KPackage
│   ├── aurorae/          # optional Aurorae window-decoration assets
│   ├── konsole/          # implemented: native color scheme and color-only profile
│   ├── plasma-style/     # implemented: bordered Plasma popup and widget frames
│   ├── kvantum/          # implemented: native Kvantum theme config
│   ├── ktexteditor/      # implemented: KSyntaxHighlighting theme for KWrite and Kate
│   └── plasma-login/     # future: KDE Plasma Login greeter
│
├── terminals/
│   └── ghostty/          # implemented: native Ghostty color theme
│
├── editors/
│   ├── cursor/           # implemented: VS Code-compatible color theme extension
│   └── zed/              # implemented: complete Zed workbench/editor theme
│
├── cli/
│   ├── atuin/            # implemented: native Atuin theme
│   ├── bottom/           # implemented: ready-to-merge bottom styles
│   ├── claude/           # implemented: native Claude Code custom theme
│   ├── dircolors/        # implemented: GNU dircolors database for LS_COLORS
│   ├── pi/               # implemented: complete Pi CLI/TUI theme
│   ├── herdr/            # implemented: complete Herdr TUI palette snippet
│   ├── bat/              # implemented: native bat syntax theme, also installed for Codex
│   ├── btop/             # implemented: native btop theme
│   ├── fzf/              # implemented: fzf color option snippets for POSIX shells and fish
│   ├── eza/              # implemented: ready-to-merge eza theme.yml
│   ├── fastfetch/        # implemented: native Fastfetch preset
│   ├── fish/             # implemented: native Fish theme file
│   ├── micro/            # implemented: native micro colorscheme
│   └── tmux/             # implemented: tmux style snippet
│
├── browsers/
│   ├── firefox/          # implemented: Mozilla Firefox static theme, live on addons.mozilla.org
│   └── chrome/           # implemented: native Google Chrome theme package
│
├── gtk/
│   ├── primer-dark/      # implemented: native GTK 3 and GTK 4 theme package
│   └── libadwaita/       # documented: optional libadwaita color override snippet
│
├── creative/             # applications with their own theme formats
│   ├── blender/          # planned: interface theme XML preset
│   └── godot/            # implemented: text editor theme; editor colors documented
│
├── media/
│   └── mpv/              # implemented: OSD, OSC, and console color snippet
│
├── gaming/
│   └── mangohud/         # implemented: MangoHud color snippet
│
├── office/               # planned: office suite appearance theme
│   └── libreoffice/      # planned: appearance theme extension with themes.xcu
│
├── chat/                 # planned: chat client appearance customization
│   └── slack/            # planned: ready-to-paste custom theme string
│
├── integrations/         # planned: third-party client-mod and patcher themes, never installed by the root script
│   ├── vencord/          # planned: Discord CSS theme for Vencord
│   ├── spicetify/        # planned: Spotify color.ini and user.css theme for Spicetify
│   └── steam/            # planned: Steam CSS theme for a third-party client loader
│
├── palette/              # implemented: canonical Primer Dark tokens
├── scripts/              # implemented: validation and asset generation
│   ├── check.sh          # implemented: palette and per-component asset validation
│   ├── components/       # shared per-component preflight, install, guard, uninstall, and check hooks
│   └── lib/              # shared component registry, paths, and shell helpers
├── .github/              # implemented: verification and Firefox release workflows
├── install.sh            # implemented: preflighted user-local component orchestrator
├── uninstall.sh          # implemented: safe component lifecycle orchestrator
├── plan.md               # implemented: suite roadmap and acceptance criteria
├── distribution.md       # implemented: store and upstream publication status per port
├── README.md
├── NOTICE
└── LICENSE
```

`kde/plasma-login/` targets KDE's Plasma Login frontend rather than SDDM. It remains separate from normal user-local ports because login-manager integration is system-level and requires dedicated packaging and safety work.

`integrations/` holds ports whose clients have no official theme API and that therefore depend on a third-party client mod or patcher (Vencord for Discord, Spicetify for Spotify, a CSS-injection loader such as Millennium for Steam). They are published as manual assets only: the suite never installs the mod or patcher, never edits the client installation, and never activates the theme. Roadmap scope for these ports is in `plan.md`.

Applications that inherit an existing port need no directory of their own: the installed KDE and Qt applications follow the color scheme and widget style, the installed GTK applications follow the GTK theme package, and the Flatpak libadwaita applications depend on the documented libadwaita and Flatpak overrides. Their coverage is tracked in the roadmap sections of `plan.md`, together with the installed applications that have no supported theme path.
