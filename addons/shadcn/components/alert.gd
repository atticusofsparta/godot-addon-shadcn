@tool
class_name ShadcnAlert
extends PanelContainer
## Callout box with a title and body (shadcn Alert). Builds its own layout.

enum Variant { DEFAULT, DESTRUCTIVE }

@export var variant: Variant = Variant.DEFAULT:
	set(v): variant = v; _apply()
@export var title: String = "Heads up!":
	set(v): title = v; _refresh()
@export_multiline var description: String = "You can add components to your app.":
	set(v): description = v; _refresh()

var _title_label: Label
var _desc_label: Label


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	_apply()


func refresh() -> void:
	_apply()


func _build() -> void:
	if _title_label:
		return
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	vbox.add_child(_title_label)
	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	vbox.add_child(_desc_label)
	_refresh()


func _refresh() -> void:
	if _title_label:
		_title_label.text = title
		_desc_label.text = description


func _apply() -> void:
	if not _title_label:
		return
	var T := ShadcnTokens
	var fg := T.c("destructive") if variant == Variant.DESTRUCTIVE else T.c("card_foreground")
	var border := T.c("destructive") if variant == Variant.DESTRUCTIVE else T.c("border")
	add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("card"), T.RADIUS, border, 1, Vector4(16, 12, 16, 12)))
	_title_label.add_theme_color_override("font_color", fg)
	_desc_label.add_theme_color_override("font_color", fg if variant == Variant.DESTRUCTIVE else T.c("muted_foreground"))
