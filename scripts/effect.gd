class_name Effect extends Node2D

@onready var timer: Timer = $Timer
@export var damaging: bool = true
@export var damage: float = 3
@export var duration: float = 0.1
#var effect1: EffectType = EffectType.new()

signal effect_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(duration)
	if get_parent() is Ability:
		connect("effect_finished",get_parent().update_effects_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	emit_signal("effect_finished")
	queue_free()
	#pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	apply_effect(body)
	print(str(body) + " entered damage, applying " + name)

func apply_effect(something: Node2D) -> void:
	if damaging:
		deal_damage(something, damage)
		print("damaging " + str(something) + " with damage = " + str(damage))

func deal_damage(something: Node2D, damage_amount: float) -> void:
	var something_parent: Node2D = something.get_parent()
	if something is StaticBody2D:
		print(str(something) + " is StaticBody2D")
		if something_parent is Enemy:
			something_parent.get_hit(damage_amount)
			print(str(something_parent) + " is Enemy, got hit with amount " + str(damage_amount))
	elif something is Area2D:
		if something_parent is Player:
			something_parent.get_hit(damage_amount)
			print(str(something_parent) + " is Player, got hit with amount " + str(damage_amount))
	else:
		print("not sure how to damage, something is not supported type")

class EffectType:
	var damaging: bool = true
	var damage: float = 3
	var duration: float = 0.1
