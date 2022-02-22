@tool
extends "../import.gd"

var name_ending = "Texture"

func _get_resource_type() -> String:
	return "Texture2D"

func _get_save_extension() -> String:
	return "tex"

func convert_resource(source_file: String, global_file: String, options: Dictionary) -> Resource:
	if options["open_editor"] and OS.execute("aseprite", [global_file]) != OK:
		return null
	var data = convert_file(global_file)
	if data.animations.size() > 1:
		push_error("Aseprite Helper: can not use multiple animations as texture")
		return null
	if data.animations[0].frames.size() > 1:
		push_error("Aseprite Helper: Can not use an animation as texture")
		return null
	return data.atlas
