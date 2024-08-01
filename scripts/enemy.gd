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
@export var speed_modifier: float = 1
@export var attack_frame: int = 3

const FPS: float = 12.0
const average_delta: float = 0.01666666666667

var sprite_material: Material
var player: CharacterBody2D


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

signal under_mouse_hover
signal stopped_mouse_hover
signal player_in_melee
signal player_left_melee


func _ready() -> void:
	animation_library = animation_player.get_animation_library("")
	construct_animation_library()
	player_in_melee.connect(game_manager.player_in_melee)
	player_left_melee.connect(game_manager.player_left_melee)
	player = game_manager.player
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)
	animation_player.play(animations[current_direction]["idle"])

	
func _on_hover_zone_mouse_entered() -> void:
	#print("mouse entered")
	emit_signal("under_mouse_hover", self)


func _on_hover_zone_mouse_exited() -> void:
	#print("mouse exited")
	emit_signal("stopped_mouse_hover", self)
	
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
	#sprite_material.blend_mode = 0

func highlight() -> void:
	sprite_material.blend_mode = 1
	highlight_circle.visible = true
	#highlight_circle.material.blend_mode = 0

func highlight_stop() -> void:
	sprite_material.blend_mode = 0
	#highlight_circle.material.blend_mode = 0
	highlight_circle.visible = false


func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_in_melee", self)


func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_left_melee", self)


func construct_animation_library() -> void:
	animations.clear()
	for key: int in direction_name:
		#print(direction_name[key])
		animations[key] = {
			"attack" : model + "_attack_" + direction_name[key],
			"idle" : model+ "_idle_" + direction_name[key],
			"walk" : model+ "_walk_" + direction_name[key],
		}
		create_animated2d_animations_from_assets(animations[key]["attack"], key)
		create_animated2d_animations_from_assets(animations[key]["idle"], key)
		create_animated2d_animations_from_assets(animations[key]["walk"], key)
	

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
	
	if "attack" in animation_name:
		action_type = "attack"
	elif "idle" in animation_name:
		action_type = "idle"
	elif "walk" in animation_name:
		action_type = "walk"
	else:
		print("unknown action type to construct")
		return
	
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
	print("animation: " + animation_name + " created in AnimatedSprite2D")
	
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
	print("frame number length: " + str(frame_number))
	print("animation: " + animation_name + " created in AnimatedSprite2D")
	animation_library.add_animation(animation_name, new_animation)
