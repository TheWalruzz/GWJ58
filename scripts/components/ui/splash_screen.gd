extends CanvasLayer


@export var fade_duration := 1.0
@export var display_duration := 2.0
@export var images: Array[Texture2D] = []
@export var next_scene: PackedScene = null

@onready var fader: TextureRect = $Fader as TextureRect
@onready var image: TextureRect = $MarginContainer/Image as TextureRect


func _ready() -> void:
	fader.modulate.a = 1.0

	for current_image in images:
		image.texture = current_image
		await _fade(0.0).finished
		await get_tree().create_timer(display_duration).timeout
		await _fade(1.0).finished
	
	if next_scene != null:
		get_tree().change_scene_to_packed(next_scene)
	else:
		get_tree().quit()


func _fade(to: float) -> PropertyTweener:
	return create_tween().tween_property(fader, "modulate:a", to, fade_duration)
