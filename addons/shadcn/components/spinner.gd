@tool
class_name ShadcnSpinner
extends Control
## Indeterminate loading spinner (shadcn Spinner): a rotating arc.

@export var diameter: float = 20.0:
	set(v): diameter = v; custom_minimum_size = Vector2(v, v); queue_redraw()
@export var line_width: float = 2.0:
	set(v): line_width = v; queue_redraw()
@export var speed: float = 4.0

var _angle: float = 0.0


func _init() -> void:
	custom_minimum_size = Vector2(diameter, diameter)


func _ready() -> void:
	add_to_group("shadcn_refresh")


func refresh() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_angle = fmod(_angle + delta * speed, TAU)
	queue_redraw()


func _draw() -> void:
	var T := ShadcnTokens
	var center := size / 2.0
	var r := diameter / 2.0 - line_width
	# faint full track + bright leading arc
	draw_arc(center, r, 0, TAU, 48, Color(T.c("muted_foreground"), 0.25), line_width, true)
	draw_arc(center, r, _angle, _angle + PI * 0.6, 24, T.c("foreground"), line_width, true)
