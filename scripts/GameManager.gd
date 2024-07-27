extends Node

@onready var player := $"../Player"
@onready var camera := $"../Player/Camera2D"
@onready var point_light := $"../Player/Camera2D/PointLight2D"
@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5
@export var lightning_amount: float = 0.12
@export var enemies_under_mouse := []
var enemy_in_focus: RigidBody2D


func _process(delta: float) -> void:
	print(enemy_in_focus)
	if enemy_in_focus != null:
		enemy_in_focus.highlight()

func player_in_melee(enemy: RigidBody2D) -> void:
	print("MELEE!! (gamemanager) with " + str(enemy))
	player.in_melee.append(enemy)
	if player.is_chasing_enemy and player.targeted_enemy == enemy:
			player.attack(enemy.position)

func player_left_melee(enemy: RigidBody2D) -> void:
	print("LEFT MELEE!! (gamemanager) with " + str(enemy))
	if enemy in player.in_melee:
		player.in_melee.erase(enemy)

func camera_shake_and_color(color: bool = true) -> void:
	var timer := Timer.new()
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

func enemy_mouse_hover(enemy: RigidBody2D) -> void:
	if enemy not in enemies_under_mouse:
		enemies_under_mouse.append(enemy)
		print("added enemy under mouse: " + str(enemy.name))
	if enemy_in_focus != null:
		enemy_in_focus.highlight_stop()	
	enemy_in_focus = enemy

func enemy_mouse_hover_stopped(enemy: RigidBody2D) -> void:
	if enemy in enemies_under_mouse:
		enemies_under_mouse.erase(enemy)
		print("removed enemy under mouse: " + str(enemy.name))
	enemy.highlight_stop()
	if enemies_under_mouse.size() > 0:
		print("switched to other enemy under mouse")
		enemy_in_focus = enemies_under_mouse[0]
	else:
		enemy_in_focus = null

func _on_player_attack_success(enemy: RigidBody2D) -> void:
	enemy.get_hit()
	camera_shake_and_color()

func freeze_display(duration := 0.5 / 12.0, delay := 0.05) -> void:
	await get_tree().create_timer(delay).timeout
	RenderingServer.set_render_loop_enabled(false)
	
	await get_tree().create_timer(duration).timeout
	RenderingServer.set_render_loop_enabled(true)

