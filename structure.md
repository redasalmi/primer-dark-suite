# Primer Dark Suite structure

Implemented directories contain the current Primer Dark ports. Numbered comments map planned directories to the suite roadmap in `plan.md`. Empty future directories do not need placeholder files until work begins.

```text
primer-dark-suite/
├── kde/
│   ├── artwork/          # implemented: preview sources
│   ├── colors/           # implemented: KDE/Qt color scheme
│   ├── look-and-feel/    # implemented: Plasma 6 Global Theme KPackage
│   ├── aurorae/          # optional Aurorae window-decoration assets
│   ├── konsole/          # implemented: native color scheme and color-only profile
│   ├── plasma-style/     # implemented: bordered Plasma popup and widget frames
│   ├── kvantum/          # future: optional Qt application style
│   └── plasma-login/     # future: KDE Plasma Login greeter
│
├── terminals/
│   └── ghostty/          # implemented: native Ghostty color theme
│
├── editors/
│   └── zed/              # implemented: complete Zed workbench/editor theme
│
├── cli/
│   ├── pi/               # implemented: complete Pi CLI/TUI theme
│   ├── herdr/            # implemented: complete Herdr TUI palette snippet
│   ├── bat/              # roadmap 3
│   ├── btop/             # roadmap 3
│   ├── fzf/              # roadmap 3
│   ├── eza/              # roadmap 3
│   ├── fastfetch/        # roadmap 3
│   ├── fish/             # roadmap 3
│   └── tmux/             # roadmap 3
│
├── browsers/
│   ├── firefox/          # implemented: native Mozilla Firefox static theme package
│   ├── chrome/           # implemented: native Google Chrome theme package
│   └── helium/           # implemented: Helium-adapted Chromium theme package
│
├── creative/
│   ├── blender/          # roadmap 5
│   ├── krita/            # roadmap 5
│   ├── gimp/             # roadmap 5
│   ├── inkscape/         # roadmap 5
│   └── godot/            # roadmap 5
│
├── gtk/
│   ├── gtk-3.0/          # roadmap 6
│   └── gtk-4.0/          # roadmap 6
│
├── integrations/         # optional and never installed by default
│   ├── discord/          # roadmap 7: Vencord/BetterDiscord CSS
│   ├── spotify/          # roadmap 7: Spicetify
│   └── steam/            # roadmap 7: Millennium/custom CSS
│
├── palette/              # implemented: canonical Primer Dark tokens
├── scripts/              # implemented: packaging and asset generation
│   ├── components/       # shared per-component install, uninstall, and package hooks
│   └── lib/              # shared component registry, paths, and shell helpers
├── install.sh            # implemented: preflighted user-local component orchestrator
├── uninstall.sh          # implemented: safe component lifecycle orchestrator
├── plan.md
├── README.md
├── NOTICE
└── LICENSE
```

`kde/plasma-login/` targets KDE's Plasma Login frontend rather than SDDM. It remains separate from normal user-local ports because login-manager integration is system-level and requires dedicated packaging and safety work.
