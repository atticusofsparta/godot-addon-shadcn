extends Control
## Per-component live demo, driven by a `?c=<id>` URL query parameter (web) or
## `--c=<id>` command-line arg (desktop). Shows one component with a live
## customization panel and a base/accent/light-dark switcher.
##
## `?c=all` (or no param) loads the full showcase gallery instead.

var _bg: ColorRect
var _preview: Container
var _controls: VBoxContainer
var _base := "neutral"
var _accent := ""
var _dark := true


func _ready() -> void:
	var id := _component_id()
	if id == "" or id == "all" or id == "showcase":
		_show_showcase()
		return
	_build_chrome(id)


func _component_id() -> String:
	if Engine.has_meta("shadcn_demo_c"):  # test hook
		return str(Engine.get_meta("shadcn_demo_c"))
	if OS.has_feature("web"):
		var v: Variant = JavaScriptBridge.eval(
			"(location.search.match(/[?&]c=([^&]+)/)||[])[1]||''", true)
		if typeof(v) == TYPE_STRING:
			return String(v)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--c="):
			return a.substr(4)
	return ""


func _show_showcase() -> void:
	var sc: Node = load("res://examples/showcase.tscn").instantiate()
	add_child(sc)


# ----------------------------------------------------------------- chrome

func _build_chrome(id: String) -> void:
	ShadcnTokens.apply(self, _base, _accent, _dark)
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	root.add_child(_make_toolbar(id))

	var split := HBoxContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 0)
	root.add_child(split)

	# left: customization panel
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 300
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	for m in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + m, 16)
	_controls = VBoxContainer.new()
	_controls.add_theme_constant_override("separation", 14)
	_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(_controls)
	scroll.add_child(margin)
	panel.add_child(scroll)
	split.add_child(panel)

	# right: preview
	var preview_wrap := MarginContainer.new()
	preview_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for m in ["left", "right", "top", "bottom"]:
		preview_wrap.add_theme_constant_override("margin_" + m, 40)
	_preview = CenterContainer.new()
	preview_wrap.add_child(_preview)
	split.add_child(preview_wrap)

	_load(id)
	_refresh_bg()


func _make_toolbar(id: String) -> PanelContainer:
	var bar := PanelContainer.new()
	var sb := ShadcnStyle.flat(ShadcnTokens.c("card"), 0, ShadcnTokens.c("border"), 1, Vector4(20, 10, 20, 10))
	bar.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	bar.add_child(row)
	var title := Label.new()
	title.text = id.capitalize()
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)

	row.add_child(_tlabel("Base"))
	var base_opt := OptionButton.new()
	for i in ShadcnPalettes.BASE_NAMES.size():
		base_opt.add_item(String(ShadcnPalettes.BASE_NAMES[i]).capitalize())
	base_opt.item_selected.connect(func(i): _base = ShadcnPalettes.BASE_NAMES[i]; _apply_scheme())
	row.add_child(base_opt)
	row.add_child(_tlabel("Accent"))
	var acc := OptionButton.new()
	acc.add_item("Default")
	for i in ShadcnPalettes.ACCENT_NAMES.size():
		acc.add_item(String(ShadcnPalettes.ACCENT_NAMES[i]).capitalize())
	acc.item_selected.connect(func(i): _accent = "" if i == 0 else ShadcnPalettes.ACCENT_NAMES[i - 1]; _apply_scheme())
	row.add_child(acc)
	row.add_child(_tlabel("Dark"))
	var mode := ShadcnSwitch.new()
	mode.button_pressed = true
	mode.switched.connect(func(on): _dark = on; _apply_scheme())
	row.add_child(mode)
	return bar


func _tlabel(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	return l


func _apply_scheme() -> void:
	ShadcnTokens.apply(self, _base, _accent, _dark)
	_refresh_bg()


func _refresh_bg() -> void:
	if _bg:
		_bg.color = ShadcnTokens.c("background")


# ----------------------------------------------------------- control specs

func _enum(label: String, opts: Array, val: int, setter: Callable) -> Dictionary:
	return {"t": "enum", "label": label, "opts": opts, "val": val, "set": setter}

func _bool(label: String, val: bool, setter: Callable) -> Dictionary:
	return {"t": "bool", "label": label, "val": val, "set": setter}

func _num(label: String, mn: float, mx: float, step: float, val: float, setter: Callable) -> Dictionary:
	return {"t": "num", "label": label, "min": mn, "max": mx, "step": step, "val": val, "set": setter}

func _str(label: String, val: String, setter: Callable) -> Dictionary:
	return {"t": "str", "label": label, "val": val, "set": setter}


func _load(id: String) -> void:
	var demo := _make(id)
	for c in _preview.get_children():
		c.queue_free()
	for c in _controls.get_children():
		c.queue_free()
	var node: Control = demo.get("node")
	if node:
		_preview.add_child(node)
	var controls: Array = demo.get("controls", [])
	if controls.is_empty():
		var none := Label.new()
		none.text = "No options — switch base/accent/dark above."
		none.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_controls.add_child(none)
	for spec in controls:
		_controls.add_child(_build_control(spec))


func _build_control(spec: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var lbl := Label.new()
	lbl.text = spec.label
	lbl.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
	lbl.add_theme_font_size_override("font_size", ShadcnTokens.FONT_XS)
	box.add_child(lbl)
	var setter: Callable = spec.set
	match spec.t:
		"enum":
			var opt := OptionButton.new()
			for o in spec.opts:
				opt.add_item(str(o))
			opt.selected = spec.val
			opt.item_selected.connect(func(i): setter.call(i))
			box.add_child(opt)
		"bool":
			var cb := ShadcnSwitch.new()
			cb.button_pressed = spec.val
			cb.switched.connect(func(v): setter.call(v))
			box.add_child(cb)
		"num":
			var hs := HSlider.new()
			hs.min_value = spec.min; hs.max_value = spec.max; hs.step = spec.step
			hs.value = spec.val
			hs.value_changed.connect(func(v): setter.call(v))
			box.add_child(hs)
		"str":
			var le := LineEdit.new()
			le.text = spec.val
			le.text_changed.connect(func(s): setter.call(s))
			box.add_child(le)
	return box


# --------------------------------------------------------------- registry

func _make(id: String) -> Dictionary:
	match id:
		"button":
			var b := ShadcnButton.new(); b.text = "Button"
			return {"node": b, "controls": [
				_enum("Variant", ShadcnButton.Variant.keys(), 0, func(i): b.variant = i),
				_enum("Size", ShadcnButton.Size.keys(), 0, func(i): b.button_size = i),
				_str("Text", "Button", func(s): b.text = s),
				_bool("Disabled", false, func(v): b.disabled = v),
			]}
		"badge":
			var bd := ShadcnBadge.new(); bd.text = "Badge"
			return {"node": bd, "controls": [
				_enum("Variant", ShadcnBadge.Variant.keys(), 0, func(i): bd.variant = i),
				_str("Text", "Badge", func(s): bd.text = s),
			]}
		"switch":
			var s := ShadcnSwitch.new(); s.button_pressed = true
			return {"node": s, "controls": [_bool("On", true, func(v): s.button_pressed = v)]}
		"toggle":
			var t := ShadcnToggle.new(); t.text = "Toggle"
			return {"node": t, "controls": [
				_enum("Variant", ShadcnToggle.Variant.keys(), 0, func(i): t.variant = i),
				_str("Text", "Toggle", func(s): t.text = s),
				_bool("Pressed", false, func(v): t.button_pressed = v),
			]}
		"toggle-group":
			var g := ShadcnToggleGroup.new(); g.single = true
			for x in ["B", "I", "U"]:
				var tg := ShadcnToggle.new(); tg.text = x; g.add_child(tg)
			return {"node": g, "controls": [_bool("Single (radio)", true, func(v): g.single = v)]}
		"button-group":
			var bg := ShadcnButtonGroup.new()
			for x in ["Left", "Center", "Right"]:
				var bb := Button.new(); bb.text = x; bg.add_child(bb)
			return {"node": bg, "controls": []}
		"kbd":
			var k := ShadcnKbd.new(); k.text = "Ctrl"
			return {"node": k, "controls": [_str("Text", "Ctrl", func(s): k.text = s)]}
		"alert":
			var a := ShadcnAlert.new(); a.custom_minimum_size.x = 360
			return {"node": a, "controls": [
				_enum("Variant", ShadcnAlert.Variant.keys(), 0, func(i): a.variant = i),
				_str("Title", a.title, func(s): a.title = s),
				_str("Description", a.description, func(s): a.description = s),
			]}
		"avatar":
			var av := ShadcnAvatar.new()
			return {"node": av, "controls": [
				_str("Fallback", "CN", func(s): av.fallback = s),
				_num("Diameter", 24, 96, 1, 40, func(v): av.diameter = v),
			]}
		"skeleton":
			var sk := ShadcnSkeleton.new(); sk.custom_minimum_size = Vector2(220, 28)
			return {"node": sk, "controls": [
				_num("Width", 80, 400, 1, 220, func(v): sk.custom_minimum_size.x = v),
				_num("Height", 12, 120, 1, 28, func(v): sk.custom_minimum_size.y = v),
				_num("Radius", 0, 24, 1, ShadcnTokens.RADIUS_SM, func(v): sk.radius = int(v)),
			]}
		"spinner":
			var sp := ShadcnSpinner.new(); sp.diameter = 36
			return {"node": sp, "controls": [
				_num("Diameter", 16, 96, 1, 36, func(v): sp.diameter = v),
				_num("Line width", 1, 8, 0.5, 2, func(v): sp.line_width = v),
				_num("Speed", 1, 10, 0.5, 4, func(v): sp.speed = v),
			]}
		"progress":
			var pb := ProgressBar.new(); pb.value = 60; pb.custom_minimum_size = Vector2(300, 10); pb.show_percentage = false
			return {"node": pb, "controls": [
				_num("Value", 0, 100, 1, 60, func(v): pb.value = v),
				_bool("Show %", false, func(v): pb.show_percentage = v),
			]}
		"slider":
			var sl := HSlider.new(); sl.value = 40; sl.custom_minimum_size.x = 300
			return {"node": sl, "controls": [
				_num("Value", 0, 100, 1, 40, func(v): sl.value = v),
				_num("Step", 0, 25, 1, 1, func(v): sl.step = v),
			]}
		"accordion":
			var ac := ShadcnAccordionItem.new(); ac.custom_minimum_size.x = 360; ac.expanded = true
			return {"node": ac, "controls": [
				_str("Title", ac.title, func(s): ac.title = s),
				_str("Body", ac.body, func(s): ac.body = s),
				_bool("Expanded", true, func(v): ac.expanded = v),
			]}
		"breadcrumb":
			var bc := ShadcnBreadcrumb.new()
			return {"node": bc, "controls": [_str("Separator", "/", func(s): bc.separator = s)]}
		"pagination":
			var pg := ShadcnPagination.new(); pg.page_count = 10; pg.current = 3
			return {"node": pg, "controls": [
				_num("Pages", 1, 30, 1, 10, func(v): pg.page_count = int(v)),
				_num("Current", 1, 30, 1, 3, func(v): pg.current = int(v)),
				_num("Max visible", 3, 12, 1, 7, func(v): pg.max_visible = int(v)),
			]}
		"card":
			var card := ShadcnCard.new(); card.custom_minimum_size.x = 320
			var vb := VBoxContainer.new(); vb.add_theme_constant_override("separation", 6); card.add_child(vb)
			var t := ShadcnCardTitle.new(); t.text = "Create project"
			var d := ShadcnCardDescription.new(); d.text = "Deploy your project in one click."
			vb.add_child(t); vb.add_child(d)
			return {"node": card, "controls": [_bool("Elevated", false, func(v): card.elevated = v)]}
		"tabs":
			var tabs := TabContainer.new(); tabs.custom_minimum_size = Vector2(380, 160)
			for n in ["Account", "Password", "Team"]:
				var pg2 := VBoxContainer.new(); pg2.name = n
				var l := Label.new(); l.text = "The %s tab." % n.to_lower(); pg2.add_child(l)
				tabs.add_child(pg2)
			return {"node": tabs, "controls": []}
		"chart":
			return _chart_demo()
		"input":
			var le := LineEdit.new(); le.placeholder_text = "Email"; le.custom_minimum_size.x = 280
			return {"node": le, "controls": [
				_str("Placeholder", "Email", func(s): le.placeholder_text = s),
				_bool("Editable", true, func(v): le.editable = v),
			]}
		"textarea":
			var te := TextEdit.new(); te.placeholder_text = "Message"; te.custom_minimum_size = Vector2(300, 120)
			return {"node": te, "controls": [_str("Placeholder", "Message", func(s): te.placeholder_text = s)]}
		"select":
			var opt := OptionButton.new(); opt.add_item("Light"); opt.add_item("Dark"); opt.add_item("System")
			return {"node": opt, "controls": []}
		"combobox":
			var cb := ShadcnCombobox.new(); cb.placeholder = "Select framework…"
			cb.items = ["Next.js", "Nuxt", "Remix", "Astro", "Godot"]
			return {"node": cb, "controls": [_str("Placeholder", "Select framework…", func(s): cb.placeholder = s; cb.text = s)]}
		"input-group":
			var ig := ShadcnInputGroup.new(); ig.placeholder = "Search…"; ig.custom_minimum_size.x = 300
			var pfx := Label.new(); pfx.text = "🔍"; ig.add_prefix(pfx)
			return {"node": ig, "controls": [_str("Placeholder", "Search…", func(s): ig.placeholder = s)]}
		"input-otp":
			var otp := ShadcnInputOTP.new(); otp.length = 6
			return {"node": otp, "controls": [_num("Length", 3, 8, 1, 6, func(v): otp.length = int(v))]}
		"field":
			var f := ShadcnField.new(); f.custom_minimum_size.x = 300; f.label = "Email"; f.description = "We never share it."
			var le2 := LineEdit.new(); le2.placeholder_text = "you@example.com"
			f.content.add_child(le2)
			return {"node": f, "controls": [
				_str("Label", "Email", func(s): f.label = s),
				_str("Description", "We never share it.", func(s): f.description = s),
				_str("Error", "", func(s): f.error = s),
			]}
		"checkbox":
			var ck := CheckBox.new(); ck.text = "Accept terms"; ck.button_pressed = true
			return {"node": ck, "controls": [
				_str("Text", "Accept terms", func(s): ck.text = s),
				_bool("Checked", true, func(v): ck.button_pressed = v),
			]}
		"radio-group":
			var rg := VBoxContainer.new(); rg.add_theme_constant_override("separation", 8)
			var grp := ButtonGroup.new()
			for x in ["Default", "Comfortable", "Compact"]:
				var rb := CheckBox.new(); rb.text = x; rb.button_group = grp
				if x == "Default": rb.button_pressed = true
				rg.add_child(rb)
			return {"node": rg, "controls": []}
		"separator":
			var sep := VBoxContainer.new(); sep.custom_minimum_size.x = 300; sep.add_theme_constant_override("separation", 10)
			var a1 := Label.new(); a1.text = "Above"
			var hs := HSeparator.new()
			var b1 := Label.new(); b1.text = "Below"
			sep.add_child(a1); sep.add_child(hs); sep.add_child(b1)
			return {"node": sep, "controls": []}
		"label":
			var l := Label.new(); l.text = "The quick brown fox"
			return {"node": l, "controls": [
				_str("Text", "The quick brown fox", func(s): l.text = s),
				_num("Size", 10, 40, 1, 16, func(v): l.add_theme_font_size_override("font_size", int(v))),
			]}
		"tooltip":
			var tb := ShadcnButton.new(); tb.variant = ShadcnButton.Variant.OUTLINE; tb.text = "Hover me"
			var tip := ShadcnTooltip.new(); tip.text = "This is a tooltip"; tb.add_child(tip)
			return {"node": tb, "controls": [
				_str("Text", "This is a tooltip", func(s): tip.text = s),
				_enum("Side", ShadcnTooltip.Placement.keys(), 0, func(i): tip.side = i),
			]}
		"hover-card":
			var hb := ShadcnButton.new(); hb.variant = ShadcnButton.Variant.LINK; hb.text = "@shadcn"
			var hc := ShadcnHoverCard.new(); hb.add_child(hc); hc._build()
			var ht := Label.new(); ht.text = "shadcn"; ht.add_theme_font_size_override("font_size", 16)
			var hd := Label.new(); hd.text = "Building UIs for Godot."
			hd.add_theme_color_override("font_color", ShadcnTokens.c("muted_foreground"))
			hc.body.add_child(ht); hc.body.add_child(hd)
			return {"node": hb, "controls": []}
		"popover":
			var pbn := ShadcnButton.new(); pbn.variant = ShadcnButton.Variant.OUTLINE; pbn.text = "Open popover"
			var pop := PopupPanel.new(); pop.wrap_controls = true
			var pl := Label.new(); pl.text = "Popover content"; pop.add_child(pl); pbn.add_child(pop)
			pbn.pressed.connect(func():
				pop.reset_size()
				pop.popup(Rect2i(pbn.get_screen_position() + Vector2(0, pbn.size.y + 6), Vector2i(pop.size))))
			return {"node": pbn, "controls": []}
		"dropdown", "context-menu":
			var mb := MenuButton.new(); mb.text = "Open menu"; mb.flat = false
			var pm := mb.get_popup(); pm.add_item("Profile"); pm.add_item("Billing"); pm.add_separator(); pm.add_item("Log out")
			return {"node": mb, "controls": []}
		"menubar":
			var menu := MenuBar.new()
			var pm1 := PopupMenu.new(); pm1.name = "File"; pm1.add_item("New"); pm1.add_item("Open")
			var pm2 := PopupMenu.new(); pm2.name = "Edit"; pm2.add_item("Undo"); pm2.add_item("Redo")
			menu.add_child(pm1); menu.add_child(pm2)
			return {"node": menu, "controls": []}
		"dialog":
			var dbn := ShadcnButton.new(); dbn.text = "Open dialog"
			dbn.pressed.connect(func():
				var d := ShadcnDialog.new(); d.title = "Edit profile"; d.description = "Make changes here."
				add_child(d)
				var ok := ShadcnButton.new(); ok.text = "Save"; ok.pressed.connect(d.close); d.footer.add_child(ok)
				d.closed.connect(d.queue_free); d.open())
			return {"node": dbn, "controls": []}
		"alert-dialog":
			var abn := ShadcnButton.new(); abn.variant = ShadcnButton.Variant.DESTRUCTIVE; abn.text = "Delete account"
			abn.pressed.connect(func():
				var a := ShadcnAlertDialog.new(); a.title = "Are you sure?"; a.description = "This cannot be undone."
				a.destructive = true; a.action_text = "Delete"; add_child(a); a.closed.connect(a.queue_free); a.open())
			return {"node": abn, "controls": []}
		"sheet":
			var sbn := ShadcnButton.new(); sbn.variant = ShadcnButton.Variant.OUTLINE; sbn.text = "Open sheet"
			var side := {"v": 1}
			sbn.pressed.connect(func():
				var s := ShadcnSheet.new(); s.side = side.v; s.title = "Settings"; s.description = "Manage preferences."
				add_child(s); s.closed.connect(s.queue_free); s.open())
			return {"node": sbn, "controls": [
				_enum("Side", ["Left", "Right", "Top", "Bottom"], 1, func(i): side.v = i),
			]}
		"drawer":
			var drbn := ShadcnButton.new(); drbn.variant = ShadcnButton.Variant.OUTLINE; drbn.text = "Open drawer"
			drbn.pressed.connect(func():
				var dr := ShadcnDrawer.new(); dr.title = "Move goal"; dr.description = "Set your daily goal."
				add_child(dr); dr.closed.connect(dr.queue_free); dr.open())
			return {"node": drbn, "controls": []}
		"sidebar":
			var sb2 := ShadcnSidebar.new(); sb2.custom_minimum_size.y = 240
			for x in ["Dashboard", "Projects", "Settings"]:
				var nav := Button.new(); nav.text = x; nav.flat = true; nav.alignment = HORIZONTAL_ALIGNMENT_LEFT
				sb2.content.add_child(nav)
			return {"node": sb2, "controls": [_bool("Collapsed", false, func(v): sb2.collapsed = v)]}
		"command":
			var cmd := ShadcnCommand.new()
			for e in [["n", "New File"], ["o", "Open…"], ["s", "Save"], ["q", "Quit"]]:
				cmd.add_item(e[0], e[1])
			return {"node": cmd, "controls": []}
		"carousel":
			var car := ShadcnCarousel.new()
			for i in 3:
				var sl := PanelContainer.new()
				sl.add_theme_stylebox_override("panel", ShadcnStyle.flat(ShadcnTokens.c("muted"), ShadcnTokens.RADIUS))
				var l := Label.new(); l.text = "Slide %d" % (i + 1)
				l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				sl.add_child(l); car.add_slide(sl)
			return {"node": car, "controls": [_bool("Loop", true, func(v): car.loop = v)]}
		"empty":
			var e := ShadcnEmpty.new(); e.custom_minimum_size = Vector2(320, 0)
			return {"node": e, "controls": [
				_str("Icon", "📭", func(s): e.icon_text = s),
				_str("Title", "No results", func(s): e.title = s),
				_str("Description", "Try adjusting your filters.", func(s): e.description = s),
			]}
		"item":
			var it := ShadcnItem.new(); it.custom_minimum_size.x = 340
			it.icon_text = "📁"; it.title = "Documents"; it.description = "12 files"
			return {"node": it, "controls": [
				_str("Title", "Documents", func(s): it.title = s),
				_str("Description", "12 files", func(s): it.description = s),
				_str("Icon", "📁", func(s): it.icon_text = s),
				_bool("Bordered", true, func(v): it.bordered = v),
			]}
		"toast":
			var tbn := ShadcnButton.new(); tbn.text = "Show toast"
			var cfg := {"title": "Event created", "desc": "Sunday at 9:00 AM."}
			tbn.pressed.connect(func(): ShadcnToast.notify(self, cfg.title, cfg.desc))
			return {"node": tbn, "controls": [
				_str("Title", "Event created", func(s): cfg.title = s),
				_str("Description", "Sunday at 9:00 AM.", func(s): cfg.desc = s),
			]}
		"calendar":
			return {"node": ShadcnCalendar.new(), "controls": []}
		"date-picker":
			return {"node": ShadcnDatePicker.new(), "controls": []}
		"table":
			var tree := Tree.new(); tree.custom_minimum_size = Vector2(360, 160); tree.columns = 3; tree.hide_root = true
			tree.column_titles_visible = true
			tree.set_column_title(0, "Invoice"); tree.set_column_title(1, "Status"); tree.set_column_title(2, "Amount")
			var r := tree.create_item()
			for row in [["INV001", "Paid", "$250"], ["INV002", "Pending", "$150"]]:
				var it2 := tree.create_item(r)
				for i in 3: it2.set_text(i, row[i])
			return {"node": tree, "controls": []}
		"data-table":
			var dt := ShadcnDataTable.new(); dt.custom_minimum_size = Vector2(380, 240)
			dt.set_columns(["Invoice", "Status", "Amount"])
			for row in [["INV001", "Paid", "$250"], ["INV002", "Pending", "$150"], ["INV003", "Unpaid", "$350"]]:
				dt.add_row(row)
			return {"node": dt, "controls": [_bool("Filterable", true, func(v): dt.filterable = v)]}
		_:
			var l := Label.new()
			l.text = "Unknown component: %s" % id
			return {"node": l, "controls": []}


func _chart_demo() -> Dictionary:
	var c := ShadcnChart.new()
	c.custom_minimum_size = Vector2(460, 280)
	c.x_labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
	c.add_series([186, 305, 237, 173, 209, 264], "Desktop")
	c.add_series([80, 200, 120, 190, 130, 140], "Mobile")
	return {"node": c, "controls": [
		_enum("Kind", ShadcnChart.Kind.keys(), 1, func(i): c.kind = i),
		_enum("Curve", ShadcnChart.CurveType.keys(), 0, func(i): c.curve = i),
		_bool("Horizontal", false, func(v): c.horizontal = v),
		_bool("Stacked", false, func(v): c.stacked = v),
		_bool("Gradient", false, func(v): c.gradient = v),
		_bool("Dots", true, func(v): c.show_dots = v),
		_bool("Values", false, func(v): c.show_values = v),
		_bool("Grid", true, func(v): c.show_grid = v),
		_bool("Legend", true, func(v): c.show_legend = v),
	]}
