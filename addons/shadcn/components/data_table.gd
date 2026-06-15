@tool
class_name ShadcnDataTable
extends VBoxContainer
## Data table (shadcn Data Table): a filter box + sortable Tree. Click a column
## header to sort; type to filter. Emits `row_activated(row_data)`.

signal row_activated(row: Array)

@export var filterable: bool = true:
	set(v): filterable = v; if _filter: _filter.visible = v

var _filter: LineEdit
var _tree: Tree
var _columns: PackedStringArray
var _rows: Array = []
var _sort_col := -1
var _sort_asc := true


func _ready() -> void:
	add_to_group("shadcn_refresh")
	_build()
	refresh()
	_rebuild()


func _build() -> void:
	if _tree:
		return
	add_theme_constant_override("separation", 8)
	_filter = LineEdit.new()
	_filter.placeholder_text = "Filter…"
	_filter.visible = filterable
	_filter.text_changed.connect(func(_t): _rebuild())
	add_child(_filter)
	_tree = Tree.new()
	_tree.custom_minimum_size.y = 200
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.hide_root = true
	_tree.column_titles_visible = true
	_tree.column_title_clicked.connect(_on_title_clicked)
	_tree.item_activated.connect(_on_item_activated)
	add_child(_tree)


func set_columns(cols: PackedStringArray) -> void:
	_columns = cols
	_rebuild()


func add_row(cells: Array) -> void:
	_rows.append(cells)
	_rebuild()


func clear_rows() -> void:
	_rows.clear()
	_rebuild()


func _on_title_clicked(col: int, _mouse: int) -> void:
	if _sort_col == col:
		_sort_asc = not _sort_asc
	else:
		_sort_col = col; _sort_asc = true
	_rebuild()


func _on_item_activated() -> void:
	var sel := _tree.get_selected()
	if sel:
		row_activated.emit(sel.get_metadata(0))


func _rebuild() -> void:
	if not _tree or _columns.is_empty():
		return
	_tree.clear()
	_tree.columns = _columns.size()
	for i in _columns.size():
		var title := _columns[i]
		if i == _sort_col:
			title += "  ↑" if _sort_asc else "  ↓"
		_tree.set_column_title(i, title)
		_tree.set_column_title_alignment(i, HORIZONTAL_ALIGNMENT_LEFT)
	var root := _tree.create_item()
	var q := _filter.text.to_lower() if _filter else ""
	var rows := _rows.duplicate()
	if _sort_col >= 0:
		rows.sort_custom(func(a, b):
			var av := str(a[_sort_col]) if _sort_col < a.size() else ""
			var bv := str(b[_sort_col]) if _sort_col < b.size() else ""
			return (av.naturalnocasecmp_to(bv) < 0) == _sort_asc)
	for r in rows:
		if q != "":
			var hay := ""
			for cell in r:
				hay += str(cell) + " "
			if not hay.to_lower().contains(q):
				continue
		var it := _tree.create_item(root)
		it.set_metadata(0, r)
		for i in mini(_columns.size(), r.size()):
			it.set_text(i, str(r[i]))


func refresh() -> void:
	_rebuild()
