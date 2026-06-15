@tool
class_name ShadcnInputGroup
extends PanelContainer
## Input with leading/trailing addons (shadcn Input Group). The bordered
## container owns a flat LineEdit (`line_edit`); add prefix/suffix nodes around it.

@export var placeholder: String = "":
	set(v): placeholder = v; if line_edit: line_edit.placeholder_text = v

var line_edit: LineEdit
var _row: HBoxContainer


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()


func _build() -> void:
	if _row:
		return
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 6)
	add_child(_row)
	line_edit = LineEdit.new()
	line_edit.placeholder_text = placeholder
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, 0))
	line_edit.add_theme_stylebox_override("focus", ShadcnStyle.flat(null, 0))
	_row.add_child(line_edit)


## Add a leading addon (Label / Button / icon).
func add_prefix(node: Control) -> void:
	_build()
	_row.add_child(node)
	_row.move_child(node, 0)


## Add a trailing addon.
func add_suffix(node: Control) -> void:
	_build()
	_row.add_child(node)


func refresh() -> void:
	var T := ShadcnTokens
	add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("background"), T.RADIUS_MD, T.c("input"), 1, Vector4(10, 6, 10, 6)))
	if line_edit:
		line_edit.add_theme_color_override("font_color", T.c("foreground"))
		line_edit.add_theme_color_override("font_placeholder_color", T.c("muted_foreground"))
		line_edit.add_theme_color_override("caret_color", T.c("foreground"))
