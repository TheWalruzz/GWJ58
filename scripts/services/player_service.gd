extends Node


const LossIcon := preload("res://assets/gfx/sprites/cross.png")

var is_running := false
var current_time_total := 60
var energy := SxProperty.new(0)
var time := SxProperty.new(0)
var level_tick_timer := SxProperty.new(0)
var energy_timer := SxProperty.new(0)

var disposables: SxCompositeDisposable


func _ready() -> void:
	randomize()


func start_level(level: LevelMap, total_time := 60) -> void:
	current_time_total = total_time
	time.value = total_time
	energy.value = Consts.ENERGY_STARTING_AMOUNT
	level_tick_timer.value = 0
	energy_timer.value = 0
	disposables = SxCompositeDisposable.new()
	is_running = true
	
	Sx.interval_timer(Consts.GAME_TICK_INTERVAL) \
		.subscribe(_tick).dispose_with(disposables)
	
	level_tick_timer.as_signal() \
		.filter(func(value: int): return value >= Consts.GAME_TICKS_TO_LEVEL_TICK) \
		.subscribe(func(_x):
			level.tick()
			_reset_timer(level_tick_timer)
	).dispose_with(disposables)
	
	energy_timer.as_signal() \
		.filter(func(value: int): return value >= Consts.ENERGY_TICKS_TO_GAIN) \
		.subscribe(func(_x):
			energy.value += Consts.ENERGY_GAINED_AMOUNT
			_reset_timer(energy_timer)
	).dispose_with(disposables)
	
	time.as_signal(false) \
		.filter(func(value: int): return value <= 0 and is_running) \
		.first() \
		.subscribe(func(_x):
			finish_level()
			UIService.show_message(LossIcon, false)
	).dispose_with(disposables)
	
	UIService.toggle_ui(true)


func finish_level() -> void:
	is_running = false
	disposables.dispose()
	UIService.toggle_ui(false)


func _is_valid() -> bool:
	return time.value > 0 and is_running
	
	
func _reset_timer(timer: SxProperty) -> void:
	await get_tree().create_timer(Consts.GAME_TICK_INTERVAL - 0.001).timeout
	timer.value = 0

	
func _tick() -> void:
	time.value -= 1
	level_tick_timer.value += 1
	energy_timer.value += 1
