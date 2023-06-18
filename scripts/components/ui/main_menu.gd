extends Node2D


@export var first_level: PackedScene = null
@export var click_sound: AudioStream = null
@export var music_loop: AudioStream = null

@onready var play_button: TextureButton = $Menu/PlayButton as TextureButton


func _ready() -> void:
	SoundService.start_music_loop(music_loop)

	play_button.pressed.connect(
		func():
			SoundService.play(click_sound, "Sounds")
			get_tree().change_scene_to_packed(first_level),
		CONNECT_ONE_SHOT
	)
