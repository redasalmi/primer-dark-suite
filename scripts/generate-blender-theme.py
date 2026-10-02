"""Generate the committed Blender interface theme from the canonical palette.

Run inside Blender so the theme is written with Blender's own preset writer
and covers the complete key set of the running version:

    blender --background --factory-startup --python scripts/generate-blender-theme.py

The script resets the in-memory theme to Blender's defaults, assigns every
color property from palette/primer-dark.json, and fails when a color property
is left unmapped or a mapped key no longer exists. Preferences are not saved.
"""

import json
import sys
from pathlib import Path

import bpy
import _rna_xml as rna_xml

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "creative" / "blender" / "Primer_Dark.xml"
TOKENS = json.loads((ROOT / "palette" / "primer-dark.json").read_text())["tokens"]


def p(token: str) -> str:
    group, name = token.split(".")
    return TOKENS[group][name].lower()


def a(color: str, alpha: str) -> str:
    """Append a two-digit hexadecimal alpha to an opaque color."""
    return color[:7] + alpha


def mix(color: str, amount: float, base: str = "#0d1117") -> str:
    """Flatten COLOR at AMOUNT opacity over BASE, as the palette's muted surfaces are."""
    channels = []
    for i in (1, 3, 5):
        top, bottom = int(color[i:i + 2], 16), int(base[i:i + 2], 16)
        channels.append(round(top * amount + bottom * (1 - amount)))
    return "#" + "".join(f"{c:02x}" for c in channels)


INSET = p("surface.inset")
DEFAULT = p("surface.default")
MUTED = p("surface.muted")
RAISED = p("surface.raised")
CONTROL = p("surface.control")
BORDER = p("border.default")
BORDER_SUBTLE = p("border.subtle")
EMPHASIS = p("border.emphasis")
FG = p("foreground.default")
FG_MUTED = p("foreground.muted")
FG_SUBTLE = p("foreground.subtle")
ON_EMPHASIS = p("foreground.onEmphasis")
ACCENT = p("accent.foreground")
FOCUS = p("accent.emphasis")
PINK = p("accent.pink")
SUCCESS = p("status.success")
SUCCESS_BRIGHT = p("status.successBright")
ATTENTION = p("status.attention")
ATTENTION_BRIGHT = p("status.attentionBright")
SEVERE = p("status.severe")
DANGER = p("status.danger")
DANGER_EMPHASIS = p("status.dangerEmphasis")
DANGER_BRIGHT = p("status.dangerBright")
DONE = p("status.done")
RED = p("terminal.red")
BLUE = p("terminal.blue")
MAGENTA = p("terminal.magenta")
CYAN = p("terminal.cyan")
BRIGHT_RED = p("terminal.brightRed")
BRIGHT_GREEN = p("terminal.brightGreen")
BRIGHT_YELLOW = p("terminal.brightYellow")
BRIGHT_BLUE = p("terminal.brightBlue")
BRIGHT_CYAN = p("terminal.brightCyan")
ORANGE = p("syntax.variable")
STRING = p("syntax.string")

# Blender marks selected items orange and the active item a lighter orange.
# The port keeps that convention with Primer's severe and orange roles.
SELECTED = SEVERE
ACTIVE = ORANGE
# Grid lines sit one step above the editor background.
GRID = RAISED
# Shared selection fill for text, matching the KWrite/Kate selection.
TEXT_SELECTION = mix(FOCUS, 0.4)


def widget(inner, inner_sel, item, *, outline=BORDER, outline_sel=BORDER,
           text=FG, text_sel=ON_EMPHASIS):
    return {
        "outline": outline,
        "outline_sel": outline_sel,
        "inner": inner,
        "inner_sel": inner_sel,
        "item": item,
        "text": text,
        "text_sel": text_sel,
    }


def space(back=None, *, text=FG, header=a(INSET, "b3")):
    colors = {
        "title": FG,
        "text": text,
        "text_hi": ON_EMPHASIS,
        "header": header,
        "header_text": FG,
        "header_text_hi": ON_EMPHASIS,
    }
    if back is not None:
        colors["back"] = back
    return colors


def editor_space(back=DEFAULT, **kwargs):
    return {"space": space(back, **kwargs)}


def bone_set(hue, normal=0.7, select=1.0, active=None):
    return {
        "normal": mix(hue, normal),
        "select": mix(hue, select),
        "active": active or mix(hue, 0.65, ON_EMPHASIS),
    }


THEME = {
    "user_interface": {
        "widget_emboss": "#00000026",
        "link": ACCENT,
        "editor_border": INSET,
        "editor_outline": BORDER_SUBTLE,
        "editor_outline_active": BORDER,
        "widget_text_cursor": ACCENT,
        "panel_header": MUTED,
        "panel_title": FG,
        "panel_text": FG,
        "panel_back": MUTED,
        "panel_sub_back": "#0000001f",
        "panel_outline": BORDER,
        "panel_active": FOCUS,
        "transparent_checker_primary": RAISED,
        "transparent_checker_secondary": MUTED,
        "axis_x": DANGER,
        "axis_y": SUCCESS,
        "axis_z": ACCENT,
        "axis_w": ATTENTION,
        "gizmo_hi": ON_EMPHASIS,
        "gizmo_primary": ATTENTION_BRIGHT,
        "gizmo_secondary": BRIGHT_CYAN,
        "gizmo_view_align": ON_EMPHASIS,
        "gizmo_a": SUCCESS,
        "gizmo_b": DANGER_EMPHASIS,
        "icon_scene": FG_SUBTLE,
        "icon_collection": FG,
        "icon_object": ORANGE,
        "icon_object_data": SUCCESS,
        "icon_modifier": BLUE,
        "icon_shading": RED,
        "icon_folder": ATTENTION,
        "icon_autokey": DANGER_EMPHASIS,
        "wcol_regular": widget(CONTROL, FOCUS, a(INSET, "80")),
        "wcol_tool": widget(CONTROL, FOCUS, FG),
        "wcol_toolbar_item": widget(MUTED, FOCUS, a(FG, "b3")),
        "wcol_radio": widget(CONTROL, FOCUS, DEFAULT),
        "wcol_text": widget(DEFAULT, INSET, a(FOCUS, "80")),
        "wcol_option": widget(CONTROL, FOCUS, ON_EMPHASIS),
        "wcol_toggle": widget(CONTROL, FOCUS, DEFAULT),
        "wcol_num": widget(CONTROL, DEFAULT, FOCUS),
        "wcol_numslider": widget(CONTROL, DEFAULT, FOCUS),
        "wcol_box": widget(a(DEFAULT, "80"), CONTROL, INSET),
        "wcol_curve": widget(RAISED, INSET, a(INSET, "59"),
                             outline=EMPHASIS, outline_sel=FG_MUTED,
                             text=INSET, text_sel=FG_SUBTLE),
        "wcol_menu": widget(RAISED, a(FOCUS, "b3"), FG),
        "wcol_pulldown": widget(a(RAISED, "00"), RAISED, a(FG, "8f"),
                                outline=a(BORDER, "00"), outline_sel=a(BORDER, "00")),
        "wcol_menu_back": widget(MUTED, FOCUS, FG, text=FG_MUTED),
        "wcol_pie_menu": widget(MUTED, FOCUS, EMPHASIS),
        "wcol_tooltip": widget(RAISED, FOCUS, FG),
        "wcol_menu_item": widget(a(MUTED, "00"), FOCUS, a(FG, "8f"),
                                 outline=a(BORDER, "00"), outline_sel=a(BORDER, "00")),
        "wcol_scroll": widget(a(DEFAULT, "00"), FG, BORDER),
        "wcol_progress": widget(DEFAULT, FOCUS, FOCUS),
        "wcol_list_item": widget(a(DEFAULT, "00"), FOCUS, a(FG, "33"),
                                 outline=a(BORDER, "00")),
        "wcol_state": {
            # Report banners draw white text, so warning and success use
            # darkened blends of the status colors.
            "error": DANGER_EMPHASIS,
            "warning": mix(ATTENTION, 0.6),
            "info": FOCUS,
            "success": mix(SUCCESS, 0.6),
            "inner_anim": SUCCESS,
            "inner_anim_sel": BRIGHT_GREEN,
            "inner_key": ATTENTION,
            "inner_key_sel": BRIGHT_YELLOW,
            "inner_driven": DONE,
            "inner_driven_sel": MAGENTA,
            "inner_overridden": CYAN,
            "inner_overridden_sel": BRIGHT_CYAN,
            "inner_changed": SEVERE,
            "inner_changed_sel": ORANGE,
        },
        "wcol_tab": widget(INSET, DEFAULT, INSET, outline=INSET, outline_sel=INSET,
                           text=FG_MUTED, text_sel=FG),
    },
    "regions": {
        "asset_shelf": {"back": a(DEFAULT, "e6"), "header_back": INSET},
        "channels": {"back": INSET, "text": FG_SUBTLE, "text_selected": ACTIVE},
        "scrubbing": {
            "back": INSET,
            "text": FG_MUTED,
            "time_marker": a(FG, "80"),
            "time_marker_selected": FG,
        },
        "sidebars": {"back": a(DEFAULT, "00"), "tab_back": a(INSET, "00")},
    },
    "common": {
        "anim": {
            "playhead": ACCENT,
            "preview_range": a(SEVERE, "66"),
            "scene_strip_range": a(INSET, "80"),
            "channels": a(FOCUS, "4d"),
            "channels_sub": a(p("surface.accentInset"), "80"),
            "channel_group": a(SUCCESS, "26"),
            "channel_group_active": a(SUCCESS, "4d"),
            "channel": a(INSET, "99"),
            "channel_selected": a(SUCCESS, "44"),
            "keyframe": FG_SUBTLE,
            "keyframe_selected": BRIGHT_YELLOW,
            "keyframe_extreme": DANGER_BRIGHT,
            "keyframe_extreme_selected": RED,
            "keyframe_breakdown": STRING,
            "keyframe_breakdown_selected": BLUE,
            "keyframe_jitter": SUCCESS_BRIGHT,
            "keyframe_jitter_selected": BRIGHT_GREEN,
            "keyframe_moving_hold": EMPHASIS,
            "keyframe_moving_hold_selected": ACTIVE,
            "keyframe_generated": BORDER,
            "keyframe_generated_selected": ATTENTION,
            "long_key": a(FG, "1f"),
            "long_key_selected": a(SEVERE, "99"),
        },
        "curves": {
            "handle_free": ATTENTION,
            "handle_sel_free": ATTENTION_BRIGHT,
            "handle_auto": DANGER_EMPHASIS,
            "handle_sel_auto": BRIGHT_RED,
            "handle_vect": FOCUS,
            "handle_sel_vect": BRIGHT_BLUE,
            "handle_align": SUCCESS,
            "handle_sel_align": SUCCESS_BRIGHT,
            "handle_auto_clamped": PINK,
            "handle_sel_auto_clamped": DANGER_BRIGHT,
            "handle_vertex": INSET,
            "handle_vertex_select": SELECTED,
        },
    },
    "view_3d": {
        "grid": a(BORDER, "80"),
        "grid_major": BORDER,
        "clipping_border_3d": BORDER,
        # Unselected object wires, cameras, and empties draw over the dark
        # viewport background, so they use the emphasis border instead of black.
        "wire": EMPHASIS,
        "wire_edit": INSET,
        "gp_wire_edit": a(FG_MUTED, "80"),
        "gp_vertex": INSET,
        "gp_vertex_select": SELECTED,
        "text_grease_pencil": SUCCESS,
        "object_selected": SELECTED,
        "object_active": ACTIVE,
        "camera": EMPHASIS,
        "empty": EMPHASIS,
        "light": a(FG_MUTED, "80"),
        "speaker": EMPHASIS,
        "vertex": INSET,
        "vertex_select": SELECTED,
        "edge_select": ACTIVE,
        "edge_mode_select": ATTENTION_BRIGHT,
        "face": a(FG, "02"),
        "face_select": a(SELECTED, "33"),
        "face_mode_select": a(ATTENTION_BRIGHT, "33"),
        "face_back": a(DANGER, "b3"),
        "face_front": a(FOCUS, "00"),
        "bevel": BLUE,
        "seam": DANGER,
        "sharp": CYAN,
        "crease": PINK,
        "freestyle": a(BRIGHT_GREEN, "4d"),
        "extra_edge_len": p("surface.dangerInset"),
        "extra_edge_angle": p("surface.attentionInset"),
        "extra_face_angle": p("surface.accentInset"),
        "extra_face_area": p("surface.successInset"),
        "editmesh_active": a(FG, "33"),
        "normal": CYAN,
        "vertex_normal": ACCENT,
        "split_normal": MAGENTA,
        "vertex_unreferenced": INSET,
        "face_retopology": a(BLUE, "0f"),
        "nurb_uline": ATTENTION,
        "nurb_vline": PINK,
        "nurb_sel_uline": ATTENTION_BRIGHT,
        "nurb_sel_vline": DANGER_BRIGHT,
        "bone_pose": BLUE,
        "bone_pose_active": STRING,
        "bone_solid": FG_SUBTLE,
        "bone_locked_weight": a(DANGER, "80"),
        "before_current_frame": DANGER,
        "after_current_frame": SUCCESS,
        "bundle_solid": FG_SUBTLE,
        "camera_path": EMPHASIS,
        "camera_passepartout": INSET,
        "skin_root": DANGER_EMPHASIS,
        "view_overlay": INSET,
        "transform": ON_EMPHASIS,
        "space": {
            **space(),
            "gradients": {"high_gradient": MUTED, "gradient": DEFAULT},
        },
    },
    "graph_editor": {
        "grid": GRID,
        "vertex": FG_MUTED,
        "vertex_select": SELECTED,
        "vertex_active": ON_EMPHASIS,
        **editor_space(text=FG_MUTED),
    },
    "file_browser": {
        "selected_file": FOCUS,
        "row_alternate": a(FG, "04"),
        **editor_space(),
    },
    "nla_editor": {
        "grid": GRID,
        "active_action": a(SEVERE, "66"),
        "active_action_unset": a(ATTENTION, "4d"),
        "strips": RAISED,
        "strips_selected": SELECTED,
        "transition_strips": mix(FOCUS, 0.25),
        "transition_strips_selected": FOCUS,
        "meta_strips": mix(DONE, 0.25),
        "meta_strips_selected": mix(DONE, 0.7),
        "sound_strips": mix(CYAN, 0.25),
        "sound_strips_selected": mix(CYAN, 0.6),
        "tweak": SUCCESS,
        "tweak_duplicate": DANGER_EMPHASIS,
        "keyframe_border": INSET,
        "keyframe_border_selected": INSET,
        **editor_space(text=FG_MUTED),
    },
    "dopesheet_editor": {
        "grid": GRID,
        "keyframe_border": INSET,
        "keyframe_border_selected": INSET,
        "summary": a(DANGER, "33"),
        "anim_interpolation_linear": a(BRIGHT_GREEN, "cc"),
        "anim_interpolation_constant": a(ORANGE, "cc"),
        "anim_interpolation_other": a(CYAN, "b3"),
        "simulated_frames": mix(PINK, 0.45),
        **editor_space(text=FG_MUTED),
    },
    "image_editor": {
        "grid": GRID,
        "vertex": INSET,
        "vertex_select": SELECTED,
        "face": a(FG, "0a"),
        "face_select": a(SELECTED, "3c"),
        "face_mode_select": a(INSET, "00"),
        "editmesh_active": a(FG, "40"),
        "wire_edit": FG_SUBTLE,
        "edge_select": SELECTED,
        "scope_back": MUTED,
        "preview_stitch_face": a(ATTENTION, "33"),
        "preview_stitch_edge": a(PINK, "33"),
        "preview_stitch_vert": a(FOCUS, "33"),
        "preview_stitch_stitchable": SUCCESS,
        "preview_stitch_unstitchable": DANGER,
        "preview_stitch_active": a(FG, "23"),
        "uv_shadow": EMPHASIS,
        "metadatabg": INSET,
        "metadatatext": FG,
        **editor_space(),
    },
    "sequence_editor": {
        "grid": GRID,
        "movie_strip": mix(BLUE, 0.6),
        "movieclip_strip": mix(SEVERE, 0.6),
        "image_strip": mix(PINK, 0.55),
        "scene_strip": FG_MUTED,
        "audio_strip": mix(SUCCESS, 0.55),
        "effect_strip": mix(DONE, 0.5),
        "transition_strip": mix(MAGENTA, 0.75),
        "color_strip": mix(ATTENTION, 0.65),
        "meta_strip": mix(BRIGHT_GREEN, 0.5),
        "mask_strip": mix(DANGER, 0.5),
        "text_strip": mix(BRIGHT_YELLOW, 0.6),
        "active_strip": ON_EMPHASIS,
        "selected_strip": SELECTED,
        "keyframe_border": INSET,
        "keyframe_border_selected": INSET,
        "preview_back": INSET,
        "metadatabg": INSET,
        "metadatatext": FG,
        "row_alternate": a(FG, "05"),
        "text_strip_cursor": ACCENT,
        "selected_text": a(FOCUS, "80"),
        **editor_space(text=FG_MUTED),
    },
    "properties": {"match": FOCUS, **editor_space()},
    "text_editor": {
        "line_numbers": EMPHASIS,
        "line_numbers_background": DEFAULT,
        "selected_text": TEXT_SELECTION,
        "cursor": ACCENT,
        # Shared syntax mapping: Python keywords, decorators, and
        # function and class names after def and class.
        "syntax_builtin": p("syntax.keyword"),
        "syntax_symbols": FG,
        "syntax_special": p("syntax.entity"),
        "syntax_preprocessor": p("syntax.constant"),
        "syntax_reserved": p("syntax.constant"),
        "syntax_comment": p("syntax.comment"),
        "syntax_string": STRING,
        "syntax_numbers": p("syntax.constant"),
        **editor_space(),
    },
    "node_editor": {
        "grid": GRID,
        "node_outline": BORDER,
        "node_selected": SELECTED,
        "node_active": ON_EMPHASIS,
        "wire": INSET,
        "wire_inner": FG_MUTED,
        "wire_select": a(FG, "b3"),
        "node_backdrop": MUTED,
        # Node headers draw white text, so each category is a hue flattened
        # over the editor background.
        "converter_node": mix(BLUE, 0.4),
        "color_node": mix(ATTENTION, 0.45),
        "group_node": mix(SUCCESS, 0.25),
        "group_socket_node": MUTED,
        "frame_node": a(INSET, "cc"),
        "matte_node": mix(RED, 0.3),
        "distor_node": mix(BRIGHT_CYAN, 0.25),
        "input_node": mix(PINK, 0.45),
        "output_node": mix(DANGER, 0.25),
        "filter_node": mix(DONE, 0.35),
        "vector_node": mix(FOCUS, 0.45),
        "texture_node": mix(SEVERE, 0.45),
        "shader_node": mix(SUCCESS, 0.4),
        "script_node": mix(CYAN, 0.2),
        "geometry_node": mix(CYAN, 0.4),
        "attribute_node": mix(ACCENT, 0.2),
        "simulation_zone": a(PINK, "33"),
        "repeat_zone": a(SEVERE, "33"),
        "foreach_geometry_element_zone": a(ACCENT, "33"),
        "closure_zone": a(ATTENTION, "33"),
        **editor_space(INSET, header=a(INSET, "b3")),
    },
    "outliner": {
        "match": mix(SUCCESS, 0.5),
        "selected_highlight": mix(FOCUS, 0.3),
        "active": mix(FOCUS, 0.5),
        "selected_object": SELECTED,
        "active_object": ACTIVE,
        "edited_object": a(SUCCESS, "66"),
        "row_alternate": a(FG, "04"),
        **editor_space(),
    },
    "info": {
        "info_selected": mix(FOCUS, 0.5),
        "info_selected_text": ON_EMPHASIS,
        "info_error_text": ON_EMPHASIS,
        "info_warning_text": ON_EMPHASIS,
        "info_info_text": ON_EMPHASIS,
        "info_debug": mix(DONE, 0.45),
        "info_debug_text": ON_EMPHASIS,
        "info_property": mix(CYAN, 0.4),
        "info_property_text": ON_EMPHASIS,
        "info_operator": mix(BLUE, 0.4),
        "info_operator_text": ON_EMPHASIS,
        **editor_space(),
    },
    "preferences": {"match": FOCUS, **editor_space()},
    "console": {
        "line_output": ACCENT,
        "line_input": FG,
        "line_info": SUCCESS,
        "line_error": DANGER,
        "cursor": ACCENT,
        "select": a(FOCUS, "80"),
        **editor_space(),
    },
    "clip_editor": {
        "grid": GRID,
        "marker_outline": INSET,
        "marker": ATTENTION,
        "active_marker": ON_EMPHASIS,
        "selected_marker": ATTENTION_BRIGHT,
        "disabled_marker": DANGER_EMPHASIS,
        "locked_marker": EMPHASIS,
        "path_before": DANGER,
        "path_after": ACCENT,
        "path_keyframe_before": DANGER_BRIGHT,
        "path_keyframe_after": STRING,
        "metadatabg": INSET,
        "metadatatext": FG,
        **editor_space(text=FG_MUTED),
    },
    "topbar": editor_space(INSET, header=INSET),
    "statusbar": {"space": {**space(INSET, text=FG_MUTED, header=INSET), "header_text": FG_MUTED}},
    "spreadsheet": {"row_alternate": a(FG, "04"), **editor_space()},
    # Blender's 15 named bone color sets keep their hues; the five unused
    # slots stay black in Blender's defaults and inset here.
    "bone_color_sets": [
        bone_set(DANGER),
        bone_set(SEVERE),
        bone_set(SUCCESS),
        bone_set(ACCENT),
        bone_set(PINK),
        bone_set(DONE),
        bone_set(CYAN),
        bone_set(BRIGHT_BLUE, 0.45, 0.7),
        bone_set(ATTENTION),
        {"normal": MUTED, "select": BORDER, "active": ON_EMPHASIS},
        bone_set(MAGENTA),
        bone_set(BRIGHT_GREEN),
        {"normal": FG_MUTED, "select": FG_SUBTLE, "active": FG},
        bone_set(SEVERE, 0.45, 0.6, mix(SEVERE, 0.85)),
        bone_set(SUCCESS, 0.2, 0.35, mix(SUCCESS, 0.5)),
    ] + [{"normal": INSET, "select": INSET, "active": INSET}] * 5,
    "collection_color": [
        {"color": RED},
        {"color": ORANGE},
        {"color": ATTENTION_BRIGHT},
        {"color": BRIGHT_GREEN},
        {"color": BLUE},
        {"color": DONE},
        {"color": PINK},
        {"color": mix(SEVERE, 0.55)},
    ],
    "strip_color": [
        {"color": mix(DANGER, 0.8)},
        {"color": mix(SEVERE, 0.8)},
        {"color": mix(ATTENTION, 0.8)},
        {"color": mix(SUCCESS, 0.8)},
        {"color": mix(ACCENT, 0.8)},
        {"color": mix(DONE, 0.8)},
        {"color": mix(PINK, 0.8)},
        {"color": mix(SEVERE, 0.5)},
        {"color": EMPHASIS},
    ],
}

assigned = set()


def is_color(rna, name):
    prop = rna.bl_rna.properties[name]
    return prop.type == 'FLOAT' and prop.subtype in {'COLOR', 'COLOR_GAMMA'}


def to_floats(value, length, where):
    digits = value.lstrip("#")
    if len(digits) == 6 and length == 4:
        digits += "ff"
    if len(digits) != length * 2:
        sys.exit(f"{where}: {value} does not match its {length}-channel property")
    return [int(digits[i:i + 2], 16) / 255 for i in range(0, len(digits), 2)]


def apply(rna, mapping, where):
    for name, value in mapping.items():
        path = f"{where}.{name}"
        if name not in rna.bl_rna.properties:
            sys.exit(f"{path} is not a Blender {bpy.app.version_string} theme property")
        if isinstance(value, dict):
            apply(getattr(rna, name), value, path)
        elif isinstance(value, list):
            collection = getattr(rna, name)
            if len(collection) != len(value):
                sys.exit(f"{path} has {len(collection)} items, the mapping {len(value)}")
            for index, item in enumerate(value):
                apply(collection[index], item, f"{path}[{index}]")
        elif is_color(rna, name):
            prop = rna.bl_rna.properties[name]
            setattr(rna, name, to_floats(value, prop.array_length, path))
            assigned.add(path)
        else:
            sys.exit(f"{path} is not a color property")


def unmapped(rna, where):
    for prop in rna.bl_rna.properties:
        name = prop.identifier
        path = f"{where}.{name}"
        if prop.type == 'POINTER' and name != "rna_type":
            yield from unmapped(getattr(rna, name), path)
        elif prop.type == 'COLLECTION':
            for index, item in enumerate(getattr(rna, name)):
                yield from unmapped(item, f"{path}[{index}]")
        elif prop.type == 'FLOAT' and prop.subtype in {'COLOR', 'COLOR_GAMMA'} and path not in assigned:
            yield path


bpy.ops.preferences.reset_default_theme()
theme = bpy.context.preferences.themes[0]
apply(theme, THEME, "theme")
missing = list(unmapped(theme, "theme"))
if missing:
    sys.exit("Unmapped theme colors:\n  " + "\n  ".join(missing))

# Write only the Theme. The empty ThemeStyle element is required by Blender's
# preset loader and leaves the user's interface font styles untouched.
rna_xml.xml_file_write(bpy.context, str(OUT), (("preferences.themes[0]", "Theme"),))
body = OUT.read_text()
assert body.endswith("</bpy>\n")
OUT.write_text(
    f"<!-- Generated by scripts/generate-blender-theme.py for Blender {bpy.app.version_string}; SPDX-License-Identifier: MIT -->\n"
    + body[: -len("</bpy>\n")]
    + "  <ThemeStyle>\n  </ThemeStyle>\n</bpy>\n"
)
print(f"Wrote {OUT.relative_to(ROOT)} with {len(assigned)} colors")
