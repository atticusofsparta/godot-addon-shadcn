@tool
class_name ShadcnAlertDialog
extends ShadcnDialog
## Confirmation dialog (shadcn Alert Dialog): a Dialog preconfigured with
## Cancel / Action buttons. Emits `confirmed` / `canceled`.

signal confirmed
signal canceled

@export var cancel_text: String = "Cancel":
	set(v): cancel_text = v; if _cancel: _cancel.text = v
@export var action_text: String = "Continue":
	set(v): action_text = v; if _action: _action.text = v
@export var destructive: bool = false:
	set(v): destructive = v; if _action: _action.variant = _action_variant()

var _cancel: ShadcnButton
var _action: ShadcnButton


func _ready() -> void:
	super._ready()
	dismissible = false
	_cancel = ShadcnButton.new()
	_cancel.variant = ShadcnButton.Variant.OUTLINE
	_cancel.text = cancel_text
	_cancel.pressed.connect(func(): canceled.emit(); close())
	_action = ShadcnButton.new()
	_action.variant = _action_variant()
	_action.text = action_text
	_action.pressed.connect(func(): confirmed.emit(); close())
	footer.add_child(_cancel)
	footer.add_child(_action)


func _action_variant() -> int:
	return ShadcnButton.Variant.DESTRUCTIVE if destructive else ShadcnButton.Variant.PRIMARY
