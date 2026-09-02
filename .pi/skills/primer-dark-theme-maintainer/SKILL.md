---
name: primer-dark-theme-maintainer
description: Creates, updates, or removes application, editor, terminal, CLI/TUI, desktop, browser, and integration theme ports in Primer Dark Suite. Use when a Primer Dark port must be researched against official documentation, implemented from the canonical palette, connected to install/uninstall and release packaging where safe, documented in structure.md and plan.md, and validated end to end.
compatibility: Intended for the primer-dark-suite repository and a Unix shell with the target application's official validation tools when available.
---

# Primer Dark theme maintainer

Maintain one theme port through its complete lifecycle: official research, semantic color mapping, native asset creation, safe installation/removal, packaging, documentation, and verification.

Run repository commands from the Git root, not from this skill directory:

```sh
REPO=$(git rev-parse --show-toplevel)
cd "$REPO"
```

## Non-negotiable rules

- Treat `palette/primer-dark.json` as the canonical color source. Do not silently invent or change suite colors.
- Prefer the target's current official native theme format, schema, discovery path, and validation command.
- Preserve unrelated user settings and unrelated working-tree changes.
- Install only user-local, theme-owned files by default. A shared application configuration may be changed only as an explicit documented exception with bounded managed sections, native validation, atomic replacement, and exact restore state; otherwise provide a manual snippet.
- Make optional ports opt-in. Unsupported patchers and third-party modifications stay under `integrations/` and are never installed by default.
- Commit ready-to-use assets; installation must work offline and must not require generation.
- Keep changes minimal and consistent with the repository's existing shell and documentation style.
- Do not add, remove, or modify tests unless the user explicitly asks. Do run existing applicable checks.
- Do not claim a port is implemented until its native format, installation/discovery path, release artifact, and representative states have been verified as far as the environment permits.

## 1. Establish the lifecycle operation

Classify the request as one of:

- **Create:** add a new target port.
- **Update:** change an existing port for colors, coverage, schema, app version, install path, packaging, or behavior.
- **Delete/retire:** remove a port from the repository and stop distributing/installing it while preserving a safe migration path for users of released versions.

Determine these facts before editing:

1. Official target name and current supported version or version range.
2. Repository category and path (`kde/`, `terminals/`, `editors/`, `cli/`, `browsers/`, `creative/`, `gtk/`, or `integrations/`).
3. Whether the app supports a standalone theme file/package, only a shared config snippet, or no supported theming API.
4. Requested scope: UI chrome, syntax, ANSI colors, statuses, diagrams, or all supported theme fields.
5. Whether the port has shipped before. For deletion or path changes, inspect Git history and release packaging.

Ask a question only if missing information materially changes safety or architecture. Otherwise follow official behavior and repository conventions, then state the assumption.

## 2. Inspect the repository and preserve current work

Always inspect:

- `git status --short` and the relevant diff;
- `palette/primer-dark.json`;
- `README.md`, `structure.md`, and `plan.md`;
- `install.sh`, `uninstall.sh`, `scripts/package.sh`, `scripts/lib/common.sh`, and the relevant `scripts/components/<target>.sh` module;
- one or more neighboring implemented ports in the same category;
- all references to the target's names, IDs, paths, flags, and artifact names.

For updates, read every existing target asset before editing. For deletions, search the whole repository and use `git log -- <path>` to determine whether legacy uninstall support is needed. Never overwrite or revert unrelated changes, including generated `dist/` output.

## 3. Research official behavior before designing

Use current primary sources in this order:

1. Official theming/configuration documentation.
2. Official schema or theme API reference.
3. Upstream source code and officially bundled themes/examples.
4. Official release notes for breaking changes.

Record the URLs, target version, and access date in the final report. Add durable official references to `plan.md` when they explain an ongoing port architecture. Community themes may help compare coverage, but they are not authoritative for keys, paths, or supported behavior.

Confirm all applicable details:

- exact file format, encoding, required metadata, schema version, and accepted key set;
- whether unknown or missing keys fail, default, or inherit;
- color notation, alpha ordering, and transparency support;
- package/folder naming and stable theme identifier;
- Linux/XDG and app-specific discovery/install paths;
- activation mechanism and how to detect whether the theme is active;
- official parser, config checker, import command, or discovery command;
- supported release/distribution format;
- app-version compatibility and deprecated fields;
- whether live reload or restart is required.

If official sources conflict, prefer the source/schema matching the supported app version and report the conflict. If no supported standalone theme API exists, create a documented, ready-to-merge snippet only; do not make the root installer edit shared configuration.

## 4. Select the integration model

Use this decision table:

| Target capability | Repository treatment | Installer/uninstaller |
| --- | --- | --- |
| Standalone native theme file | Add under the matching category | Optional install flag and owned-file removal when useful |
| Native theme package/directory | Commit complete package directory | Optional recursive install and whole owned-directory removal |
| Theme is part of shared config without a safe managed-section lifecycle | Commit a clearly documented snippet | No automatic install or removal of shared config |
| Theme is part of shared config with bounded content-preserving editing, native validation, atomic replacement, and exact restore state | Commit the snippet and document the exception | Explicit opt-in managed install and exact restoration may be supported |
| System-wide/root-only theme | Keep separate and document privileges/safety | Never include in default user-local install |
| Unsupported patcher/CSS injection | Put under `integrations/` | Explicit isolated opt-in only; never install the patcher |

Do not add an installer flag solely for symmetry. Add it only when installation can be idempotent, user-local, and limited to paths wholly owned by Primer Dark.

## 5. Map Primer roles to target semantics

Read tokens directly from `palette/primer-dark.json`. Build a scratch mapping from every target field to a semantic role before writing the asset.

Preferred mappings:

| Target semantic | Primer token |
| --- | --- |
| Deep chrome/inset surface | `surface.inset` |
| Main content/editor background | `surface.default` |
| Sidebar/muted/active-line surface | `surface.muted` |
| Raised control/selection row | `surface.raised` or `surface.control` |
| Main and subtle borders | `border.default` and `border.subtle` |
| Keyboard focus/selected emphasis | `border.focus` / `accent.emphasis` |
| Primary, secondary, disabled text | `foreground.default`, `foreground.muted`, `foreground.disabled` |
| Links/accent text | `accent.foreground` |
| Success, warning, severe, error, completed | matching `status.*` tokens |
| Syntax categories | matching `syntax.*` tokens |
| ANSI colors | matching `terminal.*` tokens |

Preserve application semantics instead of mechanically assigning colors by field name. Cover hover, active, selected, focused, disabled, inactive, error, warning, success, diffs, search, and syntax/ANSI states when the target exposes them.

Use alpha variants or blends only when the target requires them. Derive them from canonical colors, document non-obvious derivations in the asset or `plan.md`, and keep text and focus contrast usable. If a genuinely missing shared role is needed, explain why before changing the canonical palette and update every affected port; do not expand the palette casually.

## 6. Create a port

### 6.1 Add the native asset

1. Create the category and target directory shown by `structure.md`; do not create empty future directories.
2. Follow the target's official file/package name. Use stable lowercase repository filenames unless the native discovery name requires another form.
3. Include required schema, metadata, display name `Primer Dark`, author/attribution, and SPDX/license comments where the format permits.
4. Fill the complete supported theme surface for the requested scope. Avoid placeholders and undocumented keys.
5. Keep generated assets committed. If generation is necessary, update the existing generator or add a minimal reproducible helper only when required; the installer must consume generated output, not invoke the generator.
6. Run the target's parser/schema check before wiring shell scripts.

### 6.2 Update `install.sh` when safe

Follow the component-orchestrator pattern and update all of these together:

- add the component ID to `ALL_COMPONENTS` in `scripts/lib/common.sh` so `--<target>` is recognized;
- define shared destination variables using `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, or the documented app-specific environment variable;
- add `preflight_<target>`, `install_<target>`, `guard_<target>`, `uninstall_<target>`, and `package_<target>` hooks under `scripts/components/`;
- keep the install hook idempotent using `install -Dm644` for files or remove/recreate/copy for a wholly owned package directory;
- validate every selected component in its preflight hook without changing installed files;
- print a concise destination and activation message.

The installer must update an existing owned theme by replacing only that theme's file/directory. It must not activate the theme, rewrite settings, require the target app to be running, or remove unrelated files. Keep third-party integrations separate and explicit.

For a shared-config snippet, document manual merge/validation/reload instructions instead of changing the installer unless the port is an approved managed-section exception. An exception must be explicit opt-in, preserve unrelated content and settings, validate the complete candidate configuration before replacement, verify the source configuration and restore state have not changed since validation, use atomic replacement, retain exact restore state, and implement safe uninstall restoration in the same component module.

### 6.3 Update `uninstall.sh` when needed

If the installer owns a destination:

1. Define the exact owned path using the same XDG/app variables as installation.
2. Before any removal, use an official or robust read-only mechanism to detect whether the theme is active.
3. If active, stop before removing any files and tell the user how to select another theme.
4. Remove only the exact owned file, or recursively remove a directory only when that entire directory is owned by this suite.
5. Never edit shared settings to deactivate the theme.
6. Keep removal safe when the target application or its checker is absent.

If active-theme detection is unavailable, do not invent a brittle check. Document that users must switch first, limit deletion to the owned asset, and explain the limitation in the final report.

### 6.4 Update release packaging

In `scripts/package.sh`:

- add the official native parser/schema validation when it is non-interactive and available as an established dependency;
- validate and emit through the component hook into the staging directory supplied by `scripts/package.sh`; never clear or write the published `dist/` directly;
- copy a single-file port or create the appropriate archive for a package directory;
- use the repository artifact naming form `Primer-Dark-<Target>.<ext>`;
- include the artifact exactly once in `SHA256SUMS`;
- retain deterministic ordering consistent with neighboring artifacts;
- do not package caches, local settings, screenshots not intended for release, or build-only files.

Do not introduce a new packaging dependency unless the native format requires it and the dependency is documented in `README.md`.

### 6.5 Update documentation

Update all facts affected by the port:

- **`README.md`:** suite summary, included features, requirements, install/manual-merge command, activation/reload, destination, uninstall prerequisite, and artifact/use notes as applicable.
- **`structure.md`:** add the real path in the correct category and mark it implemented only after verification.
- **`plan.md`:** move the target from planned to implemented, describe supported coverage, note manual-only or unsupported limitations, update installation architecture, and add durable official references.
- **`NOTICE`:** update only if the new asset introduces attribution or license obligations beyond existing Primer attribution.

Keep roadmap ordering coherent and remove stale future wording. Documentation must not claim automatic installation for a manual snippet or claim validation that was not run.

## 7. Update an existing port

Repeat official research; do not assume the old schema or install path is still current.

1. Identify the reason and supported target version.
2. Compare the current asset against the official current schema/example and list missing, removed, renamed, and deprecated fields.
3. Update semantic mappings from the canonical palette, preserving intentional documented deviations.
4. Validate all supported states, not just the changed color.
5. Change installer/uninstaller paths only if official discovery changed.
6. On a filename, identifier, or destination migration, install the new owned path and make uninstall clean both known old and new owned paths. Remove an old installed path during update only when ownership is certain and the migration is documented.
7. Refresh package validation/artifacts/checksums and only the documentation facts that changed.
8. Report compatibility or migration implications explicitly.

A palette-wide update is larger than a single-port update: search every implemented asset for affected values, update all semantic consumers, and run every applicable port validator.

## 8. Delete or retire a port

Deletion means removing repository support, not deleting files from the user's live home directory.

1. Confirm the requested target and whether it appeared in a released package.
2. Remove source assets and now-empty target directories.
3. Remove the component ID from `ALL_COMPONENTS`, its lifecycle module, any help text, and activation messages.
4. Remove its packaging hook and generated release artifacts.
5. Remove or revise README requirements, install paths, usage, and feature claims.
6. Update `structure.md` and `plan.md`: remove the target entirely, return it to roadmap status, or mark it retired according to the request. Explain why when the theming API was removed or became unsafe.
7. Search for stale names, flags, IDs, paths, and artifact references.

For a port that shipped previously, normally retain a clearly labeled legacy active-theme guard and exact owned-path cleanup in `uninstall.sh` for at least the next release. This lets existing users remove the old installation even though new installs no longer provide it. Remove that legacy cleanup only when the user explicitly drops migration support or Git history proves the port never shipped. Never delete a user's shared-config snippet automatically.

## 9. Verify end to end

Run the narrowest applicable checks first. Use official commands discovered during research; do not invent substitutes.

### Static and native checks

- Parse JSON with `jq -e .`, XML/SVG with `xmllint --noout`, and other formats with the target's official parser/checker.
- Run `sh -n install.sh uninstall.sh scripts/package.sh scripts/lib/common.sh scripts/components/*.sh` after shell edits.
- Validate required metadata, schema version, key completeness, stable identifiers, and exact discovery names.
- Check that theme values come from canonical palette values or documented alpha/blend derivatives.
- Use the target application's theme discovery/import/config check when available.

### Isolated install/update/uninstall check

Never test against the developer's live configuration. Use a temporary `HOME`, `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, and app-specific home variable. Do not pass `--apply`. Run the root installer only if all invoked components are proven to honor the isolated paths; otherwise report why the integration could not safely be exercised.

Verify:

1. first install creates only expected paths;
2. second install updates idempotently;
3. unrelated sentinel files survive;
4. the target can discover or parse the installed theme;
5. uninstall refuses removal when a safely simulated active state is supported;
6. uninstall removes owned paths and preserves sentinels.

### Package check

Run `./scripts/package.sh` when its declared dependencies are available and doing so will not overwrite unrelated work. Then:

- list archive contents;
- confirm the new/updated artifact name and native layout;
- run `(cd dist && sha256sum -c SHA256SUMS)`;
- confirm removed ports no longer appear;
- inspect `git status` so generated output or unrelated changes are not accidentally included.

### Visual/behavioral check

When the target is available, inspect representative normal, hover, selected, focused, disabled, inactive, warning, error, success, diff, syntax, and ANSI states that apply. Record any check requiring unavailable GUI, service, app version, or system-level access as not run; never state that it passed.

For deletion, finish with a whole-repository reference search. For every operation, review the final diff for unrelated changes and stale documentation.

## 10. Completion report

Lead with the result and include:

- lifecycle operation and target version;
- changed paths and integration model;
- official sources consulted;
- semantic coverage and intentional palette deviations;
- install, activation, update, uninstall, and artifact behavior;
- exact verification commands and outcomes;
- checks not run, remaining risks, and migration notes.

A port is complete only when the source asset, safe lifecycle integration, `README.md`, `structure.md`, `plan.md`, package output, and applicable native validation agree with one another.
