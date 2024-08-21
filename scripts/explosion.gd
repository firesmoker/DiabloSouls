class_name Explosion extends Node2D

@onready var self_destruct_timer: Timer = $SelfDestructTimer
var time_to_self_destruct: float = 3

func _ready() -> void:
	self_destruct_timer.wait_time = time_to_self_destruct
	self_destruct_timer.start()

func _on_self_destruct_timer_timeout() -> void:
	queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
