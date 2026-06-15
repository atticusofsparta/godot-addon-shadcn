@tool
class_name ShadcnToggle
extends Button
## Two-state toggle button (shadcn Toggle). On = accent fill.

enum Variant { DEFAULT, OUTLINE }

@export var variant: Variant = Variant.DEFAULT:
	set(v): variant = v; _apply()


func _init() -> void:
	toggle_mode = true


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_apply()


func refresh() -> void:
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var pad := Vector4(10, 8, 10, 8)
	var border: Variant = T.c("input") if variant == Variant.OUTLINE else null
	var bw := 1 if variant == Variant.OUTLINE else 0
	var off := ShadcnStyle.flat(T.c("background") if variant == Variant.OUTLINE else Color(0, 0, 0, 0), T.RADIUS_MD, border, bw, pad)
	var hover := ShadcnStyle.flat(T.c("muted"), T.RADIUS_MD, border, bw, pad)
	var on := ShadcnStyle.flat(T.c("accent"), T.RADIUS_MD, border, bw, pad)
	add_theme_stylebox_override("normal", off)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", on)
	add_theme_stylebox_override("hover_pressed", on)
	add_theme_stylebox_override("focus", ShadcnStyle.ring(T.c("ring"), 2, T.RADIUS_MD))
	add_theme_color_override("font_color", T.c("muted_foreground"))
	add_theme_color_override("font_hover_color", T.c("foreground"))
	add_theme_color_override("font_pressed_color", T.c("accent_foreground"))
	add_theme_color_override("font_hover_pressed_color", T.c("accent_foreground"))
	add_theme_font_size_override("font_size", T.FONT_SM)
