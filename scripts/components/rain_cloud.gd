extends Node2D


@export var fade_in_duration := 0.25
@export var fade_out_duration := 0.5
@export var rain_sound: AudioStream = null

var stream_player: AudioStreamPlayer = null


func _ready() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	stream_player = SoundService.play(rain_sound, "Sounds")
	stream_player.volume_db = -80.0
	tween.parallel().tween_property(stream_player, "volume_db", 0.0, fade_in_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func fade_and_free() -> void:
	if get_tree() == null:
		return
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_out_duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(stream_player, "volume_db", -80.0, fade_in_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	stream_player.stop()
	queue_free()
