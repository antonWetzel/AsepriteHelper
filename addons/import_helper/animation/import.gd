@tool
extends "../import.gd"

var name_ending = "Animation"

func _get_resource_type() -> String:
	return "PackedScene"

func _get_save_extension() -> String:
	return "tscn"

func convert_resource(source_file: String, global_file: String, options: Dictionary) -> Resource:
	if options["open_editor"] and OS.execute("aseprite", [global_file]) != OK:
		return null
	var data = convert_file(global_file)

	var node = Node2D.new()
	node.name = source_file.get_basename().rsplit("/", true, 1)[1]

	var player := AnimationPlayer.new()
	player.name = "Player"
	node.add_child(player)
	player.owner = node

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	node.add_child(sprite)
	sprite.owner = node
	sprite.texture = data.atlas
	sprite.hframes = data.max_x + 1
	sprite.vframes = data.max_y + 1

	for animation in data.animations:
		var a := Animation.new()
		match animation.direction:
			"forward":
				a.loop_mode = Animation.LOOP_LINEAR
			"pingpong":
				a.loop_mode = Animation.LOOP_PINGPONG
			"reverse":
				push_warning("reverse direction not implemented")
		var idx := a.add_track(Animation.TYPE_VALUE)
		a.track_set_path(idx, "Sprite:frame_coords")
		a.value_track_set_update_mode(idx, Animation.UPDATE_DISCRETE)
		var time := 0.0
		for frame in animation.frames:
			a.track_insert_key(idx, time, Vector2i(frame.x, frame.y))
			time += frame.duration
		a.length = time
		player.add_animation(animation.name, a)
	player.current_animation = player.get_animation_list()[0]
	var packed_scene = PackedScene.new()
	packed_scene.pack(node)
	return packed_scene
