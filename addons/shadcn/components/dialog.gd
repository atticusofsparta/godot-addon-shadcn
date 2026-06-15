@tool
class_name ShadcnDialog
extends CanvasLayer
## Modal dialog (shadcn Dialog). A dimmed backdrop + centered card with a
## title, description, a `body` slot and a `footer` slot. Call open() / close().

signal closed

@export var title: String = "Are you sure?":
	set(v): title = v; _refresh()
@export_multiline var description: String = "This action cannot be undone.":
	set(v): description = v; _refresh()
@export var dismissible: bool = true
@export var max_width: float = 420.0:
	set(v): max_width = v; if _card: _card.custom_minimum_size.x = v

var body: VBoxContainer       # add your content here
var footer: HBoxContainer     # add action buttons here
var _root: Control
var _backdrop: ColorRect
var _card: PanelContainer
var _title: Label
var _desc: Label


func _ready() -> void:
	add_to_group("shadcn_refresh")
	layer = 100
	_build()
	refresh()
	_refresh()


func _build() -> void:
	if _root:
		return
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)

	_backdrop = ColorRect.new()
	_backdrop.color = Color(0, 0, 0, 0.5)
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.gui_input.connect(_on_backdrop_input)
	_root.add_child(_backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)

	_card = PanelContainer.new()
	_card.custom_minimum_size.x = max_width
	center.add_child(_card)

	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 24)
	_card.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	margin.add_child(vb)
	_title = Label.new(); _title.add_theme_font_size_override("font_size", 18)
	_desc = Label.new(); _desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	vb.add_child(_title); vb.add_child(_desc)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	vb.add_child(body)
	footer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 8)
	vb.add_child(footer)


func open() -> void:
	_build()
	_root.visible = true
	_card.pivot_offset = _card.size / 2.0
	_card.scale = Vector2(0.96, 0.96)
	_backdrop.modulate.a = 0.0
	_card.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_backdrop, "modulate:a", 1.0, 0.15)
	tw.tween_property(_card, "modulate:a", 1.0, 0.15)
	tw.tween_property(_card, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC)


func close() -> void:
	if not _root or not _root.visible:
		return
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_backdrop, "modulate:a", 0.0, 0.12)
	tw.tween_property(_card, "modulate:a", 0.0, 0.12)
	tw.chain().tween_callback(func():
		_root.visible = false
		closed.emit())


func _on_backdrop_input(event: InputEvent) -> void:
	if dismissible and event is InputEventMouseButton and event.pressed:
		close()


func _refresh() -> void:
	if _title:
		_title.text = title
		_desc.text = description
		_desc.visible = description != ""


func refresh() -> void:
	if not _card:
		return
	var T := ShadcnTokens
	_card.add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("popover"), T.RADIUS, T.c("border"), 1))
	_title.add_theme_color_override("font_color", T.c("popover_foreground"))
	_desc.add_theme_color_override("font_color", T.c("muted_foreground"))
