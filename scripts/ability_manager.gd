class_name AbilityManager extends Node

static var abilities: Dictionary = {}  # Holds ability names and their file paths.

# Registers an ability with its file path.
static func register_ability(ability_name: String) -> void:
	var path: String = "res://abilities/ability_explosion.tscn"
	if abilities.has(ability_name):
		print("Ability already registered: " + ability_name)
		return
	abilities[ability_name] = path
	print("Registered ability: " + ability_name)

# Retrieves a PackedScene for the specified ability by loading it dynamically.
static func get_ability_scene(ability_name: String) -> PackedScene:
	if abilities.has(ability_name):
		var path: String = abilities[ability_name]
		var scene: PackedScene = load(path)
		if scene:
			return scene
	print("Ability not found or failed to load: " + ability_name)
	return null

# Instantiates an ability by name.
static func create_ability_instance(ability_name: String) -> Ability:
	var scene: PackedScene = get_ability_scene(ability_name)
	if scene:
		var ability_instance := scene.instantiate() as Ability
		if ability_instance:
			return ability_instance
	print("Failed to create ability instance: " + ability_name)
	return null

func _ready() -> void:
	pass
		# Register abilities with file paths during runtime.
	register_ability("explosion")
