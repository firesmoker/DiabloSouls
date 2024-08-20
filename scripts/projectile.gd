class_name Projectile extends Node2D

@onready var self_destruct_timer: Timer = $SelfDestructTimer
#@onready var game_manager: GameManager = %GameManager

var velocity: Vector2 = Vector2(90,90)
var time_to_self_destruct: float = 3
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_destruct_timer.wait_time = time_to_self_destruct
	self_destruct_timer.start()
	visible = false
	#if game_manager != null:
		#player = game_manager.player
	#else:
		#print("game manager null for projectile")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = true
	position += velocity

func _on_self_destruct_timer_timeout() -> void:
	queue_free()


func _on_impact_zone_body_entered(body: CollisionObject2D) -> void:
	print("body entered " + str(body))
	if body == player:
		print("trying to hit player with projectile")
		player.get_hit()
		queue_free()
	#pass # Replace with function body.
