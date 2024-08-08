class_name Player extends CharacterBody2D

@onready var game_manager: GameManager = %GameManager
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var attack_axis: Node2D
@export var animation_player: AnimationPlayer
@export var attack_zone: Area2D
@export var attack_collider: CollisionShape2D
@onready var animation_library: AnimationLibrary = animation_player.get_animation_library("")
@export_enum("warrior_armed", "fighter_armed", "knight_armed") var model: String = "warrior_armed"
@export var speed_fps_ratio: float = 121.0
@export var speed_modifier: float = 1
@export var attack_frame: int = 3
@export var cancel_frame: int = 2
@export var attack_again_frame: int = 5
@export var hitpoints: int = 5
@export var is_moving: bool = false
@export var is_executing: bool = false
@export var is_chasing_enemy: bool = false
@export var ready_for_idle: bool= true
@export var ready_to_attack_again: bool= true
@export var animation_types: Array[String] = ["idle", "walk", "attack", "death", "parry"]

var targeted_enemy: RigidBody2D = null
var enemies_in_melee: Array[Enemy]
#var abilities_queue: Array[Ability]
var dying: bool = false
var dead: bool = false

signal attack_effects
signal attack_success

var destination: Vector2 = Vector2()
var movement: Vector2 = Vector2()

const FPS: float = 12.0
const average_delta: float = 0.01666666666667

#enum directions{N,NE,E,SE,S,SW,W,NW}
enum directions{N,NNE,NE,NEE,E,SEE,SE,SSE,S,SSW,SW,SWW,W,NWW,NW,NNW}
var current_direction: int = directions.E
var animations: Dictionary = {}
var direction_name: Dictionary = {
	directions.N : "N",
	directions.NNE : "NNE", # extra
	directions.NE : "NE",
	directions.NEE : "NEE", # extra
	directions.E : "E",
	directions.SEE : "SEE", # extra
	directions.SE : "SE",
	directions.SSE : "SSE", # extra
	directions.S : "S",
	directions.SSW : "SSW", # extra
	directions.SW : "SW",
	directions.SWW : "SWW", # extra
	directions.W : "W",
	directions.NWW : "NWW", # extra
	directions.NW : "NW",
	directions.NNW : "NNW", # extra
}
var radian_direction: Dictionary = {
	-2.0/4 * PI: directions.N,
	-1.5/4 * PI: directions.NNE, #
	-1.0/4 * PI: directions.NE,
	-0.5/4 * PI: directions.NEE, #
	0.0/4 * PI: directions.E,
	0.5/4 * PI: directions.SEE, #
	1.0/4 * PI: directions.SE,
	1.5/4 * PI: directions.SSE, #
	2.0/4 * PI: directions.S,
	2.5/4 * PI: directions.SSW, #
	3.0/4 * PI: directions.SW,
	3.5/4 * PI: directions.SWW, #
	4.0/4 * PI: directions.W,
	-4.0/4 * PI: directions.W,
	-3.5/4 * PI: directions.NWW, #
	-3.0/4 * PI: directions.NW,
	-2.5/4 * PI: directions.NNW, #
}

var attack_ability: Ability = Ability.new("attack", "melee")
var parry_ability: Ability = Ability.new("parry", "melee")

func _ready() -> void:
	destination = position
	construct_animation_library()
	add_animation_method_calls()


func _physics_process(delta: float) -> void:	
	if not dying:
		handle_movement(delta)
		
		if not is_executing:
			stop_on_destination()
			
			if velocity:
				running_state()
			else:
				standing_state()

		move_and_slide()
	elif not dead:
		animation_player.play(animations[current_direction]["death"])
		dead = true


func _unhandled_input(event: InputEvent) -> void:
	if not dying:
		if event.is_action_pressed("bobo"):
			print("test button pressed")
			print("KUKUK")
			execute(parry_ability)
		
		if event.is_action_pressed("attack_in_place"):
			var face_destination: Vector2 = get_global_mouse_position()
			attack(face_destination)
		
		if event.is_action_pressed("parry"):
			var face_destination: Vector2 = get_global_mouse_position()
			attack(face_destination, parry_ability)
		
		if event.is_action_pressed("mouse_move") and not event.is_action_pressed("attack_in_place"):
			if game_manager.enemy_in_focus != null:
				targeted_enemy = game_manager.enemy_in_focus
				#is_moving = false
				if targeted_enemy not in enemies_in_melee:
					move_to_enemy()
				else:
					attack(targeted_enemy.position)
			else:
				print("unhandled input")
				is_moving = true
				destination = get_global_mouse_position()


func _on_melee_zone_body_entered(enemy: CollisionObject2D) -> void:
	print("body entered " + str(enemy))
	enemies_in_melee.append(enemy)
	if is_chasing_enemy and targeted_enemy == enemy:
		attack(enemy.position)


func _on_melee_zone_body_exited(enemy: CollisionObject2D) -> void:
	print("body exited " + str(enemy))
	if enemy in enemies_in_melee:
		enemies_in_melee.erase(enemy)


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		print("attack finished fully")
		ready_for_idle = true


func _on_attack_zone_body_entered(body: CollisionObject2D) -> void:
	emit_signal("attack_success", body)


func _on_attack_effects() -> void:
	#if not audio.playing:
		#audio.stop()
	audio.pitch_scale = 1
	audio.pitch_scale += randf_range(-0.03, 0.03)
	audio.play()


func stop_on_destination() -> void:
	if abs(position.x - destination.x) <= 1 and abs(position.y - destination.y) <= 1:
	#if position.distance_to(destination) <= 1:
		velocity = Vector2(0,0)
		if not Input.is_action_pressed("mouse_move"):
			ready_for_idle = true


func running_state() -> void:
	var current_animation: String = animation_player.current_animation
	is_executing = false
	ready_to_attack_again = true
	if speed_modifier >= 2:
		animation_player.speed_scale = speed_modifier / 2
	else:
		animation_player.speed_scale = speed_modifier
	if "walk" in current_animation and current_animation != animations[current_direction]["walk"]:
		var current_animation_position: float = animation_player.current_animation_position
		animation_player.play(animations[current_direction]["walk"])
		animation_player.seek(current_animation_position)
	else:
		animation_player.play(animations[current_direction]["walk"])


func standing_state() -> void:
	if "attack" in animation_player.current_animation or "parry" in animation_player.current_animation:
		is_moving = false
		await animation_player.animation_finished
	#print("going idle!")
	if not dying:
		animation_player.play(animations[current_direction]["idle"])


func handle_movement(delta: float) -> void:
	if is_moving and not is_executing:
		if Input.is_action_pressed("mouse_move"):
			if game_manager.enemies_under_mouse.size() <= 0:
				is_chasing_enemy = false
				targeted_enemy = null
			is_moving = true
			ready_for_idle = false
			destination = get_global_mouse_position()
			if abs(position.x - destination.x) <= 5 and abs(position.y - destination.y) <= 5:
			#if position.distance_to(destination) <= 5:
				velocity = Vector2(0,0)
				destination = position
		if is_chasing_enemy and targeted_enemy != null:
			destination = targeted_enemy.position
		velocity = calculate_movement_velocity() * delta / average_delta


func set_direction_by_angle(angle: float) -> void:
	var half_rand: float = (0.5/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = round_to_multiple(angle, half_rand)
	current_direction = radian_direction[rounded_rand]


func attack(attack_destination: Vector2, ability: Ability = attack_ability) -> void:
	#abilities_queue.append(attack_ability)
	is_chasing_enemy = false
	targeted_enemy = null
	ready_for_idle = false
	is_moving = false
	if ability.range_type == "melee":
		print("melee attack!")
	#else:
		#print("not melee")
	velocity = Vector2(0, 0)
	var angle: float = position.angle_to_point(attack_destination)
	set_direction_by_angle(angle)
	if not dying:
		animation_player.speed_scale = speed_modifier
		if ready_to_attack_again:
			is_executing = true
			ready_to_attack_again = false
			attack_axis.rotation = angle
			print("first or restarted attack")
			animation_player.stop()
			#animation_player.play(animations[current_direction][attack_ability.animation_name])
			execute(ability)
		elif attack_collider.disabled == true:
			attack_axis.rotation = angle
			print("normal attack")
			var current_animation_position: float = animation_player.current_animation_position
			
			if current_animation_position < attack_frame/FPS or current_animation_position >= attack_again_frame/FPS:
				#animation_player.play(animations[current_direction][attack_ability.animation_name])
				execute(ability)
				animation_player.seek(current_animation_position)
	

func move_to_enemy() -> void:
	if targeted_enemy == null:
		targeted_enemy = game_manager.enemy_in_focus
		if targeted_enemy == null:
			print("enemy null")
			return
		
	is_chasing_enemy = true
	destination = targeted_enemy.position
	is_moving = true


func round_to_multiple(number: float, multiple: float) -> float:
	return float(round(number / multiple) * multiple)


func calculate_movement_velocity() -> Vector2:
	var angle: float = position.angle_to_point(destination)
	set_direction_by_angle(angle)
	
	var radius : float = speed_fps_ratio
	var direction_x: float = cos(angle) * radius
	var direction_y: float = sin(angle) * radius
	var max_velocity_x: float = direction_x * speed_modifier
	var max_velocity_y: float = direction_y * speed_modifier
	
	return Vector2(max_velocity_x, max_velocity_y)


func just_attacked() -> void: # THIS
	print("pow!")
	attack_collider.disabled = false
	emit_signal("attack_effects")
	disable_attack_zone()


func construct_animation_library() -> void:
	animations.clear()
	for key: int in direction_name:
		var animation_dictionary_for_key: Dictionary = {}
		for type: String in animation_types:
			animation_dictionary_for_key[type] = model + "_" + type + "_" + direction_name[key]
		animations[key] = animation_dictionary_for_key
		for type: String in animation_types:
			create_animated2d_animations_from_assets(animations[key][type], key)


func create_animated2d_animations_from_assets(animation_name: String, direction: int = directions.N) -> void:
	var frames: SpriteFrames = animated_sprite_2d.sprite_frames
	var action_type: String
	
	for type: String in animation_types:
		if type in animation_name:
			action_type = type
			if action_type == "parry": # TEMPORARY
				action_type = "attack" # TEMPORARY
				print("forcing parry to use attack assets") # TEMPORARY
			break
	
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 12.0)
	frames.set_animation_loop(animation_name, true)
	
	#get all pngs to add to each frame of the animation
	var assets_path: String = model + "/" + model + "_" + action_type + "/" + direction_name[direction]
	var png_list: Array[String] = game_manager.dir_contents_filter("res://assets/art/playable character/" + assets_path,"png", false)
	
	# add new frames to the spriteframes resource
	for png_path: String in png_list:
		var frame_png: Texture2D  = load(png_path)
		frames.add_frame(animation_name,frame_png)
	print("animation: " + animation_name + " created in AnimatedSprite2D")
	
	# create the matching animations in AnimationPlayer
	var new_animation: Animation = Animation.new()
	var frames_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(frames_track,"AnimatedSprite2D:frame")
	new_animation.loop_mode = Animation.LOOP_NONE
	new_animation.length = png_list.size()/FPS
	var name_track : int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(name_track,"AnimatedSprite2D:animation")
	new_animation.track_insert_key(name_track,0,animation_name)
	var frame_number: float = 0
	for png_path: String in png_list:
		new_animation.track_insert_key(frames_track,frame_number/FPS, frame_number)
		frame_number += 1
	print("frame number length: " + str(frame_number))
	print("animation: " + animation_name + " created in AnimatedSprite2D")
	animation_library.add_animation(animation_name, new_animation)


func add_animation_method_calls() -> void:
	var animation_list: Array[StringName] = animation_library.get_animation_list()
	print(animation_list)
	for animation: StringName in animation_list:
		var animation_to_modify: Animation = animation_library.get_animation(animation)
		var track: int = animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time : float = attack_frame/FPS
			var attack_again_time : float = attack_again_frame/FPS
			var cancel_time : float = cancel_frame / FPS
			#var cancel_time : float = attack_again_time + 1/FPS
			animation_to_modify.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)
		elif "parry" in animation:
			var time : float = attack_frame/FPS
			var attack_again_time : float = attack_again_frame/FPS
			var cancel_time : float = cancel_frame / FPS
			#var cancel_time : float = attack_again_time + 1/FPS
			animation_to_modify.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			#animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)


func animation_cancel_ready() -> void:
	is_executing = false


func attack_again_ready() -> void:
	ready_to_attack_again = true
	print("can attack again")


func disable_attack_zone() -> void:
	var timer: Timer = Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true


func get_hit(damage: int = 1) -> void:
	#if not audio.playing:
	#audio.stop()
	if hitpoints > 0:
		hitpoints -= damage
		print("ouch!")
		audio.pitch_scale = 0.90
		audio.pitch_scale += randf_range(-0.03, 0.03)
		audio.play()
		animated_sprite_2d.modulate = Color.RED
		var timer: Timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = 0.07
		timer.start()
		await timer.timeout
		timer.queue_free()
		animated_sprite_2d.modulate = Color.WHITE
	else:
		print("player died")
		dying = true
		

func _on_timer_timeout() -> void:
	pass


func execute(ability: Ability, target: Vector2 = Vector2(0,0)) -> void:
	animation_player.play(animations[current_direction][ability.animation_name])
	#ability.execute(target)


class Ability:
	var name: String
	var range_type: String
	var standing: bool
	var animation_name: String
	
	func _init(name: String, range_type: String, standing: bool = true) -> void:
		self.name = name
		self.range_type = range_type
		self.standing = standing
		self.animation_name = self.name
		
	func execute(target: Vector2 = Vector2(0,0)) -> void:
		print("executing " + name)
		if self.range_type != "self":
			print("execute on: " + str(target))
		
