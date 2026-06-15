@tool
class_name ShadcnSheet
extends CanvasLayer
## Slide-out panel (shadcn Sheet). Anchors to a screen edge and slides in over a
## dimmed backdrop. Populate `body`; call open() / close().

signal closed

enum SheetSide { LEFT, RIGHT, TOP, BOTTOM }

@export var side: SheetSide = SheetSide.RIGHT
@export var panel_size: float = 380.0
@export var title: String = "Sheet":
	set(v): title = v; if _title: _title.text = v
@export_multiline var description: String = "":
	set(v): description = v; _refresh()
@export var dismissible: bool = true

var body: VBoxContainer
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
	_backdrop.gui_input.connect(func(e):
		if dismissible and e is InputEventMouseButton and e.pressed: close())
	_root.add_child(_backdrop)
	_card = PanelContainer.new()
	_root.add_child(_card)
	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 20)
	_card.add_child(margin)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	margin.add_child(vb)
	_title = Label.new(); _title.text = title; _title.add_theme_font_size_override("font_size", 18)
	_desc = Label.new(); _desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	vb.add_child(_title); vb.add_child(_desc)
	body = VBoxContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	vb.add_child(body)
	_refresh()


func open() -> void:
	_build()
	_root.visible = true
	var vp := _root.size
	var from: Vector2
	var to: Vector2
	match side:
		SheetSide.LEFT:
			_card.size = Vector2(panel_size, vp.y); from = Vector2(-panel_size, 0); to = Vector2.ZERO
		SheetSide.TOP:
			_card.size = Vector2(vp.x, panel_size); from = Vector2(0, -panel_size); to = Vector2.ZERO
		SheetSide.BOTTOM:
			_card.size = Vector2(vp.x, panel_size); from = Vector2(0, vp.y); to = Vector2(0, vp.y - panel_size)
		_:  # RIGHT
			_card.size = Vector2(panel_size, vp.y); from = Vector2(vp.x, 0); to = Vector2(vp.x - panel_size, 0)
	_card.position = from
	_backdrop.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_backdrop, "modulate:a", 1.0, 0.2)
	tw.tween_property(_card, "position", to, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not _root or not _root.visible:
		return
	var vp := _root.size
	var off := _card.position
	match side:
		SheetSide.LEFT: off = Vector2(-_card.size.x, 0)
		SheetSide.TOP: off = Vector2(0, -_card.size.y)
		SheetSide.BOTTOM: off = Vector2(0, vp.y)
		_: off = Vector2(vp.x, 0)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_backdrop, "modulate:a", 0.0, 0.2)
	tw.tween_property(_card, "position", off, 0.2).set_trans(Tween.TRANS_CUBIC)
	tw.chain().tween_callback(func(): _root.visible = false; closed.emit())


func _refresh() -> void:
	if _desc:
		_desc.text = description
		_desc.visible = description != ""


func refresh() -> void:
	if not _card:
		return
	var T := ShadcnTokens
	_card.add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("popover"), 0, T.c("border"), 1))
	_title.add_theme_color_override("font_color", T.c("popover_foreground"))
	_desc.add_theme_color_override("font_color", T.c("muted_foreground"))
