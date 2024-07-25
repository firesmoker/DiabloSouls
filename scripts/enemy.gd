extends RigidBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
var sprite_material: Material

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	sprite_material = animated_sprite_2d.material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
