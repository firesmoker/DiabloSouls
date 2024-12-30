class_name Effect extends Node2D

@onready var timer: Timer = $Timer
var effect1: EffectType = EffectType.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(effect1.duration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()
	#pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	apply_effect(body, effect1)
	print(str(body) + " entered damage, applying " + str(effect1))

func apply_effect(something: Node2D, effect_type: EffectType) -> void:
	if effect_type.damaging:
		damage(something, effect_type.damage)
		print("damaging " + str(something) + " with damage = " + str(effect_type.damage))

func damage(something: Node2D, damage_amount: float) -> void:
	if something is Enemy:
		something.get_hit(damage_amount)
		print(str(something) + " is Enemy, got hit with amount " + str(damage_amount))
	elif something is Player:
		something.get_hit(damage_amount)
		print(str(something) + " is Player, got hit with amount " + str(damage_amount))

class EffectType:
	var damaging: bool = true
	var damage: float = 3
	var duration: float = 0.1
