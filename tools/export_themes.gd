extends SceneTree
## Dev tool: export shipped Theme .tres files from the GDScript ShadcnTheme
## builder (the single source of truth for the look).
##
## Run: Godot --headless --path . --script res://tools/export_themes.gd

func _initialize() -> void:
	var dir := "res://addons/shadcn/themes/"
	for base in ShadcnPalettes.BASE_NAMES:
		for dark in [true, false]:
			var mode := "dark" if dark else "light"
			var theme := ShadcnTheme.build(base, "", dark)
			var path := "%sshadcn_%s_%s.tres" % [dir, base, mode]
			var err := ResourceSaver.save(theme, path)
			print(("ok  " if err == OK else "ERR ") + path)
	# Backwards-compatible default names (neutral).
	ResourceSaver.save(ShadcnTheme.build("neutral", "", true), dir + "shadcn_dark.tres")
	ResourceSaver.save(ShadcnTheme.build("neutral", "", false), dir + "shadcn_light.tres")
	print("done")
	quit()
