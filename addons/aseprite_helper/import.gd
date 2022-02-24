@tool
extends EditorImportPlugin

const paths = preload("./paths.gd")

enum Preset {
	DEFAULT
}

func _get_import_order() -> int:
	return IMPORT_ORDER_DEFAULT

func _get_importer_name() -> String:
	return "antonWetzel.importHelper.aseprite." + _get_resource_type()

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _get_preset_count()  -> int:
	return Preset.size()

func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Preset.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_priority() -> float:
	return 1.0

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["aseprite", "ase"])

func _get_visible_name() -> String:
	return "Import Helper Aseprite " + self.name_ending

func get_file_name(path: String) -> String:
	return path.get_file().split(".")[0]

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> int:
	#I think source_file should be named source_path because it is not a File but a path (String)
	var global_file = ProjectSettings.globalize_path(source_file)
	var res := convert_resource(source_file, global_file, options)
	if res == null:
		return FAILED
	return ResourceSaver.save(save_path + "." + _get_save_extension(), res)

func convert_resource(source_file: String, global_file: String, options: Dictionary) -> Resource: return null

func _get_import_options(path: String, preset_index: int)  -> Array:
	return [
		{
			"name": "open_editor",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "No,Blocking",
		}
	]

#return {atlas: Texture2D, max_x: int, max_y: int, animations: Array[Animation]}
#Animation = Dictionary{name: String, direction: String, frames: Array[Frame]}
#Frame = {time: float, x: int, y: int}
func convert_file(ase_path: String, global_path: String) -> Dictionary:
	var data_path = ProjectSettings.globalize_path("res://temp.json")
	var sheet_path = ProjectSettings.globalize_path("res://temp.png")
	OS.execute(ase_path, [
		"--batch", #perform task in background

		#export meta data as json
		"--format", "json-array",
		"--list-tags",
		"--data", data_path,

		#export image data as png
		"--sheet-type", "packed",
		"--sheet", sheet_path,

		#file to open
		global_path,
	])
	var file := File.new()

	file.open(data_path, File.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	var data := json.get_data() as Dictionary
	file.close()

	file.open(sheet_path, File.READ)
	var img := Image.new()
	img.load_png_from_buffer(file.get_buffer(file.get_length()))
	var atlas := ImageTexture.new()
	atlas.create_from_image(img)
	file.close()

	var dir := Directory.new()
	dir.open("res://")
	dir.remove(data_path)
	dir.remove(sheet_path)

	var w := int(data.frames[0].frame.w)
	var h := int(data.frames[0].frame.h)
	var max_x := 0
	var max_y := 0

	var frame_tags: Array[Dictionary] = data.meta.frameTags
	var frames = []
	for frame in data.frames:
		var x =  int(frame.frame.x) / w
		var y =  int(frame.frame.y) / h
		max_x = max(max_x, x)
		max_y = max(max_y, y)
		frames.append({
			"duration": frame.duration / 1000.0,
			"x": x,
			"y": y,
		})
	var animations = []
	if frame_tags.size() == 0:
		animations.append({
			"name": "Default",
			"direction": "forward",
			"frames": frames,
		})
	else:
		for tag in frame_tags:
			animations.append({
				"name": tag.name,
				"direction": tag.direction,
				"frames": frames.slice(int(tag.from), int(tag.to) + 1),
			})
	return {
		"atlas": atlas,
		"max_x": max_x,
		"max_y": max_y,
		"animations": animations,
	}

func get_aseprite_command() -> String:
	if not ProjectSettings.has_setting(paths.setting_path):
		push_error("missing aseprite path setting, please reactivate the plugin")
		return ""
	var locations : Array[String] = [ProjectSettings.get(paths.setting_path)]
	match OS.get_name():
		"Windows":
			locations.append("C:/Program Files (x86)/Aseprite/Aseprite.exe")
			locations.append("C:/Program Files/Aseprite/Aseprite.exe")
			locations.append("C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe")
		"iOS":
			locations.append("/Applications/Aseprite.app/Contents/MacOS/aseprite")
			locations.append("~/Library/ApplicationSupport/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite")

	var file = File.new()
	for location in locations:
		if file.file_exists(location):
			return location

	var ending := ""
	var sep = ":"
	if OS.get_name() == "Windows":
		ending = ".exe"
		sep = ";"

	for location in OS.get_environment("path").split(sep):
		location = location.trim_suffix("\n")
		if location.length() == 0:
			continue
		location += "/Aseprite" + ending
		if file.file_exists(location):
			return location
	push_error("could not find aseprite in system path or " + JSON.new().stringify(locations))
	return ""
