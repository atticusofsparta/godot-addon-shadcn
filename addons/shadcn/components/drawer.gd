@tool
class_name ShadcnDrawer
extends ShadcnSheet
## Bottom drawer (shadcn Drawer): a Sheet anchored to the bottom edge.

func _ready() -> void:
	side = SheetSide.BOTTOM
	if panel_size == 380.0:
		panel_size = 280.0
	super._ready()
