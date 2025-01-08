class_name AbilityManager extends Node

static var abilities: Dictionary = {}  # Holds ability names and their file paths.
static var ability_scene_templates: Dictionary = {}

# Registers an ability with its file path.
static func register_ability(ability_name: String) -> void:
	var path: String = ("res://abilities/ability_" + ability_name + ".tscn")
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
			print("ability manager found scene for " + str(ability_name))
			return scene
	print("Ability not found or failed to load: " + ability_name)
	return null

static func get_ability(ability_name: String) -> Ability:
	if abilities.has(ability_name):
		if ability_scene_templates.has(ability_name):
			print("found ability scene template for: " + ability_name)
			return ability_scene_templates[ability_name]
		var path: String = abilities[ability_name]
		var scene: PackedScene = load(path)
		if scene:
			print("creating ability scene template for: " + ability_name)
			
			var temp_scene: Ability = scene.instantiate()
			if temp_scene:
				ability_scene_templates[ability_name] = temp_scene
				print("found ability script: " + ability_name)
				return ability_scene_templates[ability_name]
			else:
				print("faild to find ability script: " + ability_name)
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
	register_ability("player_basic_attack")
