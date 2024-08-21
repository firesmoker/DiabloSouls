class_name Projectile extends Node2D

@onready var self_destruct_timer: Timer = $SelfDestructTimer
@export var explosion: PackedScene
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
	var impact_explosion: Node2D = explosion.instantiate() as Node2D
	get_tree().root.add_child(impact_explosion)
	impact_explosion.global_position = global_position
	queue_free()


func _on_impact_zone_body_entered(body: CollisionObject2D) -> void:
	print("body entered " + str(body))
	if body == player:
		var impact_explosion: Node2D = explosion.instantiate() as Node2D
		#impact_explosion.global_position = self.position
		get_tree().root.add_child(impact_explosion)
		impact_explosion.global_position = global_position
		#await get_tree().process_frame
		print("trying to hit player with projectile")
		player.get_hit()
		queue_free()
	#pass # Replace with function body.
