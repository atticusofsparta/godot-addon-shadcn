@tool
class_name ShadcnDatePicker
extends Button
## Date picker (shadcn Date Picker): a button that opens a calendar popover.
## Emits `date_selected(year, month, day)`.

signal date_selected(year: int, month: int, day: int)

const _MONTHS := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

@export var placeholder: String = "Pick a date"

var _popup: PopupPanel
var _cal: ShadcnCalendar


func _ready() -> void:
	add_to_group("shadcn_refresh")
	text = placeholder
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.x = 240
	pressed.connect(_open)
	_apply()


func _apply() -> void:
	var T := ShadcnTokens
	var pad := Vector4(12, 9, 12, 9)
	add_theme_stylebox_override("normal", ShadcnStyle.flat(T.c("background"), T.RADIUS_MD, T.c("input"), 1, pad))
	add_theme_stylebox_override("hover", ShadcnStyle.flat(T.c("accent"), T.RADIUS_MD, T.c("input"), 1, pad))
	add_theme_stylebox_override("pressed", get_theme_stylebox("hover"))
	add_theme_stylebox_override("focus", ShadcnStyle.ring(T.c("ring"), 2, T.RADIUS_MD))
	add_theme_color_override("font_color", T.c("muted_foreground") if text == placeholder else T.c("foreground"))
	add_theme_color_override("font_hover_color", T.c("accent_foreground"))
	add_theme_font_size_override("font_size", T.FONT_SM)


func refresh() -> void:
	_apply()


func _open() -> void:
	if _popup == null:
		_popup = PopupPanel.new()
		_popup.wrap_controls = true
		_cal = ShadcnCalendar.new()
		_cal.date_selected.connect(func(y, m, d):
			text = "%s %d, %d" % [_MONTHS[m - 1], d, y]
			_apply()
			date_selected.emit(y, m, d)
			_popup.hide())
		_popup.add_child(_cal)
		add_child(_popup)
	_popup.reset_size()
	_popup.popup(Rect2i(get_screen_position() + Vector2(0, size.y + 6), Vector2i(_popup.size)))
