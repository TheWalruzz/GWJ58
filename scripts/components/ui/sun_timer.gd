extends TextureProgressBar


func _ready() -> void:
	value = 0
	PlayerService.level_tick_timer.as_signal().subscribe(func(current_time: int):
		if current_time == Consts.GAME_TICKS_TO_LEVEL_TICK:
			value = 0
		var tween := create_tween()
		tween.tween_property(self, "value", remap(
			current_time + 1 if current_time < Consts.GAME_TICKS_TO_LEVEL_TICK else 1, 
			0, 
			Consts.GAME_TICKS_TO_LEVEL_TICK, 
			0, 
			100
		), 0.99).set_trans(Tween.TRANS_LINEAR)
	).dispose_with(self)
