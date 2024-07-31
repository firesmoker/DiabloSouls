class_name Player extends CharacterBody2D

@onready var game_manager: GameManager = %GameManager
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

#@onready var attack_axis = $AttackAxis
#@onready var animation_player := $AnimationPlayer
#@onready var attack_zone = $AttackAxis/AttackZone
#@onready var attack_collider = $AttackAxis/AttackZone/AttackCollider

@export var attack_axis: Node2D
@export var animation_player: AnimationPlayer
@export var attack_zone: Area2D
@export var attack_collider: CollisionShape2D

@onready var animation_library: AnimationLibrary = animation_player.get_animation_library("")

@export var model: String = "warrior"
@export var speed_fps_ratio: float = 121.0
@export var speed_modifier: float = 1
@export var attack_frame: int = 3
@export var cancel_frame: int = 2
@export var attack_again_frame: int = 4
@export var is_moving: bool = false
@export var is_executing: bool = false
@export var is_chasing_enemy: bool = false
@export var ready_for_idle: bool= true
@export var ready_to_attack_again: bool= true
var targeted_enemy: RigidBody2D = null
var enemies_in_melee: Array = [Enemy]
var abilities_queue: Array = [Ability]


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
	-1.0/4 * PI: directions.NE,
	0.0/4 * PI: directions.E,
	1.0/4 * PI: directions.SE,
	2.0/4 * PI: directions.S,
	3.0/4 * PI: directions.SW,
	4.0/4 * PI: directions.W,
	-4.0/4 * PI: directions.W,
	-3.0/4 * PI: directions.NW,
}

var test_ability: Ability = Ability.new("test_ability", "melee")
var test_ability2: Ability = Ability.new("test_ability2", "melee")


func _ready() -> void:
	destination = position
	construct_animation_library()
	add_animation_method_calls()


func _physics_process(delta: float) -> void:	
	handle_movement(delta)
	
	if not is_executing:
		stop_on_destination()
		
		if velocity:
			running_state()
		else:
			standing_state()

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("test_button"):
		execute(test_ability)
	
	if event.is_action_pressed("attack_in_place"):
		var face_destination: Vector2 = get_global_mouse_position()
		attack(face_destination)
	
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


func stop_on_destination() -> void:
	if abs(position.x - destination.x) <= 1 and abs(position.y - destination.y) <= 1:
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
	if "running" in current_animation and current_animation != animations[current_direction]["running"]:
		var current_animation_position: float = animation_player.current_animation_position
		animation_player.play(animations[current_direction]["running"])
		animation_player.seek(current_animation_position)
	else:
		animation_player.play(animations[current_direction]["running"])

func standing_state() -> void:
	if "attack" in animation_player.current_animation:
		is_moving = false
		await animation_player.animation_finished
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
				velocity = Vector2(0,0)
				destination = position
		if is_chasing_enemy and targeted_enemy != null:
			destination = targeted_enemy.position
		velocity = calculate_movement_velocity() * delta / average_delta


func set_direction_by_angle(angle: float) -> void:
	var rand: float = (1.0/4.0 * PI)
	var rounded_rand: float = round_to_multiple(angle, rand)
	current_direction = radian_direction[rounded_rand]

func attack(attack_destination: Vector2) -> void:
	is_chasing_enemy = false
	targeted_enemy = null
	ready_for_idle = false
	is_moving = false
	
	velocity = Vector2(0, 0)
	var angle: float = position.angle_to_point(attack_destination)
	set_direction_by_angle(angle)
	
	animation_player.speed_scale = speed_modifier
	if ready_to_attack_again:
		is_executing = true
		ready_to_attack_again = false
		attack_axis.rotation = angle
		print("first or restarted attack")
		animation_player.stop()
		animation_player.play(animations[current_direction]["attack"]) # "test_library/" plays from test_library
	elif attack_collider.disabled == true:
		attack_axis.rotation = angle
		print("normal attack")
		var current_animation_position: float = animation_player.current_animation_position
		
		if current_animation_position < attack_frame/FPS or current_animation_position >= attack_again_frame/FPS:
			animation_player.play(animations[current_direction]["attack"]) # "test_library/" plays from test_library
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
	
	var radius := speed_fps_ratio
	var direction_x: float = cos(angle) * radius
	var direction_y: float = sin(angle) * radius
	var max_velocity_x: float = direction_x * speed_modifier
	var max_velocity_y: float = direction_y * speed_modifier
	
	return Vector2(max_velocity_x, max_velocity_y)


func just_attacked() -> void:
	print("pow!")
	attack_collider.disabled = false
	emit_signal("attack_effects")
	disable_attack_zone()


func construct_animation_library() -> void:
	animations.clear()
	for key: int in direction_name:
		animations[key] = {
			"attack" : model + "_attack_" + direction_name[key],
			"idle" : model+ "_idle_" + direction_name[key],
			"running" : model+ "_running_" + direction_name[key],
		}


func add_animation_method_calls() -> void:
	var animation_list := animation_library.get_animation_list()
	for animation in animation_list:
		var animation_to_modify := animation_library.get_animation(animation)
		var track := animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time := attack_frame/FPS
			var cancel_time := cancel_frame/FPS
			var attack_again_time := attack_again_frame/FPS
			animation_to_modify.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)


func animation_cancel_ready() -> void:
	is_executing = false


func attack_again_ready() -> void:
	ready_to_attack_again = true
	print("can attack again")


func disable_attack_zone() -> void:
	var timer := Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if "attack" in anim_name:
		print("attack finished fully")
		ready_for_idle = true


func _on_timer_timeout() -> void:
	pass


func _on_attack_zone_body_entered(body: CollisionObject2D) -> void:
	emit_signal("attack_success", body)


func _on_attack_effects() -> void:
	if not audio.playing:
		audio.stop()
		audio.pitch_scale = 1
		audio.pitch_scale += randf_range(-0.03, 0.03)
		audio.play()


func execute(ability: Ability, target: Vector2 = Vector2(0,0)) -> void:
	ability.execute(target)


class Ability:
	var name: String
	var range_type: String
	var standing: bool
	
	func _init(name: String, range_type: String, standing: bool = true) -> void:
		self.name = name
		self.range_type = range_type
		self.standing = standing
		
	func execute(target: Vector2 = Vector2(0,0)) -> void:
		print("executing " + name)
		if self.range_type != "self":
			print("execute on: " + str(target))
