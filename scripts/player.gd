extends CharacterBody2D
# test git
@onready var audio = $AudioStreamPlayer
@onready var point_light = $Camera2D/PointLight2D
@onready var camera = $Camera2D
@onready var animation_player := $AnimationPlayer
@onready var attack_zone = $Attack/AttackZone
@onready var attack_collider = $Attack/AttackZone/AttackCollider
@onready var animation_library : AnimationLibrary = animation_player.get_animation_library("")
@export var model: String = "warrior"
@export var speed: float = 121.0
@export var speed_modifier: float = 1
@export var attack_frame = 3
@export var cancel_frame = 2
@export var attack_again_frame = 4
@export var shake_time: float = 0.05
@export var shake_amount: float = 2.5
@export var moving: bool = false
@export var attacking: bool = false
@export var idle := true
@export var attack_again := true

signal attack_effects

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
	recreate_animations()
	destination = position
	var animation_list = animation_library.get_animation_list()
	for animation in animation_list:
		var new_animation = animation_library.get_animation(animation)
		var track = new_animation.add_track(Animation.TYPE_METHOD)
		new_animation.track_set_path(track, ".")
		if "attack" in animation:
			var time = attack_frame/FPS
			#var disable_attack_zone = time + 1/FPS
			var cancel_time = cancel_frame/FPS
			var attack_again_time = attack_again_frame/FPS
			new_animation.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			new_animation.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			new_animation.track_insert_key(track, time + 0.1, {"method" : "disable_attack_zone" , "args" : []}, 1)
			new_animation.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)


func _physics_process(delta):
	#attack_collider.disabled = true
	if moving and not attacking:
		if Input.is_action_pressed("mouse_move"):
			moving = true
			idle = false
			destination = get_global_mouse_position()
			if abs(position.x - destination.x) <= 5 and abs(position.y - destination.y) <= 5:
				velocity = Vector2(0,0)
				destination = position
		velocity = calculate_movement_velocity() * delta / average_delta
	
	if Input.is_action_just_pressed("recreate_animations"):
		velocity = Vector2(0,0)
			
	if Input.is_action_just_pressed("attack"):
		if 1 == 1:
			var face_destination = get_global_mouse_position()
			var angle = position.angle_to_point(face_destination)
			var rand = (1.0/4.0 * PI)
			var rounded = round_to_multiple(angle, rand)
			current_direction = radian_direction[rounded]
			idle = false
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
			velocity.x = 0
			velocity.y = 0
	
	if not attacking:
		if abs(position.x - destination.x) <= 1 and abs(position.y - destination.y) <= 1:
			velocity = Vector2(0,0)
			#destination = position
			if not Input.is_action_pressed("mouse_move"):
				#moving = false
				idle = true
		
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
				#print("waited for attack to finish")
			#print(current_direction)
			animation_player.play(animations[current_direction]["idle"])

	move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed("mouse_move") and not event.is_action_pressed("attack"):
		print("unhandled input")
		moving = true
		destination = get_global_mouse_position()
		
		
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
	
	

	

func recreate_animations():
	animations.clear()
	for key in direction_name:
		animations[key] = {
			"attack" : model + "_attack_" + direction_name[key],
			"idle" : model+ "_idle_" + direction_name[key],
			"running" : model+ "_running_" + direction_name[key],
		}


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
	
	

func camera_shake_and_color(color: bool = true):
	var timer = Timer.new()
	camera.add_child(timer)
	timer.wait_time = shake_time
	#timer.timeout.connect(_on_timer_timeout)
	if color:
		#point_light.blend_mode = 0
		#point_light.color = Color.TEAL
		point_light.energy -= 0.3
	camera.position.x += shake_amount
	camera.position.y += shake_amount*0.7
	timer.start()
	await timer.timeout
	timer.queue_free()
	if color:
		#point_light.blend_mode = 1
		#point_light.color = Color.WHITE
		point_light.energy += 0.3
	camera.position.x -= shake_amount
	camera.position.y -= shake_amount*0.7
	

func _on_animation_player_animation_finished(anim_name):
	if "attack" in anim_name:
		print("attack finished fully")
		idle = true

func _on_timer_timeout():
	pass


func _on_attack_zone_body_entered(body):
	print("colliding with something in the attack zone! it';s " + str(body))
	camera_shake_and_color()


func _on_attack_effects():
	if not audio.playing:
		audio.stop()
		audio.pitch_scale = 1
		audio.pitch_scale += randf_range(-0.03, 0.03)
		audio.play()
	
	
	pass # Replace with function body.
