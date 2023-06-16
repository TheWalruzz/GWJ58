extends CanvasLayer


@onready var ui: Control = $UIContainer as Control
@onready var rain_button: TextureButton = %RainButton as TextureButton
@onready var shrine_button: TextureButton = %ShrineButton as TextureButton
@onready var message_container: CanvasLayer = %MessageContainer as CanvasLayer
@onready var message_icon: TextureRect = %MessageIcon as TextureRect
@onready var next_level_button: Button = %NextLevelButton as Button


func _ready() -> void:
	message_container.visible = false

	PlayerService.energy.as_signal().filter(func(_x): return ui.visible) \
		.subscribe(func(value: int):
			rain_button.disabled = value < Consts.RAIN_ENERGY_COST
			shrine_button.disabled = value < Consts.SHRINE_ENERGY_COST
	).dispose_with(self)


func toggle_ui(value: bool) -> void:
	ui.visible = value
	
	
func show_message(icon: Texture2D, next_level: PackedScene = null) -> void:
	message_icon.texture = icon
	if next_level != null:
		next_level_button.pressed.connect(
			func(): 
				hide_message()
				get_tree().change_scene_to_packed(next_level), 
			CONNECT_ONE_SHOT
		)
	next_level_button.visible = next_level != null
	message_container.visible = true
	
	
func hide_message() -> void:
	message_container.visible = false
