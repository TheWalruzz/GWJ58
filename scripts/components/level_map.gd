extends TileMap
class_name LevelMap


enum DataLayer {
	BUILDABLE,
}

enum TileLayer {
	TOP,
	MIDDLE,
	BOTTOM,
}

enum TileSource {
	DESERT,
	GREEN,
}


const EMPTY_VECTOR := Vector2i(-100, -100)
const RainCloudScene := preload("res://scenes/components/rain_cloud.tscn")

@export var time_limit := 30
@export var shrine_atlas_coords := Vector2i(5, 2)
@export var rustle_sound: AudioStream = null
@export var build_sound: AudioStream = null
@export var win_icon: Texture2D = null
@export var next_level: PackedScene = null

var tiles: Dictionary = {}
var last_hovered := EMPTY_VECTOR

@onready var debug_label: Label = %DebugLabel as Label


func _ready() -> void:
	debug_label.visible = OS.is_debug_build()
	
	for cell in get_used_cells(TileLayer.BOTTOM):
		var coords := cell as Vector2i
		var tile_data := MapTileData.new()
		tile_data.has_shrine = get_cell_source_id(TileLayer.MIDDLE, _get_shrine_coords(coords)) != -1
		tiles[coords] = tile_data
		
	PlayerService.start_level(self, time_limit)


func _input(event: InputEvent) -> void:
	if PlayerService.is_running and event is InputEventMouse:
		# for some reason event's global position didn't take camera zoom into account
		var target_coords := local_to_map(to_local(get_global_mouse_position()))
		
		if OS.is_debug_build():
			debug_label.text = "%s" % str(target_coords)
			
		# hover
		if last_hovered != EMPTY_VECTOR and last_hovered != target_coords:
				_set_hover(last_hovered, false)
		if tiles.has(target_coords) \
			and _is_buildable(target_coords) \
			and not tiles[target_coords].is_raining \
			and not tiles[target_coords].has_shrine:
				_set_hover(target_coords, true)
				last_hovered = target_coords
		
				# actions
				if event.is_action_pressed("call_rain") and _can_call_rain(target_coords):
					PlayerService.energy.value -= Consts.RAIN_ENERGY_COST
					tiles[target_coords].is_raining = true
					
					var local_tile_coords := map_to_local(target_coords)
					var cloud := RainCloudScene.instantiate()
					cloud.position = Vector2(local_tile_coords.x, local_tile_coords.y - 192)
					add_child(cloud)
					
					Sx.interval_timer(Consts.RAIN_INTERVAL) \
						.take(Consts.RAIN_ITERATIONS) \
						.take_while(func(): return PlayerService.is_running) \
						.subscribe(
							func():
								_toggle_cells(
									_get_closest_desert_coords(target_coords), 
									TileSource.GREEN, 
									Consts.RAIN_TILES_PER_ITERATION
								)
								
								if _get_desert_tiles().size() == 0:
									tiles[target_coords].is_raining = false
									_end_game(),
							0,
							func():
								cloud.fade_and_free()
								tiles[target_coords].is_raining = false
					).dispose_with(self)
				if event.is_action_pressed("build_shrine") and _can_build_shrine(target_coords):
					PlayerService.energy.value -= Consts.SHRINE_ENERGY_COST
					tiles[target_coords].has_shrine = true
					set_cell(TileLayer.MIDDLE, _get_shrine_coords(target_coords), TileSource.GREEN, shrine_atlas_coords)
					SoundService.play(build_sound, "Sounds")
	
	
func tick() -> void:
	var desert_tiles := _get_desert_tiles()
	
	var candidates: Array[Vector2i] = []
	for tile in desert_tiles:
		candidates.append_array(_get_closest_green_coords(tile))
		
	_toggle_cells(
		candidates.filter(func(coords: Vector2i): 
				return not _is_shrine_in_area(coords) and not tiles[coords].is_raining),
		TileSource.DESERT,
		Consts.DESERT_TILES_PER_ITERATION
	)
	
	SoundService.play(rustle_sound, "Sounds")
	

func _get_shrine_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(coords.x + 1, coords.y - 1)


func _get_desert_tiles() -> Array[Vector2i]:
	return get_used_cells(TileLayer.BOTTOM).filter(_is_desert)

	
func _get_closest_green_coords(coords: Vector2i) -> Array[Vector2i]:
	return _get_coords_around(coords, Consts.SHRINE_BORDER_DEPTH).filter(_is_green)
	
	
func _get_closest_desert_coords(coords: Vector2i) -> Array[Vector2i]:
	return _get_coords_around(coords, Consts.RAIN_BORDER_DEPTH).filter(_is_desert)
	
	
func _is_shrine_in_area(coords: Vector2i) -> bool:
	var neighbours := _get_coords_around(coords, Consts.SHRINE_BORDER_DEPTH)
	for tile in neighbours:
		if tiles.has(tile) and tiles[tile].has_shrine:
				return true
	return false
	
	
func _set_hover(coords: Vector2i, hover: bool) -> void:
	var atlas_coords := get_cell_atlas_coords(TileLayer.BOTTOM, coords)
	set_cell(
		TileLayer.BOTTOM,
		coords,
		get_cell_source_id(TileLayer.BOTTOM, coords),
		atlas_coords,
		1 if hover else 0
	)
	

func _get_data(target_coords: Vector2i, layer_id: int) -> bool:
	return get_cell_tile_data(TileLayer.BOTTOM, target_coords).get_custom_data_by_layer_id(layer_id)
	
	
func _get_coords_around(coords: Vector2i, depth := 1) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	
	for i in range(-depth, depth + 1):
		for j in range(-depth, depth + 1):
			results.append(Vector2i(coords.x + i, coords.y + j))
			
	return results

	
func _is_buildable(target_coords: Vector2i) -> bool:
	return _get_data(target_coords, DataLayer.BUILDABLE)
	
	
func _is_green(target_coords: Vector2i) -> bool:
	return get_cell_source_id(TileLayer.BOTTOM, target_coords) == TileSource.GREEN
	
	
func _is_desert(target_coords: Vector2i) -> bool:
	return get_cell_source_id(TileLayer.BOTTOM, target_coords) == TileSource.DESERT
	
	
func _can_build_shrine(coords: Vector2i) -> bool:
	return _is_green(coords) \
		and _is_buildable(coords) \
		and not tiles[coords].has_shrine  \
		and not tiles[coords].is_raining \
		and PlayerService.energy.value >= Consts.SHRINE_ENERGY_COST
	
	
func _can_call_rain(coords: Vector2i) -> bool:
	return _is_desert(coords) and PlayerService.energy.value >= Consts.RAIN_ENERGY_COST
	
	
func _toggle_cells(coords_list: Array[Vector2i], source_id: TileSource, max_tiles := -1) -> void:
	var candidates: Array[Vector2i] = []
	candidates.assign(ArrayUtils.unique(coords_list))
		
	if max_tiles > -1 and candidates.size() > max_tiles:
		candidates.shuffle()
		candidates.resize(max_tiles)
		
	for tile in candidates:
		var atlas_coords := get_cell_atlas_coords(TileLayer.BOTTOM, tile)
		set_cell(TileLayer.BOTTOM, tile, source_id, atlas_coords)
		
		
func _end_game() -> void:
	PlayerService.finish_level()
	UIService.show_message(win_icon, next_level == null, next_level)


class MapTileData:
	var is_raining := false
	var has_shrine := false
