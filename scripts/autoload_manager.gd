extends Node

static var first_run: bool = true
var loading_screen: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_loading_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_loading_screen() -> void:
	var packed_loading_screen: PackedScene = preload("res://scenes/loading_screen.tscn")
	loading_screen = packed_loading_screen.instantiate()
	loading_screen.process_mode = Node.PROCESS_MODE_DISABLED
	mouse_ignore_screen_elements(loading_screen)
	add_child(loading_screen)

func mouse_ignore_screen_elements(screen: CanvasLayer) -> void:
	var screen_elements: Array = screen.get_children()
	for element: Variant in screen_elements:
		if element is Control:
			element.mouse_filter = Control.MOUSE_FILTER_IGNORE
