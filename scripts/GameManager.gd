extends Node

@onready var player = $"../Player"
@onready var camera = $"../Player/Camera2D"
@onready var point_light = $"../Player/Camera2D/PointLight2D"
@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5
@export var enemies_under_mouse: int = 0


#func _ready():
	#pass # Replace with function body.
#
#
#func _process(delta):
	#pass


func camera_shake_and_color(color: bool = true):
	var timer = Timer.new()
	camera.add_child(timer)
	
	timer.wait_time = shake_time
	#timer.timeout.connect(_on_timer_timeout)
	if color:
		#point_light.blend_mode = 0
		#point_light.color = Color.TEAL
		point_light.energy -= 0.3
	#freeze_display()
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
	enemies_under_mouse += 1
	enemy.highlight()

func enemy_mouse_hover_stopped(enemy):
	print("enemy mouse hover STOPPED (in gamemanager)")
	enemies_under_mouse -= 1
	enemy.highlight_stop()

func _on_player_attack_success(body):
	print("kuku!" + str(body))
	#var sprite = body.get_node("AnimatedSprite2D")
	#print(sprite)
	body.get_hit()
	camera_shake_and_color()

func freeze_display(duration = 0.5 / 12.0, delay = 0.05):
	# Disable rendering
	
	await get_tree().create_timer(delay).timeout
	RenderingServer.set_render_loop_enabled(false)
	
	# Create a timer for the specified duration
	await get_tree().create_timer(duration).timeout
	
	# Enable rendering
	RenderingServer.set_render_loop_enabled(true)

