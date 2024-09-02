class_name Projectile extends Node2D
@onready var collision_shape: CollisionShape2D = $ImpactZone/CollisionShape2D

@onready var self_destruct_timer: Timer = $SelfDestructTimer
@export var explosion: PackedScene
@export var damage: float = 1.0
#@onready var game_manager: GameManager = %GameManager

var velocity: Vector2 = Vector2(90,90)
var time_to_self_destruct: float = 3
var player: Player
var targets_player: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_destruct_timer.wait_time = time_to_self_destruct
	self_destruct_timer.start()
	visible = false
	collision_shape.scale *= 1
	#if game_manager != null:
		#player = game_manager.player
	#else:
		#print("game manager null for projectile")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = true
	position += velocity

func _on_self_destruct_timer_timeout() -> void:
	explode()


func _on_impact_zone_body_entered(body: CollisionObject2D) -> void:
	#print("body entered " + str(body))
	if player != null:
		if body == player and targets_player:
			#print("trying to hit player with projectile")
			player.get_hit()
			explode()
	if not targets_player:
		if typeof(body) == typeof(Enemy):
			#if 1 == 1: print("enemy proj")
			body.get_hit(damage)
			explode()
	#pass # Replace with function body.

func explode() -> void:
	var impact_explosion: Node2D = explosion.instantiate() as Node2D
	get_tree().root.add_child(impact_explosion)
	impact_explosion.global_position = global_position
	queue_free()
