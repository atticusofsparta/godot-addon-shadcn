@tool
class_name ShadcnCommand
extends PanelContainer
## Command palette (shadcn Command): a search box over a filterable action list.
## Add entries with add_item(); emits `selected(id)` on pick. Embed it or drop
## it into a ShadcnDialog for a ⌘K menu.

signal selected(id: String)

var _filter: LineEdit
var _list: VBoxContainer
var _items: Array = []  # [{id, label, hint}]


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()
	_rebuild()


func _build() -> void:
	if _filter:
		return
	custom_minimum_size = Vector2(360, 320)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	add_child(vb)
	_filter = LineEdit.new()
	_filter.placeholder_text = "Type a command or search…"
	_filter.text_changed.connect(func(_t): _rebuild())
	vb.add_child(_filter)
	var sep := HSeparator.new()
	vb.add_child(sep)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 2)
	scroll.add_child(_list)


func add_item(id: String, label: String, hint := "") -> void:
	_build()
	_items.append({"id": id, "label": label, "hint": hint})
	_rebuild()


func clear_items() -> void:
	_items.clear()
	_rebuild()


func refresh() -> void:
	if not _filter:
		return
	var T := ShadcnTokens
	add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("popover"), T.RADIUS, T.c("border"), 1, Vector4(8, 8, 8, 8)))
	_filter.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, 0, null, 0, Vector4(4, 6, 4, 6)))
	_filter.add_theme_stylebox_override("focus", ShadcnStyle.flat(null, 0))
	_filter.add_theme_color_override("font_color", T.c("foreground"))
	_filter.add_theme_color_override("font_placeholder_color", T.c("muted_foreground"))
	_rebuild()


func _rebuild() -> void:
	if not _list:
		return
	var T := ShadcnTokens
	for c in _list.get_children():
		c.queue_free()
	var q := _filter.text.to_lower()
	for it in _items:
		if q != "" and not String(it.label).to_lower().contains(q):
			continue
		var b := Button.new()
		b.text = it.label
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, T.RADIUS_SM, null, 0, Vector4(8, 8, 8, 8)))
		b.add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), T.RADIUS_SM, null, 0, Vector4(8, 8, 8, 8)))
		b.add_theme_stylebox_override("pressed", b.get_theme_stylebox("hover"))
		b.add_theme_color_override("font_color", T.c("popover_foreground"))
		b.add_theme_color_override("font_hover_color", T.c("accent_foreground"))
		var id: String = it.id
		b.pressed.connect(func(): selected.emit(id))
		_list.add_child(b)
