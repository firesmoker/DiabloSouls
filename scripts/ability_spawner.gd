extends Node2D

@onready var timer: Timer = $Timer
@export var ability_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ability_scene = AbilityManager.get_ability_scene("explosion")
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	spawn_ability()

func spawn_ability() -> void:
	var new_ability := AbilityManager.create_ability_instance(ability_name)
	if new_ability:
		add_child(new_ability)
		new_ability.activate(self,self.position)
	else:
		print("Failed to spawn ability: " + ability_name)
