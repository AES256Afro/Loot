class_name TownMapView
extends Control

signal location_selected(location_id: String)
signal interact_requested(location_id: String)

var locations: Array = []
var party_position := Vector2(520, 610)
var selected_location_id := ""
var _destination := Vector2(520, 610)
var _hovered_location_id := ""
var _time := 0.0


func set_town(new_locations: Array, state_position: Dictionary, selected_id: String = "") -> void:
	locations = new_locations.duplicate(true)
	party_position = Vector2(float(state_position.get("x", 520.0)), float(state_position.get("y", 610.0)))
	_destination = party_position
	selected_location_id = selected_id
	queue_redraw()


func get_party_position() -> Dictionary:
	return {"x": party_position.x, "y": party_position.y}


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if movement.length() > 0.05:
		_destination = party_position + movement.normalized() * 120.0
	var distance := party_position.distance_to(_destination)
	if distance > 1.0:
		party_position = party_position.move_toward(_destination, minf(distance, delta * 230.0))
		party_position.x = clampf(party_position.x, 50.0, maxf(50.0, size.x - 50.0))
		party_position.y = clampf(party_position.y, 95.0, maxf(95.0, size.y - 48.0))
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("102326"), true)
	for y in range(0, int(size.y), 12):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("29414544"), 1.0)
	_draw_canal()
	_draw_streets()
	_draw_buildings()
	_draw_party()


func _draw_canal() -> void:
	var canal := PackedVector2Array([
		Vector2(size.x * 0.06, 0), Vector2(size.x * 0.24, 0),
		Vector2(size.x * 0.38, size.y), Vector2(size.x * 0.20, size.y),
	])
	draw_colored_polygon(canal, Color("153e50"))
	for y in range(18, int(size.y), 38):
		draw_line(Vector2(size.x * 0.11 + y * 0.14, y), Vector2(size.x * 0.20 + y * 0.14, y), Color("4c8290aa"), 2.0)


func _draw_streets() -> void:
	draw_line(Vector2(90, size.y * 0.50), Vector2(size.x - 70, size.y * 0.50), Color("806f4c"), 84.0)
	draw_line(Vector2(size.x * 0.52, 80), Vector2(size.x * 0.52, size.y - 40), Color("72644a"), 72.0)
	draw_line(Vector2(95, size.y * 0.50), Vector2(size.x - 70, size.y * 0.50), Color("b69a5d55"), 4.0)
	for x in range(110, int(size.x - 80), 34):
		draw_line(Vector2(x, size.y * 0.50 - 28), Vector2(x + 10, size.y * 0.50 - 28), Color("d1bd8177"), 2.0)


func _draw_buildings() -> void:
	var font := ThemeDB.fallback_font
	for raw_location in locations:
		var location: Dictionary = raw_location
		var center := _location_position(location)
		var location_id := String(location.get("id", ""))
		var type_name := String(location.get("type", "social"))
		var selected := location_id == selected_location_id
		var hovered := location_id == _hovered_location_id
		var base_color := _building_color(type_name)
		var footprint := Rect2(center - Vector2(76, 42), Vector2(152, 84))
		draw_rect(footprint.grow(5), Color("061014bb"), true)
		draw_rect(footprint, base_color, true)
		draw_rect(Rect2(footprint.position, Vector2(footprint.size.x, 15)), base_color.lightened(0.25), true)
		draw_rect(footprint, Color("f2d77f") if selected else Color("84a09a") if hovered else Color("314e4d"), false, 3.0 if selected else 1.5)
		var door := Rect2(center + Vector2(-12, 12), Vector2(24, 30))
		draw_rect(door, Color("12191d"), true)
		var title := String(location.get("display_name", location_id))
		draw_string(font, center + Vector2(-70, -54), title, HORIZONTAL_ALIGNMENT_CENTER, 140, 13, Color("f2e1a0") if selected else Color("d2ded9"))
		if party_position.distance_to(center) < 94.0:
			draw_string(font, center + Vector2(-62, 64), "E  ENTER", HORIZONTAL_ALIGNMENT_CENTER, 124, 13, Color("7ff0db"))


func _draw_party() -> void:
	var bob := sin(_time * 6.0) * 1.5
	for index in range(4):
		var offset := Vector2((index % 2) * 13 - 6.5, (index / 2) * 13 - 6.5 + bob)
		var color: Color = [Color("f1bf67"), Color("78d6c7"), Color("c27be1"), Color("e9767b")][index]
		draw_circle(party_position + offset, 6.0, Color("061014"))
		draw_rect(Rect2(party_position + offset - Vector2(4, 7), Vector2(8, 12)), color, true)
	draw_arc(party_position, 19.0, 0, TAU, 20, Color("eff4d6aa"), 1.5)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hovered := _location_at(event.position)
		if hovered != _hovered_location_id:
			_hovered_location_id = hovered
			queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var clicked := _location_at(event.position)
		if not clicked.is_empty():
			selected_location_id = clicked
			var location := _find_location(clicked)
			_destination = _location_position(location) + Vector2(0, 66)
			location_selected.emit(clicked)
		else:
			_destination = event.position
		queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		var nearest := _nearest_location()
		if not nearest.is_empty() and party_position.distance_to(_location_position(nearest)) < 108.0:
			interact_requested.emit(String(nearest.get("id", "")))
			accept_event()


func _location_at(position_value: Vector2) -> String:
	for raw_location in locations:
		var location: Dictionary = raw_location
		if Rect2(_location_position(location) - Vector2(82, 58), Vector2(164, 116)).has_point(position_value):
			return String(location.get("id", ""))
	return ""


func _nearest_location() -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance := INF
	for raw_location in locations:
		var location: Dictionary = raw_location
		var distance := party_position.distance_squared_to(_location_position(location))
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = location
	return nearest


func _find_location(location_id: String) -> Dictionary:
	for raw_location in locations:
		var location: Dictionary = raw_location
		if String(location.get("id", "")) == location_id:
			return location
	return {}


func _location_position(location: Dictionary) -> Vector2:
	var reference := Vector2(float(location.get("x", 0)), float(location.get("y", 0)))
	return Vector2(reference.x / 1000.0 * size.x, reference.y / 700.0 * size.y)


func _building_color(type_name: String) -> Color:
	match type_name:
		"store": return Color("594c37")
		"guild": return Color("3c4e5f")
		"bar": return Color("593749")
		"safe_room": return Color("295956")
		"quests": return Color("5c4931")
		"information": return Color("433b5f")
		_: return Color("3f5650")
