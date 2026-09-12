# Primer Dark Suite store distribution

`install.sh` is the distribution channel for locally installed ports. This document tracks the separate, additive publication channels: browser and editor stores, theme registries, and upstream theme directories. It is the checklist to consult before publishing anything outside this repository, and it records what each store expects, what is already published, and what still blocks publication.

Local install mechanics and lifecycle behavior stay in `README.md`; roadmap scope stays in `plan.md`.

## Status overview

| Port | Channel | Status | Publish artifact |
| --- | --- | --- | --- |
| Firefox | addons.mozilla.org | Published | `browsers/firefox/primer-dark/` |
| Chrome | Chrome Web Store | Not published, loaded unpacked | `browsers/chrome/primer-dark/` |
| Zed | Zed extension registry | Not published | `editors/zed/primer-dark.json` plus a new `extension.toml` and `themes/` layout |
| Cursor | Visual Studio Marketplace and Open VSX | Theme implemented, not published | `editors/cursor/primer-dark/` |
| KDE Plasma global theme | KDE Store → Global Themes (Plasma 6) | Not published | `kde/look-and-feel/io.github.redasalmi.primerdark.desktop` |
| KDE Plasma style | KDE Store → Plasma Styles | Not published | `kde/plasma-style/PrimerDark` |
| KDE color scheme | KDE Store → Plasma Color Schemes | Not published | `kde/colors/PrimerDark.colors` |
| Konsole color scheme | KDE Store → Konsole Color Schemes | Not published | `kde/konsole/PrimerDark.colorscheme` |
| Aurorae decoration (optional) | KDE Store → Window Decorations | Not published | `kde/aurorae/PrimerDark` |
| Splash screen (optional) | KDE Store → Plasma 6 Splashscreens | Not published | needs extraction from `kde/look-and-feel/.../contents/splash` |
| Kvantum style | KDE Store → Kvantum | Not implemented | `kde/kvantum/` is still a planned directory |
| GTK 3/4 | GNOME Look / Pling → GTK3/4 Themes | Not published | zipped `gtk/primer-dark/` |
| Ghostty | upstream iTerm2-Color-Schemes (vendored into Ghostty) | Not submitted | user theme today, upstream contribution if a built-in is wanted |
| btop | upstream `aristocratos/btop` `themes/` | Not submitted | user theme today, upstream PR if a built-in is wanted |
| Fish | upstream `fish-shell/fish-shell` bundled themes | Not submitted | user theme today, upstream PR if a built-in is wanted |
| fastfetch, bat, eza, fzf, tmux, Pi, Herdr, libadwaita | None | Not applicable | files and snippets users copy or merge themselves |

## Store channels

### Firefox — addons.mozilla.org (published)

- Listing: https://addons.mozilla.org/en-US/firefox/addon/primer-dark/
- Artifact: `browsers/firefox/primer-dark/`, an unsigned Manifest V3 static theme with add-on ID `primer-dark@redasalmi.github.io` and its own `version` in `manifest.json`.
- Release path: `.github/workflows/firefox-release.yml`. A manual run verifies the manifest version against the public AMO API, runs `web-ext lint`, builds the package, and submits it with `web-ext sign --channel listed`. It requires the `WEB_EXT_API_KEY` and `WEB_EXT_API_SECRET` repository secrets and stops after submission, without waiting for review.
- Manual equivalent: `web-ext sign --source-dir browsers/firefox/primer-dark --channel listed --approval-timeout 0` with the credentials from the AMO API key page.
- The installer never writes into a Firefox profile for this port, so store and local copies cannot collide.

### Chrome — Chrome Web Store (not published)

- Artifact: `browsers/chrome/primer-dark/`, an unsigned Manifest V3 theme with its own `version`. It is currently loaded with **Load unpacked** from `chrome://extensions`.
- Registration: the Chrome Web Store requires a developer account and its one-time registration fee before an item can be published.
- Listing assets already present: `assets/store/chrome-small-tile-440x280.png` and `assets/store/chrome-screenshot-1280x800.png`, plus the 128 px icon inside the package.
- No release workflow exists yet. Publishing needs a workflow analogous to the Firefox one (store-side version check, zip the directory, upload), or a manual upload through the developer dashboard.
- Store-side limits to state in the listing: Chrome's incognito theme provider ignores custom theme suppliers, and derived hover, focus, pressed, separator, DevTools, internal-page, and website colors are not theme-controllable.

### Zed — Zed extension registry (not published)

- Zed extensions are Git repositories with an `extension.toml`; themes are JSON files inside a `themes/` directory. Theme-only extensions need no Rust, `Cargo.toml`, or WebAssembly.
- Current asset: `editors/zed/primer-dark.json` is already a Theme Family object (`name`, `author`, `themes[]`, `style.syntax`). Publishing additionally needs `themes/primer-dark.json` and an `extension.toml` (`id`, `name`, `version`, `schema_version`, `authors`, `description`, `repository`).
- ID rules: no `zed` or `extension` substring, and theme IDs must be suffixed `-theme`, so the ID is `primer-dark-theme`.
- Submission: open a PR against `zed-industries/extensions` that adds the repository as a submodule under `extensions/primer-dark-theme` using an HTTPS URL and a commit that is on a branch, adds a matching `[primer-dark-theme]` entry to `extensions.toml` (`submodule`, optional `path` when the extension lives in a subdirectory such as `editors/zed`, and `version`), and runs `pnpm sort-extensions`. One extension per PR, at most three open PRs, and a three-week response window on maintainer feedback.
- Updates: bump `version` in `extension.toml`, update the submodule commit with `git submodule update --remote`, and open another PR. The `version` in `extensions.toml` must match the pinned commit.
- Test the extension as a dev extension in Zed before submitting.
- Asset issues to fix before submitting: `icon.background` and `icon.border` are not Zed theme fields and are ignored; the 16 `vim.*` keys are honored by Zed but are absent from the published v0.2.0 schema, so schema validation reports them; nine optional style keys are unset; and no `players` array is defined.

### Cursor — Visual Studio Marketplace and Open VSX (theme implemented, not published)

- Artifact: `editors/cursor/primer-dark/`, an unpacked VS Code-compatible theme extension whose `package.json` declares `contributes.themes` and whose `version` is `1.0.0`.
- The repository publishes no VSIX and no store account yet. Publishing requires packaging the directory with `vsce package` and both a Microsoft publisher and an Open VSX namespace matching the `publisher` field, which is currently `redasalmi`.
- Visual Studio Marketplace: publishing runs through Azure DevOps credentials with `vsce publish`. Global personal access tokens are retired on 1 December 2026, so prefer Entra ID authentication with workload identity federation and `vsce publish --oidc` for automated publishing.
- Open VSX: requires an Eclipse Foundation account whose GitHub username matches the Open VSX login, a signed publisher agreement, and a namespace matching the `publisher` field, then `ovsx publish`. Cursor reads Open VSX rather than the Microsoft Marketplace, so publishing to both keeps the same extension available everywhere.
- The extension state to keep in sync when publishing: the version in `package.json` and the version in `CURSOR_EXT_VERSION` in `scripts/lib/common.sh`, which the installer uses for the installed directory name.

### KDE — KDE Store (not published)

Each KDE component is its own store item, and the global theme listing can declare dependencies on the others through `X-KPackageDependencies` in `metadata.json` once those item numbers exist.

- Global theme (Plasma 6): `kde/look-and-feel/io.github.redasalmi.primerdark.desktop`; its `metadata.json` already declares `Category: Global Themes (Plasma 6)`, `License: MIT`, and the repository website.
- Plasma style: `kde/plasma-style/PrimerDark`.
- Color scheme: `kde/colors/PrimerDark.colors`.
- Konsole color scheme: `kde/konsole/PrimerDark.colorscheme`. The companion `PrimerDark.profile` is a local convenience that references the color scheme; it is not a store artifact.
- Aurorae decoration: `kde/aurorae/PrimerDark`, optional because the suite ships the native Breeze decoration by default.
- Splash screen: the splash lives inside the global theme package at `kde/look-and-feel/io.github.redasalmi.primerdark.desktop/contents/splash`; a separate splashscreen listing requires extracting it into a standalone splashscreen package.
- Kvantum: not implemented yet; `kde/kvantum/` is listed as future work in `structure.md`.

### GTK 3/4 — GNOME Look / Pling (not published)

- Artifact: a zip of `gtk/primer-dark/` containing `index.theme`, `gtk-3.0/`, and `gtk-4.0/`, uploaded as a GTK3/4 Themes product on gnome-look.org or pling.com.
- The listing must state the known limits: libadwaita applications ignore user GTK themes and need the documented override for `~/.config/gtk-4.0/gtk.css`, and Flatpak applications need the documented filesystem permission or `GTK_THEME` override. Those are documented in `README.md` and are not part of the theme package.

## Upstream channels (not stores)

These projects have no theme store. Their built-in themes are shipped from their own repositories, so a bundled Primer Dark theme is an upstream contribution rather than a store listing.

- Ghostty: built-in themes are vendored from iTerm2-Color-Schemes and refreshed from that repository, so a built-in theme should be contributed there. Otherwise the theme stays a user theme in `~/.config/ghostty/themes`, which is how `install.sh --ghostty` installs it.
- btop: the upstream `themes/` directory accepts new `.theme` files. Otherwise the file stays a user theme in `~/.config/btop/themes`, which is how `install.sh --btop` installs it.
- Fish: bundled themes ship in fish's data directory. There is no per-user theme search path today, so the `.theme` file is loaded explicitly with `fish_config theme choose` or `save`, which is how `install.sh --fish` installs it.
- fastfetch: the upstream `presets/` directory contains examples only (such as `all.jsonc` and `neofetch.jsonc`); there is no preset contribution channel or preset store. The `primer-dark.jsonc` preset is distributed as a file users copy into their own presets directory.
- bat and eza: no store and no upstream theme submission channel. The bat `.tmTheme` and the eza `theme.yml` are published for users to install or merge themselves, as described in `README.md`.
- fzf, tmux, Pi, Herdr, and the libadwaita override: configuration snippets and user-local files only, with no publication channel.

## Rules for any store submission

1. Nothing is published or uploaded automatically. Store submissions are manual, reviewed steps, in the same way the AMO release workflow is started by hand; the install and uninstall scripts never contact a store.
2. Store manifests are the only versioned artifacts: the two browser manifests today, and Zed's `extension.toml` if that port is published. Bump only the manifest of the store being published to, and never introduce a cross-file suite version.
3. Publish only committed assets. Regenerate them with the existing scripts, then run `./scripts/check.sh` and the relevant store's own linter or packaging tool.
4. Keep the unofficial wording in every listing and keep the statements from `NOTICE` accurate: this is an independent project, is not affiliated with or endorsed by GitHub, Inc., and derives its colors from MIT-licensed Primer Primitives.
5. Store screenshots and tiles live in `assets/store/`. Add the missing per-store artwork before opening a listing, and record previews for KDE, GTK, Zed, and Cursor when those channels are used.
6. Never claim support a store cannot deliver, including website content, DevTools, incognito themes in Chrome, libadwaita applications, panel layout, wallpaper, fonts, or window-button order.

## Out of scope

- Discord, Spotify, and Steam integrations, which were removed from the roadmap.
- KDE Plasma Login, which is system-level and needs dedicated packaging and safety work.
- Panel layout, wallpaper, fonts, and window-button order.
