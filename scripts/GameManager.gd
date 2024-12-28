class_name GameManager extends Node

@onready var player: Player = $"../Player"
@onready var camera: Camera2D = $"../Player/Camera2D"
@onready var point_light: PointLight2D = $"../Player/Camera2D/PointLight2D"
@onready var hud: CanvasLayer = %HUD
@onready var enemy_label: Label = %HUD/EnemyLabel
@onready var enemy_health: ProgressBar = %HUD/EnemyHealth
@onready var player_health: ProgressBar = %HUD/PlayerHealth
@onready var player_stamina: ProgressBar = %HUD/PlayerStamina
@onready var player_mana: ProgressBar = %HUD/PlayerMana
@onready var player_mana_overdraw: ProgressBar = %HUD/PlayerManaOverdraw

@onready var darkness: Sprite2D = $"../Darkness"

@export var shake_time: float = 0.05
@export var shake_amount: float = 1.5
@export var lightning_amount: float = 0.12
@export var enemies_under_mouse := []

static var current_delta: float = 0.0167

var enemy_in_focus: Enemy
var frame_count: int = 0
var time_game_started: float = 0
var fps_time_elapsed: float = 0

func _ready() -> void:
	time_game_started = Time.get_ticks_msec()/1000.0
	print_template("Game starts at: " + str(time_game_started))
	set_default_visibility()
	set_resource_bars_values()

func set_resource_bars_values() -> void:
	player_health.max_value = player.max_hitpoints
	player_stamina.max_value = player.max_stamina
	player_mana.max_value = player.max_mana

func set_default_visibility() -> void:
	hud.visible = true
	enemy_label.visible = true

func handle_cheat_inputs(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		print_template("Restarting")
		AutoloadManager.first_run = false
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("zoom_out"):
		print_debug("zoom out")
		var zoom_in_amount:float = 115.0 / 100.0
		camera.zoom.x *= zoom_in_amount
		camera.zoom.y *= zoom_in_amount
		
	elif event.is_action_pressed("zoom_in"):
		print_debug("zoom in")
		var zoom_out_amount:float = 100.0 / 115.0
		camera.zoom.x *= zoom_out_amount
		camera.zoom.y *= zoom_out_amount


func _unhandled_input(event: InputEvent) -> void:
	handle_cheat_inputs(event)

func _process(delta: float) -> void:
	current_delta = delta
	fps_time_elapsed += delta
	update_debug(delta)
	frame_count += 1
	if frame_count == 1:
		print_template("Performance: first frame since start. Took about " + str(Time.get_ticks_msec()/1000.0 - time_game_started) + " seconds")
	darkness.position = player.position
	update_resource_bars()
	switch_to_best_focus_enemy()
	update_enemy_label()
	if player.dead:
		point_light.color = Color.RED
		point_light.energy = 1
		

func calculate_fps(delta: float) -> float:
	var fps: float = 1 / delta
	return fps

func update_debug(delta: float, update_fps_every: float = 0.2) -> void:
	var debug: Control = hud.find_child("Debug")
	if fps_time_elapsed > update_fps_every:
		fps_time_elapsed = 0
		var fps_label: Label = debug.find_child("FPS")
		var fps: float = calculate_fps(delta)
		fps_label.text = "FPS: " + str(fps)

func switch_to_best_focus_enemy() -> void:
	if enemy_in_focus != null and enemies_under_mouse.size() > 1:
		#print_template("more than one possible enemy in focus. trying to switch")
		var current_enemy_in_focus: Enemy = enemy_in_focus
		enemy_in_focus = get_closest_enemy_to_mouse()
		if current_enemy_in_focus != enemy_in_focus:
			print_template("switched from " + str(current_enemy_in_focus) + " to " + str(enemy_in_focus) + " because it's closer to mouse.")
			current_enemy_in_focus.highlight_stop()

func update_resource_bars() -> void:
	player_health.value = player.hitpoints
	player_stamina.value = player.stamina
	player_mana.value = player.mana
	player_mana.find_child("Text").text = str(player_mana.value)
	if player.mana < 0:
		player_mana_overdraw.visible = true
		player_mana.visible = false
		player_mana_overdraw.value = abs(player.mana)
		player_mana_overdraw.find_child("Text").text = str(float(-player_mana_overdraw.value))
	else:
		player_mana_overdraw.visible = false
		player_mana.visible = true

func update_enemy_label() -> void:
	if enemy_in_focus != null:
		enemy_in_focus.highlight()
		enemy_label.visible = true
		enemy_health.visible = true
		enemy_label.text = enemy_in_focus.id
		enemy_health.max_value = enemy_in_focus.hitpoints_max
		enemy_health.value = enemy_in_focus.hitpoints
	else:
		enemy_label.visible = false
		enemy_health.visible = false

	
		
func enemy_in_player_melee_zone(enemy: Enemy, in_zone: bool = true) -> void:
	enemy.in_player_melee_zone = in_zone
	enemy.highlight_circle.visible = in_zone

#func player_in_melee(enemy: Enemy) -> void:
	#pass
	#print_debug("MELEE!! (gamemanager) with " + str(enemy))
	#player.enemies_in_melee.append(enemy)
	#if player.is_chasing_enemy and player.targeted_enemy == enemy:
			#player.attack(enemy.position)

#func player_left_melee(enemy: Enemy) -> void:
	#pass
	#print_debug("LEFT MELEE!! (gamemanager) with " + str(enemy))
	#if enemy in player.enemies_in_melee:
		#player.enemies_in_melee.erase(enemy)

func player_gets_hit(damage: float = 1) -> void:
	player.get_hit(damage)
	if not player.dead:
		var timer: Timer = Timer.new()
		timer.wait_time = shake_time
		camera.add_child(timer)
		
		point_light.color = Color.RED
		point_light.energy += 0.25
		
		timer.start()
		await timer.timeout
		timer.queue_free()
		
		point_light.color = Color.WHITE
		point_light.energy -= 0.25

func camera_shake_and_color(color: bool = true, extra: bool = false) -> void:
	var timer: Timer = Timer.new()
	camera.add_child(timer)
	
	freeze_display()
	timer.wait_time = shake_time
	if color:
		#point_light.blend_mode = 0
		#point_light.color = Color.TEAL
		point_light.energy += lightning_amount
	var extra_modifier: float = 1
	if extra:
		extra_modifier = 2
	camera.position.x += shake_amount * extra_modifier
	camera.position.y += shake_amount * 0.7 * extra_modifier
	timer.start()
	await timer.timeout
	timer.queue_free()
	if color:
		#point_light.blend_mode = 1
		#point_light.color = Color.WHITE
		point_light.energy -= lightning_amount
	camera.position.x -= shake_amount * extra_modifier
	camera.position.y -= shake_amount*0.7 * extra_modifier

func enemy_mouse_hover(enemy: Enemy) -> void:
	if enemy not in enemies_under_mouse:
		enemies_under_mouse.append(enemy)
		#print_debug("added enemy under mouse: " + str(enemy.name))
	#if enemy_in_focus != null:
		#enemy_in_focus.highlight_stop()	
	if enemy_in_focus == null:
		enemy_in_focus = enemy

func enemy_mouse_hover_stopped(enemy: Enemy) -> void:
	if enemy in enemies_under_mouse:
		enemies_under_mouse.erase(enemy)
		#print_debug("removed enemy under mouse: " + str(enemy.name))
	if enemy == enemy_in_focus:
		enemy.highlight_stop()
		if enemies_under_mouse.size() > 0:
			#print_debug("switched to other enemy under mouse")
			enemy_in_focus.highlight_stop()
			enemy_in_focus = get_closest_enemy_to_mouse()
		else:
			enemy_in_focus = null

func get_closest_enemy_to_mouse() -> Enemy:
	if enemies_under_mouse.size() > 0:
		var closest_distance_to_mouse: float = 50000
		var closest_enemy: Enemy = enemies_under_mouse[0]
		for enemy: Enemy in enemies_under_mouse:
			if enemy.position.distance_to(player.get_global_mouse_position()) <= closest_distance_to_mouse:
				closest_distance_to_mouse = enemy.position.distance_to(player.get_global_mouse_position())
				closest_enemy = enemy
		print_template(str(closest_enemy.name) + " is the closest enemy")
		return closest_enemy
	else:
		print_template("no enemies under mouse!")
		return null

func _on_player_attack_success(enemy: Enemy) -> void:
	camera_shake_and_color()
	#print_debug("attack succes!")
	var enemy_death_status: bool = await enemy.get_hit()
	#print_debug(enemy_death_status)z
	#if enemy_death_status:
		#print_debug("extra death shake")
		#camera_shake_and_color()

func _on_player_parry_success(enemy: Enemy) -> void:
	#camera_shake_and_color()
	if enemy.in_melee or enemy.in_player_melee_zone:
		if enemy.can_be_countered:
			enemy.get_parried(true)
		elif enemy.can_be_parried:
			enemy.get_parried()
		else:
			print_debug("enemy can't be parried")

func freeze_display(duration := 0.2 / 12.0, delay := 0.05) -> void:
	await get_tree().create_timer(delay).timeout
	#RenderingServer.set_render_loop_enabled(false)
	var timer: Timer = Timer.new()
	add_child(timer)
	var time_scale: float = 0.1
	timer.wait_time = duration * time_scale
	timer.start()
	Engine.time_scale = time_scale
	await timer.timeout
	Engine.time_scale = 1
	#RenderingServer.set_render_loop_enabled(true)


func dir_contents(path: String) -> void:
	var dir: = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print_debug("Found directory: " + file_name)
			else:
				print_debug("Found file: " + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print_debug("An error occurred when trying to access the path.")

func dir_contents_filter(path: String, extension: String, print: bool = false) -> Array[String]:
	var dir: = DirAccess.open(path)
	var fixed_path: String
	var file_list: Array[String] = []
	if dir:
		dir.list_dir_begin()
		fixed_path = dir.get_current_dir()
		#print_debug("fixed path is " + fixed_path)
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(extension):
					#print_debug("Found a " + extension + " file: " + file_name)
					var file_name_path: String = fixed_path + "/" + file_name
					file_list.append(file_name_path)
					if print:
						print_debug("added to file list: " + file_name_path)
					
				#print_debug("Found directory: " + file_name)
			#else:
				#print_debug("Found file: " + file_name)
				
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print_debug("An error occurred when trying to access the path: " + path)
	return file_list

func print_template(message: String, tag: String = "#Main") -> void:
	Helper.print_template("game_manager", message,tag)
