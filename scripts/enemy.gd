extends RigidBody2D
@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var game_manager := %GameManager

@export var highlight_circle: Sprite2D

@export var is_under_mouse: bool = false
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


#func _process(delta: float) -> void:
	#if is_under_mouse:
		##print("emitting under mouse")
		#emit_signal("under_mouse_hover", self)
	#elif not is_under_mouse:
		##print("emitting NOT under mouse")
		#emit_signal("stopped_mouse_hover", self)
	#pass
	
func _on_hover_zone_mouse_entered() -> void:
	print("mouse entered")
	is_under_mouse = true
	#print("mouse entered - emitting under_mouse_hover (in enemy)")
	emit_signal("under_mouse_hover", self)
	pass # Replace with function body.


func _on_hover_zone_mouse_exited() -> void:
	print("mouse exited")
	is_under_mouse = false
	emit_signal("stopped_mouse_hover", self)
	pass # Replace with function body.
	
func get_hit() -> void:
	#print("blend mode changed")
	#sprite_material.blend_mode = 1
	animated_sprite_2d.modulate = Color.RED
	var timer := Timer.new()
	self.add_child(timer)
	timer.wait_time = 0.07
	timer.start()
	await timer.timeout
	timer.queue_free()
	#print("blend mode reverted")
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



#func _on_hover_zone_body_entered(body) -> void:
	#if body == player:
		#print("yay")
		#if player.is_chasing_enemy and player.targeted_enemy == self:
			#player.attack(position)
	#print(body)
	#print(player)
	#pass # Replace with function body.




func _on_melee_zone_body_entered(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_in_melee", self)
		#print("player in melee")
		#if player.is_chasing_enemy and player.targeted_enemy == self:
			#player.attack(position)
	pass # Replace with function body.


func _on_melee_zone_body_exited(body: CollisionObject2D) -> void:
	if body == player:
		emit_signal("player_left_melee", self)
		#print("player left melee")
	pass # Replace with function body.
