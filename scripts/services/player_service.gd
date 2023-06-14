extends Node


enum BuildingMode {
	NONE,
	SHRINE,
	RAIN
}


var energy := SxProperty.new(0)
var time := SxProperty.new(0)
var building_mode := SxProperty.new(BuildingMode.NONE)

var disposables: SxCompositeDisposable


func _ready() -> void:
	randomize()


func start_level(level: LevelMap) -> void:
	time.value = 60
	energy.value = 5
	disposables = SxCompositeDisposable.new()
	Sx.interval_timer(3.0).take_while(func(): return time.value > 0) \
		.subscribe(func():
			time.value -= 1
			level.tick(),
	).dispose_with(disposables)
	
	Sx.interval_timer(6.0) \
		.take_while(func(): return time.value > 0) \
		.subscribe(func():
			energy.value += 5
	).dispose_with(disposables)
	
	time.as_signal(false) \
		.filter(func(value: int): return value <= 0) \
		.subscribe(func(_x):
			# TODO: time's up! Show losing screen
			pass
	).dispose_with(disposables)


func finish_level() -> void:
	disposables.dispose()
