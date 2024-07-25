extends Node
@onready var player = $"../Player"
@onready var camera = $"../Player/Camera2D"
@onready var point_light = $"../Player/Camera2D/PointLight2D"
@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#camera.position.x += 15
	pass

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

func enemy_mouse_hover(enemy):
	print("enemy mouse hover function (in gamemanager)")
	enemy.highlight()

func enemy_mouse_hover_stopped(enemy):
	print("enemy mouse hover function (in gamemanager)")
	enemy.highlight_stop()

func _on_player_attack_success(body):
	print("kuku!" + str(body))
	#var sprite = body.get_node("AnimatedSprite2D")
	#print(sprite)
	body.get_hit()
	camera_shake_and_color()
