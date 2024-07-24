extends CharacterBody2D
# test git
@onready var audio = $AudioStreamPlayer
@onready var point_light = $Camera2D/PointLight2D
@onready var camera = $Camera2D
@onready var animation_player := $AnimationPlayer
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

#var update_movement: bool = true
const FPS = 12.0

var destination: = Vector2()
var movement: = Vector2()

#VVVVVVVVVVVVVVVV Testing the AnimationLibrary functionalit VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
#var test_animation = Animation.new()
#var test_library = AnimationLibrary.new()
#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

var current_direction := directions.E

enum directions{N,NE,E,SE,S,SW,W,NW}
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

var animations := {}




func _ready():
	recreate_animations()
	destination = position
	#VVVVVVVVVVVVVVVV Testing the AnimationLibrary functionalit VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
	#animation_library.add_animation("test_animation", test_animation)
	var animation_list = animation_library.get_animation_list()
	for animation in animation_list:
		#print(animation)
		var new_animation = animation_library.get_animation(animation)
		var track = new_animation.add_track(Animation.TYPE_METHOD)
		new_animation.track_set_path(track, ".")
		if "attack" in animation:
			#print(animation)
			var time = attack_frame/FPS
			var cancel_time = cancel_frame/FPS
			var attack_again_time = attack_again_frame/FPS
			new_animation.track_insert_key(track, cancel_time, {"method" : "animation_cancel_ready" , "args" : []}, 1)
			new_animation.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)
			new_animation.track_insert_key(track, attack_again_time, {"method" : "attack_again_ready" , "args" : []}, 1)
		#test_library.add_animation(animation, new_animation)
	#animation_player.add_animation_library("test_library", test_library)
	#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA


func _physics_process(_delta):
	if moving and not attacking:
		if Input.is_action_pressed("mouse_move"):
			moving = true
			idle = false
			destination = get_global_mouse_position()
			if abs(position.x - destination.x) <= 5 and abs(position.y - destination.y) <= 5:
				velocity = Vector2(0,0)
				destination = position
				#idle = true
				#moving = false
		velocity = calculate_movement_velocity()
	
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
	
	#var direction_x = Input.get_axis("move_left", "move_right")
	#var direction_y = Input.get_axis("move_up", "move_down")	
	#var direction: Vector2 = Vector2(direction_x,direction_y)
	
	if not attacking:
		if abs(position.x - destination.x) <= 1 and abs(position.y - destination.y) <= 1:
			velocity = Vector2(0,0)
			#destination = position
			if not Input.is_action_pressed("mouse_move"):
				#moving = false
				idle = true
				
		#if direction_x and direction_y:
			#velocity.x = direction_x * speed * 0.7 * speed_modifier
			#velocity.y = direction_y * speed * 0.7 * speed_modifier
		#else:
			#if direction_x:
				#velocity.x = direction_x * speed * speed_modifier
			#else:
				#velocity.x = move_toward(velocity.x, 0, speed)			
			#if direction_y:
				#velocity.y = direction_y * speed * speed_modifier
			#else:
				#velocity.y = move_toward(0, 0, speed)
		
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
				#print(current_animation_position)
				#print("blending running animation")
				#print(velocity)
			else:
				animation_player.play(animations[current_direction]["running"])
			#match direction:
				#Vector2(0,-1):
					#current_direction = directions.N
				#Vector2(1,0):
					#current_direction = directions.E
				#Vector2(0,1):
					#current_direction = directions.S
				#Vector2(-1,0):
					#current_direction = directions.W
				#Vector2(1,1):
					#current_direction = directions.SE
				#Vector2(1,-1):
					#current_direction = directions.NE
				#Vector2(-1,1):
					#current_direction = directions.SW
				#Vector2(-1,-1):
					#current_direction = directions.NW
		else:
			#animation_player.stop()
			
				
			if "attack" in animation_player.current_animation:
				moving = false
				await animation_player.animation_finished
				#print("waited for attack to finish")
			print(current_direction)
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
	#velocity.x = max_velocity_x
	#velocity.y = max_velocity_y

func just_attacked():
	print("pow!")
	if not audio.playing:
		audio.stop()
		audio.play()
	camera_shake_and_color(false)

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

func camera_shake_and_color(color: bool = true):
	var timer = Timer.new()
	
	camera.add_child(timer)
	timer.wait_time = shake_time
	#timer.timeout.connect(_on_timer_timeout)
	if color:
		point_light.blend_mode = 0
		point_light.color = Color.TEAL
		point_light.energy /= 10000
	camera.position.x += shake_amount
	camera.position.y += shake_amount*0.7
	timer.start()
	await timer.timeout
	timer.queue_free()
	if color:
		point_light.blend_mode = 1
		point_light.color = Color.WHITE
		point_light.energy *= 10000
	camera.position.x -= shake_amount
	camera.position.y -= shake_amount*0.7
	

func _on_animation_player_animation_finished(anim_name):
	#print(anim_name)
	if "attack" in anim_name:
		print("attack finished fully")
		idle = true
	#attacking = false

func _on_timer_timeout():
	pass
