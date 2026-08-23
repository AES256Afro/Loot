class_name HexMapView
extends Control

signal hex_selected(q: int, r: int)

const TERRAIN_COLORS := {
	"road": Color("806f4c"),
	"roof_march": Color("374f4b"),
	"fungus": Color("51415f"),
	"scrap": Color("4e4a3e"),
	"marsh": Color("294b45"),
	"blackwater": Color("172f3e"),
}
const SITE_COLORS := {
	"anchor": Color("78ead5"),
	"town": Color("f0c968"),
	"resource": Color("87d582"),
	"event": Color("e68e59"),
	"dungeon": Color("dd6677"),
	"lore": Color("b993ea"),
	"social": Color("71b9df"),
	"shrine": Color("f1e4a0"),
	"border": Color("d6a765"),
}

var cells: Array = []
var sites: Array = []
var world_state: Dictionary = {}
var _radius := 28.0
var _origin := Vector2.ZERO
var _hovered := Vector2i(-1, -1)


func set_map(new_cells: Array, new_sites: Array, state: Dictionary) -> void:
	cells = new_cells.duplicate(true)
	sites = new_sites.duplicate(true)
	world_state = state.duplicate(true)
	queue_redraw()


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)
	_on_resized()


func _on_resized() -> void:
	var usable_width := maxf(200.0, size.x - 34.0)
	var usable_height := maxf(200.0, size.y - 42.0)
	_radius = minf(32.0, minf(usable_width / (sqrt(3.0) * 14.65), usable_height / 15.0))
	var map_width := sqrt(3.0) * _radius * 14.5
	var map_height := _radius * 15.5
	_origin = Vector2((size.x - map_width) * 0.5 + _radius, (size.y - map_height) * 0.5 + _radius)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b171d"), true)
	_draw_grid_lines()
	for raw_cell in cells:
		var cell: Dictionary = raw_cell
		var coord := Vector2i(int(cell.get("q", 0)), int(cell.get("r", 0)))
		_draw_cell(coord, cell)
	_draw_roads()
	_draw_sites()
	_draw_party()


func _draw_grid_lines() -> void:
	for index in range(0, int(size.y), 8):
		draw_line(Vector2(0, index), Vector2(size.x, index), Color("17303855"), 1.0)


func _draw_cell(coord: Vector2i, cell: Dictionary) -> void:
	var center := _hex_center(coord)
	var points := _hex_points(center, _radius - 1.2)
	var discovered := _is_discovered(coord)
	var terrain := String(cell.get("terrain", "roof_march"))
	var fill: Color = TERRAIN_COLORS.get(terrain, Color("374f4b"))
	if String(cell.get("jurisdiction", "")) == "water_continuity":
		fill = fill.lerp(Color("233f58"), 0.20)
	if not discovered:
		fill = Color("11191d")
	draw_colored_polygon(points, fill)
	var border := Color("52645f") if discovered else Color("263239")
	if coord == Vector2i(int(world_state.get("selected_q", -1)), int(world_state.get("selected_r", -1))):
		border = Color("f1d77c")
	elif coord == _hovered:
		border = Color("a8e3d9")
	draw_polyline(PackedVector2Array(Array(points) + [points[0]]), border, 2.3 if coord == _hovered else 1.25, true)
	if discovered:
		_draw_terrain_mark(center, terrain)


func _draw_terrain_mark(center: Vector2, terrain: String) -> void:
	match terrain:
		"fungus":
			draw_circle(center + Vector2(-7, 3), 3.0, Color("b577b9aa"))
			draw_circle(center + Vector2(2, -3), 4.0, Color("8965a2aa"))
		"scrap":
			draw_line(center + Vector2(-8, 5), center + Vector2(7, -5), Color("a8946e88"), 2.0)
			draw_line(center + Vector2(-5, -5), center + Vector2(8, 5), Color("a8946e66"), 2.0)
		"marsh":
			for x in [-8.0, -2.0, 4.0]:
				draw_line(center + Vector2(x, 7), center + Vector2(x + 3, -5), Color("61a17477"), 1.4)
		"blackwater":
			draw_arc(center, 9.0, 0.1, PI - 0.1, 14, Color("4a829477"), 1.4)
		"road":
			draw_circle(center, 2.0, Color("d4bc7a77"))


func _draw_roads() -> void:
	var road_coords := {}
	for raw_cell in cells:
		var cell: Dictionary = raw_cell
		if bool(cell.get("road", false)):
			var coord := Vector2i(int(cell.get("q", 0)), int(cell.get("r", 0)))
			road_coords[_coord_key(coord)] = true
	for raw_key in road_coords.keys():
		var coord := _coord_from_key(String(raw_key))
		if not _is_discovered(coord):
			continue
		for neighbor in [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1)]:
			var next_coord: Vector2i = coord + neighbor
			if road_coords.has(_coord_key(next_coord)) and _is_discovered(next_coord):
				draw_line(_hex_center(coord), _hex_center(next_coord), Color("c5a95caa"), 4.0, true)
				draw_line(_hex_center(coord), _hex_center(next_coord), Color("f2d68677"), 1.0, true)


func _draw_sites() -> void:
	var font := ThemeDB.fallback_font
	for raw_site in sites:
		var site: Dictionary = raw_site
		var coord := Vector2i(int(site.get("q", 0)), int(site.get("r", 0)))
		if not _is_discovered(coord):
			continue
		var center := _hex_center(coord)
		var type_name := String(site.get("type", "lore"))
		var color: Color = SITE_COLORS.get(type_name, Color.WHITE)
		var selected := coord == Vector2i(int(world_state.get("selected_q", -1)), int(world_state.get("selected_r", -1)))
		draw_circle(center, 10.0 if selected else 8.0, Color("071014dd"))
		match type_name:
			"town":
				draw_rect(Rect2(center - Vector2(7, 5), Vector2(14, 11)), color, true)
				draw_colored_polygon(PackedVector2Array([center + Vector2(-9, -4), center + Vector2(0, -11), center + Vector2(9, -4)]), color.lightened(0.18))
			"dungeon":
				draw_arc(center, 8.0, PI, TAU, 12, color, 4.0)
				draw_line(center + Vector2(-8, 0), center + Vector2(-8, 8), color, 3.0)
				draw_line(center + Vector2(8, 0), center + Vector2(8, 8), color, 3.0)
			"resource":
				draw_colored_polygon(PackedVector2Array([center + Vector2(0, -9), center + Vector2(8, 2), center + Vector2(3, 9), center + Vector2(-7, 5), center + Vector2(-7, -4)]), color)
			"event":
				draw_string(font, center + Vector2(-4, 7), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, color)
			"anchor":
				draw_arc(center, 8.0, 0.0, TAU, 16, color, 2.5)
				draw_line(center + Vector2(0, -10), center + Vector2(0, 10), color, 2.0)
			_:
				draw_colored_polygon(PackedVector2Array([center + Vector2(0, -8), center + Vector2(8, 0), center + Vector2(0, 8), center + Vector2(-8, 0)]), color)
		if selected:
			draw_arc(center, 15.0, 0.0, TAU, 24, Color("fff0a4"), 2.0)


func _draw_party() -> void:
	if world_state.is_empty():
		return
	var coord := Vector2i(int(world_state.get("q", 0)), int(world_state.get("r", 0)))
	var center := _hex_center(coord) + Vector2(0, 18)
	for index in range(4):
		var offset := Vector2((index % 2) * 7 - 3.5, (index / 2) * 7 - 3.5)
		draw_circle(center + offset, 3.2, [Color("f1bf67"), Color("78d6c7"), Color("c27be1"), Color("e9767b")][index])
	draw_arc(center + Vector2(0, 1), 9.0, 0.0, TAU, 20, Color("f7f0cf"), 1.5)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var coord := _coord_at_position(event.position)
		if coord != _hovered:
			_hovered = coord
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var selected := _coord_at_position(event.position)
		if selected.x >= 0:
			hex_selected.emit(selected.x, selected.y)
			accept_event()


func _coord_at_position(position_value: Vector2) -> Vector2i:
	var closest := Vector2i(-1, -1)
	var closest_distance := INF
	for raw_cell in cells:
		var cell: Dictionary = raw_cell
		var coord := Vector2i(int(cell.get("q", 0)), int(cell.get("r", 0)))
		var distance := position_value.distance_squared_to(_hex_center(coord))
		if distance < closest_distance:
			closest_distance = distance
			closest = coord
	return closest if closest_distance <= _radius * _radius else Vector2i(-1, -1)


func _hex_center(coord: Vector2i) -> Vector2:
	return _origin + Vector2(sqrt(3.0) * _radius * (coord.x + coord.y * 0.5), 1.5 * _radius * coord.y)


func _hex_points(center: Vector2, radius_value: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(6):
		var angle := deg_to_rad(60.0 * index - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius_value)
	return points


func _is_discovered(coord: Vector2i) -> bool:
	return (world_state.get("discovered", []) as Array).has(_coord_key(coord))


func _coord_key(coord: Vector2i) -> String:
	return "%d,%d" % [coord.x, coord.y]


func _coord_from_key(key: String) -> Vector2i:
	var parts := key.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))
