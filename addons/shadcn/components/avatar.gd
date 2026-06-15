@tool
class_name ShadcnAvatar
extends Control
## Circular avatar with image, falling back to initials on a muted circle.

@export var image: Texture2D:
	set(v): image = v; queue_redraw()
@export var fallback: String = "CN":
	set(v): fallback = v; queue_redraw()
@export var diameter: float = 40.0:
	set(v): diameter = v; custom_minimum_size = Vector2(v, v); queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(diameter, diameter)


func _ready() -> void:
	add_to_group("shadcn_refresh")


func refresh() -> void:
	queue_redraw()


func _draw() -> void:
	var T := ShadcnTokens
	var r := diameter / 2.0
	var center := Vector2(r, r)
	if image:
		# Clip the texture into a circle using a polygon mask.
		var pts := PackedVector2Array()
		var uvs := PackedVector2Array()
		var seg := 48
		for i in seg + 1:
			var a := TAU * i / seg
			var p := center + Vector2(cos(a), sin(a)) * r
			pts.append(p)
			uvs.append(p / diameter)
		draw_colored_polygon(pts, Color.WHITE, uvs, image)
	else:
		draw_circle(center, r, T.c("muted"))
		var f := ShadcnTokens.font()
		var fs := int(diameter * 0.4)
		var text := fallback.substr(0, 2).to_upper()
		var ts := f.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		draw_string(f, center - ts / 2.0 + Vector2(0, ts.y * 0.35), text,
			HORIZONTAL_ALIGNMENT_CENTER, -1, fs, T.c("muted_foreground"))
