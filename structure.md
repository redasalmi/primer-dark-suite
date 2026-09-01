# Primer Dark Suite structure

Implemented directories contain the Plasma 6 v1 foundation. Numbered comments map planned directories to the suite roadmap in `plan.md`. Empty future directories do not need placeholder files until work begins.

```text
primer-dark-suite/
├── kde/
│   ├── artwork/          # implemented: preview sources
│   ├── colors/           # implemented: KDE/Qt color scheme
│   ├── look-and-feel/    # implemented: Plasma 6 Global Theme KPackage
│   ├── aurorae/          # optional legacy window-decoration assets
│   ├── konsole/          # roadmap 1: Konsole color scheme/profile
│   ├── plasma-style/     # future: custom Plasma desktoptheme
│   ├── kvantum/          # future: optional Qt application style
│   └── plasma-login/     # future: KDE Plasma Login greeter
│
├── terminals/
│   └── ghostty/          # roadmap 1
│
├── editors/
│   ├── zed/              # roadmap 2
│   ├── cursor/           # roadmap 2
│   └── pi/               # roadmap 2
│
├── cli/
│   ├── bat/              # roadmap 3
│   ├── btop/             # roadmap 3
│   ├── fzf/              # roadmap 3
│   ├── eza/              # roadmap 3
│   ├── fastfetch/        # roadmap 3
│   ├── fish/             # roadmap 3
│   └── tmux/             # roadmap 3
│
├── browsers/
│   ├── firefox/          # roadmap 4
│   ├── chrome/           # roadmap 4
│   └── helium/           # roadmap 4
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
├── install.sh            # implemented: KDE v1 user-local installer
├── uninstall.sh          # implemented: safe KDE v1 removal
├── plan.md
├── README.md
├── NOTICE
└── LICENSE
```

`kde/plasma-login/` targets KDE's Plasma Login frontend rather than SDDM. It remains separate from normal user-local ports because login-manager integration is system-level and requires dedicated packaging and safety work.
