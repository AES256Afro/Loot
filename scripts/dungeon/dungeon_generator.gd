class_name DungeonGenerator
extends RefCounted

const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]

const ROOM_ROLES := [
	{"type": "intake", "title": "Underworks Intake", "encounter": ""},
	{"type": "nursery", "title": "Fungus Nursery", "encounter": "nursery"},
	{"type": "junction", "title": "Pressure Junction", "encounter": ""},
	{"type": "cistern", "title": "Flooded Cistern", "encounter": "cistern"},
	{"type": "office", "title": "Promoted Office", "encounter": "office"},
	{"type": "anchor", "title": "Hearthfold Anchor", "encounter": ""},
]


func generate(run_seed: int, room_count: int = 6) -> Dictionary:
	var count := clampi(room_count, 2, ROOM_ROLES.size())
	var rng := RandomNumberGenerator.new()
	var attempt := 0
	while true:
		rng.seed = run_seed + attempt * 1_000_003
		var rooms: Array[Dictionary] = []
		var connections: Array[Dictionary] = []
		var occupied := {Vector2i.ZERO: 0}
		var trapped := false
		rooms.append(_make_room(0, Vector2i.ZERO))
		while rooms.size() < count:
			# The M00 expedition is one procedural critical path. Its shape varies by
			# seed, while encounter and Hearthfold cadence remain authored and readable.
			var parent_index := rooms.size() - 1
			var parent_coord: Vector2i = rooms[parent_index]["coord"]
			var available := _free_directions(parent_coord, occupied)
			if available.is_empty():
				trapped = true
				break
			var direction: Vector2i = available[rng.randi_range(0, available.size() - 1)]
			var child_coord := parent_coord + direction
			var child_index := rooms.size()
			rooms.append(_make_room(child_index, child_coord))
			occupied[child_coord] = child_index
			connections.append({"a": parent_index, "b": child_index})
		if not trapped:
			return {
				"seed": run_seed,
				"rooms": rooms,
				"connections": connections,
			}
		attempt += 1
	return {}


func neighbor_in_direction(layout: Dictionary, room_index: int, direction: Vector2i) -> int:
	var rooms: Array = layout.get("rooms", [])
	if room_index < 0 or room_index >= rooms.size():
		return -1
	var desired: Vector2i = (rooms[room_index] as Dictionary)["coord"] + direction
	for room in rooms:
		if (room as Dictionary)["coord"] == desired:
			return int((room as Dictionary)["id"])
	return -1


func connection_direction(layout: Dictionary, from_room: int, to_room: int) -> Vector2i:
	var rooms: Array = layout.get("rooms", [])
	if from_room < 0 or to_room < 0 or from_room >= rooms.size() or to_room >= rooms.size():
		return Vector2i.ZERO
	return (rooms[to_room] as Dictionary)["coord"] - (rooms[from_room] as Dictionary)["coord"]


func signature(layout: Dictionary) -> String:
	var parts: PackedStringArray = []
	for room in layout.get("rooms", []):
		var data: Dictionary = room
		var coord: Vector2i = data["coord"]
		parts.append("%d:%d,%d:%s" % [int(data["id"]), coord.x, coord.y, String(data["type"])])
	for connection in layout.get("connections", []):
		parts.append("%d-%d" % [int(connection["a"]), int(connection["b"])])
	return "|".join(parts)


func _make_room(index: int, coord: Vector2i) -> Dictionary:
	var role: Dictionary = ROOM_ROLES[index]
	return {
		"id": index,
		"coord": coord,
		"type": String(role["type"]),
		"title": String(role["title"]),
		"encounter": String(role["encounter"]),
	}


func _free_directions(coord: Vector2i, occupied: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for direction in CARDINAL_DIRECTIONS:
		if not occupied.has(coord + direction):
			result.append(direction)
	return result
