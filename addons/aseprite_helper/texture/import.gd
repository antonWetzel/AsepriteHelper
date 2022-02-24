@tool
extends "../import.gd"

var name_ending = "Texture"

func _get_resource_type() -> String:
	return "Texture2D"

func _get_save_extension() -> String:
	return "tex"

func convert_resource(source_file: String, global_file: String, options: Dictionary) -> Resource:
	var ase = get_aseprite_command()
	if ase == "":
		return null
	match options["open_editor"]:
		0:
			pass
		1:
			OS.execute(ase, [global_file])
	var data = convert_file(ase, global_file)
	if data.animations.size() > 1 or data.animations[0].frames.size() > 1:
		push_warning("Aseprite Helper: used an animation as a texture")
	return data.atlas
