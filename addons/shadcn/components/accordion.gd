@tool
class_name ShadcnAccordionItem
extends VBoxContainer
## Collapsible titled section (shadcn Accordion item). Self-contained text
## accordion: set a title and body, click the header to expand/collapse.

@export var title: String = "Is it accessible?":
	set(v): title = v; _refresh()
@export_multiline var body: String = "Yes. It adheres to sensible defaults.":
	set(v): body = v; _refresh()
@export var expanded: bool = false:
	set(v): expanded = v; _refresh()

var _header: Button
var _content: PanelContainer
var _body_label: Label


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	_refresh()


func refresh() -> void:
	_refresh()


func _build() -> void:
	if _header:
		return
	add_theme_constant_override("separation", 0)
	_header = Button.new()
	_header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_header.flat = true
	_header.pressed.connect(func(): expanded = not expanded)
	add_child(_header)

	_content = PanelContainer.new()
	_body_label = Label.new()
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(_body_label)
	add_child(_content)


func _refresh() -> void:
	if not _header:
		return
	var T := ShadcnTokens
	_header.text = ("▼  " if expanded else "▶  ") + title
	_header.add_theme_color_override("font_color", T.c("foreground"))
	_header.add_theme_color_override("font_hover_color", T.c("foreground"))
	_header.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, 0, null, 0, Vector4(0, 12, 0, 12)))
	_header.add_theme_stylebox_override("hover", ShadcnStyle.flat(null, 0, null, 0, Vector4(0, 12, 0, 12)))
	_body_label.text = body
	_body_label.add_theme_color_override("font_color", T.c("muted_foreground"))
	_content.add_theme_stylebox_override("panel", ShadcnStyle.flat(null, 0, null, 0, Vector4(0, 0, 0, 12)))
	_content.visible = expanded
	# bottom border to separate items
	var sep := HSeparator.new() if get_child_count() < 3 else null
	if sep:
		sep.add_theme_stylebox_override("separator", ShadcnStyle.flat(T.c("border"), 0))
		add_child(sep)
