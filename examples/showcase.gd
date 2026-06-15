extends Control
## Gallery of every shadcn-godot component plus the stock controls the theme
## restyles, with a live color-scheme selector (base color + accent + light/dark).

var _bg: ColorRect
var _content: VBoxContainer
var _scheme_base := "neutral"
var _scheme_accent := ""
var _scheme_dark := true


func _ready() -> void:
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var root_v := VBoxContainer.new()
	root_v.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_v.add_theme_constant_override("separation", 0)
	add_child(root_v)

	_build_toolbar(root_v)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_v.add_child(scroll)

	var pad := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + m, 40)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 24)
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(_content)

	_apply_scheme()


# ------------------------------------------------------------------- toolbar

func _build_toolbar(parent: Node) -> void:
	var bar := PanelContainer.new()
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	for m in ["left", "right"]:
		inner.add_theme_constant_override("margin_" + m, 24)
	bar.add_child(inner)

	var title := Label.new()
	title.text = "shadcn for Godot"
	title.add_theme_font_size_override("font_size", 20)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(title)

	inner.add_child(_label("Base"))
	var base_opt := OptionButton.new()
	for i in ShadcnPalettes.BASE_NAMES.size():
		base_opt.add_item(String(ShadcnPalettes.BASE_NAMES[i]).capitalize())
	base_opt.selected = 0
	base_opt.item_selected.connect(func(i):
		_scheme_base = ShadcnPalettes.BASE_NAMES[i]
		_apply_scheme())
	inner.add_child(base_opt)

	inner.add_child(_label("Accent"))
	var accent_opt := OptionButton.new()
	accent_opt.add_item("Default")
	for i in ShadcnPalettes.ACCENT_NAMES.size():
		accent_opt.add_item(String(ShadcnPalettes.ACCENT_NAMES[i]).capitalize())
	accent_opt.selected = 0
	accent_opt.item_selected.connect(func(i):
		_scheme_accent = "" if i == 0 else ShadcnPalettes.ACCENT_NAMES[i - 1]
		_apply_scheme())
	inner.add_child(accent_opt)

	inner.add_child(_label("Dark"))
	var mode := ShadcnSwitch.new()
	mode.button_pressed = true
	mode.switched.connect(func(on):
		_scheme_dark = on
		_apply_scheme())
	inner.add_child(mode)

	parent.add_child(bar)
	# Style the toolbar itself (it's outside the scrolled content).
	bar.add_theme_stylebox_override("panel", ShadcnStyle.flat(
		ShadcnTokens.c("card"), 0, ShadcnTokens.c("border"), 1, Vector4(24, 12, 24, 12)))
	_toolbar_panel = bar


var _toolbar_panel: PanelContainer
var _toolbar_labels: Array[Label] = []


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	_toolbar_labels.append(l)
	return l


# ------------------------------------------------------- scheme application

func _apply_scheme() -> void:
	ShadcnTokens.apply(self, _scheme_base, _scheme_accent, _scheme_dark)
	_bg.color = ShadcnTokens.c("background")
	if _toolbar_panel:
		_toolbar_panel.add_theme_stylebox_override("panel", ShadcnStyle.flat(
			ShadcnTokens.c("card"), 0, ShadcnTokens.c("border"), 1, Vector4(24, 12, 24, 12)))
	for l in _toolbar_labels:
		l.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	_rebuild_content()


func _rebuild_content() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(columns)
	var left := _column(columns)
	var right := _column(columns)

	_buttons(left)
	_button_sizes(left)
	_badges(left)
	_chart_area(left)        # area + gradient + smooth
	_chart_line(left)        # line + dots
	_chart_line_step(left)   # line + step
	_chart_radar(left)
	_chart_pie(left)
	_inputs(left)
	_selects(left)
	_toggles(left)
	_radios(left)
	_kbd(left)
	_button_group(left)
	_toggle_group(left)
	_input_group(left)
	_input_otp(left)
	_combobox(left)
	_field(left)

	_card(right)
	_chart_bar(right)            # grouped vertical
	_chart_bar_stacked(right)
	_chart_bar_horizontal(right)
	_chart_radial(right)
	_chart_donut(right)
	_alerts(right)
	_tabs(right)
	_table(right)
	_list(right)
	_media(right)
	_progress(right)
	_accordion(right)
	_breadcrumb(right)
	_misc(right)
	_toast(right)
	_pagination(right)
	_item(right)
	_empty(right)
	_calendar(right)
	_date_picker(right)
	_command(right)
	_carousel(right)
	_data_table(right)
	_overlays(right)


# ---------------------------------------------------------------- sections

func _buttons(p: Node) -> void:
	_section(p, "Buttons — variants")
	var row := _row(p)
	for v in ShadcnButton.Variant.values():
		var b := ShadcnButton.new()
		b.variant = v
		b.text = ShadcnButton.Variant.keys()[v].capitalize()
		row.add_child(b)


func _button_sizes(p: Node) -> void:
	_section(p, "Buttons — sizes & states")
	var row := _row(p)
	var sm := ShadcnButton.new(); sm.button_size = ShadcnButton.Size.SM; sm.text = "Small"
	var df := ShadcnButton.new(); df.text = "Default"
	var lg := ShadcnButton.new(); lg.button_size = ShadcnButton.Size.LG; lg.text = "Large"
	var ic := ShadcnButton.new(); ic.button_size = ShadcnButton.Size.ICON; ic.text = "+"
	var dis := ShadcnButton.new(); dis.text = "Disabled"; dis.disabled = true
	for b in [sm, df, lg, ic, dis]:
		row.add_child(b)


func _badges(p: Node) -> void:
	_section(p, "Badges")
	var row := _row(p)
	for v in ShadcnBadge.Variant.values():
		var bd := ShadcnBadge.new()
		bd.variant = v
		bd.text = ShadcnBadge.Variant.keys()[v].capitalize()
		row.add_child(bd)


func _inputs(p: Node) -> void:
	_section(p, "Inputs")
	var le := LineEdit.new()
	le.placeholder_text = "Email"
	p.add_child(le)
	var te := TextEdit.new()
	te.placeholder_text = "Type your message here."
	te.custom_minimum_size.y = 80
	p.add_child(te)
	var sb := SpinBox.new()
	sb.max_value = 100; sb.value = 42
	p.add_child(sb)


func _selects(p: Node) -> void:
	_section(p, "Select & Menu")
	var opt := OptionButton.new()
	opt.add_item("Light"); opt.add_item("Dark"); opt.add_item("System")
	p.add_child(opt)
	var mb := MenuButton.new()
	mb.text = "Open menu"
	mb.flat = false
	var pm := mb.get_popup()
	pm.add_item("Profile"); pm.add_item("Billing")
	pm.add_separator(); pm.add_item("Log out")
	p.add_child(mb)


func _toggles(p: Node) -> void:
	_section(p, "Toggles")
	var row := _row(p, 16)
	var sw := ShadcnSwitch.new(); sw.button_pressed = true
	row.add_child(sw)
	var cb := CheckBox.new(); cb.text = "Checkbox"; cb.button_pressed = true
	row.add_child(cb)
	var cbtn := CheckButton.new(); cbtn.text = "Notifications"; cbtn.button_pressed = true
	row.add_child(cbtn)


func _radios(p: Node) -> void:
	_section(p, "Radio group")
	var row := _row(p, 16)
	var group := ButtonGroup.new()
	for label in ["Default", "Comfortable", "Compact"]:
		var rb := CheckBox.new()
		rb.text = label
		rb.button_group = group
		if label == "Default":
			rb.button_pressed = true
		row.add_child(rb)


const _MONTHS := ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
const _BROWSERS := ["Chrome", "Safari", "Firefox", "Edge", "Other"]

func _two_series(ch: ShadcnChart) -> void:
	ch.x_labels = _MONTHS
	ch.add_series([186, 305, 237, 173, 209, 264], "Desktop")
	ch.add_series([80, 200, 120, 190, 130, 140], "Mobile")


func _chart_area(p: Node) -> void:
	_section(p, "Chart — area (gradient, smooth)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.AREA
	ch.curve = ShadcnChart.CurveType.SMOOTH
	ch.gradient = true
	_two_series(ch)
	p.add_child(ch)


func _chart_line(p: Node) -> void:
	_section(p, "Chart — line (dots)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.LINE
	ch.x_labels = _MONTHS
	ch.add_series([12, 19, 14, 22, 18, 27], "Visitors")
	p.add_child(ch)


func _chart_line_step(p: Node) -> void:
	_section(p, "Chart — line (step)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.LINE
	ch.curve = ShadcnChart.CurveType.STEP
	ch.show_dots = false
	ch.x_labels = _MONTHS
	ch.add_series([12, 19, 14, 22, 18, 27], "Visitors")
	p.add_child(ch)


func _chart_bar(p: Node) -> void:
	_section(p, "Chart — bar (grouped)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.BAR
	_two_series(ch)
	p.add_child(ch)


func _chart_bar_stacked(p: Node) -> void:
	_section(p, "Chart — bar (stacked)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.BAR
	ch.stacked = true
	_two_series(ch)
	p.add_child(ch)


func _chart_bar_horizontal(p: Node) -> void:
	_section(p, "Chart — bar (horizontal)")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.BAR
	ch.horizontal = true
	_two_series(ch)
	p.add_child(ch)


func _chart_radar(p: Node) -> void:
	_section(p, "Chart — radar")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.RADAR
	ch.custom_minimum_size.y = 240
	ch.x_labels = _MONTHS
	ch.add_series([186, 305, 237, 173, 209, 264], "Desktop")
	ch.add_series([80, 200, 120, 190, 130, 140], "Mobile")
	p.add_child(ch)


func _chart_radial(p: Node) -> void:
	_section(p, "Chart — radial")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.RADIAL
	ch.custom_minimum_size.y = 240
	ch.x_labels = _BROWSERS
	ch.add_series([275, 200, 187, 173, 90])
	p.add_child(ch)


func _chart_pie(p: Node) -> void:
	_section(p, "Chart — pie")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.PIE
	ch.custom_minimum_size.y = 220
	ch.x_labels = _BROWSERS
	ch.add_series([275, 200, 187, 173, 90])
	p.add_child(ch)


func _chart_donut(p: Node) -> void:
	_section(p, "Chart — donut")
	var ch := ShadcnChart.new()
	ch.kind = ShadcnChart.Kind.DONUT
	ch.custom_minimum_size.y = 220
	ch.x_labels = _BROWSERS
	ch.add_series([275, 200, 187, 173, 90])
	p.add_child(ch)


func _card(p: Node) -> void:
	_section(p, "Card")
	var card := ShadcnCard.new()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)
	var t := ShadcnCardTitle.new(); t.text = "Create project"
	var d := ShadcnCardDescription.new(); d.text = "Deploy your new project in one click."
	box.add_child(t); box.add_child(d)
	var spacer := Control.new(); spacer.custom_minimum_size.y = 8
	box.add_child(spacer)
	var actions := _row(box)
	actions.alignment = BoxContainer.ALIGNMENT_END
	var cancel := ShadcnButton.new(); cancel.variant = ShadcnButton.Variant.OUTLINE; cancel.text = "Cancel"
	var ok := ShadcnButton.new(); ok.text = "Deploy"
	actions.add_child(cancel); actions.add_child(ok)
	p.add_child(card)


func _alerts(p: Node) -> void:
	_section(p, "Alerts")
	p.add_child(ShadcnAlert.new())
	var a2 := ShadcnAlert.new()
	a2.variant = ShadcnAlert.Variant.DESTRUCTIVE
	a2.title = "Error"
	a2.description = "Your session has expired. Please log in again."
	p.add_child(a2)


func _tabs(p: Node) -> void:
	_section(p, "Tabs")
	var tabs := TabContainer.new()
	tabs.custom_minimum_size.y = 120
	for tab_name in ["Account", "Password", "Team"]:
		var tab := VBoxContainer.new()
		tab.name = tab_name
		var l := Label.new()
		l.text = "Make changes to your %s here." % tab_name.to_lower()
		l.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
		tab.add_child(l)
		tabs.add_child(tab)
	p.add_child(tabs)


func _table(p: Node) -> void:
	_section(p, "Table")
	var tree := Tree.new()
	tree.custom_minimum_size.y = 130
	tree.columns = 3
	tree.column_titles_visible = true
	tree.set_column_title(0, "Invoice")
	tree.set_column_title(1, "Status")
	tree.set_column_title(2, "Amount")
	tree.hide_root = true
	var root := tree.create_item()
	var rows := [["INV001", "Paid", "$250.00"], ["INV002", "Pending", "$150.00"],
		["INV003", "Unpaid", "$350.00"]]
	for r in rows:
		var it := tree.create_item(root)
		for i in 3:
			it.set_text(i, r[i])
	p.add_child(tree)


func _list(p: Node) -> void:
	_section(p, "List")
	var il := ItemList.new()
	il.custom_minimum_size.y = 90
	for s in ["Calendar", "Search Emoji", "Settings"]:
		il.add_item(s)
	il.select(0)
	p.add_child(il)


func _media(p: Node) -> void:
	_section(p, "Avatar · Spinner · Skeleton")
	var row := _row(p, 16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(ShadcnAvatar.new())
	var sp := ShadcnSpinner.new(); sp.diameter = 28
	row.add_child(sp)
	var sk := ShadcnSkeleton.new(); sk.custom_minimum_size = Vector2(180, 24)
	row.add_child(sk)


func _progress(p: Node) -> void:
	_section(p, "Progress & Sliders")
	var pb := ProgressBar.new()
	pb.value = 60; pb.show_percentage = false
	pb.custom_minimum_size.y = 8
	p.add_child(pb)
	var row := _row(p, 16)
	var hs := HSlider.new(); hs.value = 40
	hs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(hs)
	var vs := VSlider.new(); vs.value = 60
	vs.custom_minimum_size = Vector2(0, 80)
	row.add_child(vs)


func _accordion(p: Node) -> void:
	_section(p, "Accordion")
	var acc := VBoxContainer.new()
	var a := ShadcnAccordionItem.new(); a.expanded = true
	acc.add_child(a)
	var b := ShadcnAccordionItem.new()
	b.title = "Is it styled?"
	b.body = "Yes. It matches the shadcn aesthetic out of the box."
	acc.add_child(b)
	p.add_child(acc)


func _breadcrumb(p: Node) -> void:
	_section(p, "Breadcrumb")
	p.add_child(ShadcnBreadcrumb.new())


func _misc(p: Node) -> void:
	_section(p, "Separator")
	p.add_child(HSeparator.new())

	_section(p, "Popover & Tooltip")
	var row := _row(p, 12)

	# Popover: click-toggled styled PopupPanel (shadcn Popover).
	var pop_btn := ShadcnButton.new()
	pop_btn.variant = ShadcnButton.Variant.OUTLINE
	pop_btn.text = "Open popover"
	var popover := PopupPanel.new()
	popover.wrap_controls = true   # auto-size to content (fixes huge first popup)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 4)
	var pt := ShadcnCardTitle.new(); pt.text = "Dimensions"
	# Plain (non-wrapping) label: autowrap labels report a huge min-height when
	# sized before layout, which made the popup open at full screen height.
	var pd := Label.new()
	pd.text = "Set the dimensions for the layer."
	pd.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	pv.add_child(pt); pv.add_child(pd)
	popover.add_child(pv)
	pop_btn.add_child(popover)
	pop_btn.pressed.connect(func():
		popover.reset_size()
		var at := pop_btn.get_screen_position() + Vector2(0, pop_btn.size.y + 6)
		popover.popup(Rect2i(at, Vector2i(popover.size))))
	row.add_child(pop_btn)

	# Tooltip: opens above the trigger (shadcn default), via ShadcnTooltip.
	var hint := ShadcnButton.new()
	hint.variant = ShadcnButton.Variant.OUTLINE
	hint.text = "Hover me"
	var tip := ShadcnTooltip.new()
	tip.text = "This is a tooltip"
	hint.add_child(tip)
	row.add_child(hint)


func _toast(p: Node) -> void:
	_section(p, "Toast")
	var btn := ShadcnButton.new()
	btn.text = "Show toast"
	btn.pressed.connect(func():
		ShadcnToast.notify(self, "Event created", "Sunday, June 15 at 9:00 AM."))
	p.add_child(btn)


# ------------------------------------------------------ new components

func _kbd(p: Node) -> void:
	_section(p, "Kbd")
	var row := _row(p, 6)
	for k in ["⌘", "K", "⇧", "Esc"]:
		var kb := ShadcnKbd.new(); kb.text = k
		row.add_child(kb)


func _button_group(p: Node) -> void:
	_section(p, "Button group")
	var g := ShadcnButtonGroup.new()
	for t in ["Left", "Center", "Right"]:
		var b := Button.new(); b.text = t
		g.add_child(b)
	p.add_child(g)


func _toggle_group(p: Node) -> void:
	_section(p, "Toggle group")
	var g := ShadcnToggleGroup.new()
	g.single = true
	for t in ["B", "I", "U"]:
		var tg := ShadcnToggle.new(); tg.text = t
		g.add_child(tg)
	p.add_child(g)


func _input_group(p: Node) -> void:
	_section(p, "Input group")
	var ig := ShadcnInputGroup.new()
	ig.placeholder = "Search…"
	var lbl := Label.new(); lbl.text = "🔍"
	ig.add_prefix(lbl)
	p.add_child(ig)


func _input_otp(p: Node) -> void:
	_section(p, "Input OTP")
	var otp := ShadcnInputOTP.new()
	otp.length = 6
	p.add_child(otp)


func _combobox(p: Node) -> void:
	_section(p, "Combobox")
	var cb := ShadcnCombobox.new()
	cb.placeholder = "Select framework…"
	cb.items = ["Next.js", "SvelteKit", "Nuxt", "Remix", "Astro", "Godot"]
	p.add_child(cb)


func _field(p: Node) -> void:
	_section(p, "Field")
	var f := ShadcnField.new()
	f.label = "Email"
	f.description = "We'll never share your email."
	p.add_child(f)  # add first so _ready builds `content`
	var le := LineEdit.new(); le.placeholder_text = "you@example.com"
	f.content.add_child(le)


func _pagination(p: Node) -> void:
	_section(p, "Pagination")
	var pg := ShadcnPagination.new()
	pg.page_count = 10
	pg.current = 3
	p.add_child(pg)


func _item(p: Node) -> void:
	_section(p, "Item")
	var it := ShadcnItem.new()
	it.icon_text = "📁"
	it.title = "Documents"
	it.description = "12 files · updated 2h ago"
	p.add_child(it)


func _empty(p: Node) -> void:
	_section(p, "Empty")
	var e := ShadcnEmpty.new()
	e.title = "No projects"
	e.description = "Create your first project to get started."
	p.add_child(e)  # add first so _ready builds `actions`
	var b := ShadcnButton.new(); b.text = "New project"
	e.actions.add_child(b)


func _calendar(p: Node) -> void:
	_section(p, "Calendar")
	var c := ShadcnCalendar.new()
	c.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.add_child(c)


func _date_picker(p: Node) -> void:
	_section(p, "Date picker")
	p.add_child(ShadcnDatePicker.new())


func _command(p: Node) -> void:
	_section(p, "Command")
	var cmd := ShadcnCommand.new()
	cmd.custom_minimum_size.y = 200
	for entry in [["new", "New file"], ["open", "Open…"], ["save", "Save"], ["settings", "Settings"], ["quit", "Quit"]]:
		cmd.add_item(entry[0], entry[1])
	p.add_child(cmd)


func _carousel(p: Node) -> void:
	_section(p, "Carousel")
	var car := ShadcnCarousel.new()
	car.custom_minimum_size.y = 160
	for i in 3:
		var slide := PanelContainer.new()
		slide.add_theme_stylebox_override("panel", ShadcnStyle.flat(ShadcnTokens.c("muted"), ShadcnTokens.RADIUS))
		var l := Label.new(); l.text = "Slide %d" % (i + 1)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slide.add_child(l)
		car.add_slide(slide)
	p.add_child(car)


func _data_table(p: Node) -> void:
	_section(p, "Data table (sort + filter)")
	var dt := ShadcnDataTable.new()
	dt.set_columns(["Invoice", "Status", "Amount"])
	for r in [["INV001", "Paid", "$250"], ["INV002", "Pending", "$150"],
			["INV003", "Unpaid", "$350"], ["INV004", "Paid", "$450"]]:
		dt.add_row(r)
	p.add_child(dt)


func _overlays(p: Node) -> void:
	_section(p, "Dialog · Alert · Sheet · Drawer · Hover card")
	var row := _row(p, 8)
	var dlg := ShadcnButton.new(); dlg.text = "Dialog"
	dlg.pressed.connect(func():
		var d := ShadcnDialog.new()
		d.title = "Edit profile"; d.description = "Make changes to your profile here."
		add_child(d)  # add first so footer/body exist
		var ok := ShadcnButton.new(); ok.text = "Save"
		ok.pressed.connect(func(): d.close())
		d.footer.add_child(ok)
		d.closed.connect(d.queue_free); d.open())
	row.add_child(dlg)

	var alert := ShadcnButton.new(); alert.variant = ShadcnButton.Variant.DESTRUCTIVE; alert.text = "Delete"
	alert.pressed.connect(func():
		var a := ShadcnAlertDialog.new()
		a.title = "Are you absolutely sure?"
		a.description = "This permanently deletes your account."
		a.destructive = true; a.action_text = "Delete"
		add_child(a); a.closed.connect(a.queue_free); a.open())
	row.add_child(alert)

	var sheet := ShadcnButton.new(); sheet.variant = ShadcnButton.Variant.OUTLINE; sheet.text = "Sheet"
	sheet.pressed.connect(func():
		var s := ShadcnSheet.new(); s.title = "Settings"; s.description = "Manage your preferences."
		add_child(s); s.closed.connect(s.queue_free); s.open())
	row.add_child(sheet)

	var drawer := ShadcnButton.new(); drawer.variant = ShadcnButton.Variant.OUTLINE; drawer.text = "Drawer"
	drawer.pressed.connect(func():
		var dr := ShadcnDrawer.new(); dr.title = "Move goal"; dr.description = "Set your daily activity goal."
		add_child(dr); dr.closed.connect(dr.queue_free); dr.open())
	row.add_child(drawer)

	var hov := ShadcnButton.new(); hov.variant = ShadcnButton.Variant.LINK; hov.text = "@shadcn"
	var hc := ShadcnHoverCard.new()
	hov.add_child(hc)
	row.add_child(hov)
	hc._build()  # build now so we can populate the body
	var t := Label.new(); t.text = "shadcn"; t.add_theme_font_size_override("font_size", 16)
	var d := Label.new(); d.text = "Building UIs for Godot."
	d.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	hc.body.add_child(t); hc.body.add_child(d)


# ----------------------------------------------------------------- helpers

func _column(parent: Node) -> VBoxContainer:
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 18)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(c)
	return c


func _row(parent: Node, sep := 8) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", sep)
	parent.add_child(r)
	return r


func _section(parent: Node, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	parent.add_child(l)
