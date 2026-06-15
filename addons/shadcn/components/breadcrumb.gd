@tool
class_name ShadcnBreadcrumb
extends HBoxContainer
## Navigation trail (shadcn Breadcrumb). Builds clickable crumbs from `items`,
## the last one rendered as the current page.

signal crumb_pressed(index: int)

@export var items: PackedStringArray = ["Home", "Components", "Breadcrumb"]:
	set(v): items = v; if is_inside_tree(): _rebuild()
@export var separator: String = "/":
	set(v): separator = v; if is_inside_tree(): _rebuild()


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_rebuild()


func refresh() -> void:
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var T := ShadcnTokens
	add_theme_constant_override("separation", 8)
	for i in items.size():
		var is_last := i == items.size() - 1
		var crumb := Button.new() if not is_last else Label.new()
		if crumb is Button:
			crumb.flat = true
			crumb.text = items[i]
			crumb.add_theme_color_override("font_color", T.c("muted_foreground"))
			crumb.add_theme_color_override("font_hover_color", T.c("foreground"))
			crumb.add_theme_stylebox_override("normal", ShadcnStyle.flat(null, 0))
			crumb.add_theme_stylebox_override("hover", ShadcnStyle.flat(null, 0))
			var idx := i
			crumb.pressed.connect(func(): crumb_pressed.emit(idx))
		else:
			crumb.text = items[i]
			crumb.add_theme_color_override("font_color", T.c("foreground"))
		add_child(crumb)
		if not is_last:
			var sep := Label.new()
			sep.text = separator
			sep.add_theme_color_override("font_color", T.c("muted_foreground"))
			add_child(sep)
