@tool
class_name ShadcnCombobox
extends Button
## Searchable select (shadcn Combobox): a button that opens a filterable list.
## Emits `selected(value)`.

signal selected(value: String)

@export var items: PackedStringArray:
	set(v): items = v
@export var placeholder: String = "Select…"

var value: String = ""
var _popup: PopupPanel
var _filter: LineEdit
var _list: VBoxContainer


func _ready() -> void:
	add_to_group("shadcn_refresh")
	text = placeholder
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.x = 240
	pressed.connect(_open)
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var pad := Vector4(12, 9, 12, 9)
	add_theme_stylebox_override("normal", ShadcnStyle.flat(T.c("background"), T.RADIUS_MD, T.c("input"), 1, pad))
	add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), T.RADIUS_MD, T.c("input"), 1, pad))
	add_theme_stylebox_override("pressed", get_theme_stylebox("hover"))
	add_theme_stylebox_override("focus", ShadcnStyle.ring(T.c("ring"), 2, T.RADIUS_MD))
	add_theme_color_override("font_color", T.c("muted_foreground") if value == "" else T.c("foreground"))
	add_theme_color_override("font_hover_color", T.c("accent_foreground"))
	add_theme_font_size_override("font_size", T.FONT_SM)


func refresh() -> void:
	_apply()


func _open() -> void:
	var T := ShadcnTokens
	if _popup == null:
		_popup = PopupPanel.new()
		_popup.add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("popover"), T.RADIUS_MD, T.c("border"), 1, Vector4(6, 6, 6, 6)))
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 4)
		_popup.add_child(vb)
		_filter = LineEdit.new()
		_filter.placeholder_text = "Search…"
		_filter.custom_minimum_size.x = 220
		_filter.text_changed.connect(func(_t): _rebuild())
		vb.add_child(_filter)
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size.y = 180
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		vb.add_child(scroll)
		_list = VBoxContainer.new()
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(_list)
		add_child(_popup)
	_filter.text = ""
	_rebuild()
	_popup.popup(Rect2i(get_screen_position() + Vector2(0, size.y + 6), Vector2i(maxi(240, int(size.x)), 240)))
	_filter.grab_focus()


func _rebuild() -> void:
	var T := ShadcnTokens
	for c in _list.get_children():
		c.queue_free()
	var q := _filter.text.to_lower()
	for it in items:
		if q != "" and not it.to_lower().contains(q):
			continue
		var b := Button.new()
		b.text = ("✓  " if it == value else "    ") + it
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, T.RADIUS_SM, null, 0, Vector4(8, 6, 8, 6)))
		b.add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), T.RADIUS_SM, null, 0, Vector4(8, 6, 8, 6)))
		b.add_theme_stylebox_override("pressed", b.get_theme_stylebox("hover"))
		b.add_theme_color_override("font_color", T.c("popover_foreground"))
		b.add_theme_color_override("font_hover_color", T.c("accent_foreground"))
		var v := it
		b.pressed.connect(func():
			value = v
			text = v
			_apply()
			selected.emit(v)
			_popup.hide())
		_list.add_child(b)
