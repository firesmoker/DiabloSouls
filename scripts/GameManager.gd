extends Node

@onready var player = $"../Player"
@onready var camera = $"../Player/Camera2D"
@onready var point_light = $"../Player/Camera2D/PointLight2D"
@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5
@export var lightning_amount: float = 0.12
@export var enemies_under_mouse: int = 0
var enemy_in_focus


#func _ready():
	#pass # Replace with function body.
#
#
#func _process(delta):
	#pass

func player_in_melee(enemy):
	print("MELEE!! (gamemanager) with " + str(enemy))
	player.in_melee.append(enemy)
	print(player.in_melee)
	if player.is_chasing_enemy and player.targeted_enemy == enemy:
			player.attack(enemy.position)

func player_left_melee(enemy):
	print("LEFT MELEE!! (gamemanager) with " + str(enemy))
	player.in_melee.erase(enemy)
	print(player.in_melee)

func camera_shake_and_color(color: bool = true):
	var timer = Timer.new()
	camera.add_child(timer)
	
	timer.wait_time = shake_time
	if color:
		#point_light.blend_mode = 0
		#point_light.color = Color.TEAL
		point_light.energy -= lightning_amount
	#freeze_display()
	camera.position.x += shake_amount
	camera.position.y += shake_amount*0.7
	timer.start()
	await timer.timeout
	timer.queue_free()
	if color:
		#point_light.blend_mode = 1
		#point_light.color = Color.WHITE
		point_light.energy += lightning_amount
	camera.position.x -= shake_amount
	camera.position.y -= shake_amount*0.7

func enemy_mouse_hover(enemy):
	print("enemy mouse hover function (in gamemanager)")
	enemies_under_mouse += 1
	if enemy_in_focus:
		enemy_in_focus.highlight()
	enemy_in_focus = enemy
	enemy_in_focus.highlight()

func enemy_mouse_hover_stopped(enemy):
	print("enemy mouse hover STOPPED (in gamemanager)")
	enemies_under_mouse -= 1
	enemy_in_focus.highlight_stop()
	enemy_in_focus = null

func _on_player_attack_success(body):
	body.get_hit()
	camera_shake_and_color()

func freeze_display(duration = 0.5 / 12.0, delay = 0.05):
	await get_tree().create_timer(delay).timeout
	RenderingServer.set_render_loop_enabled(false)
	
	await get_tree().create_timer(duration).timeout
	RenderingServer.set_render_loop_enabled(true)

