@tool
class_name ShadcnCalendar
extends PanelContainer
## Month calendar with date selection (shadcn Calendar).
## Emits `date_selected(year, month, day)`.

signal date_selected(year: int, month: int, day: int)

const _WEEKDAYS := ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
const _MONTHS := ["January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"]

var _year: int = 2026
var _month: int = 1
var _sel := {}
var _today := {}
var _header: Label
var _grid: GridContainer


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_today = Time.get_date_dict_from_system()
	_year = _today.get("year", 2026)
	_month = _today.get("month", 1)
	_build()
	_rebuild()


func _build() -> void:
	if _grid:
		return
	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 12)
	add_child(margin)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	margin.add_child(vb)
	var head := HBoxContainer.new()
	vb.add_child(head)
	var prev := _nav_btn("‹"); prev.pressed.connect(func(): _shift(-1))
	head.add_child(prev)
	_header = Label.new()
	_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.add_theme_font_size_override("font_size", ShadcnTokens.FONT_SM)
	head.add_child(_header)
	var next := _nav_btn("›"); next.pressed.connect(func(): _shift(1))
	head.add_child(next)
	_grid = GridContainer.new()
	_grid.columns = 7
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	vb.add_child(_grid)


func _nav_btn(txt: String) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(28, 28)
	return b


func _shift(delta: int) -> void:
	_month += delta
	if _month < 1:
		_month = 12; _year -= 1
	elif _month > 12:
		_month = 1; _year += 1
	_rebuild()


func _days_in_month(y: int, m: int) -> int:
	var d: int = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
	if m == 2 and (y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)):
		d = 29
	return d


func _first_weekday(y: int, m: int) -> int:
	var unix := Time.get_unix_time_from_datetime_dict({"year": y, "month": m, "day": 1,
		"hour": 12, "minute": 0, "second": 0})
	return Time.get_datetime_dict_from_unix_time(unix).get("weekday", 0)


func _rebuild() -> void:
	if not _grid:
		return
	var T := ShadcnTokens
	_header.text = "%s %d" % [_MONTHS[_month - 1], _year]
	_header.add_theme_color_override("font_color", T.c("foreground"))
	for c in _grid.get_children():
		c.queue_free()
	for wd in _WEEKDAYS:
		var l := Label.new()
		l.text = wd
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(32, 24)
		l.add_theme_color_override("font_color", T.c("muted_foreground"))
		l.add_theme_font_size_override("font_size", T.FONT_XS)
		_grid.add_child(l)
	var pad := _first_weekday(_year, _month)
	for i in pad:
		_grid.add_child(Control.new())
	for day in range(1, _days_in_month(_year, _month) + 1):
		_grid.add_child(_day_btn(day))


func _day_btn(day: int) -> Button:
	var T := ShadcnTokens
	var b := Button.new()
	b.text = str(day)
	b.custom_minimum_size = Vector2(32, 32)
	var selected: bool = _sel.get("year") == _year and _sel.get("month") == _month and _sel.get("day") == day
	var today: bool = _today.get("year") == _year and _today.get("month") == _month and _today.get("day") == day
	var bg := T.c("primary") if selected else Color(0, 0, 0, 0)
	var border: Variant = T.c("border") if (today and not selected) else null
	b.add_theme_stylebox_override("normal", ShadcnStyle.flat(bg if bg.a > 0 else null, T.RADIUS_SM, border, 1 if border != null else 0, Vector4(0, 6, 0, 6)))
	b.add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("primary") if selected else T.c("accent"), T.RADIUS_SM, null, 0, Vector4(0, 6, 0, 6)))
	b.add_theme_stylebox_override("pressed", b.get_theme_stylebox("hover"))
	var fg := T.c("primary_foreground") if selected else T.c("foreground")
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", fg if selected else T.c("accent_foreground"))
	b.add_theme_font_size_override("font_size", T.FONT_SM)
	b.pressed.connect(func():
		_sel = {"year": _year, "month": _month, "day": day}
		date_selected.emit(_year, _month, day)
		_rebuild())
	return b


func refresh() -> void:
	var T := ShadcnTokens
	add_theme_stylebox_override("panel", ShadcnStyle.flat(T.c("card"), T.RADIUS, T.c("border"), 1))
	_rebuild()
