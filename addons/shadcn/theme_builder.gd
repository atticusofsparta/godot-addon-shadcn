@tool
class_name ShadcnTheme
extends RefCounted
## Builds a complete Godot Theme from a shadcn palette, at runtime. This is the
## single source of truth for the look — the shipped themes/*.tres files are
## exported from here (see tools/export_themes.gd).
##
## Usage:
##   var theme := ShadcnTheme.build("zinc", "blue", true)  # base, accent, dark
##   $Root.theme = theme

# Literals (not ShadcnTokens.*) to avoid a class-body dependency cycle:
# ShadcnTokens references ShadcnTheme, so ShadcnTheme must not need ShadcnTokens
# resolved at parse time. Values mirror ShadcnTokens.RADIUS* / FONT_SM.
const R := 10
const R_MD := 8
const R_SM := 6
const FS := 14


## Resolve a base color + optional accent override for the given mode.
static func resolve(base := "neutral", accent := "", dark := true) -> Dictionary:
	var mode := "dark" if dark else "light"
	if not ShadcnPalettes.BASE.has(base):
		base = "neutral"
	var p: Dictionary = ShadcnPalettes.BASE[base][mode].duplicate()
	if accent != "" and ShadcnPalettes.ACCENT.has(accent):
		for k in ShadcnPalettes.ACCENT[accent][mode]:
			p[k] = ShadcnPalettes.ACCENT[accent][mode][k]
	return p


static func _flat(bg, radius := R_MD, border = null, bw := 0, pad := Vector4()) -> StyleBoxFlat:
	return ShadcnStyle.flat(bg, radius, border, bw, pad)


static func _alpha(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)


## A circular slider thumb (shadcn: bg-background, border-primary) — visible in
## both light and dark. Drawn at 2x and downscaled for cheap anti-aliasing.
static func _make_grabber(fill: Color, ring: Color, d := 18) -> ImageTexture:
	var s := d * 2
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Vector2(s / 2.0, s / 2.0)
	var r := s / 2.0 - 1.0
	var ring_w := 4.0
	for y in s:
		for x in s:
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(c)
			if dist <= r - ring_w:
				img.set_pixel(x, y, fill)
			elif dist <= r:
				img.set_pixel(x, y, ring)
	img.resize(d, d, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)


# --- Icon helpers (SDF-based, anti-aliased) for CheckBox / CheckButton ----

static func _sd_round(p: Vector2, half: Vector2, r: float) -> float:
	var q := p.abs() - (half - Vector2(r, r))
	return Vector2(maxf(q.x, 0), maxf(q.y, 0)).length() + minf(maxf(q.x, q.y), 0) - r


static func _dist_seg(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0, 1)
	return (p - (a + ab * t)).length()


static func _blend(img: Image, x: int, y: int, col: Color, aa: float) -> void:
	var cov := clampf(aa, 0, 1) * col.a
	if cov <= 0:
		return
	var cur := img.get_pixel(x, y)
	var out_a := cov + cur.a * (1.0 - cov)
	if out_a <= 0:
		return
	var r := (col.r * cov + cur.r * cur.a * (1.0 - cov)) / out_a
	var g := (col.g * cov + cur.g * cur.a * (1.0 - cov)) / out_a
	var b := (col.b * cov + cur.b * cur.a * (1.0 - cov)) / out_a
	img.set_pixel(x, y, Color(r, g, b, out_a))


static func _icon_check(checked: bool, fill: Color, border: Color, mark: Color) -> ImageTexture:
	var s := 18
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var half := Vector2(s / 2.0 - 1.0, s / 2.0 - 1.0)
	for y in s:
		for x in s:
			var p := Vector2(x + 0.5 - s / 2.0, y + 0.5 - s / 2.0)
			var sd := _sd_round(p, half, 4.0)
			if checked:
				_blend(img, x, y, fill, 0.5 - sd)
			else:
				_blend(img, x, y, border, 0.5 - absf(sd + 0.75) + 0.75)
	if checked:
		var a := Vector2(s * 0.27, s * 0.52)
		var b := Vector2(s * 0.43, s * 0.68)
		var c := Vector2(s * 0.74, s * 0.30)
		for y in s:
			for x in s:
				var p := Vector2(x + 0.5, y + 0.5)
				var dd := minf(_dist_seg(p, a, b), _dist_seg(p, b, c))
				_blend(img, x, y, mark, 1.3 - dd)
	return ImageTexture.create_from_image(img)


static func _icon_radio(checked: bool, fill: Color, border: Color) -> ImageTexture:
	var s := 18
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var ctr := Vector2(s / 2.0, s / 2.0)
	var r := s / 2.0 - 1.0
	for y in s:
		for x in s:
			var d := (Vector2(x + 0.5, y + 0.5) - ctr).length()
			_blend(img, x, y, fill if checked else border, 0.75 - absf(d - (r - 0.75)))
			if checked and d < r * 0.42:
				_blend(img, x, y, fill, r * 0.42 - d)
	return ImageTexture.create_from_image(img)


static func _icon_switch(on: bool, primary: Color, knob_on: Color, off_track: Color, knob_off: Color) -> ImageTexture:
	var w := 36
	var h := 20
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var half := Vector2(w / 2.0 - 1.0, h / 2.0 - 1.0)
	var track := primary if on else off_track
	for y in h:
		for x in w:
			var p := Vector2(x + 0.5 - w / 2.0, y + 0.5 - h / 2.0)
			_blend(img, x, y, track, 0.5 - _sd_round(p, half, h / 2.0 - 1.0))
	var kr := h / 2.0 - 3.0
	var kc := Vector2(w - h / 2.0 if on else h / 2.0, h / 2.0)
	var knob := knob_on if on else knob_off
	for y in h:
		for x in w:
			var d := (Vector2(x + 0.5, y + 0.5) - kc).length()
			_blend(img, x, y, knob, kr - d + 0.5)
	return ImageTexture.create_from_image(img)


static func build(base := "neutral", accent := "", dark := true) -> Theme:
	var p := resolve(base, accent, dark)
	return build_from_palette(p, dark)


static func build_from_palette(p: Dictionary, dark := true) -> Theme:
	var t := Theme.new()
	t.default_font_size = FS

	var primary: Color = p["primary"]
	var bg: Color = p["background"]
	var fg: Color = p["foreground"]
	var ring: Color = p["ring"]
	var primary_hover := primary.lerp(bg, 0.10)
	var btn_pad := Vector4(16, 9, 16, 9)

	# ---- Button (primary) ----
	t.set_stylebox("normal", "Button", _flat(primary, R_MD, null, 0, btn_pad))
	t.set_stylebox("hover", "Button", _flat(primary_hover, R_MD, null, 0, btn_pad))
	t.set_stylebox("pressed", "Button", _flat(primary_hover, R_MD, null, 0, btn_pad))
	t.set_stylebox("disabled", "Button", _flat(primary, R_MD, null, 0, btn_pad))
	t.set_stylebox("focus", "Button", ShadcnStyle.ring(ring, 2, R_MD))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, "Button", p["primary_foreground"])
	t.set_color("font_disabled_color", "Button", _alpha(p["primary_foreground"], 0.5))
	t.set_color("icon_normal_color", "Button", p["primary_foreground"])
	t.set_color("icon_hover_color", "Button", p["primary_foreground"])
	t.set_constant("h_separation", "Button", 8)
	t.set_constant("outline_size", "Button", 0)

	# ---- LineEdit / TextEdit ----
	var field_pad := Vector4(12, 8, 12, 8)
	for ty in ["LineEdit", "TextEdit"]:
		t.set_stylebox("normal", ty, _flat(bg, R_MD, p["input"], 1, field_pad))
		t.set_stylebox("focus", ty, ShadcnStyle.ring(ring, 2, R_MD))
		t.set_stylebox("read_only", ty, _flat(p["muted"], R_MD, p["input"], 1, field_pad))
		t.set_color("font_color", ty, fg)
		t.set_color("font_placeholder_color", ty, p["muted_foreground"])
		t.set_color("font_selected_color", ty, p["selection_foreground"])
		t.set_color("caret_color", ty, fg)
		t.set_color("selection_color", ty, _alpha(p["selection"], 0.25))
	t.set_color("font_uneditable_color", "LineEdit", p["muted_foreground"])
	t.set_color("clear_button_color", "LineEdit", p["muted_foreground"])

	# ---- SpinBox ----
	t.set_color("up_icon_modulate", "SpinBox", p["muted_foreground"])
	t.set_color("down_icon_modulate", "SpinBox", p["muted_foreground"])

	# ---- OptionButton (Select) = outline ----
	var sel_pad := Vector4(12, 9, 12, 9)
	t.set_stylebox("normal", "OptionButton", _flat(bg, R_MD, p["input"], 1, sel_pad))
	t.set_stylebox("hover", "OptionButton", _flat(p["accent"], R_MD, p["input"], 1, sel_pad))
	t.set_stylebox("pressed", "OptionButton", _flat(p["accent"], R_MD, p["input"], 1, sel_pad))
	t.set_stylebox("focus", "OptionButton", ShadcnStyle.ring(ring, 2, R_MD))
	t.set_color("font_color", "OptionButton", fg)
	t.set_color("font_hover_color", "OptionButton", p["accent_foreground"])
	t.set_color("font_pressed_color", "OptionButton", p["accent_foreground"])
	t.set_color("font_focus_color", "OptionButton", fg)

	# ---- PopupMenu ----
	t.set_stylebox("panel", "PopupMenu", _flat(p["popover"], R_MD, p["border"], 1, Vector4(6, 6, 6, 6)))
	t.set_stylebox("hover", "PopupMenu", _flat(p["accent"], R_SM, null, 0, Vector4(8, 6, 8, 6)))
	var sep := _flat(p["border"], 0)
	t.set_stylebox("separator", "PopupMenu", sep)
	t.set_color("font_color", "PopupMenu", p["popover_foreground"])
	t.set_color("font_hover_color", "PopupMenu", p["accent_foreground"])
	t.set_color("font_accelerator_color", "PopupMenu", p["muted_foreground"])
	t.set_color("font_disabled_color", "PopupMenu", _alpha(p["muted_foreground"], 0.5))
	t.set_color("font_separator_color", "PopupMenu", p["muted_foreground"])
	t.set_constant("v_separation", "PopupMenu", 4)
	t.set_constant("item_start_padding", "PopupMenu", 8)
	t.set_constant("item_end_padding", "PopupMenu", 8)

	# ---- PopupPanel / Tooltip ----
	t.set_stylebox("panel", "PopupPanel", _flat(p["popover"], R_MD, p["border"], 1, Vector4(12, 12, 12, 12)))
	t.set_stylebox("panel", "TooltipPanel", _flat(primary, R_SM, null, 0, Vector4(10, 6, 10, 6)))
	t.set_color("font_color", "TooltipLabel", p["primary_foreground"])
	t.set_font_size("font_size", "TooltipLabel", 12)

	# ---- Card / Panel ----
	t.set_stylebox("panel", "PanelContainer", _flat(p["card"], R, p["border"], 1, Vector4(24, 24, 24, 24)))
	t.set_stylebox("panel", "Panel", _flat(p["card"], R, p["border"], 1))

	# ---- Tabs ----
	var tab_pad := Vector4(12, 6, 12, 6)
	for ty in ["TabContainer", "TabBar"]:
		t.set_stylebox("tab_selected", ty, _flat(bg, R_SM, null, 0, tab_pad))
		t.set_stylebox("tab_unselected", ty, _flat(null, 0, null, 0, tab_pad))
		t.set_stylebox("tab_hovered", ty, _flat(p["accent"], R_SM, null, 0, tab_pad))
		t.set_color("font_selected_color", ty, fg)
		t.set_color("font_unselected_color", ty, p["muted_foreground"])
		t.set_color("font_hovered_color", ty, fg)
	t.set_stylebox("panel", "TabContainer", _flat(bg, R_MD, p["border"], 1, Vector4(16, 16, 16, 16)))
	t.set_stylebox("tabbar_background", "TabContainer", _flat(p["muted"], R_MD, null, 0, Vector4(4, 4, 4, 4)))

	# ---- ProgressBar ----
	t.set_stylebox("background", "ProgressBar", _flat(p["muted"], 999))
	t.set_stylebox("fill", "ProgressBar", _flat(primary, 999))
	t.set_color("font_color", "ProgressBar", fg)

	# ---- Sliders ----
	# Track styleboxes need a content margin or they render 0px thick (invisible).
	# HSlider grows vertically; VSlider horizontally. The thumb is an *icon*, not
	# a stylebox, so we generate a circular grabber that contrasts in both modes.
	var h_pad := Vector4(0, 3, 0, 3)
	var v_pad := Vector4(3, 0, 3, 0)
	t.set_stylebox("slider", "HSlider", _flat(p["muted"], 999, null, 0, h_pad))
	t.set_stylebox("grabber_area", "HSlider", _flat(primary, 999, null, 0, h_pad))
	t.set_stylebox("grabber_area_highlight", "HSlider", _flat(primary, 999, null, 0, h_pad))
	t.set_stylebox("slider", "VSlider", _flat(p["muted"], 999, null, 0, v_pad))
	t.set_stylebox("grabber_area", "VSlider", _flat(primary, 999, null, 0, v_pad))
	t.set_stylebox("grabber_area_highlight", "VSlider", _flat(primary, 999, null, 0, v_pad))
	var grabber := _make_grabber(bg, primary)
	for ty in ["HSlider", "VSlider"]:
		t.set_icon("grabber", ty, grabber)
		t.set_icon("grabber_highlight", ty, grabber)
		t.set_icon("grabber_disabled", ty, grabber)

	# ---- ScrollBars ----
	var muted_fg: Color = p["muted_foreground"]
	var grab := muted_fg.lerp(bg, 0.4)
	for ty in ["HScrollBar", "VScrollBar"]:
		t.set_stylebox("scroll", ty, _flat(p["muted"], 999))
		t.set_stylebox("grabber", ty, _flat(grab, 999))
		t.set_stylebox("grabber_highlight", ty, _flat(p["muted_foreground"], 999))
		t.set_stylebox("grabber_pressed", ty, _flat(p["muted_foreground"], 999))

	# ---- ItemList / Tree ----
	for ty in ["ItemList", "Tree"]:
		t.set_stylebox("panel", ty, _flat(bg, R_MD, p["border"], 1, Vector4(4, 4, 4, 4)))
		t.set_stylebox("focus", ty, ShadcnStyle.ring(ring, 2, R_MD))
		t.set_stylebox("selected", ty, _flat(p["accent"], R_SM))
		t.set_stylebox("selected_focus", ty, _flat(p["accent"], R_SM))
		t.set_stylebox("hovered", ty, _flat(p["muted"], R_SM))
		t.set_color("font_color", ty, fg)
		t.set_color("font_selected_color", ty, p["accent_foreground"])
		t.set_color("guide_color", ty, p["border"])
	t.set_stylebox("title_button_normal", "Tree", _flat(p["muted"], 0))
	t.set_color("title_button_color", "Tree", fg)

	# ---- CheckBox / CheckButton ----
	for ty in ["CheckBox", "CheckButton"]:
		t.set_color("font_color", ty, fg)
		t.set_color("font_hover_color", ty, fg)
		t.set_color("font_pressed_color", ty, fg)
		t.set_color("font_disabled_color", ty, _alpha(p["muted_foreground"], 0.5))
		t.set_color("font_hover_pressed_color", ty, fg)
		# These are toggles: a *checked* control that's hovered uses
		# `hover_pressed`. All states must share the same margins or the label
		# shifts/clips on hover. Include every draw state explicitly.
		for st in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			t.set_stylebox(st, ty, _flat(null, 0, null, 0, Vector4(0, 4, 0, 4)))
		t.set_stylebox("focus", ty, _flat(null, 0))
		t.set_constant("h_separation", ty, 8)
		t.set_constant("check_v_offset", ty, 0)

	# Accent-aware check / radio / switch icons (the built-in ones ignore the
	# palette, so a checked box/toggle wouldn't pick up primary/accent).
	var pfg: Color = p["primary_foreground"]
	var off_track := muted_fg.lerp(bg, 0.5)
	t.set_icon("checked", "CheckBox", _icon_check(true, primary, p["input"], pfg))
	t.set_icon("unchecked", "CheckBox", _icon_check(false, primary, p["input"], pfg))
	t.set_icon("checked_disabled", "CheckBox", _icon_check(true, _alpha(primary, 0.5), p["input"], pfg))
	t.set_icon("unchecked_disabled", "CheckBox", _icon_check(false, primary, _alpha(p["input"], 0.5), pfg))
	t.set_icon("radio_checked", "CheckBox", _icon_radio(true, primary, p["input"]))
	t.set_icon("radio_unchecked", "CheckBox", _icon_radio(false, primary, p["input"]))
	t.set_icon("radio_checked_disabled", "CheckBox", _icon_radio(true, _alpha(primary, 0.5), p["input"]))
	t.set_icon("radio_unchecked_disabled", "CheckBox", _icon_radio(false, primary, _alpha(p["input"], 0.5)))
	t.set_icon("checked", "CheckButton", _icon_switch(true, primary, pfg, off_track, bg))
	t.set_icon("unchecked", "CheckButton", _icon_switch(false, primary, pfg, off_track, bg))
	t.set_icon("checked_disabled", "CheckButton", _icon_switch(true, _alpha(primary, 0.5), pfg, off_track, bg))
	t.set_icon("unchecked_disabled", "CheckButton", _icon_switch(false, primary, pfg, _alpha(off_track, 0.5), bg))

	# ---- LinkButton ----
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		t.set_color(c, "LinkButton", primary)

	# ---- Label ----
	t.set_color("font_color", "Label", fg)
	t.set_font_size("font_size", "Label", FS)

	# ---- Separators ----
	for ty in ["HSeparator", "VSeparator"]:
		t.set_stylebox("separator", ty, _flat(p["border"], 0))
		t.set_constant("separation", ty, 1)

	# ---- ScrollContainer ----
	t.set_stylebox("panel", "ScrollContainer", _flat(null, 0))

	# ---- MenuBar ----
	t.set_color("font_color", "MenuBar", fg)
	t.set_color("font_hover_color", "MenuBar", p["accent_foreground"])
	t.set_stylebox("normal", "MenuBar", _flat(null, 0, null, 0, Vector4(10, 6, 10, 6)))
	t.set_stylebox("hover", "MenuBar", _flat(p["accent"], R_SM, null, 0, Vector4(10, 6, 10, 6)))

	return t
