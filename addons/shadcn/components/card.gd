@tool
class_name ShadcnCard
extends PanelContainer
## Bordered surface container (shadcn Card). Pair with ShadcnCardTitle /
## ShadcnCardDescription labels inside a VBoxContainer for the full pattern.

@export var elevated: bool = false:
	set(v): elevated = v; _apply()


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_apply()


func refresh() -> void:
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var sb := ShadcnStyle.flat(T.c("card"), T.RADIUS, T.c("border"), 1, Vector4(24, 24, 24, 24))
	if elevated:
		sb.shadow_color = Color(0, 0, 0, 0.10 if not T.dark else 0.35)
		sb.shadow_size = 8
		sb.shadow_offset = Vector2(0, 2)
	add_theme_stylebox_override("panel", sb)
