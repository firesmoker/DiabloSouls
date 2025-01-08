extends Node2D

@onready var player_detector_area: Area2D = $PlayerDetectorArea
var original_alpha: float = 1
var parent: Variant
var fade_interval: float = 0.005
var alpha_when_showing_player: float = 0.5
var target_for_fade_out: float = 0
var target_for_fade_in: float = 1
var fade_state: String = "none"
var player: Player

func _ready() -> void:
	parent = get_parent()
	original_alpha = parent.self_modulate.a


func _process(delta: float) -> void:
	fade()


func fade() -> void:
	match fade_state:
		"default_alpha":
			fade_in(original_alpha)
		"show_player":
			if player:
				if player.global_position.y < parent.global_position.y:
					fade_out(alpha_when_showing_player)
				else:
					fade_in(original_alpha)
		#"no_player":
			#parent.self_modulate.a += fade_interval
			#if parent.self_modulate.a >= target_for_fade_in:
				#parent.self_modulate.a = target_for_fade_in

func fade_in(target_for_fade_in: float = 1) -> void:
	parent.self_modulate.a += fade_interval
	if parent.self_modulate.a >= target_for_fade_in:
		parent.self_modulate.a = target_for_fade_in

func fade_out(target_for_fade_out: float = 0) -> void:
	parent.self_modulate.a -= fade_interval
	if parent.self_modulate.a <= target_for_fade_out:
		parent.self_modulate.a = target_for_fade_out


func show_player() -> void:
	fade_state = "show_player"
	
func change_to_default_alpha() -> void:
	fade_state = "default_alpha"


func _on_player_detector_area_area_entered(area: Area2D) -> void:
	var area_parent: Variant = area.get_parent()
	if area_parent is Player:
		player = area_parent
		show_player()


func _on_player_detector_area_area_exited(area: Area2D) -> void:
	var area_parent: Variant = area.get_parent()
	if area_parent is Player:
		player = null
		change_to_default_alpha()
