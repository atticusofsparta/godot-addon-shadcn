@tool
class_name ShadcnButtonGroup
extends HBoxContainer
## Joins related buttons with a single shared border (shadcn Button Group).
## Add plain Button children; they get outline styling with merged borders.

func _ready() -> void:
	add_to_group("shadcn_refresh")
	add_theme_constant_override("separation", 0)
	child_entered_tree.connect(func(_n): _apply.call_deferred())
	_apply.call_deferred()


func refresh() -> void:
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var buttons := get_children().filter(func(c): return c is Button)
	for i in buttons.size():
		var b: Button = buttons[i]
		var first := i == 0
		var last := i == buttons.size() - 1
		for state in ["normal", "hover", "pressed"]:
			var bg := T.c("background") if state == "normal" else T.c("accent")
			var sb := StyleBoxFlat.new()
			sb.bg_color = bg
			sb.border_color = T.c("input")
			sb.set_border_width_all(1)
			if not first:
				sb.border_width_left = 0
			sb.content_margin_left = 14
			sb.content_margin_right = 14
			sb.content_margin_top = 9
			sb.content_margin_bottom = 9
			sb.corner_radius_top_left = T.RADIUS_MD if first else 0
			sb.corner_radius_bottom_left = T.RADIUS_MD if first else 0
			sb.corner_radius_top_right = T.RADIUS_MD if last else 0
			sb.corner_radius_bottom_right = T.RADIUS_MD if last else 0
			sb.anti_aliasing = true
			b.add_theme_stylebox_override(state, sb)
		b.add_theme_color_override("font_color", T.c("foreground"))
		b.add_theme_color_override("font_hover_color", T.c("accent_foreground"))
