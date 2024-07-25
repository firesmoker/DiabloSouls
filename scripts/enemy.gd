extends RigidBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var game_manager = %GameManager
@onready var highlight_circle = $HighlightCircle

var sprite_material: Material

signal under_mouse_hover
signal stopped_mouse_hover

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	sprite_material = animated_sprite_2d.material
	if game_manager != null:
		under_mouse_hover.connect(game_manager.enemy_mouse_hover)
		stopped_mouse_hover.connect(game_manager.enemy_mouse_hover_stopped)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(game_manager)
	#print(sprite_material.blend_mode)
	pass
	
func get_hit():
	print("blend mode changed")
	#sprite_material.blend_mode = 1
	animated_sprite_2d.modulate = Color.RED
	var timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = 0.07
	timer.start()
	await timer.timeout
	timer.queue_free()
	print("blend mode reverted")
	animated_sprite_2d.modulate = Color.WHITE
	#sprite_material.blend_mode = 0

func highlight():
	sprite_material.blend_mode = 1
	highlight_circle.visible = false
	highlight_circle.material.blend_mode = 0

func highlight_stop():
	sprite_material.blend_mode = 0
	highlight_circle.material.blend_mode = 0
	highlight_circle.visible = false

func _on_mouse_entered():
	print("mouse entered - emitting under_mouse_hover (in enemy)")
	emit_signal("under_mouse_hover", self)
	pass # Replace with function body.


func _on_mouse_exited():
	emit_signal("stopped_mouse_hover", self)
	pass # Replace with function body.
