@tool
class_name ShadcnCarousel
extends Control
## Carousel / pager (shadcn Carousel). Add slides with add_slide(control); shows
## one at a time with prev/next controls and dot indicators.

signal slide_changed(index: int)

@export var loop: bool = true

var _slides: Array[Control] = []
var _index := 0
var _viewport: Control
var _dots: HBoxContainer
var _prev: Button
var _next: Button


func _init() -> void:
	custom_minimum_size = Vector2(400, 240)
	clip_contents = true


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()


func _build() -> void:
	if _viewport:
		return
	_viewport = Control.new()
	_viewport.set_anchors_preset(Control.PRESET_FULL_RECT)
	_viewport.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_viewport)
	_prev = _nav("‹"); _prev.pressed.connect(func(): go(_index - 1))
	_prev.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	_prev.position = Vector2(6, -16)
	add_child(_prev)
	_next = _nav("›"); _next.pressed.connect(func(): go(_index + 1))
	_next.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_next.position = Vector2(-38, -16)
	add_child(_next)
	_dots = HBoxContainer.new()
	_dots.add_theme_constant_override("separation", 6)
	_dots.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dots.position = Vector2(0, -18)
	_dots.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_dots)


func _nav(txt: String) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(32, 32)
	return b


func add_slide(slide: Control) -> void:
	_build()
	slide.set_anchors_preset(Control.PRESET_FULL_RECT)
	_viewport.add_child(slide)
	_slides.append(slide)
	_update()


func go(i: int) -> void:
	if _slides.is_empty():
		return
	if loop:
		_index = wrapi(i, 0, _slides.size())
	else:
		_index = clampi(i, 0, _slides.size() - 1)
	_update()
	slide_changed.emit(_index)


func _update() -> void:
	for i in _slides.size():
		_slides[i].visible = i == _index
	if _prev:
		_prev.disabled = not loop and _index == 0
		_next.disabled = not loop and _index == _slides.size() - 1
	_rebuild_dots()


func _rebuild_dots() -> void:
	if not _dots:
		return
	var T := ShadcnTokens
	for c in _dots.get_children():
		c.queue_free()
	for i in _slides.size():
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(8, 8)
		var col := T.c("primary") if i == _index else T.c("muted_foreground").lerp(T.c("background"), 0.4)
		dot.add_theme_stylebox_override("panel", ShadcnStyle.flat(col, 4))
		_dots.add_child(dot)


func refresh() -> void:
	var T := ShadcnTokens
	for b in [_prev, _next]:
		if b == null:
			continue
		b.add_theme_stylebox_override("normal", ShadcnStyle.flat(T.c("background"), 999, T.c("border"), 1, Vector4(6, 6, 6, 6)))
		b.add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), 999, T.c("border"), 1, Vector4(6, 6, 6, 6)))
		b.add_theme_stylebox_override("pressed", b.get_theme_stylebox("hover"))
		b.add_theme_color_override("font_color", T.c("foreground"))
	_rebuild_dots()
