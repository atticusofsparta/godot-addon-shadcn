@tool
class_name ShadcnToggleGroup
extends HBoxContainer
## A row of ShadcnToggles (shadcn Toggle Group). `single` makes them mutually
## exclusive (radio-like). Add ShadcnToggle children.

@export var single: bool = false:
	set(v): single = v; _wire()

var _group: ButtonGroup


func _ready() -> void:
	add_theme_constant_override("separation", 4)
	_wire()
	child_entered_tree.connect(func(_n): _wire())


func _wire() -> void:
	if single and _group == null:
		_group = ButtonGroup.new()
	for c in get_children():
		if c is ShadcnToggle:
			c.toggle_mode = true
			c.button_group = _group if single else null
