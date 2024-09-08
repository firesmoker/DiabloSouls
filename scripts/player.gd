class_name Player extends CharacterBody2D
@onready var light: Sprite2D = $Light

@onready var audio_player: AudioPlayer = $AudioPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var ray_cast: RayCast2D = $Rays/RayCast2
@onready var ray_axis: Node2D = $Rays

var last_movement_offset: int = 0
var minimum_collision_distance: float = 0

@export var rays: Array[RayCast2D]
@export var rays_right: Array[RayCast2D]
@export var rays_left: Array[RayCast2D]
@export var blood_template: PackedScene

@onready var game_manager: GameManager = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var light_radius: float = 3.5
@export var projectile: PackedScene
@export var attack_axis: Node2D
@export var animation_player: AnimationPlayer
@export var attack_zone: Area2D
@export var attack_collider: CollisionShape2D
@export var parry_collider: CollisionShape2D
@onready var animation_library: AnimationLibrary = animation_player.get_animation_library("")
@export_enum("warrior_armed", "fighter_armed", "knight_armed") var model: String = "warrior_armed"
@export var speed_fps_ratio: float = 121.0
@export var moving_speed_modifier: float = 1
@export var attack_speed_modifier: float = 0.8
@export var dodge_speed_bonus: float = 3.5
@export var attack_frame: int = 3
@export var re_attack_frame: int = 3
@export var no_cancel_frame: float = 2.9
@export var attack_again_frame: int = 5
@export var max_hitpoints: float = 5
var hitpoints: float = 5
var stamina: float = 5
@export var max_stamina: float = 5
var mana: float = 5
@export var health_regen_amount: float = 0.006
@export var stamina_regen_amount: float = 0.02
@export var mana_regen_amount: float = 0.02
@export var max_mana: float = 5
@export var invlunerable: bool = false
@export var animation_types: Array[String] = ["idle", "walk", "attack", "death", "parry", "defend", "ranged_attack"]
@export var attack_with_melee: bool = false # TEMPORARY
var is_locked: bool = false
var is_chasing_enemy: bool = false
var is_dodging: bool = false
var is_idle: bool= true
var ready_to_attack_again: bool = true
var is_attacking: bool = false
var is_defending: bool = false
var is_parrying: bool = false

var stamina_regen_rate: float = 0.1
var stamina_regen_time: float = 0.0

var health_regen_rate: float = 0.1
var health_regen_time: float = 0.0

var mana_regen_rate: float = 0.1
var mana_regen_time: float = 0.0

var dodge_cost: float = 1
var is_moving_with_offset: bool = false
var number_of_offset_frames: int = 0

var targeted_enemy: Enemy = null
var enemies_in_melee: Array[Enemy]
var enemies_in_defense_zone: Array[Enemy]
#var abilities_queue: Array[Ability]
var is_dying: bool = false
var dead: bool = false
var target_for_ranged: Vector2

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
var ranged_ability: Ability = Ability.new("ranged_attack", "ranged", true, 1.4)

func _ready() -> void:

	motion_mode = 1
	hitpoints = max_hitpoints
	stamina = max_stamina
	mana = max_mana
	destination = position
	construct_animation_library()
	add_animation_method_calls()
	if game_manager != null:
		pass


func _physics_process(delta: float) -> void:	
	light.material.set_shader_parameter("radius", light_radius)
	mana_regen(delta)
	stamina_regen(delta)
	health_regen(delta)
	
	if not is_dying:
		handle_movement(delta)
		handle_block(delta)
		
		if not is_locked:
			stop_on_destination()
			
			if velocity:
				running_state()
			else:
				standing_state()

		move_and_slide()
	elif not dead:
		animation_player.play(animations[current_direction]["death"])
		audio_player.play("Death")
		dead = true


func mana_regen(delta_time: float) -> void:
	if mana < max_mana and not is_dying:
		mana_regen_time += delta_time
		if mana_regen_time >= mana_regen_rate:
			mana_regen_time = 0
			mana += mana_regen_amount
	elif is_dying:
		mana = mana
	else:
		mana = max_mana
		mana_regen_time = 0


func stamina_regen(delta_time: float) -> void:
	if stamina < max_stamina and not is_dying:
		stamina_regen_time += delta_time
		if stamina_regen_time >= stamina_regen_rate:
			stamina_regen_time = 0
			stamina += stamina_regen_amount
	elif is_dying:
		stamina = stamina
	else:
		stamina = max_stamina
		stamina_regen_time = 0

func health_regen(delta_time: float) -> void:
	if hitpoints < max_hitpoints and not is_dying:
		health_regen_time += delta_time
		if health_regen_time >= health_regen_rate:
			health_regen_time = 0
			hitpoints += health_regen_amount
	elif is_dying:
		hitpoints = 0
	else:
		hitpoints = max_hitpoints
		health_regen_time = 0

func dodge(dodge_destination: Vector2) -> void:
	if stamina - dodge_cost < 0:
		print("not enough stamina")
	elif not is_dodging and not is_locked:
		is_dodging = true
		animation_player.stop()
		audio_player.play("Dodge")
		stamina -= dodge_cost
		#print("dodging to " + str(dodge_destination))
		is_attacking = false
		#original_position = position
		destination = dodge_destination
		invlunerable = true
		animated_sprite_2d.material.set_shader_parameter("dir_x", 0.025)
		#set_collision_mask_value(1, false)
		#set_collision_layer_value(2, false)
		#set_collision_layer_value(3, true)
		var timer: Timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.1
		timer.start()
		await timer.timeout
		animated_sprite_2d.material.set_shader_parameter("dir_x", 0.0)
		#set_collision_mask_value(1, true)
		#set_collision_layer_value(2, true)
		#set_collision_layer_value(3, false)
		invlunerable = false
		if is_dodging != false:
			is_dodging = false
			velocity = Vector2(0,0)
			#original_position = position
			destination = position
	#velocity += dodge_destination
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test_button"): # TEMPORARY
		animation_player.play(animations[current_direction]["walk"]) # TEMPORARY
	
	if event.is_action_pressed("speed up"): # TEMPORARY
		print("more speed") # TEMPORARY
		var speed_change:float = 115.0 / 100.0 # TEMPORARY
		moving_speed_modifier *= speed_change # TEMPORARY
		
	elif event.is_action_pressed("speed down"): # TEMPORARY
		print("less speed") # TEMPORARY
		var speed_change:float = 100.0 / 115.0 # TEMPORARY
		moving_speed_modifier *= speed_change # TEMPORARY
		
		
	if not is_dying:
		if event.is_action_pressed("dodge"):
			var face_destination: Vector2 = get_global_mouse_position()
			dodge(face_destination)
		
		if event.is_action_pressed("attack_in_place"):
			var face_destination: Vector2 = get_global_mouse_position()
			attack(face_destination)
		
		if event.is_action_pressed("ability_1"):
			var face_destination: Vector2
			if game_manager.enemy_in_focus != null:
				face_destination = game_manager.enemy_in_focus.position
				target_for_ranged = game_manager.enemy_in_focus.position
			else:
				face_destination = get_global_mouse_position()
				target_for_ranged = get_global_mouse_position()
			if mana - 1 < 0:
				print("not enough stamina")
			else:
				mana -= 1
				if mana < 0:
					mana = 0
				attack(face_destination, ranged_ability)
		
		if event.is_action_pressed("parry"):
			if not is_locked:
				if stamina - 1 < 0:
					print("not enough stamina")
				else:
					stamina -= 1
					if stamina < 0:
						stamina = 0
					var face_destination: Vector2 = get_global_mouse_position()
					attack(face_destination, parry_ability)
		
		if event.is_action_pressed("mouse_move") and not event.is_action_pressed("attack_in_place") and not event.is_action_pressed("parry"):
			if game_manager.enemy_in_focus != null:
				targeted_enemy = game_manager.enemy_in_focus
				if targeted_enemy not in enemies_in_melee and attack_with_melee:
					move_to_enemy()
				elif not attack_with_melee:
					
					var face_destination: Vector2
					face_destination = game_manager.enemy_in_focus.position
					target_for_ranged = game_manager.enemy_in_focus.position
					
					if mana - 1 < 0:
						print("not enough stamina")
					else:
						mana -= 1
						if mana < 0:
							mana = 0
						attack(face_destination, ranged_ability)
					
				else:
					attack(targeted_enemy.position)
			else:
				#print("unhandled input")
				is_attacking = false
				original_position = position
				destination = get_global_mouse_position()
		elif event.is_action_released("mouse_move"):
			last_movement_offset = 0
			var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(get_world_2d().navigation_map, get_global_mouse_position())
			destination = closest_point - (closest_point - global_position).normalized() * 5


func _on_melee_zone_body_entered(enemy: RigidBody2D) -> void:
	#print("body entered " + str(enemy))
	enemies_in_melee.append(enemy)
	game_manager.enemy_in_player_melee_zone(enemy)
	if is_chasing_enemy and targeted_enemy == enemy:
		attack(enemy.position)


func _on_melee_zone_body_exited(enemy: RigidBody2D) -> void:
	#print("body exited " + str(enemy))
	if enemy in enemies_in_melee:
		enemies_in_melee.erase(enemy)
		game_manager.enemy_in_player_melee_zone(enemy, false)


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		#print("attack finished fully")
		is_idle = true
		#is_attacking = false


func _on_attack_zone_body_entered(body: RigidBody2D) -> void:
	emit_signal("attack_success", body)
	audio_player.play("Hit")
	var effect_position: Vector2 = body.position + Vector2(0, -10.0)
	#create_blood_effect(effect_position)
	print(str(body) + " has entered attack zone")


func create_blood_effect(effect_position: Vector2, custom_parent: Node = null) -> void:
	var blood_effect: Node2D = blood_template.instantiate() as Node2D
	if custom_parent == null:
		get_tree().root.add_child(blood_effect)
	else:
		custom_parent.add_child(blood_effect)
		blood_effect.z_as_relative = true
		blood_effect.z_index = custom_parent.z_index + 1
		blood_effect.y_sort_enabled = false
	blood_effect.global_position = effect_position


func _on_parry_zone_body_entered(enemy: RigidBody2D) -> void:
	enemies_in_defense_zone.append(enemy)
	print("enemies in parry: " + str(enemy))
	if not is_defending and is_parrying:
		emit_signal("parry_success", enemy)
		print("parrying" + str(enemy) + "(in player.gd)")
	#else:
		#enemies_in_defense_zone.append(enemy)


func _on_parry_zone_body_exited(enemy: RigidBody2D) -> void:
	enemies_in_defense_zone.erase(enemy)

func _on_attack_effects() -> void:
	pass


func stop_on_destination() -> void:
	if velocity:
		#print("trying to stop on destination " + str(velocity))
		var distance_to_stop: float = 1.0
		#if moving_speed_modifier > 1.8:
			#distance_to_stop = moving_speed_modifier * 2
		if position.distance_to(original_position) > destination.distance_to(original_position):
			#print("stopping because player is too far away")
			is_dodging = false
			velocity = Vector2(0,0)
			position = destination
			if not Input.is_action_pressed("mouse_move"):
				is_idle = true
				#is_attacking = false
		elif position.distance_to(destination) <= distance_to_stop:
		#if position.distance_to(destination) <= 1:
			#print("should be stopping " + str(velocity))
			is_dodging = false
			velocity = Vector2(0,0)
			if not Input.is_action_pressed("mouse_move"):
				is_idle = true
				#is_attacking = false


func running_state() -> void:
	if not is_moving_with_offset:
		set_direction_by_destination(nav.get_next_path_position())
	else:
		set_direction_by_velocity(velocity)
	#set_direction_by_velocity(velocity)
	var current_animation: String = animation_player.current_animation
	is_locked = false
	ready_to_attack_again = true
	if moving_speed_modifier >= 2:
		animation_player.speed_scale = moving_speed_modifier / 2
	else:
		animation_player.speed_scale = moving_speed_modifier
	if "walk" in current_animation and current_animation != animations[current_direction]["walk"]:
		var current_animation_position: float = animation_player.current_animation_position
		animation_player.play(animations[current_direction]["walk"])
		animation_player.seek(current_animation_position)
	else:
		animation_player.play(animations[current_direction]["walk"])


func standing_state() -> void:
	if "attack" in animation_player.current_animation or "parry" in animation_player.current_animation:
		await animation_player.animation_finished
	if not is_dying:
		animation_player.play(animations[current_direction]["idle"])



func handle_movement(delta: float) -> void:
	var offset: float = 0
	var move_offset: Vector2 = Vector2(0,0)
	if not is_attacking and not is_locked and not is_defending:
		if Input.is_action_pressed("mouse_move"):
			if game_manager.enemies_under_mouse.size() <= 0:
				is_chasing_enemy = false
				targeted_enemy = null
			#is_attacking = false
			is_idle = false
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
		var collisions: float = 0
		#var collisions: float = ray_coliisions()
		#print(collisions)
		if collisions != 0 and not Input.is_action_pressed("mouse_move") and not is_dodging:
			if global_position.distance_to(destination) - minimum_collision_distance > 5:
				offset = collisions
				is_moving_with_offset = true
			else:
				is_moving_with_offset = false
		else:
			is_moving_with_offset = false
			#var body: Object = ray_cast.get_collider()
			#if body.get_script():
				#if body.get_script().get_global_name() == "Enemy":
					#print("offset!")
					#offset = true
		var new_velocity: Vector2 = calculate_movement_velocity(offset)
		#if offset:
		ray_axis.rotation = position.angle_to_point(destination)
		velocity = (new_velocity + move_offset) * delta / average_delta

func ray_coliisions() -> float:
	var direction_angle: int = 0
	var collision_count: int = 0
	var count: int = 0
	var angle_size: float = 7.5
	var colliding_with_enemy: bool = false
	var positive_collisions: int = 0
	var negative_collisions: int = 0
	var maximum_collision_distance: float = global_position.distance_to(rays[5].target_position)
	minimum_collision_distance = maximum_collision_distance
	for ray in rays:
		colliding_with_enemy = false
		if ray.is_colliding():
			if ray.get_collider().get_script():
				if ray.get_collider().get_script().get_global_name() == "Enemy":
					colliding_with_enemy = true
			if colliding_with_enemy:
				var collision_point_distance: float = global_position.distance_to(rays[count].get_collision_point())
				if collision_point_distance < minimum_collision_distance:
					minimum_collision_distance = collision_point_distance
				collision_count += 1
				if count < 4:
					direction_angle += angle_size
					positive_collisions += 1
				else:
					direction_angle -= angle_size
					negative_collisions += 1
		count += 1
	#if count >= 2:
		#number_of_offset_frames += 1
	#if collision_count <= 0:
		#number_of_offset_frames = 0
	#if number_of_offset_frames >= 2:
		#return deg_to_rad(direction_counter)
		
	#if collision_count > 0 and direction_angle == 0:
		#return deg_to_rad(angle_size * collision_count)
	#if collision_count > rays.size() / 2:
		#pass
	#return deg_to_rad(direction_angle)
	
	var distance_ratio: float = (maximum_collision_distance - minimum_collision_distance) / maximum_collision_distance
	if last_movement_offset == 1:
		if positive_collisions > 0:
			last_movement_offset = 1
			return deg_to_rad((positive_collisions + collision_count) * angle_size * distance_ratio)
		#if positive_collisions <= 0:
		last_movement_offset = 0
		return 0
	elif last_movement_offset == 2:
		if negative_collisions > 0:
			last_movement_offset = 2
			return deg_to_rad((negative_collisions + collision_count) * -angle_size * distance_ratio)
		#if negative_collisions <= 0:
		last_movement_offset = 0
		return 0
	else:
		if positive_collisions > negative_collisions:
			last_movement_offset = 1
			return deg_to_rad((positive_collisions + collision_count) * angle_size * distance_ratio)
		elif negative_collisions > 0:
			last_movement_offset = 2
			return deg_to_rad((negative_collisions + collision_count) * -angle_size * distance_ratio)
		else:
			last_movement_offset = 0
			return deg_to_rad((positive_collisions + collision_count) * angle_size * distance_ratio)
		
		
	
	#return 0

func set_direction_by_velocity(moving_velocity: Vector2) -> void:
	var angle: float = position.angle_to_point(global_position + moving_velocity)
	var half_rand: float = (0.5/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = round_to_multiple(angle, half_rand)
	current_direction = radian_direction[rounded_rand]

func set_direction_by_destination(look_destination: Vector2 = destination) -> void:
	var angle: float = position.angle_to_point(look_destination)
	var half_rand: float = (0.5/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = round_to_multiple(angle, half_rand)
	current_direction = radian_direction[rounded_rand]

func handle_block(delta: float) -> void:
	#if not is_attacking:
	if Input.is_action_pressed("parry"):
		if "parry" in animation_player.current_animation:
			await animation_player.animation_finished
			print("parry animation finished")
		if Input.is_action_pressed("parry"):
			print("handle block -> blocking -> collider = NOT disabled")
			parry_collider.disabled = false
			var defend_destination: Vector2 = get_global_mouse_position()
			var angle: float = position.angle_to_point(defend_destination)
			attack_axis.rotation = angle
			set_direction_by_destination(defend_destination)
			targeted_enemy = null
			is_idle = false
			is_defending = true
			is_locked = true
			#invlunerable = true
			velocity = Vector2(0, 0)
			print("trying to play defened animation")
			animation_player.play(animations[current_direction]["defend"])
		else:
			print("disabled parry collider after animation finished")
			parry_collider.disabled = true
		
	if Input.is_action_just_released("parry"):
		if is_defending:
			print("released defense -> collider = disabled")
			is_defending = false
			is_locked = false
			invlunerable = false
			destination = position
			parry_collider.disabled = true
		else:
			print("released parry")

func attack(attack_destination: Vector2, ability: Ability = attack_ability, speed: float = 1) -> void:
	#abilities_queue.append(attack_ability)
	is_chasing_enemy = false
	targeted_enemy = null
	is_idle = false
	#can_move = false
	is_defending = false
	is_attacking = true
	if ability.range_type == "melee":
		#print("melee attack!")
		pass
	#else:
		#print("not melee")
	velocity = Vector2(0, 0)
	var angle: float = position.angle_to_point(attack_destination)
	set_direction_by_destination(attack_destination)
	if not is_dying:
		animation_player.speed_scale = moving_speed_modifier
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


func calculate_movement_velocity(offset: float = 0) -> Vector2:

	nav.target_position = destination
	
	var direction: Vector2 = Vector2()
	direction = nav.get_next_path_position() - global_position
	if offset != 0:
		direction = direction.rotated(offset)
		
		var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(get_world_2d().navigation_map, (global_position + direction))
		direction = closest_point - global_position
		#directions = findclo
	
	direction = direction.normalized()
	#get_angle_to()
	
	
	if is_dodging:
		#print("dodge calculation")
		#return Vector2(max_velocity_x * dodge_speed_bonus, max_velocity_y * dodge_speed_bonus)
		
		return direction * speed_fps_ratio * moving_speed_modifier * dodge_speed_bonus
	#return Vector2(max_velocity_x, max_velocity_y)
	#print(position.direction_to(destination) * speed_fps_ratio * moving_speed_modifier)
	#print(direction)
	return direction * speed_fps_ratio * moving_speed_modifier


func just_attacked(attack_type: String = "melee") -> void: # THIS
	if attack_type == "melee":
		print("melee attack")
		attack_collider.disabled = false
		emit_signal("attack_effects")
		disable_attack_zone()
	elif attack_type == "ranged":
		if target_for_ranged == null:
			target_for_ranged = get_global_mouse_position()
		print("ranged attack")
		emit_signal("attack_effects")
		create_projectile(target_for_ranged, 4)

func create_projectile(target: Vector2 = Vector2(0,0), speed: float = 1.0) -> void:
	var instance: Projectile = projectile.instantiate() as Projectile
	instance.targets_player = false
	get_tree().root.add_child(instance)
	instance.collision_shape.scale *= 2.5
	instance.global_position = global_position
	instance.rotation += get_angle_to(target)
	instance.position += position.direction_to(target) * 30
	instance.velocity = position.direction_to(target) * speed


func just_parried() -> void: # THIS
	print("PARRY! -> collider not disabled")
	is_parrying = true
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
			if action_type == "defend": # TEMPORARY
				action_type = "attack" # TEMPORARY
				print("forcing defend to use attack assets for direction " + direction_name[direction]) # TEMPORARY
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
		if "parry" in animation_name: # TEMPORARY
			count += 1 # TEMPORARY
			if count >= 3: # TEMPORARY
				break # TEMPORARY
		if "defend" in animation_name: # TEMPORARY
			#count += 1 # TEMPORARY
			#if count >= 3: # TEMPORARY
			var frame_png: Texture2D  = load(png_list[2]) # TEMPORARY
			frames.add_frame(animation_name,frame_png) # TEMPORARY
			break # TEMPORARY
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
		if "ranged_attack" in animation:
			var time : float = attack_frame/FPS
			var attack_again_time : float = attack_again_frame/FPS
			var no_cancel_time : float = no_cancel_frame / FPS
			#var cancel_time : float = attack_again_time + 1/FPS
			animation_to_modify.track_insert_key(track, no_cancel_time, {"method" : "animation_cancel_disabled" , "args" : []})
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : ["ranged"]})
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []})
		elif "attack" in animation:
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
	if not Input.is_action_pressed("parry"):
		print("disable parry zone -> collider = disabled")
		parry_collider.disabled = true


func get_hit(damage: int = 1) -> void:
	if invlunerable:
		damage = 0
	if hitpoints - damage <= 0:
		hitpoints -= damage
		is_dying = true
	elif hitpoints > 0:
		hitpoints -= damage
		animated_sprite_2d.material.set_shader_parameter("modulated_color", Color.RED)
		var timer: Timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = 0.07
		timer.start()
		await timer.timeout
		timer.queue_free()
		animated_sprite_2d.material.set_shader_parameter("modulated_color", Color.WHITE)
		

func _on_timer_timeout() -> void:
	pass


func execute(ability: Ability, speed: float = ability.attack_speed) -> void:
	animation_player.speed_scale = speed * attack_speed_modifier
	animation_player.play(animations[current_direction][ability.animation_name])
	#ability.execute(target)


class Ability:
	var name: String
	var range_type: String
	var standing: bool
	var animation_name: String
	var attack_speed: float
	
	func _init(name: String, range_type: String, standing: bool = true, attack_speed: float = 1) -> void:
		self.name = name
		self.range_type = range_type
		self.standing = standing
		self.animation_name = self.name
		self.attack_speed = attack_speed
		
	func execute(target: Vector2 = Vector2(0,0)) -> void:
		#print("executing " + name)
		if self.range_type != "self":
			#print("execute on: " + str(target))
			pass
		
