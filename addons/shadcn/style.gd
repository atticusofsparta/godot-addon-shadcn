@tool
class_name ShadcnStyle
extends RefCounted
## StyleBoxFlat factory used by ShadcnTheme and the runtime components.
## Deliberately depends on NOTHING in this addon (colors are passed in) so the
## dependency graph stays acyclic: ShadcnTokens -> ShadcnTheme -> ShadcnStyle.


static func flat(bg: Variant, radius: int = 8,
		border: Variant = null, border_width: int = 0,
		pad := Vector4(0, 0, 0, 0)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if bg == null:
		sb.draw_center = false
	else:
		sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border != null and border_width > 0:
		sb.border_color = border
		sb.set_border_width_all(border_width)
	sb.content_margin_left = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_right = pad.z
	sb.content_margin_bottom = pad.w
	sb.anti_aliasing = true
	return sb


## A focus-ring overlay (transparent centre, coloured border that expands out).
static func ring(color: Color, width: int = 2, radius: int = 8) -> StyleBoxFlat:
	var sb := flat(null, radius, color, width)
	sb.expand_margin_left = width
	sb.expand_margin_top = width
	sb.expand_margin_right = width
	sb.expand_margin_bottom = width
	return sb
