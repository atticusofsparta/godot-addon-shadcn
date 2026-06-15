@tool
class_name ShadcnHoverCard
extends Node
## Rich content preview on hover (shadcn Hover Card). Add as a child of any
## Control, then populate `body` (created on first hover). Opens above by default.

@export var delay: float = 0.4
@export var card_width: float = 280.0

var body: VBoxContainer
var _panel: PopupPanel
var _hovered := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var parent := get_parent()
	if parent is Control:
		parent.mouse_entered.connect(_on_enter)
		parent.mouse_exited.connect(_on_exit)
		parent.tree_exiting.connect(_on_exit)


func _build() -> void:
	_panel = PopupPanel.new()
	_panel.wrap_controls = true
	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 16)
	_panel.add_child(margin)
	body = VBoxContainer.new()
	body.custom_minimum_size.x = card_width
	body.add_theme_constant_override("separation", 6)
	margin.add_child(body)
	var host := get_parent()
	if host is Control:
		host.add_child(_panel)
	else:
		add_child(_panel)


func _on_enter() -> void:
	_hovered = true
	if _panel == null:
		_build()
	await get_tree().create_timer(delay).timeout
	if _hovered:
		_show()


func _on_exit() -> void:
	_hovered = false
	if is_instance_valid(_panel):
		_panel.hide()


func _show() -> void:
	var trigger := get_parent() as Control
	if trigger == null or not trigger.is_visible_in_tree():
		return
	_panel.reset_size()
	var ts := Vector2(_panel.size)
	var g := trigger.get_screen_position()
	var pos := Vector2(g.x + trigger.size.x * 0.5 - ts.x * 0.5, g.y - ts.y - 8)
	_panel.popup(Rect2i(pos, Vector2i(ts)))
