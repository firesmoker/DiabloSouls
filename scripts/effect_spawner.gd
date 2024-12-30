extends Node2D

@export var effect: PackedScene
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	spawn_effect()

func spawn_effect() -> void:
	var new_effect: Effect = effect.instantiate()
	add_child(new_effect)
	print("spawning effect")
