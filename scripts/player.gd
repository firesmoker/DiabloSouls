class_name Player extends CharacterBody2D

@onready var game_manager: GameManager = %GameManager
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var attack_axis: Node2D
@export var animation_player: AnimationPlayer
@export var attack_zone: Area2D
@export var attack_collider: CollisionShape2D
@export var parry_collider: CollisionShape2D
@onready var animation_library: AnimationLibrary = animation_player.get_animation_library("")
@export_enum("warrior_armed", "fighter_armed", "knight_armed") var model: String = "warrior_armed"
@export var speed_fps_ratio: float = 121.0
@export var speed_modifier: float = 1
@export var attack_speed_modifier: float = 0.8
@export var dodge_speed_bonus: float = 3.5
@export var attack_frame: int = 3
@export var re_attack_frame: int = 3
@export var no_cancel_frame: float = 2.9
@export var attack_again_frame: int = 5
@export var max_hitpoints: float = 5
@export var hitpoints: float = 5
@export var stamina: float = 5
@export var max_stamina: float = 5
@export var mana: int = 5
@export var health_regen_amount: float = 0.006
@export var stamina_regen_amount: float = 0.02
@export var max_mana: int = 5
@export var invlunerable: bool = false
@export var animation_types: Array[String] = ["idle", "walk", "attack", "death", "parry"]
#var can_move: bool = false
var is_locked: bool = false
var is_chasing_enemy: bool = false
var is_dodging: bool = false
var ready_for_idle: bool= true
var ready_to_attack_again: bool = true
var is_attacking: bool = false

var stamina_regen_rate: float = 0.1
var stamina_regen_time: float = 0.0

var health_regen_rate: float = 0.1
var health_regen_time: float = 0.0

var dodge_cost: float = 2

var targeted_enemy: RigidBody2D = null
var enemies_in_melee: Array[Enemy]
#var abilities_queue: Array[Ability]
var is_dying: bool = false
var dead: bool = false

signal ready_to_attack_again_signal
signal attack_effects
signal attack_success
signal parry_success
signal execution_started
signal execution_aborted

var destination: Vector2 = Vector2()
var movement: Vector2 = Vector2()
var original_position: Vector2 = Vector2()

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
	hitpoints = max_hitpoints
	stamina = max_stamina
	mana = max_mana
	#animation_player.playback_default_blend_time
	#original_position = position
	destination = position
	construct_animation_library()
	add_animation_method_calls()
	if game_manager != null:
		pass


func _physics_process(delta: float) -> void:	
	stamina_regen(delta)
	health_regen(delta)
	
	if not is_dying:
		handle_movement(delta)
		
		if not is_locked:
			stop_on_destination()
			
			if velocity:
				running_state()
			else:
				standing_state()

		move_and_slide()
	elif not dead:
		animation_player.play(animations[current_direction]["death"])
		dead = true


func stamina_regen(delta_time: float) -> void:
	if stamina < max_stamina:
		stamina_regen_time += delta_time
		if stamina_regen_time >= stamina_regen_rate:
			stamina_regen_time = 0
			stamina += stamina_regen_amount
	else:
		stamina = 5
		stamina_regen_time = 0

func health_regen(delta_time: float) -> void:
	if hitpoints < max_hitpoints:
		health_regen_time += delta_time
		if health_regen_time >= health_regen_rate:
			health_regen_time = 0
			hitpoints += health_regen_amount
	else:
		hitpoints = 5
		health_regen_time = 0

func dodge(dodge_destination: Vector2) -> void:
	if stamina - dodge_cost < 0:
		print("not enough stamina")
	else:
		stamina -= dodge_cost
		print("dodging to " + str(dodge_destination))
		#can_move = true
		is_attacking = false
		#original_position = position
		destination = dodge_destination
		is_dodging = true
		invlunerable = true
		#set_collision_mask_value(1, false)
		#set_collision_layer_value(2, false)
		#set_collision_layer_value(3, true)
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.1
		timer.start()
		await timer.timeout
		#set_collision_mask_value(1, true)
		#set_collision_layer_value(2, true)
		#set_collision_layer_value(3, false)
		invlunerable = false
		if is_dodging != false:
			is_dodging = false
			#can_move = false
			velocity = Vector2(0,0)
			#original_position = position
			destination = position
		#can_move = true
		#velocity += dodge_destination
	

func _unhandled_input(event: InputEvent) -> void:
	if not is_dying:
		if event.is_action_pressed("dodge"):
			var face_destination: Vector2 = get_global_mouse_position()
			dodge(face_destination)
		
		if event.is_action_pressed("attack_in_place"):
			var face_destination: Vector2 = get_global_mouse_position()
			attack(face_destination)
		
		if event.is_action_pressed("parry"):
			if stamina - 1 < 0:
				print("not enough stamina")
			else:
				stamina -= 1
				if stamina < 0:
					stamina = 0
				var face_destination: Vector2 = get_global_mouse_position()
				attack(face_destination, parry_ability)
		
		if event.is_action_pressed("mouse_move") and not event.is_action_pressed("attack_in_place"):
			if game_manager.enemy_in_focus != null:
				targeted_enemy = game_manager.enemy_in_focus
				#can_move = false
				if targeted_enemy not in enemies_in_melee:
					move_to_enemy()
				else:
					attack(targeted_enemy.position)
			else:
				#print("unhandled input")
				#can_move = true
				is_attacking = false
				original_position = position
				destination = get_global_mouse_position()


func _on_melee_zone_body_entered(enemy: CollisionObject2D) -> void:
	#print("body entered " + str(enemy))
	enemies_in_melee.append(enemy)
	game_manager.enemy_in_player_melee_zone(enemy)
	if is_chasing_enemy and targeted_enemy == enemy:
		attack(enemy.position)


func _on_melee_zone_body_exited(enemy: CollisionObject2D) -> void:
	#print("body exited " + str(enemy))
	if enemy in enemies_in_melee:
		enemies_in_melee.erase(enemy)
		game_manager.enemy_in_player_melee_zone(enemy, false)


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		#print("attack finished fully")
		ready_for_idle = true


func _on_attack_zone_body_entered(body: CollisionObject2D) -> void:
	emit_signal("attack_success", body)


func _on_parry_zone_body_entered(body: CollisionObject2D) -> void:
	emit_signal("parry_success", body)
	print("parrying" + str(body) + "(in player.gd)")

func _on_attack_effects() -> void:
	#if not audio.playing:
		#audio.stop()
	audio.pitch_scale = 1
	audio.pitch_scale += randf_range(-0.03, 0.03)
	audio.play()


func stop_on_destination() -> void:
	if not is_attacking:
		print("trying to stop on destination")
		var distance_to_stop: float = 1.0
		#if speed_modifier > 1.8:
			#distance_to_stop = speed_modifier * 2
		if position.distance_to(original_position) > destination.distance_to(original_position):
			print("stopping because player is too far away")
			is_dodging = false
			velocity = Vector2(0,0)
			position = destination
			if not Input.is_action_pressed("mouse_move"):
				ready_for_idle = true
		elif abs(position.x - destination.x) <= distance_to_stop and abs(position.y - destination.y) <= distance_to_stop:
		#if position.distance_to(destination) <= 1:
			print("should be stopping")
			is_dodging = false
			velocity = Vector2(0,0)
			if not Input.is_action_pressed("mouse_move"):
				ready_for_idle = true


func running_state() -> void:
	var current_animation: String = animation_player.current_animation
	is_locked = false
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
		#can_move = false
		await animation_player.animation_finished
	#print("going idle!")
	if not is_dying:
		animation_player.play(animations[current_direction]["idle"])


func handle_movement(delta: float) -> void:
	if not is_attacking and not is_locked:
		if Input.is_action_pressed("mouse_move"):
			if game_manager.enemies_under_mouse.size() <= 0:
				is_chasing_enemy = false
				targeted_enemy = null
			is_attacking = false
			ready_for_idle = false
			original_position = position
			destination = get_global_mouse_position()
			if abs(position.x - destination.x) <= 5 and abs(position.y - destination.y) <= 5:
			#if position.distance_to(destination) <= 5:
				velocity = Vector2(0,0)
				#original_position = position
				destination = position
		if is_chasing_enemy and targeted_enemy != null:
			#original_position = position
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
	#can_move = false
	is_attacking = true
	if ability.range_type == "melee":
		#print("melee attack!")
		pass
	#else:
		#print("not melee")
	velocity = Vector2(0, 0)
	var angle: float = position.angle_to_point(attack_destination)
	set_direction_by_angle(angle)
	if not is_dying:
		animation_player.speed_scale = speed_modifier
		if not ready_to_attack_again and animation_player.current_animation_position >= re_attack_frame/FPS and ability != parry_ability:
			print("waiting for attack again ready")
			await ready_to_attack_again_signal
			print("thinking can attack again and it is: " + str(ready_to_attack_again))
			ready_to_attack_again = false
			#is_locked = true
			attack_axis.rotation = angle
			animation_player.stop()
			execute(ability)
		if ready_to_attack_again:
			#is_locked = true
			ready_to_attack_again = false
			attack_axis.rotation = angle
			#print("first or restarted attack")
			animation_player.stop()
			#animation_player.play(animations[current_direction][attack_ability.animation_name])
			execute(ability)
		elif attack_collider.disabled == true:
			attack_axis.rotation = angle
			#print("normal attack")
			var current_animation_position: float = animation_player.current_animation_position
			
			if current_animation_position < attack_frame/FPS or current_animation_position >= attack_again_frame/FPS:
				#animation_player.play(animations[current_direction][attack_ability.animation_name])
				execute(ability)
				animation_player.seek(current_animation_position)
			#else:
				#print("trying to queue attack whil attack collider is disabled")
				#await attack_again_ready()
				#print(ready_to_attack_again)
				#print("re-attack")	
				#animation_player.stop()
				#execute(ability)
		#elif not ready_to_attack_again:
			#print("trying to queue attack! while attack collider is EXACTLY ENABLED")
			#await attack_again_ready()
			#print(ready_to_attack_again)
			#print("re-attack")
			#animation_player.stop()
			#execute(ability)
	

func move_to_enemy() -> void:
	if targeted_enemy == null:
		targeted_enemy = game_manager.enemy_in_focus
		if targeted_enemy == null:
			print("enemy null")
			return
		
	is_chasing_enemy = true
	#original_position = position
	destination = targeted_enemy.position
	#can_move = true
	is_attacking = false


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
	if is_dodging:
		print("dodge calculation")
		return Vector2(max_velocity_x * dodge_speed_bonus, max_velocity_y * dodge_speed_bonus)
	#return Vector2(max_velocity_x, max_velocity_y)
	print(position.direction_to(destination) * speed_fps_ratio * speed_modifier)
	return position.direction_to(destination) * speed_fps_ratio * speed_modifier


func just_attacked() -> void: # THIS
	print("pow!")
	attack_collider.disabled = false
	emit_signal("attack_effects")
	disable_attack_zone()

func just_parried() -> void: # THIS
	print("PARRY!")
	parry_collider.disabled = false
	emit_signal("attack_effects")
	disable_parry_zone()


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
				#print("forcing parry to use attack assets") # TEMPORARY
			break
	
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 12.0)
	frames.set_animation_loop(animation_name, true)
	
	#get all pngs to add to each frame of the animation
	var assets_path: String = model + "/" + model + "_" + action_type + "/" + direction_name[direction]
	var png_list: Array[String] = game_manager.dir_contents_filter("res://assets/art/playable character/" + assets_path,"png", false)
	
	# add new frames to the spriteframes resource
	var count: int = 0
	for png_path: String in png_list:
		if "parry" in animation_name:
			count += 1
			if count >= 3:
				break
		var frame_png: Texture2D  = load(png_path)
		frames.add_frame(animation_name,frame_png)
	#print("animation: " + animation_name + " created in AnimatedSprite2D")
	
	# create the matching animations in AnimationPlayer
	var new_animation: Animation = Animation.new()
	var frames_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(frames_track,"AnimatedSprite2D:frame")
	new_animation.loop_mode = Animation.LOOP_NONE
	if count <= 0:
		new_animation.length = png_list.size()/FPS
	else:
		new_animation.length = count/FPS
	var name_track : int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(name_track,"AnimatedSprite2D:animation")
	new_animation.track_insert_key(name_track,0,animation_name)
	var frame_number: float = 0
	for png_path: String in png_list:
		new_animation.track_insert_key(frames_track,frame_number/FPS, frame_number)
		frame_number += 1
	#print("frame number length: " + str(frame_number))
	#print("animation: " + animation_name + " created in AnimatedSprite2D")
	animation_library.add_animation(animation_name, new_animation)


func add_animation_method_calls() -> void:
	var animation_list: Array[StringName] = animation_library.get_animation_list()
	#print(animation_list)
	for animation: StringName in animation_list:
		var animation_to_modify: Animation = animation_library.get_animation(animation)
		var track: int = animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time : float = attack_frame/FPS
			var attack_again_time : float = attack_again_frame/FPS
			var no_cancel_time : float = no_cancel_frame / FPS
			#var cancel_time : float = attack_again_time + 1/FPS
			animation_to_modify.track_insert_key(track, no_cancel_time, {"method" : "animation_cancel_disabled" , "args" : []})
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []})
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []})
		elif "parry" in animation:
			var time : float = 0/FPS
			var attack_again_time : float = 2/FPS
			var no_cancel_time : float = 1 / FPS
			#var cancel_time : float = attack_again_time + 1/FPS
			animation_to_modify.track_insert_key(track, no_cancel_time, {"method" : "animation_cancel_disabled" , "args" : []})
			animation_to_modify.track_insert_key(track, time, {"method" : "just_parried" , "args" : []})
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []})


func animation_cancel_disabled() -> void:
	is_locked = true


func attack_again_ready() -> void:
	is_locked = false
	ready_to_attack_again = true
	emit_signal("ready_to_attack_again_signal")


func disable_attack_zone() -> void:
	var timer: Timer = Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true

func disable_parry_zone() -> void:
	var timer: Timer = Timer.new()
	parry_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	parry_collider.disabled = true


func get_hit(damage: int = 1) -> void:
	if invlunerable:
		damage = 0
	if hitpoints - damage <= 0:
		hitpoints -= damage
		is_dying = true
	elif hitpoints > 0:
		hitpoints -= damage
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
		
		

func _on_timer_timeout() -> void:
	pass


func execute(ability: Ability, target: Vector2 = Vector2(0,0)) -> void:
	animation_player.speed_scale = 1 * attack_speed_modifier
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
		#print("executing " + name)
		if self.range_type != "self":
			#print("execute on: " + str(target))
			pass
		


