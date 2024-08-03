class_name Enemy extends RigidBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: GameManager = %GameManager
@onready var highlight_circle: Sprite2D = $HighlightCircle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_library: AnimationLibrary
@onready var attack_axis: Node2D = $AttackAxis
@onready var attack_zone: Area2D = $AttackAxis/AttackZone
@onready var attack_collider: CollisionShape2D = $AttackAxis/AttackZone/AttackCollider
@export_enum("skeleton_default", "slime") var model: String = "skeleton_default"
@export var speed_fps_ratio: float = 121.0
@export var speed: float = 0.35
@export var speed_modifier: float = 1
@export var attack_frame: int = 3
@export var hitpoints: int = 2
@export var animation_types: Array = ["idle", "walk"]

var move_offset: Vector2 = Vector2(0,0)
var moving: bool = true
var dying: bool = false
var can_attack: bool = true
var attacking: bool = false

const FPS: float = 12.0
const average_delta: float = 0.01666666666667

var sprite_material: Material
var player: CharacterBody2D
var destination: Vector2
var player_in_range: bool = false
var attack_range: float = 35

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
signal player_in_melee
signal player_left_melee


func _ready() -> void:
	gravity_scale = 0
	animation_library = animation_player.get_animation_library("")
	construct_animation_library()
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		player = game_manager.player
		player_in_melee.connect(game_manager.player_in_melee)
		player_left_melee.connect(game_manager.player_left_melee)
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)

func _process(delta: float) -> void:
	destination = player.position
	if position.distance_to(player.position) <= attack_range and not dying:
		can_attack = true
		attacking = true
		animation_player.play(animations[current_direction]["attack"])
		print("can attack")
	else:
		can_attack = false
		attacking = false
	if not attacking:
		if moving and not dying:
			move_and_collide(calculate_movement() * speed * delta)
			animation_player.play(animations[current_direction]["walk"])
		elif not dying:
			animation_player.play(animations[current_direction]["idle"])

func calculate_movement() -> Vector2:
	var angle: float = position.angle_to_point(destination + move_offset)
	var rand: float = (1/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = float(round(angle / rand) * rand)
	current_direction = radian_direction[rounded_rand]
	
	var radius := speed_fps_ratio
	var direction_x: float = cos(angle) * radius
	var direction_y: float = sin(angle) * radius
	var max_velocity_x: float = direction_x * speed_modifier
	var max_velocity_y: float = direction_y * speed_modifier
	
	return Vector2(max_velocity_x, max_velocity_y)

func _on_body_entered(body: RigidBody2D) -> void:
	pass
	
func _on_hover_zone_mouse_entered() -> void:
	#print("mouse entered")
	emit_signal("under_mouse_hover", self)

func _on_hover_zone_mouse_exited() -> void:
	#print("mouse exited")
	emit_signal("stopped_mouse_hover", self)
	
func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_in_melee", self)
		moving = false
	elif body != self:
		#print("hurrary")
		move_offset += position - body.position

func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_left_melee", self)
		moving = true
	elif body != self:
		#print("fixxx")
		move_offset -= position - body.position
		
func get_hit() -> void:
	#sprite_material.blend_mode = 1
	animated_sprite_2d.modulate = Color.RED
	var timer := Timer.new()
	self.add_child(timer)
	timer.wait_time = 0.07
	timer.start()
	await timer.timeout
	timer.queue_free()
	animated_sprite_2d.modulate = Color.WHITE
	hitpoints -= 1
	if hitpoints <= 0:
		emit_signal("stopped_mouse_hover", self)
		emit_signal("player_left_melee", self)
		die()
		#await Timer.new().timeout
		#queue_free()
	#sprite_material.blend_mode = 0

func die() -> void:
	dying = true
	animation_player.play(animations[current_direction]["death"])
	$PhysicalCollider.disabled = true
	highlight_circle.visible = false
	$HoverZone.DISABLE_MODE_REMOVE
	$MeleeZone.DISABLE_MODE_REMOVE
	attack_zone.DISABLE_MODE_REMOVE
	player_in_melee.disconnect(game_manager.player_in_melee)
	player_left_melee.disconnect(game_manager.player_left_melee)
	under_mouse_hover.disconnect(game_manager.enemy_mouse_hover)
	stopped_mouse_hover.disconnect(game_manager.enemy_mouse_hover_stopped)
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 8
	timer.start()
	await timer.timeout
	queue_free()

func highlight() -> void:
	sprite_material.blend_mode = 1
	highlight_circle.visible = true
	#highlight_circle.material.blend_mode = 0

func highlight_stop() -> void:
	sprite_material.blend_mode = 0
	#highlight_circle.material.blend_mode = 0
	highlight_circle.visible = false


func construct_animation_library() -> void:
	animations.clear()
	for key: int in direction_name:
		#print(direction_name[key])
		var animation_dictionary_for_key: Dictionary = {}
		for type: String in animation_types:
			animation_dictionary_for_key[type] = model + "_" + type + "_" + direction_name[key]
				#"attack" : model + "_attack_" + direction_name[key],
				#"idle" : model+ "_idle_" + direction_name[key],
				#"walk" : model+ "_walk_" + direction_name[key],
		animations[key] = animation_dictionary_for_key
		for type: String in animation_types:
			create_animated2d_animations_from_assets(animations[key][type], key)
		#create_animated2d_animations_from_assets(animations[key]["attack"], key)
		#create_animated2d_animations_from_assets(animations[key]["idle"], key)
		#create_animated2d_animations_from_assets(animations[key]["walk"], key)
	

func add_animation_method_calls() -> void:
	var animation_list := animation_library.get_animation_list()
	for animation in animation_list:
		var animation_to_modify := animation_library.get_animation(animation)
		var track := animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time := attack_frame/FPS
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)



func create_animated2d_animations_from_assets(animation_name: String, direction: int = directions.N) -> void:
	var frames: SpriteFrames = animated_sprite_2d.sprite_frames
	var action_type: String
	
	for type: String in animation_types:
		if type in animation_name:
			action_type = type
			break
	#elif "idle" in animation_name:
		#action_type = "idle"
	#elif "walk" in animation_name:
		#action_type = "walk"
	#else:
		#print("unknown action type to construct")
		#return
	
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 12.0)
	frames.set_animation_loop(animation_name, true)
	
	#get all pngs to add to each frame of the animation
	var assets_path: String = model + "/" + model + "_" + action_type + "/" + direction_name[direction]
	var png_list: Array = game_manager.dir_contents_filter("res://assets/art/enemy/" + assets_path,"png")
	
	# add new frames to the spriteframes resource
	for png_path: String in png_list:
		var frame_png: Texture2D  = load(png_path)
		frames.add_frame(animation_name,frame_png)
	#print("animation: " + animation_name + " created in AnimatedSprite2D")
	
	# create the matching animations in AnimationPlayer
	var new_animation: Animation = Animation.new()
	var frames_track := new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(frames_track,"AnimatedSprite2D:frame")
	new_animation.loop_mode = Animation.LOOP_NONE
	new_animation.length = png_list.size()/FPS
	var name_track := new_animation.add_track(Animation.TYPE_VALUE)
	new_animation.track_set_path(name_track,"AnimatedSprite2D:animation")
	new_animation.track_insert_key(name_track,0,animation_name)
	var frame_number: float = 0
	for png_path: String in png_list:
		new_animation.track_insert_key(frames_track,frame_number/FPS, frame_number)
		frame_number += 1
	#print("frame number length: " + str(frame_number))
	#print("animation: " + animation_name + " created in AnimatedSprite2D")
	animation_library.add_animation(animation_name, new_animation)


#func allow_animation_refresh() -> void:
	#var timer := Timer.new()
	#attack_collider.add_child(timer)
	#timer.wait_time = 0.06
	#timer.start()
	#await timer.timeout
	#timer.queue_free()
	#attack_collider.disabled = true
