extends TileMap

enum layers{
	level0 = 0,
	level1 = 1,
	level2 = 2,
}

const GREEN_BLOCK_ATLAS_POS = Vector2i(2, 0)
const MAIN_SOURCE = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for y in range(3):
		for x in range(3):
			set_cell(layers.level0, Vector2i(2 + x, 2 + y), MAIN_SOURCE, GREEN_BLOCK_ATLAS_POS)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
