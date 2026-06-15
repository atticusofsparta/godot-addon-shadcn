class_name ShadcnToast
extends CanvasLayer
## Toast / notification stack (shadcn Sonner). Two ways to use it:
##   1. Add a ShadcnToast node to your scene (or as an autoload) and call
##      `$ShadcnToast.push("Saved", "Your changes were saved.")`.
##   2. One-shot from anywhere: `ShadcnToast.notify(self, "Saved", "...")`.

enum Variant { DEFAULT, DESTRUCTIVE }

const DURATION := 4.0
const GAP := 8

var _stack: VBoxContainer


func _ready() -> void:
	layer = 128
	_stack = VBoxContainer.new()
	_stack.add_theme_constant_override("separation", GAP)
	_stack.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_stack.alignment = BoxContainer.ALIGNMENT_END
	_stack.offset_left = -380
	_stack.offset_top = -320
	_stack.offset_right = -16
	_stack.offset_bottom = -16
	_stack.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_stack.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(_stack)


## Show a toast on this instance.
func push(title: String, description: String = "", variant: Variant = Variant.DEFAULT) -> void:
	var T := ShadcnTokens
	var panel := PanelContainer.new()
	var border := T.c("destructive") if variant == Variant.DESTRUCTIVE else T.c("border")
	panel.add_theme_stylebox_override("panel",
		ShadcnStyle.flat(T.c("popover"), T.RADIUS, border, 1, Vector4(16, 12, 16, 12)))
	panel.modulate.a = 0.0

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_color_override("font_color",
		T.c("destructive") if variant == Variant.DESTRUCTIVE else T.c("popover_foreground"))
	title_label.add_theme_font_size_override("font_size", T.FONT_SM)
	vbox.add_child(title_label)
	if description != "":
		var desc := Label.new()
		desc.text = description
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_color_override("font_color", T.c("muted_foreground"))
		desc.add_theme_font_size_override("font_size", T.FONT_XS)
		vbox.add_child(desc)

	_stack.add_child(panel)
	var tw := create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)
	tw.tween_interval(DURATION)
	tw.tween_property(panel, "modulate:a", 0.0, 0.3)
	tw.tween_callback(panel.queue_free)


## One-shot helper: spawns a temporary ShadcnToast on the scene tree's root.
static func notify(ctx: Node, title: String, description: String = "",
		variant: Variant = Variant.DEFAULT) -> void:
	var tree := ctx.get_tree()
	var root := tree.root
	var inst: ShadcnToast = root.get_node_or_null("__ShadcnToast__")
	if inst == null:
		inst = ShadcnToast.new()
		inst.name = "__ShadcnToast__"
		root.add_child.call_deferred(inst)
		await inst.ready
	inst.push(title, description, variant)
