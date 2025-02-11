extends CanvasLayer

@onready var pause_label: Label = $PauseLabel
@onready var darken_screen: Panel = $DarkenScreen
@onready var restart_button: Button = $RestartButton
@onready var loading_panel: Panel = $LoadingPanel
@onready var game_manager: GameManager = %GameManager



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		var pause_status: bool = get_tree().paused
		pause(!pause_status)

func _ready() -> void:
	set_default_visibility()

func set_default_visibility() -> void:
	self.visible = true
	toggle_menu_elements(false)

func toggle_menu_elements(toggle: bool) -> void:
	var menu_elements: Array = get_children()
	for element: Variant in menu_elements:
		element.visible = toggle
	loading_panel.visible = false

func pause(toggle: bool) -> void:
	get_tree().paused = toggle
	game_manager.toggle_hud(!toggle)
	toggle_menu_elements(toggle)

func restart_game() -> void:
	toggle_menu_elements(false)
	loading_panel.visible = true
	darken_screen.visible = true
	await get_tree().create_timer(0.5).timeout
	pause(false)
	get_tree().reload_current_scene()

func _on_restart_button_up() -> void:
	restart_game()
	
func _on_resume_button_up() -> void:
	pause(false)
