@tool
class_name ShadcnSkeleton
extends Control
## Animated loading placeholder (shadcn Skeleton): a pulsing rounded block.

@export var radius: int = ShadcnTokens.RADIUS_SM:
	set(v): radius = v; queue_redraw()

var _phase: float = 0.0


func _ready() -> void:
	add_to_group("shadcn_refresh")


func refresh() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta * 1.5, TAU)
	queue_redraw()


func _draw() -> void:
	var T := ShadcnTokens
	var base := T.c("muted")
	var alpha: float = 0.5 + 0.25 * (sin(_phase) * 0.5 + 0.5)
	var col := Color(base.r, base.g, base.b, alpha)
	draw_style_box(ShadcnStyle.flat(col, radius), Rect2(Vector2.ZERO, size))
