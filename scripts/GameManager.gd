class_name GameManager extends Node

@onready var player: Player = $"../Player"
@onready var camera: Camera2D = $"../Player/Camera2D"
@onready var point_light: PointLight2D = $"../Player/Camera2D/PointLight2D"
@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5
@export var lightning_amount: float = 0.12
@export var enemies_under_mouse := []
var enemy_in_focus: Enemy


func _process(delta: float) -> void:
	#print(enemy_in_focus)
	if enemy_in_focus != null:
		enemy_in_focus.highlight()
	if player.dead:
		point_light.color = Color.RED
		point_light.energy = 1
		

func player_in_melee(enemy: Enemy) -> void:
	pass
	#print("MELEE!! (gamemanager) with " + str(enemy))
	#player.enemies_in_melee.append(enemy)
	#if player.is_chasing_enemy and player.targeted_enemy == enemy:
			#player.attack(enemy.position)

func player_left_melee(enemy: Enemy) -> void:
	pass
	#print("LEFT MELEE!! (gamemanager) with " + str(enemy))
	#if enemy in player.enemies_in_melee:
		#player.enemies_in_melee.erase(enemy)

func player_gets_hit(damage: float = 1) -> void:
	player.get_hit(damage)
	if not player.dead:
		var timer := Timer.new()
		timer.wait_time = shake_time
		camera.add_child(timer)
		
		point_light.color = Color.RED
		point_light.energy += 0.25
		
		timer.start()
		await timer.timeout
		timer.queue_free()
		
		point_light.color = Color.WHITE
		point_light.energy -= 0.25

func camera_shake_and_color(color: bool = true) -> void:
	var timer := Timer.new()
	camera.add_child(timer)
	
	#freeze_display()
	timer.wait_time = shake_time
	if color:
		#point_light.blend_mode = 0
		#point_light.color = Color.TEAL
		point_light.energy += lightning_amount
	camera.position.x += shake_amount
	camera.position.y += shake_amount*0.7
	timer.start()
	await timer.timeout
	timer.queue_free()
	if color:
		#point_light.blend_mode = 1
		#point_light.color = Color.WHITE
		point_light.energy -= lightning_amount
	camera.position.x -= shake_amount
	camera.position.y -= shake_amount*0.7

func enemy_mouse_hover(enemy: Enemy) -> void:
	if enemy not in enemies_under_mouse:
		enemies_under_mouse.append(enemy)
		#print("added enemy under mouse: " + str(enemy.name))
	#if enemy_in_focus != null:
		#enemy_in_focus.highlight_stop()	
	if enemy_in_focus == null:
		enemy_in_focus = enemy

func enemy_mouse_hover_stopped(enemy: Enemy) -> void:
	if enemy in enemies_under_mouse:
		enemies_under_mouse.erase(enemy)
		#print("removed enemy under mouse: " + str(enemy.name))
	enemy.highlight_stop()
	if enemies_under_mouse.size() > 0:
		#print("switched to other enemy under mouse")
		enemy_in_focus = enemies_under_mouse[0]
	else:
		enemy_in_focus = null

func _on_player_attack_success(enemy: Enemy) -> void:
	camera_shake_and_color()
	enemy.get_hit()

func _on_player_parry_success(enemy: Enemy) -> void:
	#camera_shake_and_color()
	enemy.get_parried()

func freeze_display(duration := 0.3 / 12.0, delay := 0.05) -> void:
	await get_tree().create_timer(delay).timeout
	RenderingServer.set_render_loop_enabled(false)
	
	await get_tree().create_timer(duration).timeout
	RenderingServer.set_render_loop_enabled(true)


func dir_contents(path: String) -> void:
	var dir: = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")

func dir_contents_filter(path: String, extension: String, print: bool = false) -> Array[String]:
	var dir: = DirAccess.open(path)
	var fixed_path: String
	var file_list: Array[String] = []
	if dir:
		dir.list_dir_begin()
		fixed_path = dir.get_current_dir()
		#print("fixed path is " + fixed_path)
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(extension):
					#print("Found a " + extension + " file: " + file_name)
					var file_name_path: String = fixed_path + "/" + file_name
					file_list.append(file_name_path)
					if print:
						print("added to file list: " + file_name_path)
					
				#print("Found directory: " + file_name)
			#else:
				#print("Found file: " + file_name)
				
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
	return file_list
