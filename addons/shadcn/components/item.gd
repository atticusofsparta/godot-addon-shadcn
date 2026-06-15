@tool
class_name ShadcnItem
extends PanelContainer
## List item with media, title, description and a trailing `actions` slot
## (shadcn Item).

@export var icon_text: String = "":
	set(v): icon_text = v; _refresh()
@export var title: String = "Title":
	set(v): title = v; _refresh()
@export var description: String = "Description":
	set(v): description = v; _refresh()
@export var bordered: bool = true:
	set(v): bordered = v; refresh()

var actions: HBoxContainer
var _icon: Label
var _title: Label
var _desc: Label


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()


func _build() -> void:
	if _title:
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)
	_icon = Label.new()
	_icon.add_theme_font_size_override("font_size", 20)
	_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_icon)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	_title = Label.new(); _title.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	_desc = Label.new(); _desc.add_theme_font_size_override("font_size", ShadcnTokens.FONT_XS)
	col.add_child(_title); col.add_child(_desc)
	actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	actions.alignment = BoxContainer.ALIGNMENT_END
	row.add_child(actions)
	_refresh()


func _refresh() -> void:
	if not _title:
		return
	_icon.text = icon_text
	_icon.visible = icon_text != ""
	_title.text = title
	_desc.text = description
	_desc.visible = description != ""


func refresh() -> void:
	if not _title:
		return
	var T := ShadcnTokens
	var border: Variant = T.c("border") if bordered else null
	add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("card"), T.RADIUS_MD, border, 1 if bordered else 0, Vector4(14, 12, 14, 12)))
	_icon.add_theme_color_override("font_color", T.c("foreground"))
	_title.add_theme_color_override("font_color", T.c("card_foreground"))
	_desc.add_theme_color_override("font_color", T.c("muted_foreground"))
