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

@export var time_limit := 30
@export var shrine_atlas_coords := Vector2i(5, 2)

var tiles: Dictionary = {}
var last_hovered := EMPTY_VECTOR

@onready var debug_label: Label = %DebugLabel as Label


func _ready() -> void:
	if OS.is_debug_build():
		debug_label.visible = true
	
	for cell in get_used_cells(TileLayer.BOTTOM):
		var coords := cell as Vector2i
		var tile_data := MapTileData.new()
		tile_data.has_shrine = get_cell_source_id(TileLayer.MIDDLE, _get_shrine_coords(coords)) != -1
		tiles[coords] = tile_data
		
	PlayerService.start_level(self, time_limit)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		# for some reason event's global position didn't take camera zoom into account
		var target_coords := local_to_map(to_local(get_global_mouse_position()))
		
		if OS.is_debug_build():
			debug_label.text = str(target_coords)
			
		# hover
		if last_hovered != EMPTY_VECTOR and last_hovered != target_coords and is_green(last_hovered):
				_set_hover(last_hovered, false)
		if PlayerService.building_mode.value != PlayerService.BuildingMode.NONE \
			and tiles.has(target_coords) \
			and is_green(target_coords) \
			and not tiles[target_coords].is_raining \
			and not tiles[target_coords].has_shrine:
				_set_hover(target_coords, true)
				last_hovered = target_coords
		
		# actions
		if event.is_action_pressed("pointer_click"):
			# TODO: check if has enough energy
			# TODO: build stuff
			pass
				

func _get_shrine_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(coords.x, coords.y - 1)


func _get_desert_tiles() -> Array[Vector2i]:
	return get_used_cells(TileLayer.BOTTOM).filter(func(cell: Vector2i):
			return get_cell_source_id(TileLayer.BOTTOM, cell) == TileSource.DESERT
	)

	
func _get_closest_green_coords(coords: Vector2i) -> Array[Vector2i]:
	return _get_coords_around(coords, 1).filter(is_green)
	
	
func _is_shrine_in_area(coords: Vector2i) -> bool:
	var neighbours := _get_coords_around(coords, 2)
	for tile in neighbours:
		if tiles.has(tile) and tiles[tile].has_shrine:
				return true
	return false
	
	
func _set_hover(coords: Vector2i, hover: bool) -> void:
	var atlas_coords := get_cell_atlas_coords(TileLayer.BOTTOM, coords)
	set_cell(
		TileLayer.BOTTOM,
		coords,
		TileSource.GREEN,
		atlas_coords,
		1 if hover else 0
	)
	

func _get_data(target_coords: Vector2i, layer_id: int) -> bool:
	return get_cell_tile_data(TileLayer.BOTTOM, target_coords).get_custom_data_by_layer_id(layer_id)
	
	
func _get_coords_around(coords: Vector2i, depth := 1) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	
	for i in range(-depth, depth):
		for j in range(-depth, depth):
			results.append(Vector2i(coords.x + i, coords.y + j))
			
	return results

	
func is_buildable(target_coords: Vector2i) -> bool:
	return _get_data(target_coords, DataLayer.BUILDABLE)
	
	
func is_green(target_coords: Vector2i) -> bool:
	return get_cell_source_id(TileLayer.BOTTOM, target_coords) == TileSource.GREEN
	
	
func is_desert(target_coords: Vector2i) -> bool:
	return get_cell_source_id(TileLayer.BOTTOM, target_coords) == TileSource.DESERT


func tick() -> void:
	var desert_tiles := _get_desert_tiles()
	if desert_tiles.size() == 0:
		PlayerService.finish_level()
		return
	
	var candidates: Array[Vector2i] = []
	for tile in desert_tiles:
		candidates.append_array(_get_closest_green_coords(tile))
		
	var unique_candidates := ArrayUtils.unique(candidates.filter(func(coords: Vector2i): return not _is_shrine_in_area(coords)))
		
	candidates.assign(unique_candidates.filter(func(coords: Vector2i): return not _is_shrine_in_area(coords)))
		
	if candidates.size() > 5:
		candidates.shuffle()
		candidates.resize(5)
		
	for tile in candidates:
		var atlas_coords := get_cell_atlas_coords(TileLayer.BOTTOM, tile)
		set_cell(TileLayer.BOTTOM, tile, TileSource.DESERT, atlas_coords)


class MapTileData:
	var is_raining := false
	var has_shrine := false
