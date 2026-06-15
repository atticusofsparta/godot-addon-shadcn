@tool
class_name ShadcnPagination
extends HBoxContainer
## Page navigation (shadcn Pagination). Emits `page_changed(page)` (1-based).

signal page_changed(page: int)

@export var page_count: int = 5:
	set(v): page_count = maxi(1, v); _rebuild()
@export var current: int = 1:
	set(v): current = clampi(v, 1, page_count); _rebuild()
@export var max_visible: int = 7:
	set(v): max_visible = maxi(3, v); _rebuild()


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_rebuild()


func refresh() -> void:
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	if not is_inside_tree():
		return
	add_theme_constant_override("separation", 4)
	_nav("‹", current > 1, func(): _go(current - 1))
	for p in _pages():
		if p == -1:
			var dots := Label.new()
			dots.text = "…"
			dots.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
			dots.custom_minimum_size = Vector2(28, 36)
			dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			dots.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			add_child(dots)
		else:
			_page_btn(p)
	_nav("›", current < page_count, func(): _go(current + 1))


func _pages() -> Array:
	if page_count <= max_visible:
		return range(1, page_count + 1)
	var out := [1]
	var lo := maxi(2, current - 1)
	var hi := mini(page_count - 1, current + 1)
	if lo > 2:
		out.append(-1)
	for p in range(lo, hi + 1):
		out.append(p)
	if hi < page_count - 1:
		out.append(-1)
	out.append(page_count)
	return out


func _page_btn(p: int) -> void:
	var T := ShadcnTokens
	var b := Button.new()
	b.text = str(p)
	b.custom_minimum_size = Vector2(36, 36)
	var active := p == current
	var bg := T.c("primary") if active else Color(0, 0, 0, 0)
	var hover := T.mix(T.c("primary"), T.c("background"), 0.1) if active else T.c("accent")
	b.add_theme_stylebox_override("normal", ShadcnStyle.flat(bg if bg.a > 0 else null, T.RADIUS_MD, null, 0, Vector4(8, 8, 8, 8)))
	b.add_theme_stylebox_override("hover", ShadcnStyle.flat(hover, T.RADIUS_MD, null, 0, Vector4(8, 8, 8, 8)))
	b.add_theme_stylebox_override("pressed", ShadcnStyle.flat(hover, T.RADIUS_MD, null, 0, Vector4(8, 8, 8, 8)))
	var fg := T.c("primary_foreground") if active else T.c("foreground")
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", fg if active else T.c("accent_foreground"))
	b.pressed.connect(func(): _go(p))
	add_child(b)


func _nav(label: String, enabled: bool, cb: Callable) -> void:
	var T := ShadcnTokens
	var b := Button.new()
	b.text = label
	b.disabled = not enabled
	b.custom_minimum_size = Vector2(36, 36)
	b.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, T.RADIUS_MD, null, 0, Vector4(8, 8, 8, 8)))
	b.add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), T.RADIUS_MD, null, 0, Vector4(8, 8, 8, 8)))
	b.add_theme_color_override("font_color", T.c("foreground"))
	b.add_theme_color_override("font_hover_color", T.c("accent_foreground"))
	b.add_theme_color_override("font_disabled_color", ShadcnTokens.c("muted_foreground"))
	b.pressed.connect(cb)
	add_child(b)


func _go(p: int) -> void:
	current = p
	page_changed.emit(current)
