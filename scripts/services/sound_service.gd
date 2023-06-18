extends Node


const INITIAL_POOL_SIZE := 5

var pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer = null


func _ready() -> void:
	for i in INITIAL_POOL_SIZE:
		_create_new_player()
		
		
func play(stream: AudioStream, bus: String) -> AudioStreamPlayer:
	var player := _get_free_player()
	player.bus = bus
	player.stream = stream
	player.volume_db = 0.0
	player.play()
	return player
	
	
func start_music_loop(stream: AudioStream) -> void:
	if music_player == null:
		music_player = play(stream, "Music")


func _create_new_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	pool.append(player)
	add_child(player)
	return player
	
	
func _get_free_player() -> AudioStreamPlayer:
	for player in pool:
		if not player.playing:
			return player
	var new_player := _create_new_player()
	return new_player
