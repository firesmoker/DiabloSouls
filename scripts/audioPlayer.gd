class_name AudioPlayer extends Node

var audio_streams: Array[AudioStreamPlayer2D]
var my_sounds: Dictionary
@export var sounds: Dictionary

func _ready() -> void:
	my_sounds = sounds.duplicate()
	var sounds_keys: Array = my_sounds.keys()
	if my_sounds.size() <= 0:
		return
	else:
		for i in range(0,my_sounds.size()):
			var new_audio_stream: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			new_audio_stream.bus = "SFX"
			self.add_child(new_audio_stream)
			if my_sounds[sounds_keys[i]] != null:
				#print_debug("SOUND:" + str(my_sounds[sounds_keys[i]]))
				new_audio_stream.stream = my_sounds[sounds_keys[i]]
			else:
				#print_debug("null on " + str(self))
				pass
			audio_streams.append(new_audio_stream)
			var sound_name: String = sounds_keys[i] as String
			my_sounds[sounds_keys[i]] = {
				"name": sound_name,
				"stream": i
			}



func play(name: String, pitch_min: float = 1.0, pitch_max: float = 1.0) -> void:
	if my_sounds.size() > 0:
		if name in my_sounds:
			audio_streams[my_sounds[name]["stream"]].pitch_scale = randf_range(pitch_min, pitch_max)
			audio_streams[my_sounds[name]["stream"]].play()
		else:
			print_debug("no " + name + " in sounds")
	else:
		print_debug("no sounds for " + str(self.get_parent()))
