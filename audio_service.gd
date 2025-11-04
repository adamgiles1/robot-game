extends Node

const NUMBER_OF_CHANNELS = 32

var sound_effect_cache: Dictionary[String, AudioStream] = {}

var audio_players: Array[AudioStreamPlayer]
var audio_stream_players_idx: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(NUMBER_OF_CHANNELS):
		var player := AudioStreamPlayer.new()
		add_child(player)
		audio_players.append(player)

func play_sound(sound_name: String) -> void:
	var player := audio_players[audio_stream_players_idx]
	player.stream = get_audio_stream(sound_name)
	player.play()
	
	audio_stream_players_idx = wrapi(audio_stream_players_idx + 1, 0, audio_players.size())

func get_audio_stream(name: String) -> AudioStream:
	var stream: AudioStream
	if sound_effect_cache.has(name):
		stream = sound_effect_cache[name]
	else:
		print("cache miss, loading sound effect: ", name)
		stream = load("res://audio/" + name + ".wav")
		sound_effect_cache[name] = stream
	
	return stream
