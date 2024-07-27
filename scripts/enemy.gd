class_name Enemy extends RigidBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: GameManager = %GameManager

@export var highlight_circle: Sprite2D

var sprite_material: Material
var player: CharacterBody2D


signal under_mouse_hover
signal stopped_mouse_hover
signal player_in_melee
signal player_left_melee


func _ready() -> void:
	#pass # Replace with function body.
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

func highlight() -> void:
	#sprite_material.blend_mode = 1
	highlight_circle.visible = true
	#highlight_circle.material.blend_mode = 0

func highlight_stop() -> void:
	#sprite_material.blend_mode = 0
	#highlight_circle.material.blend_mode = 0
	highlight_circle.visible = false


func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_in_melee", self)


func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_left_melee", self)
