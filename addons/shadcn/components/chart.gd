@tool
class_name ShadcnChart
extends Control
## Chart component (shadcn Chart). Godot ships no chart control. One flexible
## chart that covers shadcn's gallery via options instead of dozens of types:
##
##   kind      LINE / AREA / BAR / PIE / DONUT / RADAR / RADIAL
##   curve     LINEAR / STEP / SMOOTH        (line + area)
##   horizontal, stacked                     (bar; stacked also for area)
##   gradient                                (area fill fades out)
##   show_dots, show_values
##
## So "area gradient", "bar horizontal", "line step/dots", "radar", "radial",
## stacked variants, etc. are all reachable. Animates in + hover data tooltip.

enum Kind { LINE, AREA, BAR, PIE, DONUT, RADAR, RADIAL }
enum CurveType { LINEAR, STEP, SMOOTH }

@export var kind: Kind = Kind.AREA:
	set(v): kind = v; _restart_anim()
@export var curve: CurveType = CurveType.LINEAR:
	set(v): curve = v; queue_redraw()
@export var horizontal: bool = false:
	set(v): horizontal = v; queue_redraw()
@export var stacked: bool = false:
	set(v): stacked = v; queue_redraw()
@export var gradient: bool = false:
	set(v): gradient = v; queue_redraw()
@export var show_dots: bool = true:
	set(v): show_dots = v; queue_redraw()
@export var show_values: bool = false:
	set(v): show_values = v; queue_redraw()
@export var x_labels: PackedStringArray:
	set(v): x_labels = v; queue_redraw()
@export var show_grid: bool = true:
	set(v): show_grid = v; queue_redraw()
@export var show_legend: bool = true:
	set(v): show_legend = v; queue_redraw()
@export var y_ticks: int = 4:
	set(v): y_ticks = maxi(1, v); queue_redraw()
@export var animate: bool = true:
	set(v): animate = v; _restart_anim()
@export var animate_duration: float = 0.6

var _series: Array = []
var _anim: float = 1.0
var _hover := -1
var _hover_pos := Vector2.ZERO

const _FS := 10


func _init() -> void:
	custom_minimum_size = Vector2(360, 200)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	add_to_group("shadcn_refresh")
	mouse_exited.connect(func(): _hover = -1; queue_redraw())
	_restart_anim()


func refresh() -> void:
	queue_redraw()


func clear_series() -> void:
	_series.clear()
	_restart_anim()


func add_series(data: Array, name := "", color := Color(0, 0, 0, 0)) -> void:
	_series.append({"name": name, "data": PackedFloat32Array(data), "color": color})
	_restart_anim()


func _restart_anim() -> void:
	_anim = 0.0 if animate else 1.0
	set_process(animate)
	queue_redraw()


func _process(delta: float) -> void:
	if _anim < 1.0:
		_anim = minf(1.0, _anim + delta / maxf(0.05, animate_duration))
		if _anim >= 1.0:
			set_process(false)
		queue_redraw()


func _eased() -> float:
	return 1.0 - pow(1.0 - _anim, 3.0)


func _series_color(i: int) -> Color:
	var c: Color = _series[i]["color"]
	return c if c.a > 0.0 else ShadcnTokens.c("chart_%d" % ((i % 5) + 1))


func _font() -> Font:
	return ShadcnTokens.font()


# ----------------------------------------------------------------- hover

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_hover_pos = event.position
		_update_hover()


func _update_hover() -> void:
	var prev := _hover
	_hover = -1
	if not _series.is_empty():
		if kind == Kind.PIE or kind == Kind.DONUT:
			_update_hover_pie()
		elif kind == Kind.LINE or kind == Kind.AREA or kind == Kind.BAR:
			var m := _metrics()
			var plot: Rect2 = m.plot
			var n: int = m.n
			if n > 0 and plot.grow(8.0).has_point(_hover_pos):
				if horizontal:
					var t := (_hover_pos.y - plot.position.y) / plot.size.y
					_hover = clampi(int(t * n), 0, n - 1)
				else:
					var t := 0.0 if n <= 1 else (_hover_pos.x - plot.position.x) / plot.size.x
					_hover = clampi(roundi(t * (n - 1)), 0, n - 1)
	if _hover != prev:
		queue_redraw()


func _update_hover_pie() -> void:
	var data: PackedFloat32Array = _series[0]["data"]
	var total := 0.0
	for v in data:
		total += v
	if total <= 0:
		return
	var geo := _pie_geo()
	var center: Vector2 = geo.center
	var radius: float = geo.radius
	var d := _hover_pos - center
	var dist := d.length()
	var inner: float = radius * (0.58 if kind == Kind.DONUT else 0.0)
	if dist < inner or dist > radius:
		return
	var ang := fposmod(atan2(d.y, d.x) - (-PI / 2.0), TAU)
	var acc := 0.0
	for i in data.size():
		var slice := data[i] / total * TAU
		if ang >= acc and ang < acc + slice:
			_hover = i
			return
		acc += slice


# ----------------------------------------------------------------- metrics

func _metrics() -> Dictionary:
	var n := 0
	for s in _series:
		n = maxi(n, s["data"].size())
	var legend_h := 18.0 if (show_legend and not _series.is_empty()) else 0.0
	var pad_l := 34.0
	var pad_b := 20.0 if not x_labels.is_empty() else 6.0
	if horizontal:
		pad_l = 64.0
		pad_b = 18.0
	var plot := Rect2(pad_l, 6.0, size.x - pad_l - 8.0, size.y - 6.0 - pad_b - legend_h)
	var vmax := -INF
	var vmin := INF
	if stacked and n > 0:
		for i in n:
			var sum := 0.0
			for s in _series:
				if i < s["data"].size():
					sum += s["data"][i]
			vmax = maxf(vmax, sum); vmin = minf(vmin, 0.0)
	else:
		for s in _series:
			for v in s["data"]:
				vmax = maxf(vmax, v); vmin = minf(vmin, v)
	if vmax == -INF:
		vmax = 1.0; vmin = 0.0
	if kind != Kind.LINE:
		vmin = minf(vmin, 0.0)
	if is_equal_approx(vmax, vmin):
		vmax += 1.0
	return {"plot": plot, "vmin": vmin, "vmax": vmax, "span": vmax - vmin, "n": n, "legend_h": legend_h}


# ----------------------------------------------------------------- draw

func _draw() -> void:
	match kind:
		Kind.PIE, Kind.DONUT:
			_draw_pie()
		Kind.RADAR:
			_draw_radar()
		Kind.RADIAL:
			_draw_radial()
		_:
			_draw_cartesian()


func _draw_cartesian() -> void:
	var T := ShadcnTokens
	var font := _font()
	var m := _metrics()
	var plot: Rect2 = m.plot
	if plot.size.x <= 0 or plot.size.y <= 0:
		return
	var vmin: float = m.vmin
	var vmax: float = m.vmax
	var span: float = m.span
	var n: int = m.n
	var a := _eased()

	# grid + value-axis labels
	if show_grid:
		for i in range(y_ticks + 1):
			if horizontal:
				var gx: float = plot.position.x + plot.size.x * float(i) / y_ticks
				draw_line(Vector2(gx, plot.position.y), Vector2(gx, plot.end.y), T.c("border"), 1.0)
				var hv := lerpf(vmin, vmax, float(i) / y_ticks)
				draw_string(font, Vector2(gx - 10, plot.end.y + _FS + 4), str(roundi(hv)),
					HORIZONTAL_ALIGNMENT_CENTER, 24, _FS, T.c("muted_foreground"))
			else:
				var ty: float = plot.position.y + plot.size.y * float(i) / y_ticks
				draw_line(Vector2(plot.position.x, ty), Vector2(plot.end.x, ty), T.c("border"), 1.0)
				var vv := lerpf(vmax, vmin, float(i) / y_ticks)
				draw_string(font, Vector2(2, ty + _FS * 0.4), str(roundi(vv)),
					HORIZONTAL_ALIGNMENT_LEFT, 30, _FS, T.c("muted_foreground"))

	# category-axis labels
	if not x_labels.is_empty():
		for i in x_labels.size():
			if horizontal:
				var ly: float = plot.position.y + plot.size.y * (float(i) + 0.5) / float(maxi(1, n))
				draw_string(font, Vector2(2, ly + _FS * 0.4), x_labels[i],
					HORIZONTAL_ALIGNMENT_LEFT, plot.position.x - 6, _FS, T.c("muted_foreground"))
			elif n > 1:
				var lx: float = plot.position.x + plot.size.x * float(i) / float(n - 1)
				draw_string(font, Vector2(lx - 14, plot.end.y + _FS + 4), x_labels[i],
					HORIZONTAL_ALIGNMENT_CENTER, 28, _FS, T.c("muted_foreground"))

	# hover guide (vertical charts)
	if _hover >= 0 and not horizontal and n > 1 and kind != Kind.BAR:
		var hx: float = plot.position.x + plot.size.x * float(_hover) / float(n - 1)
		draw_line(Vector2(hx, plot.position.y), Vector2(hx, plot.end.y), T.c("muted_foreground"), 1.0)

	if kind == Kind.BAR:
		_draw_bars(plot, vmin, span, a)
	elif stacked and kind == Kind.AREA:
		_draw_stacked_area(plot, vmin, span, a)
	else:
		for si in _series.size():
			var data: PackedFloat32Array = _series[si]["data"]
			if not data.is_empty():
				_draw_line_or_area(data, plot, vmin, span, _series_color(si), kind == Kind.AREA, a)

	if show_legend and not _series.is_empty():
		_draw_legend(font, plot)
	if _hover >= 0:
		_draw_data_tooltip(font, plot, n)


func _anchor(i: int, v: float, count: int, plot: Rect2, vmin: float, span: float) -> Vector2:
	var x: float = plot.position.x if count <= 1 else plot.position.x + plot.size.x * float(i) / float(count - 1)
	var y := plot.end.y - plot.size.y * (v - vmin) / span
	return Vector2(x, y)


func _curve_points(anchors: PackedVector2Array) -> PackedVector2Array:
	if anchors.size() < 2:
		return anchors
	match curve:
		CurveType.STEP:
			var out := PackedVector2Array()
			for i in anchors.size():
				out.append(anchors[i])
				if i < anchors.size() - 1:
					out.append(Vector2(anchors[i + 1].x, anchors[i].y))
			return out
		CurveType.SMOOTH:
			var out2 := PackedVector2Array()
			for i in range(anchors.size() - 1):
				var p0 := anchors[maxi(i - 1, 0)]
				var p1 := anchors[i]
				var p2 := anchors[i + 1]
				var p3 := anchors[mini(i + 2, anchors.size() - 1)]
				for s in 12:
					var t := s / 12.0
					out2.append(_catmull(p0, p1, p2, p3, t))
			out2.append(anchors[anchors.size() - 1])
			return out2
		_:
			return anchors


func _catmull(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 \
		+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)


func _draw_line_or_area(data: PackedFloat32Array, plot: Rect2, vmin: float, span: float,
		col: Color, area: bool, a: float) -> void:
	var anchors := PackedVector2Array()
	for i in data.size():
		anchors.append(_anchor(i, lerpf(vmin, data[i], a), data.size(), plot, vmin, span))
	var render := _curve_points(anchors)
	if area and render.size() >= 2:
		var poly := render.duplicate()
		poly.append(Vector2(render[render.size() - 1].x, plot.end.y))
		poly.append(Vector2(render[0].x, plot.end.y))
		if gradient:
			var cols := PackedColorArray()
			for p in poly:
				var f := clampf((plot.end.y - p.y) / plot.size.y, 0.0, 1.0)
				cols.append(Color(col.r, col.g, col.b, lerpf(0.02, 0.35, f)))
			draw_polygon(poly, cols)
		else:
			draw_colored_polygon(poly, Color(col.r, col.g, col.b, 0.22))
	if render.size() >= 2:
		draw_polyline(render, col, 2.0, true)
	if show_dots:
		for i in anchors.size():
			draw_circle(anchors[i], 4.0 if i == _hover else 3.0, col)
	if show_values:
		for i in anchors.size():
			draw_string(_font(), anchors[i] + Vector2(-8, -6), str(roundi(data[i])),
				HORIZONTAL_ALIGNMENT_LEFT, -1, _FS, ShadcnTokens.c("foreground"))


func _draw_stacked_area(plot: Rect2, vmin: float, span: float, a: float) -> void:
	var n := 0
	for s in _series:
		n = maxi(n, s["data"].size())
	var cum := PackedFloat32Array()
	cum.resize(n)
	for si in _series.size():
		var data: PackedFloat32Array = _series[si]["data"]
		var col := _series_color(si)
		var top := PackedVector2Array()
		var bot := PackedVector2Array()
		for i in n:
			var v: float = data[i] if i < data.size() else 0.0
			top.append(_anchor(i, lerpf(vmin, cum[i] + v, a), n, plot, vmin, span))
			bot.append(_anchor(i, lerpf(vmin, cum[i], a), n, plot, vmin, span))
			cum[i] += v
		var poly := _curve_points(top)
		var bot_r := _curve_points(bot)
		bot_r.reverse()
		poly.append_array(bot_r)
		draw_colored_polygon(poly, Color(col.r, col.g, col.b, 0.55))
		draw_polyline(_curve_points(top), col, 2.0, true)


func _draw_bars(plot: Rect2, vmin: float, span: float, a: float) -> void:
	var n := 0
	for s in _series:
		n = maxi(n, s["data"].size())
	if n == 0:
		return
	var sc := _series.size()
	if horizontal:
		var slot := plot.size.y / float(n)
		var zero_x := plot.position.x + plot.size.x * (0.0 - vmin) / span
		var cum := PackedFloat32Array(); cum.resize(n)
		for i in n:
			var inner := slot * 0.7
			var bh: float = inner if stacked else inner / float(sc)
			for si in sc:
				var data: PackedFloat32Array = _series[si]["data"]
				var v: float = (data[i] if i < data.size() else 0.0)
				var base := cum[i] if stacked else 0.0
				var x0 := plot.position.x + plot.size.x * (lerpf(0.0, base, a) - vmin) / span
				var x1 := plot.position.x + plot.size.x * (lerpf(0.0, base + v, a) - vmin) / span
				var gy := plot.position.y + slot * i + (slot - inner) * 0.5 + (0.0 if stacked else bh * si)
				var col := _series_color(si)
				if i == _hover:
					col = col.lerp(ShadcnTokens.c("foreground"), 0.15)
				draw_style_box(ShadcnStyle.flat(col, 3), Rect2(minf(x0, x1), gy, absf(x1 - x0), maxf(bh - 2, 1)))
				if stacked:
					cum[i] += v
		var _z := zero_x
		return
	# vertical
	var slot := plot.size.x / float(n)
	var inner := slot * 0.7
	var bw: float = inner if stacked else inner / float(sc)
	var zero_y := plot.end.y - plot.size.y * (0.0 - vmin) / span
	var cumv := PackedFloat32Array(); cumv.resize(n)
	for i in n:
		for si in sc:
			var data: PackedFloat32Array = _series[si]["data"]
			var v: float = (data[i] if i < data.size() else 0.0)
			var base := cumv[i] if stacked else 0.0
			var y0 := plot.end.y - plot.size.y * (lerpf(0.0, base, a) - vmin) / span
			var y1 := plot.end.y - plot.size.y * (lerpf(0.0, base + v, a) - vmin) / span
			var gx := plot.position.x + slot * i + (slot - inner) * 0.5 + (0.0 if stacked else bw * si)
			var col := _series_color(si)
			if i == _hover:
				col = col.lerp(ShadcnTokens.c("foreground"), 0.15)
			draw_style_box(ShadcnStyle.flat(col, 3), Rect2(gx, minf(y0, y1), maxf(bw - 2, 1), absf(y1 - y0)))
			if show_values and not stacked:
				draw_string(_font(), Vector2(gx, minf(y0, y1) - 4), str(roundi(v)),
					HORIZONTAL_ALIGNMENT_LEFT, bw, _FS, ShadcnTokens.c("muted_foreground"))
			if stacked:
				cumv[i] += v
	var _z2 := zero_y


func _draw_legend(font: Font, plot: Rect2) -> void:
	var lx := plot.position.x
	var ly := size.y - 9.0
	for si in _series.size():
		var col := _series_color(si)
		draw_rect(Rect2(lx, ly - 5, 10, 10), col)
		var name: String = _series[si]["name"]
		if name == "":
			name = "Series %d" % (si + 1)
		draw_string(font, Vector2(lx + 14, ly + _FS * 0.4), name, HORIZONTAL_ALIGNMENT_LEFT, -1, _FS,
			ShadcnTokens.c("muted_foreground"))
		lx += 14 + font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, _FS).x + 18


func _draw_data_tooltip(font: Font, plot: Rect2, n: int) -> void:
	var title := x_labels[_hover] if _hover < x_labels.size() else "#%d" % _hover
	var rows := []
	for si in _series.size():
		var data: PackedFloat32Array = _series[si]["data"]
		if _hover < data.size():
			rows.append({"name": _series[si]["name"], "val": data[_hover], "col": _series_color(si)})
	var anchor: Vector2
	if horizontal:
		anchor = Vector2(_hover_pos.x, plot.position.y + plot.size.y * (float(_hover) + 0.5) / float(maxi(1, n)))
	else:
		anchor = Vector2(plot.position.x + plot.size.x * float(_hover) / float(maxi(1, n - 1)), plot.position.y)
	_draw_tooltip(font, anchor, title, rows)


func _draw_tooltip(font: Font, anchor: Vector2, title: String, rows: Array) -> void:
	var T := ShadcnTokens
	var fs := 11
	var pad := 8.0
	var line_h := 16.0
	var w := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	for r in rows:
		w = maxf(w, 16 + font.get_string_size("%s  %d" % [r.name, roundi(r.val)], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	var box := Vector2(w + pad * 2, line_h * (rows.size() + 1) + pad * 2 - 4)
	var pos := anchor + Vector2(10, -box.y - 8)
	pos.x = clampf(pos.x, 0, size.x - box.x)
	pos.y = clampf(pos.y, 0, size.y - box.y)
	draw_style_box(ShadcnStyle.flat(T.c("popover"), T.RADIUS_SM, T.c("border"), 1), Rect2(pos, box))
	var y := pos.y + pad + 10
	draw_string(font, Vector2(pos.x + pad, y), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, T.c("popover_foreground"))
	y += line_h
	for r in rows:
		draw_rect(Rect2(pos.x + pad, y - 8, 9, 9), r.col)
		draw_string(font, Vector2(pos.x + pad + 14, y), "%s  %d" % [r.name, roundi(r.val)],
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, T.c("muted_foreground"))
		y += line_h


# ----------------------------------------------------------------- pie / donut

func _pie_geo() -> Dictionary:
	var legend_h := 18.0 if show_legend else 0.0
	var avail := Rect2(0, 0, size.x, size.y - legend_h)
	return {"center": avail.get_center(), "radius": minf(avail.size.x, avail.size.y) * 0.45}


func _draw_pie() -> void:
	if _series.is_empty():
		return
	var T := ShadcnTokens
	var font := _font()
	var data: PackedFloat32Array = _series[0]["data"]
	var total := 0.0
	for v in data:
		total += v
	if total <= 0:
		return
	var geo := _pie_geo()
	var center: Vector2 = geo.center
	var radius: float = geo.radius
	var max_angle := _eased() * TAU
	var start := -PI / 2.0
	var acc := 0.0
	for i in data.size():
		var slice := data[i] / total * TAU
		var seg_start := start + acc
		var seg_end := minf(seg_start + slice, start + max_angle)
		if seg_end > seg_start:
			_draw_slice(center, radius * (1.06 if i == _hover else 1.0), seg_start, seg_end, _pie_color(i))
		acc += slice
		if acc > max_angle:
			break
	if kind == Kind.DONUT:
		draw_circle(center, radius * 0.58, T.c("background"))
	if show_legend:
		_draw_pie_legend(font, data.size())
	if _hover >= 0 and _hover < data.size():
		var lbl := x_labels[_hover] if _hover < x_labels.size() else "#%d" % _hover
		_draw_tooltip(font, _hover_pos, "%s · %d%%" % [lbl, roundi(data[_hover] / total * 100.0)],
			[{"name": "Value", "val": data[_hover], "col": _pie_color(_hover)}])


func _draw_pie_legend(font: Font, count: int) -> void:
	var lx := 8.0
	var ly := size.y - 9.0
	for i in count:
		var lbl := x_labels[i] if i < x_labels.size() else "Slice %d" % (i + 1)
		draw_rect(Rect2(lx, ly - 5, 10, 10), _pie_color(i))
		draw_string(font, Vector2(lx + 14, ly + 4), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, _FS,
			ShadcnTokens.c("muted_foreground"))
		lx += 14 + font.get_string_size(lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, _FS).x + 16


func _pie_color(i: int) -> Color:
	return ShadcnTokens.c("chart_%d" % ((i % 5) + 1))


func _draw_slice(center: Vector2, radius: float, a0: float, a1: float, col: Color) -> void:
	var pts := PackedVector2Array([center])
	var segs := maxi(2, int((a1 - a0) / 0.12))
	for s in segs + 1:
		var ang := lerpf(a0, a1, float(s) / segs)
		pts.append(center + Vector2(cos(ang), sin(ang)) * radius)
	draw_colored_polygon(pts, col)


# ----------------------------------------------------------------- radar

func _draw_radar() -> void:
	if _series.is_empty():
		return
	var T := ShadcnTokens
	var font := _font()
	var n := 0
	for s in _series:
		n = maxi(n, s["data"].size())
	if n < 3:
		return
	var vmax := 0.0
	for s in _series:
		for v in s["data"]:
			vmax = maxf(vmax, v)
	if vmax <= 0:
		vmax = 1.0
	var legend_h := 18.0 if show_legend else 0.0
	var center := Vector2(size.x * 0.5, (size.y - legend_h) * 0.5)
	var radius := minf(size.x, size.y - legend_h) * 0.4
	var a := _eased()

	# grid rings
	if show_grid:
		for t in range(1, y_ticks + 1):
			var rr := radius * float(t) / y_ticks
			var ring := PackedVector2Array()
			for i in n:
				var ang := -PI / 2.0 + TAU * i / n
				ring.append(center + Vector2(cos(ang), sin(ang)) * rr)
			ring.append(ring[0])
			draw_polyline(ring, T.c("border"), 1.0, true)
		for i in n:
			var ang2 := -PI / 2.0 + TAU * i / n
			var edge := center + Vector2(cos(ang2), sin(ang2)) * radius
			draw_line(center, edge, T.c("border"), 1.0)
			if i < x_labels.size():
				draw_string(font, edge + Vector2(cos(ang2), sin(ang2)) * 10 - Vector2(14, 0),
					x_labels[i], HORIZONTAL_ALIGNMENT_CENTER, 40, _FS, T.c("muted_foreground"))

	for si in _series.size():
		var data: PackedFloat32Array = _series[si]["data"]
		var col := _series_color(si)
		var poly := PackedVector2Array()
		for i in n:
			var v: float = (data[i] if i < data.size() else 0.0)
			var ang3 := -PI / 2.0 + TAU * i / n
			poly.append(center + Vector2(cos(ang3), sin(ang3)) * radius * (v / vmax) * a)
		var fill := poly.duplicate()
		draw_colored_polygon(fill, Color(col.r, col.g, col.b, 0.25))
		poly.append(poly[0])
		draw_polyline(poly, col, 2.0, true)
		if show_dots:
			for j in poly.size() - 1:
				draw_circle(poly[j], 3.0, col)
	if show_legend:
		_draw_legend(font, Rect2(8, 0, size.x, size.y))


# ----------------------------------------------------------------- radial

func _draw_radial() -> void:
	if _series.is_empty():
		return
	var T := ShadcnTokens
	var font := _font()
	var data: PackedFloat32Array = _series[0]["data"]
	var vmax := 0.0
	for v in data:
		vmax = maxf(vmax, v)
	if vmax <= 0:
		vmax = 1.0
	var legend_h := 18.0 if show_legend else 0.0
	var center := Vector2(size.x * 0.5, (size.y - legend_h) * 0.5)
	var outer := minf(size.x, size.y - legend_h) * 0.45
	var ring_w := maxf(8.0, outer / float(data.size() + 1))
	var gap := 4.0
	var a := _eased()
	for i in data.size():
		var r := outer - i * (ring_w + gap)
		if r < ring_w * 0.5:
			break
		var col := _pie_color(i)
		draw_arc(center, r, 0, TAU, 64, Color(col.r, col.g, col.b, 0.18), ring_w, true)
		var sweep := data[i] / vmax * TAU * a
		draw_arc(center, r, -PI / 2.0, -PI / 2.0 + sweep, 64, col, ring_w, true)
	if show_legend:
		_draw_pie_legend(font, data.size())
