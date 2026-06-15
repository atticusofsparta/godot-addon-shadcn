@tool
class_name ShadcnCardTitle
extends Label
## Card heading. Place inside a ShadcnCard's VBoxContainer.

func _ready() -> void:
	add_to_group("shadcn_refresh")
	refresh()


func refresh() -> void:
	add_theme_color_override("font_color", ShadcnTokens.c("card_foreground"))
	add_theme_font_size_override("font_size", 16)
