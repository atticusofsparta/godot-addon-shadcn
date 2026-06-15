@tool
class_name ShadcnSidebar
extends PanelContainer
## App sidebar (shadcn Sidebar): a bordered vertical surface with a `content`
## VBox. Toggle `collapsed` to animate its width.

@export var expanded_width: float = 240.0:
	set(v): expanded_width = v; _resize()
@export var collapsed_width: float = 0.0:
	set(v): collapsed_width = v; _resize()
@export var collapsed: bool = false:
	set(v): collapsed = v; _animate()

var content: VBoxContainer


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()
	_resize()


func _build() -> void:
	if content:
		return
	clip_contents = true
	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 12)
	add_child(margin)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)


func toggle() -> void:
	collapsed = not collapsed


func _resize() -> void:
	custom_minimum_size.x = collapsed_width if collapsed else expanded_width


func _animate() -> void:
	if not is_inside_tree():
		_resize(); return
	var target := collapsed_width if collapsed else expanded_width
	create_tween().tween_property(self, "custom_minimum_size:x", target, 0.2) \
		.set_trans(Tween.TRANS_CUBIC)


func refresh() -> void:
	var T := ShadcnTokens
	var sb := StyleBoxFlat.new()
	sb.bg_color = T.c("sidebar") if T.palette().has("sidebar") else T.c("card")
	sb.border_color = T.c("border")
	sb.border_width_right = 1
	add_theme_stylebox_override("panel", sb)
