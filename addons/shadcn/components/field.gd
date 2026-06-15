@tool
class_name ShadcnField
extends VBoxContainer
## Form field wrapper (shadcn Field): a label, a `content` slot for the control,
## and helper/error text. Add your control with `field.content.add_child(ctrl)`.

@export var label: String = "Label":
	set(v): label = v; _refresh()
@export var description: String = "":
	set(v): description = v; _refresh()
@export var error: String = "":
	set(v): error = v; _refresh()

var content: VBoxContainer
var _label: Label
var _help: Label


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()


func _build() -> void:
	if _label:
		return
	add_theme_constant_override("separation", 6)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	add_child(_label)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	add_child(content)
	_help = Label.new()
	_help.add_theme_font_size_override("font_size", ShadcnTokens.FONT_XS)
	_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_help)
	_refresh()


func _refresh() -> void:
	if not _label:
		return
	_label.text = label
	var msg := error if error != "" else description
	_help.text = msg
	_help.visible = msg != ""
	refresh()


func refresh() -> void:
	if not _label:
		return
	var T := ShadcnTokens
	_label.add_theme_color_override("font_color", T.c("foreground"))
	_help.add_theme_color_override("font_color", T.c("destructive") if error != "" else T.c("muted_foreground"))
