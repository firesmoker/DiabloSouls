class_name AnimationManager extends Node

#var animations: Dictionary = {}
#var animation_library: AnimationLibrary
var enemies_animations: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_animations_for_enemy(enemy: Enemy) -> Dictionary:
	if not enemies_animations.has(enemy.base_id):
		print_template("STARTING constructing animations for enemy base model: " + enemy.base_id)
		var enemy_animation_list: Dictionary = {}
		enemies_animations[enemy.base_id] = construct_animation_dictionary(enemy,enemy_animation_list)
		add_animation_method_calls(enemies_animations[enemy.base_id]["AnimationLibrary"], enemy)
		print_template("FINISHED constructing animations for enemy base model: " + enemy.base_id)
		#print("created: " + str(enemies_animations[enemy.base_id]))
	else:
		#print("found: " + str(enemies_animations[enemy.base_id]))
		pass
	return enemies_animations[enemy.base_id]

func construct_animation_dictionary(enemy: Enemy, enemy_animation_list: Dictionary) -> Dictionary:
	var animation_library: AnimationLibrary = AnimationLibrary.new()
	#animations.clear()
	var frames: SpriteFrames = SpriteFrames.new()
	for key: int in Utility.direction_name:
		var animation_dictionary_for_key: Dictionary = {}
		for type: String in enemy.animation_types:
			animation_dictionary_for_key[type] = enemy.model + "_" + type + "_" + Utility.direction_name[key]
		enemy_animation_list[key] = animation_dictionary_for_key
		for type: String in enemy.animation_types:
			create_animated2d_animations_from_assets(enemy,frames,animation_library,enemy_animation_list[key][type], key)
	#print_template("Finished constructing animation library")
	var animation_dictionary: Dictionary = {}
	animation_dictionary["AnimationLibrary"] = animation_library
	animation_dictionary["Animations"] = enemy_animation_list
	animation_dictionary["SpriteFrames"] = frames
	return animation_dictionary
	
	

func create_animated2d_animations_from_assets(enemy: Enemy, frames:SpriteFrames, animation_library: AnimationLibrary, animation_name: String, direction: int = Utility.directions.N) -> void:
	#var frames: SpriteFrames = animated_sprite_2d.sprite_frames
	#var frames: SpriteFrames = SpriteFrames.new()
	var action_type: String
	for type: String in enemy.animation_types:
		if type in animation_name:
			action_type = type
			break
	if action_type == null:
		print_debug("no animation type found for this entity: " + name)
		return
	
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 12.0)
	frames.set_animation_loop(animation_name, true)
	
	#get all pngs to add to each frame of the animation
	var assets_path: String = enemy.model + "/" + enemy.model + "_" + action_type + "/" + Utility.direction_name[direction]
	var parent_directory: String = "enemy"
	if enemy.category == "boss":
		parent_directory = "boss"
	var png_list: Array[String] = Helper.dir_contents_filter("res://assets/art/" + parent_directory + "/" + assets_path,"png")
	
	# add new frames to the spriteframes resource
	for png_path: String in png_list:
		var frame_png: Texture2D  = load(png_path)
		frames.add_frame(animation_name,frame_png)
	
	# create the matching animations in AnimationPlayer
	var new_animation: Animation = Animation.new()
	var frames_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(frames_track,"AnimatedSprite2D:frame")
	new_animation.loop_mode = Animation.LOOP_NONE
	new_animation.length = png_list.size()/Utility.FPS
	var name_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(name_track,"AnimatedSprite2D:animation")
	new_animation.track_insert_key(name_track,0,animation_name)
	var frame_number: float = 0
	for png_path: String in png_list:
		new_animation.track_insert_key(frames_track,frame_number/Utility.FPS, frame_number)
		frame_number += 1
	animation_library.add_animation(animation_name, new_animation)
	
	
func add_animation_method_calls(animation_library: AnimationLibrary, enemy: Enemy) -> void:
	var animation_list: Array[StringName] = animation_library.get_animation_list()
	for animation: StringName in animation_list:
		var animation_to_modify: Animation = animation_library.get_animation(animation)
		var track: int = animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time: float = enemy.attack_frame/Utility.FPS
			var parried_time: float = 0.5/Utility.FPS
			var countered_time: float = 3/Utility.FPS
			#print_debug("adding method calls for animation " + str(animation))
			animation_to_modify.track_insert_key(track, parried_time, {"method" : "ready_to_be_parried" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, countered_time, {"method" : "ready_to_be_countered" , "args" : []}, 1)
			if enemy.has_ranged_attack:
				animation_to_modify.track_insert_key(track, time, {"method" : "attack_effect" , "args" : [false]}, 1)
				#print_debug(str(self) + "added RANGED effects to " + str(animation_to_modify))
			else:
				#print_debug(str(self) + "added MELEE effects to " + str(animation_to_modify) + "because has_ranged attack = " + str(has_ranged_attack))
				animation_to_modify.track_insert_key(track, time, {"method" : "attack_effect" , "args" : []}, 1)
	#print_template("Finished adding animation method calls")

func print_template(message: Variant) -> void:
	Helper.print_template("animation_manager", message, "#Main")
