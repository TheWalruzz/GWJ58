extends TextureProgressBar


func _ready() -> void:
	PlayerService.time.as_signal().subscribe(func(time_left: int):
		value = remap(time_left, 0, PlayerService.current_time_total, 0, 100)
	).dispose_with(self)
