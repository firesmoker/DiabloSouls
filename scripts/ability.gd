class_name Ability extends Node2D

@export var ability_name: String
@export var display_name: String
@export var mana_cost: float
@export var stamina_cost: float
@export var range_type: String # personal, melee, ranged
@export var friendly_fire: bool
@export var display_image: Image
@export var description: String
@export var effect_names: Array[String]
@export var effects: Dictionary
var effects_num: int = 0
var effects_finished: int = 0
var activated: bool = false
signal ablility_constructed

func _init() -> void:
	#connect("ablility_constructed",AbilityManager.register_ability)
	#emit_signal("ablility_constructed",self.ability_name)
	print(ability_name + " initialized")

#func _init(ability_name: String, 
	#display_name: String, 
	#mana_cost: float, 
	#stamina_cost: float, 
	#range_type: String, 
	#friendly_fire: bool, 
	#display_image: Image, 
	#description: String, 
	#effect_names: Array) -> void:
	#
	#self.ability_name = ability_name
	#self.display_name = display_name
	#self.mana_cost = mana_cost
	#self.stamina_cost = stamina_cost
	#self.range_type = range_type
	#self.friendly_fire = friendly_fire
	#self.display_image = display_image
	#self.description = description
	#self.effect_names = effect_names
	#connect("ablility_constructed",AbilityManager.register_ability)
	#emit_signal("ablility_constructed",self.ability_name,"res://abilities/ability_" + ability_name + ".tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_effects_by_name()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if effects_finished >= effects_num and activated:
		queue_free()

func load_effects_by_name() -> void:
	#var i: int = 0
	for effect_name: String in effect_names:
		effects[effect_name] = load("res://effects/" + effect_name + ".tscn")
		if effects[effect_name]:
			effects_num += 1

func activate(creator: Node2D, location: Vector2) -> void:
	for effect_name: String in effects:
		activated = true
		create_effect(creator, location, effects[effect_name])


func create_effect(creator: Node2D, location: Vector2, effect: PackedScene) -> void:
	var new_effect: Effect = effect.instantiate()
	add_child(new_effect)

func update_effects_finished() -> void:
	effects_finished += 1
