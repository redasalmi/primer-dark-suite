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
│   ├── pi/               # implemented: complete Pi CLI/TUI theme
│   ├── herdr/            # implemented: complete Herdr TUI palette snippet
│   ├── bat/              # implemented: native bat syntax theme
│   ├── btop/             # implemented: native btop theme
│   ├── fzf/              # implemented: fzf color option snippet
│   ├── eza/              # implemented: ready-to-merge eza theme.yml
│   ├── fastfetch/        # implemented: native Fastfetch preset
│   ├── fish/             # implemented: native Fish theme file
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
