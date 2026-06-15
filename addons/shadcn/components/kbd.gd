@tool
class_name ShadcnKbd
extends Label
## Keyboard key display (shadcn Kbd). e.g. set text to "⌘K".

func _ready() -> void:
	add_to_group("shadcn_refresh")
	refresh()


func refresh() -> void:
	var T := ShadcnTokens
	add_theme_stylebox_override("normal", ShadcnStyle.flat(T.c("muted"), T.RADIUS_SM, T.c("border"), 1, Vector4(6, 1, 6, 1)))
	add_theme_color_override("font_color", T.c("muted_foreground"))
	add_theme_font_size_override("font_size", T.FONT_XS)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
