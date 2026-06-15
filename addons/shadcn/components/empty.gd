@tool
class_name ShadcnEmpty
extends VBoxContainer
## Empty-state placeholder (shadcn Empty): centered icon + title + description,
## with an `actions` row you can add buttons to.

@export var icon_text: String = "📭":
	set(v): icon_text = v; _refresh()
@export var title: String = "No results":
	set(v): title = v; _refresh()
@export_multiline var description: String = "Try adjusting your filters.":
	set(v): description = v; _refresh()

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
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)
	_icon = Label.new(); _icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon.add_theme_font_size_override("font_size", 32)
	_title = Label.new(); _title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 16)
	_desc = Label.new(); _desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actions = HBoxContainer.new(); actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 8)
	for nd in [_icon, _title, _desc, actions]:
		add_child(nd)
	_refresh()


func _refresh() -> void:
	if not _title:
		return
	_icon.text = icon_text
	_title.text = title
	_desc.text = description


func refresh() -> void:
	if not _title:
		return
	var T := ShadcnTokens
	_title.add_theme_color_override("font_color", T.c("foreground"))
	_desc.add_theme_color_override("font_color", T.c("muted_foreground"))
