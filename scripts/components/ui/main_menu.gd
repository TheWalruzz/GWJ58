extends Node2D


@export var first_level: PackedScene = null

@onready var play_button: TextureButton = $Menu/PlayButton


func _ready() -> void:
	play_button.pressed.connect(
		func():
			get_tree().change_scene_to_packed(first_level),
		CONNECT_ONE_SHOT
	)
