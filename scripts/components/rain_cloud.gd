extends Node2D


@export var fade_in_duration := 0.25
@export var fade_out_duration := 0.5


func _ready() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, fade_in_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func fade_and_free() -> void:
	if not is_instance_valid(self):
		return
	
	var tween := create_tween().tween_property(self, "modulate:a", 0.0, fade_out_duration) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	queue_free()
