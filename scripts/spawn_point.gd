extends Node2D

var new_y_position_offset: float = 0
@onready var skeleton: Enemy = $Skeleton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body. 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(5).timeout
	duplicate_enemy()


func duplicate_enemy() -> void:
	new_y_position_offset += 5
	var new_skeleton: Enemy = skeleton.duplicate()
	add_child(new_skeleton)
	skeleton.position.y += new_y_position_offset

func create_enemies_timed(delay: float = 3.0) -> void:
	var enemy_type: PackedScene = load("res://scenes/skeleton_fast.tscn")
	while true:
		#print_debug("creating enemy")
		await get_tree().create_timer(delay).timeout
		var new_enemy:  = enemy_type.instantiate()
		add_child(new_enemy)
		print_debug(new_enemy.owner)
