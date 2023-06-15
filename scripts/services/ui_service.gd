extends CanvasLayer


@onready var ui: Control = $UIContainer as Control
@onready var rain_button: TextureButton = %RainButton as TextureButton
@onready var shrine_button: TextureButton = %ShrineButton as TextureButton


func _ready() -> void:
	PlayerService.energy.as_signal().filter(func(_x): return ui.visible) \
		.subscribe(func(value: int):
			rain_button.disabled = value < Consts.RAIN_ENERGY_COST
			shrine_button.disabled = value < Consts.SHRINE_ENERGY_COST
	).dispose_with(self)


func toggle_ui(value: bool) -> void:
	ui.visible = value


func _on_rain_button_pressed() -> void:
	PlayerService.building_mode.value = PlayerService.BuildingMode.RAIN


func _on_shrine_button_pressed() -> void:
	PlayerService.building_mode.value = PlayerService.BuildingMode.SHRINE
