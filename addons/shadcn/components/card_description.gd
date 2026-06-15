@tool
class_name ShadcnCardDescription
extends Label
## Muted secondary text for a card. Place inside a ShadcnCard's VBoxContainer.

func _ready() -> void:
	add_to_group("shadcn_refresh")
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	refresh()


func refresh() -> void:
	add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
