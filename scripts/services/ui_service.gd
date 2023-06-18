extends CanvasLayer


const BackIcon := preload("res://assets/gfx/sprites/back.png")
const NextIcon := preload("res://assets/gfx/sprites/next.png")
const ReloadIcon := preload("res://assets/gfx/sprites/reload.png")
const MainMenuScene := preload("res://scenes/main_menu.tscn")


@onready var ui: Control = $UIContainer as Control
@onready var rain_button: TextureButton = %RainButton as TextureButton
@onready var shrine_button: TextureButton = %ShrineButton as TextureButton
@onready var message_container: CanvasLayer = %MessageContainer as CanvasLayer
@onready var message_icon: TextureRect = %MessageIcon as TextureRect
@onready var next_level_button: Button = %NextLevelButton as Button


func _ready() -> void:
	ui.visible = false
	message_container.visible = false

	PlayerService.energy.as_signal().filter(func(_x): return ui.visible) \
		.subscribe(func(value: int):
			rain_button.modulate.a = 0.6 if value < Consts.RAIN_ENERGY_COST else 1.0
			shrine_button.modulate.a = 0.6 if value < Consts.SHRINE_ENERGY_COST else 1.0
	).dispose_with(self)


func toggle_ui(value: bool) -> void:
	ui.visible = value
	
	
func show_message(icon: Texture2D, is_last_level: bool, next_level: PackedScene = null) -> void:
	message_icon.texture = icon
	message_container.visible = true
	
	if is_last_level:
		next_level_button.icon = BackIcon
		next_level_button.pressed.connect(
			func(): 
				hide_message()
				get_tree().change_scene_to_packed(MainMenuScene), 
			CONNECT_ONE_SHOT
		)
		return
	
	if next_level != null:
		next_level_button.icon = NextIcon
		next_level_button.pressed.connect(
			func(): 
				hide_message()
				get_tree().change_scene_to_packed(next_level), 
			CONNECT_ONE_SHOT
		)
		return
	
	next_level_button.icon = ReloadIcon
	next_level_button.pressed.connect(
		func(): 
			hide_message()
			get_tree().reload_current_scene(), 
		CONNECT_ONE_SHOT
	)
	
	
func hide_message() -> void:
	message_container.visible = false
