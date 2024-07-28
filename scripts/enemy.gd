class_name Enemy extends RigidBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: GameManager = %GameManager
@export var highlight_circle: Sprite2D
@export var animation_player: AnimationPlayer
@onready var animation_library: AnimationLibrary = animation_player.get_animation_library("")
@export var attack_axis: Node2D
@export var attack_zone: Area2D
@export var attack_collider: CollisionShape2D
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
	construct_animation_library()
	create_animated2d_animations_from_assets()
	player_in_melee.connect(game_manager.player_in_melee)
	player_left_melee.connect(game_manager.player_left_melee)
	player = game_manager.player
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)

	
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
	animated_sprite_2d.play("test_animation_2")

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
		animations[key] = {
			"attack" : model + "_attack_" + direction_name[key],
			"idle" : model+ "_idle_" + direction_name[key],
			"running" : model+ "_walk_" + direction_name[key],
		}


	

func add_animation_method_calls() -> void:
	var animation_list := animation_library.get_animation_list()
	for animation in animation_list:
		var animation_to_modify := animation_library.get_animation(animation)
		var track := animation_to_modify.add_track(Animation.TYPE_METHOD)
		animation_to_modify.track_set_path(track, ".")
		if "attack" in animation:
			var time := attack_frame/FPS
			animation_to_modify.track_insert_key(track, time, {"method" : "just_attacked" , "args" : []}, 1)

func create_animated2d_animations_from_assets() -> void:
	# new spriteframes resource to add all frames to
	var frames: SpriteFrames = SpriteFrames.new()
	
	# add new animation to the spriteframes resource
	frames.add_animation("test_animation")
	
	# add new frames to the spriteframes resource
	var frame_png: Texture2D
	frame_png = load("res://assets/art/enemy/skeleton_default/skeleton_default_attack/N/skeleton_default_attack_N_90.0_0.png")
	frames.add_frame("test_animation",frame_png)
	
	frame_png = load("res://assets/art/enemy/skeleton_default/skeleton_default_attack/N/skeleton_default_attack_N_90.0_1.png")
	frames.add_frame("test_animation",frame_png)
	
	frames.set_animation_loop("test_animation", true)
	
	
	
	
	frames.add_animation("test_animation_2")
	
	# add new frames to the spriteframes resource
	frame_png = load("res://assets/art/enemy/skeleton_default/skeleton_default_attack/N/skeleton_default_attack_N_90.0_3.png")
	frames.add_frame("test_animation_2",frame_png)
	
	frame_png = load("res://assets/art/enemy/skeleton_default/skeleton_default_attack/N/skeleton_default_attack_N_90.0_4.png")
	frames.add_frame("test_animation_2",frame_png)
	
	frames.set_animation_loop("test_animation_2", true)
	
	
	
	
	
	#set animated sprite 2d spriteframes resource to the one we created
	animated_sprite_2d.sprite_frames = frames
	
	animated_sprite_2d.play("test_animation")
	
	
func create_animation(anim_name: String, frames: Array) -> void:
	var animation: Animation = Animation.new()
	animation.length = frames.size() / float(FPS)
	animation.step = 1.0 / FPS

	for i in range(frames.size()):
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(0, "AnimatedSprite2D:frame")
		animation.track_insert_key(0, i / float(FPS), i)
		
	animation_player.add_animation(anim_name, animation)
	
	
	#var path_start: String = "res://assets/art/enemy/" + model + "/"
	#var sprite_frames: = animated_sprite_2d.sprite_frames
	##var new_animation: = animated_sprite_2d.animation.
	#sprite_frames.add_animation(model+ "_walk_" + "S")
	##var new_animation: = sprite_frames.animations.
	#print(sprite_frames.get_animation_names())
	
	
	#var new_animation: Animation
	#var new_track: = new_animation.add_track(Animation.TYPE_VALUE)
	#animation_library.add_animation("skeleton_default_walk_S",new_animation)
