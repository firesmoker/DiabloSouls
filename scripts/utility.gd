class_name Utility extends Node

const average_delta: float = 0.01666666666667
const FPS: float = 12
enum directions{N,NE,E,SE,S,SW,W,NW}
static var direction_name: Dictionary = {
	directions.N : "N",
	directions.NE : "NE",
	directions.E : "E",
	directions.SE : "SE",
	directions.S : "S",
	directions.SW : "SW",
	directions.W : "W",
	directions.NW : "NW",
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
