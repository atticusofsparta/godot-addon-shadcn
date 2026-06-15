@tool
extends EditorPlugin
## shadcn-godot plugin.
##
## Every component declares `class_name Shadcn*`, so it already shows up in the
## editor's "Create New Node" search and is usable from code even when this
## plugin is disabled. This script only installs the convenience toast autoload
## (`ShadcnToasts`) so `ShadcnToasts.push(...)` works from anywhere.

const BASE := "res://addons/shadcn/"


func _enter_tree() -> void:
	add_autoload_singleton("ShadcnToasts", BASE + "components/toast.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ShadcnToasts")


## Convenience: returns the bundled theme for the given mode ("dark" | "light").
func get_theme_resource(mode: String = "dark") -> Theme:
	return load(BASE + "themes/shadcn_%s.tres" % mode)
