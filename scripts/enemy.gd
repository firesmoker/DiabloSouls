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
@export var speed_fps_ratio: float = 42.35
@export var move_speed_modifier: float = 1
@export var attack_speed_modifier: float = 0.7
@export var attack_frame: int = 3
@export var hitpoints: int = 2
@export var has_attack: bool = false
@export var animation_types: Array = ["idle", "walk"]

var move_offset: Vector2 = Vector2(0,0)
var moving: bool = true
var dying: bool = false
var can_attack: bool = true
var attacking: bool = false
var switch_animation_timer: Timer
var adjacent_enemies: Array = []

const FPS: float = 12.0
const average_delta: float = 0.01666666666667

var sprite_material: Material
var player: CharacterBody2D
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
signal player_in_melee
signal player_left_melee
signal switch_direction_animation


func _ready() -> void:
	switch_animation_timer = Timer.new()
	self.add_child(switch_animation_timer)
	gravity_scale = 0
	animation_library = animation_player.get_animation_library("")
	construct_animation_library()
	add_animation_method_calls()
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		player = game_manager.player
		player_in_melee.connect(game_manager.player_in_melee)
		player_left_melee.connect(game_manager.player_left_melee)
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)

func _process(delta: float) -> void:
	destination = player.position
	if "attack" in animation_player.current_animation:
		moving = false
		#print("attacking, please hold")
		await animation_player.animation_finished
	if not dying:
		animation_player.speed_scale = attack_speed_modifier
		if position.distance_to(player.position) <= attack_range and has_attack:
			can_attack = true
			attacking = true
			var angle: float = position.angle_to_point(player.position)
			attack_axis.rotation = angle
			animation_player.play(animations[current_direction]["attack"])
		else:
			can_attack = false
			attacking = false
		if not attacking:
			if moving:
				move_and_collide(calculate_movement() * move_speed_modifier * delta)
				#if ready_to_switch_direction:

				var animation_before_change: String = animation_player.current_animation
				animation_player.speed_scale = move_speed_modifier
				animation_player.play(animations[current_direction]["walk"])
				if animation_player.current_animation != animation_before_change:
					#print("animation changed!")
					animation_player.seek(randi_range(0, 3) / FPS)
			else:
				animation_player.play(animations[current_direction]["idle"])

func switch_direction() -> void:
	#print("awaiting animation timer")
	await switch_animation_timer.timeout
	#print("ready to switch")
	ready_to_switch_direction = true

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if not attacking and has_attack:
		moving = true


func _on_body_entered(body: RigidBody2D) -> void:
	pass
	
func _on_hover_zone_mouse_entered() -> void:
	#print("mouse entered")
	emit_signal("under_mouse_hover", self)

func _on_hover_zone_mouse_exited() -> void:
	#print("mouse exited")
	emit_signal("stopped_mouse_hover", self)



func _on_clump_zone_body_entered(body: CollisionObject2D) -> void: 
	if body != player and body != self:
		#print("enemy entered HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
		adjacent_enemies.append(body)


func _on_clump_zone_body_exited(body: CollisionObject2D) -> void:
	if body != player and body != self:
		#print("clump exit")
		adjacent_enemies.erase(body)

func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		print("player in melee")
		#emit_signal("player_in_melee", self)
		moving = false

func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		#emit_signal("player_left_melee", self)
		moving = true
		
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
func calculate_movement() -> Vector2:
	var angle: float = position.angle_to_point(destination)
	var rand: float = (1/4.0 * PI) # switch to full rand 1.0/4.0 * PI for 8 directions
	var rounded_rand: float = float(round(angle / rand) * rand)
	if ready_to_switch_direction:
		ready_to_switch_direction = false
		current_direction = radian_direction[rounded_rand]
		#print("starting animation timer")
		switch_animation_timer.paused = false
		switch_animation_timer.start(0.2)
		#emit_signal("switch_direction_animation")
		switch_direction()
	
	var radius := speed_fps_ratio
	var direction_x: float = cos(angle) * radius
	var direction_y: float = sin(angle) * radius
	var max_velocity_x: float = direction_x
	var max_velocity_y: float = direction_y
	
	move_offset = Vector2(0,0)
	for enemy: CollisionObject2D in adjacent_enemies:
		move_offset += position - enemy.position
	
	return Vector2(max_velocity_x + move_offset.x, max_velocity_y + move_offset.y)

func die() -> void:
	dying = true
	animation_player.speed_scale = 1
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
			animation_to_modify.track_insert_key(track, time, {"method" : "attack_effect" , "args" : []}, 1)

func attack_effect() -> void:
	#print("pow!")
	print("pow!")
	attack_collider.disabled = false
	#emit_signal("attack_effects")
	disable_attack_zone()
	
func disable_attack_zone() -> void:
	var timer := Timer.new()
	attack_collider.add_child(timer)
	timer.wait_time = 0.06
	timer.start()
	await timer.timeout
	timer.queue_free()
	attack_collider.disabled = true



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
	#elif "idle" in animation_name:
		#action_type = "idle"
	#elif "walk" in animation_name:
		#action_type = "walk"
	#else:
		print("unknown action type to construct")
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



func _on_attack_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		game_manager.player_gets_hit()
		print("player supposed to get hit")
	else:
		print(body)
		print("not player")
