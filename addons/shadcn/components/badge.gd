@tool
class_name ShadcnBadge
extends Label
## Small inline status label. Not present in Godot's control set.

enum Variant { DEFAULT, SECONDARY, DESTRUCTIVE, OUTLINE }

@export var variant: Variant = Variant.DEFAULT:
	set(v): variant = v; _apply()


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_apply()


func refresh() -> void:
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var bg: Color
	var fg: Color
	var border: Variant = null
	var bw := 0
	match variant:
		Variant.SECONDARY:
			bg = T.c("secondary"); fg = T.c("secondary_foreground")
		Variant.DESTRUCTIVE:
			bg = T.c("destructive"); fg = T.c("destructive_foreground")
		Variant.OUTLINE:
			bg = Color(0, 0, 0, 0); fg = T.c("foreground"); border = T.c("border"); bw = 1
		_:
			bg = T.c("primary"); fg = T.c("primary_foreground")
	var sb := ShadcnStyle.flat(bg if bg.a > 0 else null, ShadcnTokens.RADIUS_SM, border, bw, Vector4(9, 3, 9, 3))
	add_theme_stylebox_override("normal", sb)
	add_theme_color_override("font_color", fg)
	add_theme_font_size_override("font_size", T.FONT_XS)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
