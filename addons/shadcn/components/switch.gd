@tool
class_name ShadcnSwitch
extends BaseButton
## Toggle switch (shadcn Switch). Godot only ships CheckButton; this is the
## pill-shaped, animated shadcn variant.

signal switched(on: bool)

const W := 36.0
const H := 20.0
const KNOB := 16.0

var _t: float = 0.0  # 0 = off, 1 = on


func _init() -> void:
	toggle_mode = true
	custom_minimum_size = Vector2(W, H)


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_t = 1.0 if button_pressed else 0.0
	toggled.connect(_on_toggled)
	queue_redraw()


func refresh() -> void:
	queue_redraw()


func _on_toggled(on: bool) -> void:
	switched.emit(on)
	var tw := create_tween()
	tw.tween_method(func(v): _t = v; queue_redraw(), _t, 1.0 if on else 0.0, 0.15) \
		.set_trans(Tween.TRANS_CUBIC)


func _draw() -> void:
	var T := ShadcnTokens
	var track_off := T.c("input") if not T.dark else T.c("secondary")
	var track := track_off.lerp(T.c("primary"), _t)
	var track_rect := Rect2(0, (size.y - H) / 2.0, W, H)
	draw_style_box(ShadcnStyle.flat(track, int(H / 2.0)), track_rect)
	var pad := (H - KNOB) / 2.0
	var x: float = lerp(pad, W - KNOB - pad, _t)
	var knob_color := T.c("background") if T.dark else T.c("primary_foreground")
	draw_circle(Vector2(track_rect.position.x + x + KNOB / 2.0, track_rect.get_center().y), KNOB / 2.0, knob_color)
	if has_focus():
		draw_style_box(ShadcnStyle.ring(T.c("ring"), 2, int(H / 2.0)), track_rect.grow(2))
