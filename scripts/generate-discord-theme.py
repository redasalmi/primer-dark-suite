#!/usr/bin/env python3
"""Generate the committed Vencord theme for Discord from the palette.

Discord builds its dark appearances from semantic CSS custom properties
(--background-base-lower, --text-default, --control-primary-background-default,
...) declared on the .theme-dark, .theme-darker, and .theme-midnight elements,
and from the --brand-* and --primary-* color ramps that older components still
read directly. This script maps those properties to palette colors and writes
integrations/vencord/primer-dark.theme.css. The theme only sets custom
properties, so it never depends on Discord's generated class names.
With --check it fails when the committed file differs from the output.
"""

import colorsys
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "integrations" / "vencord" / "primer-dark.theme.css"
TOKENS = json.loads((ROOT / "palette" / "primer-dark.json").read_text())["tokens"]


def p(token: str) -> str:
    group, name = token.split(".")
    return TOKENS[group][name].upper()


def rgb(color: str) -> tuple[int, int, int]:
    return tuple(int(color[i:i + 2], 16) for i in (1, 3, 5))


def a(color: str, alpha: float) -> str:
    """The color with an alpha channel, as #RRGGBBAA."""
    return f"{color[:7]}{round(alpha * 255):02X}"


def mix(color: str, other: str, amount: float) -> str:
    """The color moved toward other by amount, as an opaque #RRGGBB."""
    channels = (round(c + (o - c) * amount) for c, o in zip(rgb(color), rgb(other)))
    return "#" + "".join(f"{c:02X}" for c in channels)


def hsl(color: str) -> str:
    """The color as the space-separated HSL triplet Discord's *-hsl ramps use."""
    h, l, s = colorsys.rgb_to_hls(*(c / 255 for c in rgb(color)))
    return f"{round(h * 360, 1):g} {round(s * 100, 1):g}% {round(l * 100, 1):g}%"


INSET = p("surface.inset")
DEFAULT = p("surface.default")
MUTED = p("surface.muted")
RAISED = p("surface.raised")
CONTROL = p("surface.control")
BORDER = p("border.default")
BORDER_SUBTLE = p("border.subtle")
EMPHASIS = p("border.emphasis")
FG = p("foreground.default")
FG_SUBTLE = p("foreground.subtle")
FG_MUTED = p("foreground.muted")
FG_DISABLED = p("foreground.disabled")
ON_EMPHASIS = p("foreground.onEmphasis")
ACCENT = p("accent.foreground")
FOCUS = p("accent.emphasis")
SUCCESS = p("status.success")
ATTENTION = p("status.attention")
DANGER = p("status.danger")
DANGER_EMPHASIS = p("status.dangerEmphasis")

# Filled controls carry white text, so like Discord's own they darken on hover
# and press, and the green fill darkens success until white text on it reaches
# a 4.5:1 contrast ratio.
FOCUS_HOVER = mix(FOCUS, INSET, 0.1)
FOCUS_ACTIVE = mix(FOCUS, INSET, 0.2)
SUCCESS_EMPHASIS = mix(SUCCESS, INSET, 0.3)
SUCCESS_EMPHASIS_HOVER = mix(SUCCESS, INSET, 0.4)
SUCCESS_EMPHASIS_ACTIVE = mix(SUCCESS, INSET, 0.5)

# Discord layers translucent white over its surfaces for hover, pressed, and
# selected states. Primer uses its emphasis gray the same way.
MOD_MUTED = a(EMPHASIS, 0.1)
MOD_SUBTLE = a(EMPHASIS, 0.2)
MOD_NORMAL = a(EMPHASIS, 0.3)
MOD_STRONG = a(EMPHASIS, 0.4)

# Semantic properties of Discord's dark appearances, grouped by role. Discord
# properties that are not listed (Nitro, Quests, chips, charts, and other
# promotional gradients) keep Discord's colors.
SECTIONS = {
    "Surfaces: the app frame and server list sit below the chat and channel list, popouts above them": {
        "--background-base-lowest": INSET,
        "--background-base-lower": DEFAULT,
        "--background-base-low": MUTED,
        "--background-surface-high": MUTED,
        "--background-surface-higher": RAISED,
        "--background-surface-highest": CONTROL,
        "--app-frame-background": INSET,
        "--app-frame-border": BORDER,
        "--home-background": INSET,
        "--panel-bg": DEFAULT,
        "--channel-background-default": DEFAULT,
        "--chat-background": DEFAULT,
        "--chat-background-default": MUTED,
        "--chat-border": BORDER,
        "--channeltextarea-background": MUTED,
        "--card-background-default": MUTED,
        "--card-border-default": BORDER,
        "--card-secondary-bg": MOD_SUBTLE,
        "--modal-background": MUTED,
        "--modal-footer-background": MUTED,
        "--embed-background": MUTED,
        "--embed-background-alternate": MUTED,
        "--user-profile-overlay-background": RAISED,
        "--user-profile-toolbar-background": RAISED,
        "--user-profile-activity-toolbar-background": RAISED,
        "--user-profile-note-background-focus": DEFAULT,
        "--user-profile-border": BORDER,
        "--user-profile-toolbar-border": BORDER_SUBTLE,
        "--user-profile-background-hover": MOD_SUBTLE,
        "--user-profile-overlay-background-hover": MOD_SUBTLE,
        "--guild-profile-banner-background-default": INSET,
    },
    "State layers": {
        "--background-mod-muted": MOD_MUTED,
        "--background-mod-subtle": MOD_SUBTLE,
        "--background-mod-normal": MOD_NORMAL,
        "--background-mod-strong": MOD_STRONG,
        "--interactive-background-default": MOD_MUTED,
        "--interactive-background-hover": MOD_SUBTLE,
        "--interactive-background-active": MOD_NORMAL,
        "--interactive-background-selected": a(EMPHASIS, 0.24),
        "--message-background-hover": MOD_MUTED,
        "--message-highlight-background-default": p("overlay.accentMuted"),
        "--message-highlight-background-hover": a(ACCENT, 0.15),
        "--message-mentioned-background-default": a(ATTENTION, 0.15),
        "--message-mentioned-background-hover": a(ATTENTION, 0.1),
        "--keyword-highlight-background": a(ATTENTION, 0.3),
        "--mention-background": a(FOCUS, 0.3),
        "--mention-foreground": FG,
    },
    "Borders": {
        "--border-muted": BORDER_SUBTLE,
        "--border-subtle": BORDER,
        "--border-normal": BORDER,
        "--border-strong": EMPHASIS,
        "--border-focus": FOCUS,
        "--border-feedback-critical": DANGER,
        "--border-feedback-info": ACCENT,
        "--border-feedback-positive": SUCCESS,
        "--border-feedback-warning": ATTENTION,
        "--spine-default": BORDER,
        "--thread-channel-spine": BORDER,
    },
    "Text": {
        "--text-strong": FG,
        "--text-default": FG,
        "--text-subtle": FG_SUBTLE,
        "--text-muted": FG_MUTED,
        "--text-link": ACCENT,
        "--text-brand": ACCENT,
        "--text-invert": DEFAULT,
        "--text-feedback-critical": DANGER,
        "--text-feedback-info": ACCENT,
        "--text-feedback-positive": SUCCESS,
        "--text-feedback-warning": ATTENTION,
        "--text-status-online": SUCCESS,
        "--text-status-idle": ATTENTION,
        "--text-status-dnd": DANGER,
        "--text-status-offline": FG_MUTED,
        "--text-voice-connected": SUCCESS,
        "--text-voice-disconnected": DANGER,
        "--text-voice-speaking": SUCCESS,
        "--channels-default": FG_MUTED,
        "--channel-icon": FG_MUTED,
        "--channel-text-area-placeholder": FG_MUTED,
        "--chat-text-muted": FG_MUTED,
        "--textbox-markdown-syntax": FG_MUTED,
        "--interactive-text-default": FG_SUBTLE,
        "--interactive-text-hover": FG,
        "--interactive-text-active": FG,
        "--interactive-muted": FG_DISABLED,
    },
    "Icons": {
        "--icon-strong": FG,
        "--icon-default": FG,
        "--icon-subtle": FG_SUBTLE,
        "--icon-muted": FG_MUTED,
        "--icon-link": ACCENT,
        "--icon-brand": ACCENT,
        "--icon-invert": DEFAULT,
        "--icon-feedback-critical": DANGER,
        "--icon-feedback-info": ACCENT,
        "--icon-feedback-positive": SUCCESS,
        "--icon-feedback-warning": ATTENTION,
        "--icon-feedback-notification": DANGER_EMPHASIS,
        "--icon-status-online": SUCCESS,
        "--icon-status-idle": ATTENTION,
        "--icon-status-dnd": DANGER,
        "--icon-status-offline": FG_MUTED,
        "--icon-voice-connected": SUCCESS,
        "--icon-voice-disconnected": DANGER,
        "--icon-voice-muted": DANGER,
        "--icon-voice-speaking": SUCCESS,
        "--interactive-icon-default": FG_MUTED,
        "--interactive-icon-hover": FG,
        "--interactive-icon-active": FG,
    },
    "Status and feedback": {
        "--status-online": SUCCESS,
        "--status-positive": SUCCESS,
        "--status-speaking": SUCCESS,
        "--status-danger": DANGER,
        "--status-warning": ATTENTION,
        "--status-positive-background": SUCCESS_EMPHASIS,
        "--status-positive-text": ON_EMPHASIS,
        "--status-warning-background": ATTENTION,
        "--status-warning-text": INSET,
        "--background-brand": FOCUS,
        "--background-accent": FOCUS,
        "--background-feedback-critical": p("overlay.dangerMuted"),
        "--background-feedback-info": p("overlay.accentMuted"),
        "--background-feedback-positive": p("overlay.successMuted"),
        "--background-feedback-warning": a(ATTENTION, 0.15),
        "--background-feedback-notification": DANGER_EMPHASIS,
        "--inlinenotice-border-critical": a(DANGER, 0.4),
        "--inlinenotice-border-info": a(ACCENT, 0.4),
        "--inlinenotice-border-positive": a(SUCCESS, 0.4),
        "--inlinenotice-border-warning": a(ATTENTION, 0.4),
        "--notice-background-critical": p("surface.dangerInset"),
        "--notice-text-critical": p("status.dangerBright"),
        "--notice-background-info": p("surface.accentInset"),
        "--notice-text-info": FG,
        "--notice-background-positive": p("surface.successInset"),
        "--notice-text-positive": p("status.successBright"),
        "--notice-background-warning": p("surface.attentionInset"),
        "--notice-text-warning": p("status.attentionBright"),
        "--toast-critical-background": p("overlay.dangerMuted"),
        "--toast-critical-border": DANGER,
        "--toast-success-background": p("overlay.successMuted"),
        "--toast-success-border": SUCCESS,
        "--badge-notification-background": DANGER_EMPHASIS,
        "--badge-background-brand": FOCUS,
        "--badge-text-brand": ON_EMPHASIS,
        "--badge-background-default": MOD_NORMAL,
        "--badge-text-default": FG,
    },
    "Buttons": {
        "--control-primary-background-default": FOCUS,
        "--control-primary-background-hover": FOCUS_HOVER,
        "--control-primary-background-active": FOCUS_ACTIVE,
        "--control-primary-text-default": ON_EMPHASIS,
        "--control-primary-text-hover": ON_EMPHASIS,
        "--control-primary-text-active": ON_EMPHASIS,
        "--control-primary-icon-default": ON_EMPHASIS,
        "--control-primary-icon-hover": ON_EMPHASIS,
        "--control-primary-icon-active": ON_EMPHASIS,
        "--control-secondary-background-default": MOD_SUBTLE,
        "--control-secondary-background-hover": MOD_NORMAL,
        "--control-secondary-background-active": MOD_STRONG,
        "--control-secondary-border-default": BORDER,
        "--control-secondary-border-hover": EMPHASIS,
        "--control-secondary-border-active": EMPHASIS,
        "--control-secondary-text-default": FG,
        "--control-secondary-text-hover": FG,
        "--control-secondary-text-active": FG,
        "--control-secondary-icon-default": FG,
        "--control-secondary-icon-hover": FG,
        "--control-secondary-icon-active": FG,
        "--control-critical-primary-background-default": DANGER_EMPHASIS,
        "--control-critical-primary-background-hover": p("status.dangerEmphasisHover"),
        "--control-critical-primary-background-active": p("status.dangerEmphasisActive"),
        "--control-critical-primary-text-default": ON_EMPHASIS,
        "--control-critical-primary-text-hover": ON_EMPHASIS,
        "--control-critical-primary-text-active": ON_EMPHASIS,
        "--control-critical-primary-icon-default": ON_EMPHASIS,
        "--control-critical-primary-icon-hover": ON_EMPHASIS,
        "--control-critical-primary-icon-active": ON_EMPHASIS,
        "--control-critical-secondary-background-default": MOD_SUBTLE,
        "--control-critical-secondary-background-hover": MOD_NORMAL,
        "--control-critical-secondary-background-active": MOD_STRONG,
        "--control-critical-secondary-border-default": BORDER,
        "--control-critical-secondary-border-hover": EMPHASIS,
        "--control-critical-secondary-border-active": EMPHASIS,
        "--control-critical-secondary-text-default": DANGER,
        "--control-critical-secondary-text-hover": DANGER,
        "--control-critical-secondary-text-active": DANGER,
        "--control-critical-secondary-icon-default": DANGER,
        "--control-critical-secondary-icon-hover": DANGER,
        "--control-critical-secondary-icon-active": DANGER,
        "--control-connected-background-default": SUCCESS_EMPHASIS,
        "--control-connected-background-hover": SUCCESS_EMPHASIS_HOVER,
        "--control-connected-background-active": SUCCESS_EMPHASIS_ACTIVE,
        "--control-connected-text-default": ON_EMPHASIS,
        "--control-connected-text-hover": ON_EMPHASIS,
        "--control-connected-text-active": ON_EMPHASIS,
        "--control-connected-icon-default": ON_EMPHASIS,
        "--control-connected-icon-hover": ON_EMPHASIS,
        "--control-connected-icon-active": ON_EMPHASIS,
        "--control-icon-only-icon-default": FG_MUTED,
        "--control-icon-only-icon-hover": FG,
        "--control-icon-only-icon-active": FG,
        "--control-icon-only-background-hover": MOD_SUBTLE,
        "--control-icon-only-background-active": MOD_NORMAL,
        "--control-brand-foreground": ACCENT,
        "--control-brand-foreground-new": ACCENT,
    },
    "Form controls": {
        "--input-background-default": DEFAULT,
        "--input-background-error-default": p("overlay.dangerMuted"),
        "--input-border-default": BORDER,
        "--input-border-hover": EMPHASIS,
        "--input-border-active": FOCUS,
        "--input-border-error-default": DANGER,
        "--input-border-readonly": BORDER_SUBTLE,
        "--input-text-default": FG,
        "--input-text-error-default": FG,
        "--input-placeholder-text-default": FG_MUTED,
        "--input-icon-default": FG_MUTED,
        "--checkbox-background-default": DEFAULT,
        "--checkbox-background-hover": DEFAULT,
        "--checkbox-background-active": FOCUS_ACTIVE,
        "--checkbox-background-selected-default": FOCUS,
        "--checkbox-background-selected-hover": FOCUS_HOVER,
        "--checkbox-border-default": EMPHASIS,
        "--checkbox-border-hover": FG_MUTED,
        "--checkbox-border-active": FOCUS,
        "--checkbox-border-selected-default": FOCUS,
        "--checkbox-border-selected-hover": FOCUS_HOVER,
        "--checkbox-icon-active": ON_EMPHASIS,
        "--radio-background-default": DEFAULT,
        "--radio-background-hover": DEFAULT,
        "--radio-background-active": FOCUS_ACTIVE,
        "--radio-background-selected-default": FOCUS,
        "--radio-background-selected-hover": FOCUS_HOVER,
        "--radio-border-default": EMPHASIS,
        "--radio-border-hover": FG_MUTED,
        "--radio-border-active": FOCUS,
        "--radio-border-selected-default": FOCUS,
        "--radio-border-selected-hover": FOCUS_HOVER,
        "--radio-foreground-default": DEFAULT,
        "--radio-foreground-hover": DEFAULT,
        "--radio-foreground-active": FOCUS,
        "--radio-thumb-background-active": ON_EMPHASIS,
        "--switch-background-default": CONTROL,
        "--switch-background-hover": BORDER_SUBTLE,
        "--switch-background-active": FOCUS_ACTIVE,
        "--switch-background-selected-default": FOCUS,
        "--switch-background-selected-hover": FOCUS_HOVER,
        "--switch-border-default": BORDER,
        "--switch-border-hover": EMPHASIS,
        "--switch-border-selected-default": FOCUS,
        "--switch-border-selected-hover": FOCUS_HOVER,
        "--switch-thumb-background-default": FG,
        "--switch-thumb-background-selected-default": FG,
        "--switch-thumb-icon-default": CONTROL,
        "--switch-thumb-icon-active": FOCUS,
        "--togglebutton-background-selected": a(FOCUS, 0.2),
        "--togglebutton-background-selected-hover": a(FOCUS, 0.3),
        "--togglebutton-background-selected-active": a(FOCUS, 0.4),
        "--togglebutton-border-selected": FOCUS,
        "--togglebutton-border-active": FOCUS,
        "--togglebutton-critical-background-selected": a(DANGER, 0.15),
        "--togglebutton-critical-background-selected-hover": a(DANGER, 0.25),
        "--togglebutton-critical-border-active": a(DANGER, 0.4),
        "--togglebutton-critical-icon-active": DANGER,
        "--togglebutton-critical-icon-selected": DANGER,
        "--togglebutton-critical-icon-selected-hover": DANGER,
        "--tabs-indicator-default": ACCENT,
        "--progressbar-indicator-background": FOCUS,
        "--progressbar-track-background": MOD_NORMAL,
        "--slider-track-background": BORDER,
        "--datepicker-range-background-default": a(FOCUS, 0.3),
        "--datepicker-range-background-hover": a(FOCUS, 0.4),
        "--scrollbar-thin-thumb": BORDER,
        "--scrollbar-auto-thumb": BORDER,
        "--scrollbar-auto-scrollbar-color-thumb": BORDER,
        "--scrollbar-auto-scrollbar-color-track": "transparent",
    },
    "Messages": {
        "--reaction-background-default": MOD_MUTED,
        "--reaction-background-hover": MOD_SUBTLE,
        "--reaction-background-active": MOD_NORMAL,
        "--reaction-background-reacted-default": p("overlay.accentMuted"),
        "--reaction-background-reacted-hover": a(FOCUS, 0.2),
        "--reaction-border-default": BORDER,
        "--reaction-border-hover": EMPHASIS,
        "--reaction-border-active": EMPHASIS,
        "--reaction-border-reacted-default": FOCUS,
        "--reaction-text-default": FG_MUTED,
        "--reaction-text-hover": FG,
        "--reaction-text-active": FG,
        "--reaction-text-reacted-default": ACCENT,
        "--spoiler-hidden-background": BORDER,
        "--spoiler-hidden-background-hover": EMPHASIS,
        "--spoiler-revealed-background": MOD_SUBTLE,
        "--polls-voted-fill": a(FOCUS, 0.2),
        "--polls-victor-fill": a(SUCCESS, 0.2),
    },
    "Code blocks, with the shared syntax mapping": {
        "--background-code": MOD_SUBTLE,
        "--background-code-addition": p("syntax.markupInsertedBackground"),
        "--background-code-deletion": p("syntax.markupDeletedBackground"),
        "--text-code": FG,
        "--text-code-addition": p("syntax.markupInsertedText"),
        "--text-code-deletion": p("syntax.markupDeletedText"),
        "--text-code-attribute": p("syntax.constant"),
        "--text-code-builtin": p("syntax.variable"),
        "--text-code-bullet": p("status.attentionBright"),
        "--text-code-comment": p("syntax.comment"),
        "--text-code-decorator": p("syntax.constant"),
        "--text-code-error": DANGER,
        "--text-code-escape": p("syntax.constant"),
        "--text-code-keyword": p("syntax.keyword"),
        "--text-code-link": p("syntax.string"),
        "--text-code-namespace": p("syntax.entity"),
        "--text-code-number": p("syntax.constant"),
        "--text-code-operator": p("syntax.constant"),
        "--text-code-property": p("syntax.constant"),
        "--text-code-regexp": p("syntax.string"),
        "--text-code-section": p("syntax.constant"),
        "--text-code-string": p("syntax.string"),
        "--text-code-tag": p("syntax.entityTag"),
        "--text-code-title": p("syntax.entity"),
        "--text-code-type": p("syntax.keyword"),
        "--text-code-variable": p("syntax.constant"),
    },
    "ANSI code blocks": {
        f"--ansi-{'bright-' if name.startswith('bright') else ''}{name.removeprefix('bright').lower()}": color.upper()
        for name, color in TOKENS["terminal"].items()
    },
}

# Discord's color ramps, from light to dark. Older components read these
# directly instead of a semantic property. The brand ramp follows Primer's
# accent blues; the primary ramp follows Primer's foreground, border, and
# surface grays in the order Discord's dark appearance uses its steps.
RAMPS = {
    "brand": [
        ((100, 130, 160, 200, 230), p("syntax.string")),
        ((260, 300, 330), p("syntax.constant")),
        ((345, 360), p("terminal.blue")),
        ((400, 430, 460), ACCENT),
        ((500, 530), FOCUS),
        ((560, 600), FOCUS_ACTIVE),
        ((630, 660, 700), p("diff.hunkNumber")),
        ((730, 760, 800, 830, 860, 900), p("surface.accentInset")),
    ],
    "primary": [
        ((100, 130, 160, 200), FG),
        ((230, 260, 300), FG_SUBTLE),
        ((330, 345, 360, 400), FG_MUTED),
        ((430, 460), EMPHASIS),
        ((500,), BORDER),
        ((530,), CONTROL),
        ((560,), MUTED),
        ((600,), DEFAULT),
        ((630, 645, 660, 700, 730, 760, 800, 830, 860, 900), INSET),
    ],
}

# Discord's own dark appearances. The selectors match Discord's declarations,
# so the theme, which Vencord loads after Discord's style sheets, replaces
# them; Discord's high-contrast mode and Nitro client themes use more specific
# selectors and keep precedence.
SELECTORS = (".theme-dark", ".theme-darker", ".theme-midnight")


def render() -> str:
    lines = [
        "/**",
        " * @name Primer Dark",
        " * @author Reda Salmi",
        " * @description GitHub Primer Dark colors for Discord's dark appearances.",
        " * @license MIT",
        " * @source https://github.com/redasalmi/primer-dark-suite",
        " */",
        "",
        "/* Generated by scripts/generate-discord-theme.py from palette/primer-dark.json; SPDX-License-Identifier: MIT */",
        "",
        ",\n".join(SELECTORS) + " {",
    ]
    for title, properties in SECTIONS.items():
        lines.append(f"    /* {title} */")
        lines += [f"    {name}: {value};" for name, value in properties.items()]
        lines.append("")
    for ramp, steps in RAMPS.items():
        lines.append(f"    /* --{ramp}-* ramp */")
        for numbers, color in steps:
            for number in numbers:
                lines.append(f"    --{ramp}-{number}: {color};")
                lines.append(f"    --{ramp}-{number}-hsl: {hsl(color)};")
        lines.append("")
    lines[-1] = "}"
    return "\n".join(lines) + "\n"


def main() -> int:
    content = render()
    if sys.argv[1:] == ["--check"]:
        if not OUT.is_file() or OUT.read_text() != content:
            print(f"{OUT.relative_to(ROOT)} is out of date; run scripts/generate-discord-theme.py", file=sys.stderr)
            return 1
        return 0
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(content)
    count = sum(map(len, SECTIONS.values()))
    print(f"Wrote {OUT.relative_to(ROOT)} with {count} properties and {len(RAMPS)} ramps")
    return 0


if __name__ == "__main__":
    sys.exit(main())
