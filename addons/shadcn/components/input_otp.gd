@tool
class_name ShadcnInputOTP
extends HBoxContainer
## One-time-password input (shadcn Input OTP): N single-char boxes with
## auto-advancing focus. Emits `completed(code)` when all filled.

signal changed(code: String)
signal completed(code: String)

@export var length: int = 6:
	set(v): length = maxi(1, v); _rebuild()

var _fields: Array[LineEdit] = []


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_rebuild()


func refresh() -> void:
	_rebuild()


func get_code() -> String:
	var s := ""
	for f in _fields:
		s += f.text
	return s


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	_fields.clear()
	if not is_inside_tree():
		return
	var T := ShadcnTokens
	add_theme_constant_override("separation", 6)
	for i in length:
		var f := LineEdit.new()
		f.max_length = 1
		f.custom_minimum_size = Vector2(40, 40)
		f.alignment = HORIZONTAL_ALIGNMENT_CENTER
		f.add_theme_stylebox_override("normal", ShadcnStyle.flat(T.c("background"), T.RADIUS_MD, T.c("input"), 1, Vector4(0, 8, 0, 8)))
		f.add_theme_stylebox_override("focus", ShadcnStyle.ring(T.c("ring"), 2, T.RADIUS_MD))
		f.add_theme_color_override("font_color", T.c("foreground"))
		f.add_theme_color_override("caret_color", T.c("foreground"))
		var idx := i
		f.text_changed.connect(func(t): _on_changed(idx, t))
		add_child(f)
		_fields.append(f)


func _on_changed(idx: int, t: String) -> void:
	if t.length() >= 1 and idx + 1 < _fields.size():
		_fields[idx + 1].grab_focus()
	var code := get_code()
	changed.emit(code)
	if code.length() == length:
		completed.emit(code)
