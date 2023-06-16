extends TextureProgressBar


func _ready() -> void:
	value = 0
	PlayerService.energy_timer.as_signal().subscribe(func(current_time: int):
		if current_time == Consts.ENERGY_TICKS_TO_GAIN:
			value = 0
		var tween := create_tween()
		tween.tween_property(self, "value", remap(
			current_time + 1 if current_time < Consts.ENERGY_TICKS_TO_GAIN else 1, 
			0, 
			Consts.ENERGY_TICKS_TO_GAIN, 
			0, 
			100
		), 0.99).set_trans(Tween.TRANS_LINEAR)
	).dispose_with(self)
