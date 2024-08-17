class_name Enemy extends RigidBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: GameManager = %GameManager
@onready var highlight_circle: Sprite2D = $HighlightCircle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_library: AnimationLibrary
@onready var attack_axis: Node2D = $AttackAxis
@onready var attack_zone: Area2D = $AttackAxis/AttackZone
@onready var attack_collider: CollisionShape2D = $AttackAxis/AttackZone/AttackCollider
@onready var health_bar: ProgressBar = $HealthBar

@export var body_color: Color = Color.WHITE
@export var id: String = "Enemy"
@export var base_id: String
@export_enum("skeleton_default", "slime", "demonlord") var model: String = "skeleton_default"
@export_enum("normal", "boss") var category: String = "normal"
@export var speed_fps_ratio: float = 42.35
@export var move_speed_modifier: float = 1
@export var attack_speed_modifier: float = 0.7
@export var attack_frame: int = 3
@export var hitpoints_max: int = 2
@export var hitpoints: int = 2
@export var has_attack: bool = false
@export var animation_types: Array[String] = ["idle", "walk"]

var move_offset: Vector2 = Vector2(0,0)
var moving: bool = true
var dying: bool = false
var can_attack: bool = true
var attacking: bool = false
var switch_animation_timer: Timer
var adjacent_enemies: Array = []
var can_be_countered: bool = false
var can_be_parried: bool = false
var stunned: bool = false
var stun_time: float = 1
var in_melee: bool = false
var in_player_melee_zone: bool = false
var perry_subdued: bool = false

const FPS: float = 12.0
const average_delta: float = 0.01666666666667

var sprite_material: Material
var player: Player
var destination: Vector2
var player_in_range: bool = false
var attack_range: float = 35
var ready_to_switch_direction: bool = true

var animations: Dictionary = {}
var current_direction: int = directions.E
enum directions{N,NE,E,SE,S,SW,W,NW}
var direction_name: Dictionary = {
	directions.N : "N",
	directions.NE : "NE",
	directions.E : "E",
	directions.SE : "SE",
	directions.S : "S",
	directions.SW : "SW",
	directions.W : "W",
	directions.NW : "NW",
}

var radian_direction: Dictionary = {
	-2.0/4 * PI: directions.N,
	-1.0/4 * PI: directions.NE,
	0.0/4 * PI: directions.E,
	1.0/4 * PI: directions.SE,
	2.0/4 * PI: directions.S,
	3.0/4 * PI: directions.SW,
	4.0/4 * PI: directions.W,
	-4.0/4 * PI: directions.W,
	-3.0/4 * PI: directions.NW,
}

signal under_mouse_hover
signal stopped_mouse_hover


func _ready() -> void:
	#custom_integrator = true
	animated_sprite_2d.material.set_shader_parameter("modulated_color", body_color)
	health_bar.max_value = hitpoints_max
	hitpoints = hitpoints_max
	health_bar.value = hitpoints
	health_bar.visible = false
	highlight_circle.modulate = Color.TRANSPARENT
	switch_animation_timer = Timer.new()
	self.add_child(switch_animation_timer)
	gravity_scale = 0
	animation_library = animation_player.get_animation_library("")
	construct_animation_library()
	add_animation_method_calls()
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		player = game_manager.player
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)


#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#state.linear_velocity = Vector2.ZERO
	#state.angular_velocity = 0


func _process(delta: float) -> void:
	handle_parry_visibility()
		
	if player.dead and in_melee:
		in_melee = false
	elif !player.dead:
		destination = player.position
	else:
		destination = position
		moving = false
		
	if "attack" in animation_player.current_animation:
		moving = false
		await animation_player.animation_finished
	if not dying and not stunned:
		animation_player.speed_scale = attack_speed_modifier
		#if position.distance_to(player.position) <= attack_range and has_attack:
		if in_melee and has_attack:
			can_attack = true
			attacking = true
			var angle: float = position.angle_to_point(player.position)
			
			var rand: float = (1/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
			var rounded_rand: float = float(round(angle / rand) * rand)
			current_direction = radian_direction[rounded_rand]
			
			attack_axis.rotation = angle
			animation_player.play(animations[current_direction]["attack"])
		else:
			can_attack = false
			attacking = false
		if not attacking:
			if moving and not stunned:
				set_direction_by_angle()
				var velocity: Vector2 = calculate_movement() * move_speed_modifier * delta
				move_and_collide(velocity)
				var animation_before_change: String = animation_player.current_animation
				animation_player.speed_scale = move_speed_modifier
				animation_player.play(animations[current_direction]["walk"])
				if animation_player.current_animation != animation_before_change and animation_player.current_animation in animation_library:
					animation_player.seek(randi_range(0, 3) / FPS)
			else:
				animation_player.play(animations[current_direction]["idle"])

func handle_parry_visibility() -> void:
	if player.is_locked and not perry_subdued:
		perry_subdued = true
		highlight_circle.modulate = Color.TRANSPARENT
		highlight_circle.process_mode = Node.PROCESS_MODE_DISABLED
	elif perry_subdued:
		perry_subdued = false
		highlight_circle.process_mode = Node.PROCESS_MODE_INHERIT


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	if not attacking and has_attack:
		moving = true


func _on_hover_zone_mouse_entered() -> void:
	emit_signal("under_mouse_hover", self)


func _on_hover_zone_mouse_exited() -> void:
	emit_signal("stopped_mouse_hover", self)


func _on_clump_zone_body_entered(body: CollisionObject2D) -> void: 
	if body != player and body != self:
		adjacent_enemies.append(body)


func _on_clump_zone_body_exited(body: CollisionObject2D) -> void:
	if body != player and body != self:
		adjacent_enemies.erase(body)

func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		in_melee = true
		highlight_circle.visible = true
		moving = false

func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		in_melee = false
		if not in_player_melee_zone:
			highlight_circle.visible = false
		highlight_circle.modulate = Color.TRANSPARENT
		moving = true
		
func _on_attack_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		if self in player.enemies_in_defense_zone and player.is_defending:
			print(str(self) + " in defense zone when trying to attack")
		else:
			game_manager.player_gets_hit()
	else:
		print(body)
		print("not player")


func switch_direction() -> void:
	await switch_animation_timer.timeout
	ready_to_switch_direction = true

func get_stunned() -> void:
	animation_player.stop()
	highlight_circle.modulate = Color.TRANSPARENT
	var stun_timer: Timer = Timer.new()
	self.add_child(stun_timer)
	stun_timer.wait_time = stun_time
	stun_timer.set_physics_process(true)
	stunned = true
	moving = false
	stun_timer.start()
	await stun_timer.timeout
	stunned = false
	moving = true
	stun_timer.queue_free()

func get_parried(counter: bool = false) -> void:
	if counter:
		print("COUNTER!")
		
		game_manager.camera_shake_and_color()
		get_hit(2)
	else:
		animated_sprite_2d.modulate = Color.BLUE
	if not dying:
		can_be_parried = false
		can_be_countered = false
		highlight_circle.modulate = Color.TRANSPARENT
		get_stunned()

		var timer: Timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = 0.07
		timer.start()
		
		await timer.timeout
		timer.queue_free()
		animated_sprite_2d.modulate = body_color
		if not dying:
			animation_player.stop()
		attack_collider.disabled = true

func get_hit(damage: int = randi_range(1,3)) -> bool:
	can_be_parried = false
	can_be_countered = false
	highlight_circle.modulate = Color.TRANSPARENT
	animated_sprite_2d.modulate = Color.RED
	var timer: Timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = 0.07
	timer.start()
	await timer.timeout
	timer.queue_free()
	animated_sprite_2d.modulate = body_color
	hitpoints -= damage
	if hitpoints <= 0:
		health_bar.visible = false
		die()
		return true
	elif not dying:
		health_bar.value = hitpoints
		health_bar.visible = true
		if randi() % 100 + 1 > 50:
			animation_player.stop()
		attack_collider.disabled = true
	return false

func set_direction_by_angle(angle: float = position.angle_to_point(destination)) -> void:
	var rand: float = (1/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = float(round(angle / rand) * rand)
	if ready_to_switch_direction:
		ready_to_switch_direction = false
		current_direction = radian_direction[rounded_rand]
		switch_animation_timer.paused = false
		switch_animation_timer.start(0.2)
		#switch_direction()
		await switch_animation_timer.timeout
		ready_to_switch_direction = true

func calculate_movement() -> Vector2:
	if stunned:
		return Vector2(0, 0)
	move_offset = Vector2(0,0)
	for enemy: CollisionObject2D in adjacent_enemies:
		move_offset += position - enemy.position
	var movement_vector: Vector2 = position.direction_to(destination) * speed_fps_ratio
	return Vector2(movement_vector.x + move_offset.x, movement_vector.y + move_offset.y)

func die() -> void:
	emit_signal("stopped_mouse_hover", self)
	dying = true
	animation_player.speed_scale = 1
	animation_player.play(animations[current_direction]["death"])
	$PhysicalCollider.disabled = true
	highlight_circle.modulate = Color.TRANSPARENT
	$HoverZone.process_mode = Node.PROCESS_MODE_DISABLED
	$MeleeZone.process_mode = Node.PROCESS_MODE_DISABLED
	attack_zone.process_mode = Node.PROCESS_MODE_DISABLED
	under_mouse_hover.disconnect(game_manager.enemy_mouse_hover)
	stopped_mouse_hover.disconnect(game_manager.enemy_mouse_hover_stopped)
	z_index = 4
	y_sort_enabled = false

func highlight() -> void:
	animated_sprite_2d.material.set_shader_parameter("width", 1.5)

func highlight_stop() -> void:
	animated_sprite_2d.material.set_shader_parameter("width", 0)


func construct_animation_library() -> void:
	animations.clear()
	for key: int in direction_name:
		var animation_dictionary_for_key: Dictionary = {}
		for type: String in animation_types:
			animation_dictionary_for_key[type] = model + "_" + type + "_" + direction_name[key]
		animations[key] = animation_dictionary_for_key
		for type: String in animation_types:
			create_animated2d_animations_from_assets(animations[key][type], key)
	

func add_animation_method_calls() -> void:
	var animation_list: Array[StringName] = animation_library.get_animation_list()
	for animation: StringName in animation_list:
		var animation_to_modify: Animation = animation_library.get_animation(animation)
		var track: int = animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time: float = attack_frame/FPS
			var parried_time: float = 0.5/FPS
			var countered_time: float = 3/FPS
			animation_to_modify.track_insert_key(track, parried_time, {"method" : "ready_to_be_parried" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, countered_time, {"method" : "ready_to_be_countered" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, time, {"method" : "attack_effect" , "args" : []}, 1)

func attack_effect() -> void:
	attack_collider.disabled = false
	highlight_circle.modulate = Color.TRANSPARENT
	can_be_countered = false
	can_be_parried = false
	disable_attack_zone()
	
func disable_attack_zone() -> void:
	var timer: Timer = Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true
	
func ready_to_be_parried() -> void:
	if not stunned:
		if in_melee:
			highlight_circle.modulate = Color.WHITE
		can_be_parried = true

func ready_to_be_countered() -> void:
	if not stunned:
		highlight_circle.modulate = Color.BLUE
		can_be_countered = true


func create_animated2d_animations_from_assets(animation_name: String, direction: int = directions.N) -> void:
	var frames: SpriteFrames = animated_sprite_2d.sprite_frames
	var action_type: String
	for type: String in animation_types:
		if type in animation_name:
			action_type = type
			break
	if action_type == null:
		print("no animation type found for this entity: " + name)
		return
	
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 12.0)
	frames.set_animation_loop(animation_name, true)
	
	#get all pngs to add to each frame of the animation
	var assets_path: String = model + "/" + model + "_" + action_type + "/" + direction_name[direction]
	var parent_directory: String = "enemy"
	if category == "boss":
		parent_directory = "boss"
	var png_list: Array[String] = game_manager.dir_contents_filter("res://assets/art/" + parent_directory + "/" + assets_path,"png")
	
	# add new frames to the spriteframes resource
	for png_path: String in png_list:
		var frame_png: Texture2D  = load(png_path)
		frames.add_frame(animation_name,frame_png)
	
	# create the matching animations in AnimationPlayer
	var new_animation: Animation = Animation.new()
	var frames_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(frames_track,"AnimatedSprite2D:frame")
	new_animation.loop_mode = Animation.LOOP_NONE
	new_animation.length = png_list.size()/FPS
	var name_track: int = new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(name_track,"AnimatedSprite2D:animation")
	new_animation.track_insert_key(name_track,0,animation_name)
	var frame_number: float = 0
	for png_path: String in png_list:
		new_animation.track_insert_key(frames_track,frame_number/FPS, frame_number)
		frame_number += 1
	animation_library.add_animation(animation_name, new_animation)
