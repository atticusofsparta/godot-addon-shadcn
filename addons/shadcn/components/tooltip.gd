@tool
class_name ShadcnTooltip
extends Node
## Hover tooltip that opens ABOVE its trigger by default (shadcn's default
## "top" side), unlike Godot's built-in tooltip which opens below the cursor.
##
## Add it as a child of any Control and set `text`:
##   var btn := Button.new()
##   var tip := ShadcnTooltip.new()
##   tip.text = "Add to library"
##   btn.add_child(tip)

enum Placement { TOP, BOTTOM, LEFT, RIGHT }

@export_multiline var text: String = "Tooltip":
	set(value):
		text = value
		if _label:
			_label.text = value
@export var side: Placement = Placement.TOP
@export var delay: float = 0.3

var _panel: PopupPanel
var _label: Label
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
	_panel.wrap_controls = true                 # size to content (avoids huge first popup)
	_panel.theme_type_variation = "TooltipPanel"
	_label = Label.new()
	_label.text = text
	_label.theme_type_variation = "TooltipLabel"
	_panel.add_child(_label)
	# Parent to the trigger Control (not this Node) so the theme propagates and
	# the TooltipPanel/TooltipLabel styling resolves.
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
	var sz := trigger.size
	var gap := 8.0
	var pos: Vector2
	match side:
		Placement.BOTTOM:
			pos = Vector2(g.x + sz.x * 0.5 - ts.x * 0.5, g.y + sz.y + gap)
		Placement.LEFT:
			pos = Vector2(g.x - ts.x - gap, g.y + sz.y * 0.5 - ts.y * 0.5)
		Placement.RIGHT:
			pos = Vector2(g.x + sz.x + gap, g.y + sz.y * 0.5 - ts.y * 0.5)
		_:  # TOP
			pos = Vector2(g.x + sz.x * 0.5 - ts.x * 0.5, g.y - ts.y - gap)
	_panel.popup(Rect2i(pos, Vector2i(ts)))
