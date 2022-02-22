@tool
extends EditorPlugin

var plugin: EditorImportPlugin

func _enter_tree():
	plugin = get_plugin()
	add_import_plugin(plugin)

func _exit_tree():
	remove_import_plugin(plugin)
	plugin = null

func get_plugin() -> EditorImportPlugin:
	push_error("get_plugin not overwritten")
	return null
