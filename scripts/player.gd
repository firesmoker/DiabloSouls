extends CharacterBody2D
# test git

@onready var game_manager = %GameManager
@onready var attack_axis = $AttackAxis
@onready var audio = $AudioStreamPlayer
@onready var animation_player := $AnimationPlayer
@onready var attack_zone = $AttackAxis/AttackZone
@onready var attack_collider = $AttackAxis/AttackZone/AttackCollider
@onready var animation_library : AnimationLibrary = animation_player.get_animation_library("")

@export var model: String = "warrior"
@export var speed: float = 121.0
@export var speed_modifier: float = 1
@export var attack_frame = 3
@export var cancel_frame = 2
@export var attack_again_frame = 4
@export var moving: bool = false
@export var attacking: bool = false
@export var ready_for_idle := true
@export var attack_again := true
@export var is_chasing_enemy := false
var targeted_enemy = null

signal attack_effects
signal attack_success

var destination: = Vector2()
var movement: = Vector2()

const FPS = 12.0
const average_delta := 0.01666666666667

enum directions{N,NE,E,SE,S,SW,W,NW}
var current_direction := directions.E
var animations := {}
var direction_name: = {
	directions.N : "N",
	directions.NE : "NE",
	directions.E : "E",
	directions.SE : "SE",
	directions.S : "S",
	directions.SW : "SW",
	directions.W : "W",
	directions.NW : "NW",
}
var radian_direction: = {
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


func _ready():
	destination = position
	construct_animation_library()
	add_animation_method_calls()


func _physics_process(delta):
	
	
	if moving and not attacking:
		if Input.is_action_pressed("mouse_move"):
			if game_manager.enemies_under_mouse <= 0:
				is_chasing_enemy = false
				targeted_enemy = null
			moving = true
			ready_for_idle = false
			destination = get_global_mouse_position()
			if abs(position.x - destination.x) <= 5 and abs(position.y - destination.y) <= 5:
				velocity = Vector2(0,0)
				destination = position
		if is_chasing_enemy and targeted_enemy != null:
			destination = targeted_enemy.position
		velocity = calculate_movement_velocity() * delta / average_delta
	
			
	if not attacking:
		if abs(position.x - destination.x) <= 1 and abs(position.y - destination.y) <= 1:
			velocity = Vector2(0,0)
			if not Input.is_action_pressed("mouse_move"):
				ready_for_idle = true
		
		if velocity:
			attacking = false
			attack_again = true
			var current_animation = animation_player.current_animation
			if speed_modifier >= 2:
				animation_player.speed_scale = speed_modifier / 2
			else:
				animation_player.speed_scale = speed_modifier
			if "running" in current_animation and current_animation != animations[current_direction]["running"]:
				var current_animation_position = animation_player.current_animation_position
				animation_player.play(animations[current_direction]["running"])
				animation_player.seek(current_animation_position)
			else:
				animation_player.play(animations[current_direction]["running"])
		else:
			if "attack" in animation_player.current_animation:
				moving = false
				await animation_player.animation_finished
			animation_player.play(animations[current_direction]["ready_for_idle"])

	move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed("attack_in_place"):
		var face_destination = get_global_mouse_position()
		attack(face_destination)
	
	if event.is_action_pressed("mouse_move") and not event.is_action_pressed("attack_in_place"):
		if game_manager.enemies_under_mouse > 0:
			#moving = false
			move_to_enemy()
		else:
			print("unhandled input")
			moving = true
			destination = get_global_mouse_position()

func attack(attack_destination):
		is_chasing_enemy = false
		targeted_enemy = null
		var angle = position.angle_to_point(attack_destination)
		var rand = (1.0/4.0 * PI)
		var rounded = round_to_multiple(angle, rand)
		current_direction = radian_direction[rounded]
		attack_axis.rotation = angle
		ready_for_idle = false
		moving = false
		animation_player.speed_scale = speed_modifier
		if attack_again:
			print("first or restarted attack")
			attacking = true
			attack_again = false
			animation_player.stop()
			animation_player.play(animations[current_direction]["attack"]) # "test_library/" plays from test_library
		else:
			print("normal attack")
			var current_animation_position = animation_player.current_animation_position
			animation_player.play(animations[current_direction]["attack"]) # "test_library/" plays from test_library
			animation_player.seek(current_animation_position)
		velocity = Vector2(0, 0)

		
func move_to_enemy():
	print("should attack:" + str(game_manager.enemy_in_focus))
	is_chasing_enemy = true
	targeted_enemy = game_manager.enemy_in_focus
	destination = targeted_enemy.position
	moving = true
	

		
func round_to_multiple(number, multiple):
	return round(number / multiple) * multiple
	

func calculate_movement_velocity():
	var radius = speed
	var angle = position.angle_to_point(destination)
	
	var rand = (1.0/4.0 * PI)
	var rounded = round_to_multiple(angle, rand)
	current_direction = radian_direction[rounded]
	
	var direction_x = cos(angle) * radius
	var direction_y = sin(angle) * radius
	var max_velocity_x = direction_x * speed_modifier
	var max_velocity_y = direction_y * speed_modifier
	
	return Vector2(max_velocity_x, max_velocity_y)
	

func just_attacked():
	print("pow!")
	attack_collider.disabled = false
	emit_signal("attack_effects")
	disable_attack_zone()
	

func construct_animation_library():
	animations.clear()
	for key in direction_name:
		animations[key] = {
			"attack" : model + "_attack_" + direction_name[key],
			"ready_for_idle" : model+ "_idle_" + direction_name[key],
			"running" : model+ "_running_" + direction_name[key],
		}

func add_animation_method_calls():
	var animation_list = animation_library.get_animation_list()
	for animation in animation_list:
		var animation_to_modify = animation_library.get_animation(animation)
		var track = animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time = attack_frame/FPS
			var cancel_time = cancel_frame/FPS
			var attack_again_time = attack_again_frame/FPS
			animation_to_modify.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			animation_to_modify.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)

func animation_cancel_ready():
	attacking = false


func attack_again_ready():
	attack_again = true
	print("can attack again")

func disable_attack_zone():
	var timer = Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true
		

func _on_animation_player_animation_finished(anim_name):
	if "attack" in anim_name:
		print("attack finished fully")
		ready_for_idle = true

func _on_timer_timeout():
	pass


func _on_attack_zone_body_entered(body):
	emit_signal("attack_success", body)


func _on_attack_effects():
	if not audio.playing:
		audio.stop()
		audio.pitch_scale = 1
		audio.pitch_scale += randf_range(-0.03, 0.03)
		audio.play()
