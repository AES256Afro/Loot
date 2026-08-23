class_name KingdomMapService
extends RefCounted

const DEFINITION_PATH := "res://content/world/gutterbloom_reach.json"
const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

var definition: Dictionary = {}
var last_errors: PackedStringArray = []


func load_definition(path: String = DEFINITION_PATH) -> bool:
	last_errors.clear()
	if not FileAccess.file_exists(path):
		last_errors.append("Kingdom definition is missing: %s" % path)
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_errors.append("Kingdom definition could not be opened: %s" % path)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		last_errors.append("Kingdom definition must contain a JSON object.")
		return false
	definition = (parsed as Dictionary).duplicate(true)
	last_errors.append_array(validate_definition(definition))
	return last_errors.is_empty()


func validate_definition(data: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var kingdom: Dictionary = data.get("kingdom", {})
	var width := int(kingdom.get("width", 0))
	var height := int(kingdom.get("height", 0))
	if int(data.get("schema_version", 0)) != 1:
		errors.append("Kingdom schema_version must be 1.")
	if String(kingdom.get("id", "")).is_empty():
		errors.append("Kingdom requires an immutable id.")
	if width < 2 or height < 2:
		errors.append("Kingdom dimensions must be at least 2 by 2.")
	var seen_sites := {}
	for raw_site in data.get("sites", []):
		if typeof(raw_site) != TYPE_DICTIONARY:
			errors.append("Every kingdom site must be an object.")
			continue
		var site: Dictionary = raw_site
		var site_id := String(site.get("id", ""))
		if site_id.is_empty() or seen_sites.has(site_id):
			errors.append("Kingdom site ids must be present and unique: %s" % site_id)
		seen_sites[site_id] = true
		var q := int(site.get("q", -1))
		var r := int(site.get("r", -1))
		if q < 0 or q >= width or r < 0 or r >= height:
			errors.append("Kingdom site %s is outside the map." % site_id)
	var seen_locations := {}
	for raw_location in (data.get("town", {}) as Dictionary).get("locations", []):
		if typeof(raw_location) != TYPE_DICTIONARY:
			errors.append("Every town location must be an object.")
			continue
		var location_id := String((raw_location as Dictionary).get("id", ""))
		if location_id.is_empty() or seen_locations.has(location_id):
			errors.append("Town location ids must be present and unique: %s" % location_id)
		seen_locations[location_id] = true
	var seen_quests := {}
	for raw_quest in data.get("quests", []):
		if typeof(raw_quest) != TYPE_DICTIONARY:
			errors.append("Every quest must be an object.")
			continue
		var quest_id := String((raw_quest as Dictionary).get("id", ""))
		if quest_id.is_empty() or seen_quests.has(quest_id):
			errors.append("Quest ids must be present and unique: %s" % quest_id)
		seen_quests[quest_id] = true
	var seen_lore := {}
	for raw_lore in data.get("lore_fragments", []):
		if typeof(raw_lore) != TYPE_DICTIONARY:
			errors.append("Every lore fragment must be an object.")
			continue
		var lore_id := String((raw_lore as Dictionary).get("id", ""))
		if lore_id.is_empty() or seen_lore.has(lore_id):
			errors.append("Lore ids must be present and unique: %s" % lore_id)
		seen_lore[lore_id] = true
	for raw_stock in (data.get("store", {}) as Dictionary).get("stock", []):
		if typeof(raw_stock) != TYPE_DICTIONARY or String((raw_stock as Dictionary).get("item_id", "")).is_empty() or int((raw_stock as Dictionary).get("price", 0)) <= 0:
			errors.append("Every store entry requires an item_id and positive price.")
	return errors


func create_default_state() -> Dictionary:
	_ensure_loaded()
	var start: Dictionary = (definition.get("kingdom", {}) as Dictionary).get("start", {"q": 0, "r": 0})
	var state := {
		"schema_version": 1,
		"kingdom_id": String((definition.get("kingdom", {}) as Dictionary).get("id", "")),
		"active_view": "kingdom",
		"q": int(start.get("q", 0)),
		"r": int(start.get("r", 0)),
		"selected_q": int(start.get("q", 0)),
		"selected_r": int(start.get("r", 0)),
		"strategic_pulse": 0,
		"resources": {
			"marks": int((definition.get("store", {}) as Dictionary).get("starting_marks", 0)),
			"salvage": 0,
			"spore_glass": 0,
			"route_seals": 0,
		},
		"discovered": [],
		"claimed_resources": [],
		"resolved_events": {},
		"discovered_lore": [],
		"purchases": [],
		"quests": {},
		"dungeon": {
			"entrance_site": "",
			"entrance_q": int(start.get("q", 0)),
			"entrance_r": int(start.get("r", 0)),
			"entered": false,
			"return_pending": false,
			"completed_returns": 0,
		},
		"town_position": {"x": 520.0, "y": 610.0},
	}
	_reveal_around(state, Vector2i(int(state["q"]), int(state["r"])), 2)
	return state


func normalize_state(raw_state: Variant) -> Dictionary:
	var base := create_default_state()
	if typeof(raw_state) != TYPE_DICTIONARY:
		return base
	var raw: Dictionary = raw_state
	for key in ["active_view", "q", "r", "selected_q", "selected_r", "strategic_pulse", "discovered", "claimed_resources", "resolved_events", "discovered_lore", "purchases", "quests", "dungeon", "town_position"]:
		if raw.has(key):
			base[key] = raw[key]
	var resources: Dictionary = base["resources"]
	var raw_resources: Dictionary = raw.get("resources", {})
	for resource_id in resources.keys():
		resources[resource_id] = maxi(0, int(raw_resources.get(resource_id, resources[resource_id])))
	base["resources"] = resources
	var kingdom: Dictionary = definition.get("kingdom", {})
	base["q"] = clampi(int(base["q"]), 0, int(kingdom.get("width", 1)) - 1)
	base["r"] = clampi(int(base["r"]), 0, int(kingdom.get("height", 1)) - 1)
	base["selected_q"] = clampi(int(base["selected_q"]), 0, int(kingdom.get("width", 1)) - 1)
	base["selected_r"] = clampi(int(base["selected_r"]), 0, int(kingdom.get("height", 1)) - 1)
	base["schema_version"] = 1
	base["kingdom_id"] = String(kingdom.get("id", ""))
	_reveal_around(base, Vector2i(int(base["q"]), int(base["r"])), 1)
	return base


func generate_cells() -> Array:
	_ensure_loaded()
	var kingdom: Dictionary = definition.get("kingdom", {})
	var width := int(kingdom.get("width", 0))
	var height := int(kingdom.get("height", 0))
	var seed_value := int(kingdom.get("seed", 0))
	var roads := {}
	for raw_road in definition.get("roads", []):
		var road: Dictionary = raw_road
		roads[_coord_key(Vector2i(int(road.get("q", 0)), int(road.get("r", 0))))] = true
	var site_coords := {}
	for raw_site in definition.get("sites", []):
		var site: Dictionary = raw_site
		site_coords[_coord_key(Vector2i(int(site.get("q", 0)), int(site.get("r", 0))))] = true
	var cells: Array = []
	for r in range(height):
		for q in range(width):
			var coord := Vector2i(q, r)
			var noise := _stable_number(seed_value, q, r) % 100
			var terrain := "roof_march"
			if noise < 14:
				terrain = "blackwater"
			elif noise < 36:
				terrain = "fungus"
			elif noise < 57:
				terrain = "scrap"
			elif noise < 77:
				terrain = "marsh"
			if roads.has(_coord_key(coord)):
				terrain = "road"
			if site_coords.has(_coord_key(coord)) and terrain == "blackwater":
				terrain = "roof_march"
			cells.append({
				"q": q,
				"r": r,
				"terrain": terrain,
				"road": roads.has(_coord_key(coord)),
				"jurisdiction": "free_roof" if q < 7 else "water_continuity",
			})
	return cells


func cell_signature(cells: Array) -> String:
	var parts := PackedStringArray()
	for raw_cell in cells:
		var cell: Dictionary = raw_cell
		parts.append("%d,%d:%s:%s" % [int(cell.get("q", 0)), int(cell.get("r", 0)), String(cell.get("terrain", "")), String(cell.get("jurisdiction", ""))])
	return "|".join(parts)


func find_path(from_coord: Vector2i, to_coord: Vector2i) -> Array[Vector2i]:
	_ensure_loaded()
	if not _in_bounds(from_coord) or not _in_bounds(to_coord):
		return []
	var frontier: Array[Vector2i] = [from_coord]
	var came_from := {_coord_key(from_coord): Vector2i(-999, -999)}
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == to_coord:
			break
		for offset in NEIGHBORS:
			var next_coord := current + offset
			var key := _coord_key(next_coord)
			if _in_bounds(next_coord) and not came_from.has(key):
				came_from[key] = current
				frontier.append(next_coord)
	if not came_from.has(_coord_key(to_coord)):
		return []
	var reversed_path: Array[Vector2i] = []
	var cursor := to_coord
	while cursor != from_coord:
		reversed_path.append(cursor)
		cursor = came_from[_coord_key(cursor)]
	reversed_path.append(from_coord)
	reversed_path.reverse()
	return reversed_path


func travel(state: Dictionary, destination: Vector2i) -> Dictionary:
	var next_state := normalize_state(state)
	var origin := Vector2i(int(next_state.get("q", 0)), int(next_state.get("r", 0)))
	var path := find_path(origin, destination)
	if path.is_empty():
		return {"ok": false, "message": "That hex is outside the surveyed kingdom.", "state": next_state, "path": []}
	for coord in path:
		_reveal_around(next_state, coord, 1)
	next_state["q"] = destination.x
	next_state["r"] = destination.y
	next_state["selected_q"] = destination.x
	next_state["selected_r"] = destination.y
	next_state["strategic_pulse"] = int(next_state.get("strategic_pulse", 0)) + maxi(0, path.size() - 1)
	return {
		"ok": true,
		"message": "The party traveled %d hex%s. No movement allowance expired." % [maxi(0, path.size() - 1), "" if path.size() == 2 else "es"],
		"state": next_state,
		"path": path,
	}


func site_at(coord: Vector2i) -> Dictionary:
	_ensure_loaded()
	for raw_site in definition.get("sites", []):
		var site: Dictionary = raw_site
		if int(site.get("q", -1)) == coord.x and int(site.get("r", -1)) == coord.y:
			return site.duplicate(true)
	return {}


func site_by_id(site_id: String) -> Dictionary:
	_ensure_loaded()
	for raw_site in definition.get("sites", []):
		var site: Dictionary = raw_site
		if String(site.get("id", "")) == site_id:
			return site.duplicate(true)
	return {}


func location_by_id(location_id: String) -> Dictionary:
	_ensure_loaded()
	for raw_location in (definition.get("town", {}) as Dictionary).get("locations", []):
		var location: Dictionary = raw_location
		if String(location.get("id", "")) == location_id:
			return location.duplicate(true)
	return {}


func quest_by_id(quest_id: String) -> Dictionary:
	_ensure_loaded()
	for raw_quest in definition.get("quests", []):
		var quest: Dictionary = raw_quest
		if String(quest.get("id", "")) == quest_id:
			return quest.duplicate(true)
	return {}


func claim_resource(state: Dictionary, site_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var site := site_by_id(site_id)
	var claimed: Array = next_state.get("claimed_resources", [])
	if site.is_empty() or String(site.get("type", "")) != "resource":
		return {"ok": false, "message": "This site has no claimable regional resource.", "state": next_state}
	if claimed.has(site_id):
		return {"ok": false, "message": "This deposit was already collected. The site remains on the map.", "state": next_state}
	var resource: Dictionary = site.get("resource", {})
	var resource_id := String(resource.get("id", ""))
	var amount := int(resource.get("amount", 0))
	var resources: Dictionary = next_state.get("resources", {})
	resources[resource_id] = int(resources.get(resource_id, 0)) + amount
	claimed.append(site_id)
	next_state["claimed_resources"] = claimed
	next_state["resources"] = resources
	return {"ok": true, "message": "+%d %s. Collection has no daily reset or expiration." % [amount, String(resource.get("label", resource_id))], "state": next_state}


func resolve_event(state: Dictionary, site_id: String, choice_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var site := site_by_id(site_id)
	if site.is_empty() or String(site.get("type", "")) != "event":
		return {"ok": false, "message": "No persistent event was found here.", "state": next_state}
	var selected_choice: Dictionary = {}
	for raw_choice in site.get("choices", []):
		var choice: Dictionary = raw_choice
		if String(choice.get("id", "")) == choice_id:
			selected_choice = choice
			break
	if selected_choice.is_empty():
		return {"ok": false, "message": "That event choice does not exist.", "state": next_state}
	if choice_id == "leave_event":
		return {"ok": true, "resolved": false, "message": String(selected_choice.get("result", "The event remains.")), "state": next_state}
	var resolved_events: Dictionary = next_state.get("resolved_events", {})
	if resolved_events.has(site_id):
		return {"ok": false, "resolved": true, "message": "This crossing already remembers the party's decision.", "state": next_state}
	resolved_events[site_id] = choice_id
	next_state["resolved_events"] = resolved_events
	var resources: Dictionary = next_state.get("resources", {})
	if choice_id == "recognize_crossing":
		resources["route_seals"] = int(resources.get("route_seals", 0)) + 1
	else:
		resources["marks"] = int(resources.get("marks", 0)) + 12
	next_state["resources"] = resources
	return {"ok": true, "resolved": true, "message": String(selected_choice.get("result", "The event changes.")), "state": next_state}


func accept_quest(state: Dictionary, quest_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var quest := quest_by_id(quest_id)
	if quest.is_empty():
		return {"ok": false, "message": "That contract is not on this board.", "state": next_state}
	var quests: Dictionary = next_state.get("quests", {})
	var existing := String(quests.get(quest_id, ""))
	if existing in ["accepted", "ready_to_turn_in", "completed"]:
		return {"ok": false, "message": "%s is already %s." % [quest.get("display_name", quest_id), existing.replace("_", " ")], "state": next_state}
	quests[quest_id] = "accepted"
	next_state["quests"] = quests
	return {"ok": true, "message": "Accepted: %s. It has no real-world timer." % quest.get("display_name", quest_id), "state": next_state}


func buy_item(state: Dictionary, item_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var stock_entry: Dictionary = {}
	for raw_stock in (definition.get("store", {}) as Dictionary).get("stock", []):
		var stock: Dictionary = raw_stock
		if String(stock.get("item_id", "")) == item_id:
			stock_entry = stock
			break
	if stock_entry.is_empty():
		return {"ok": false, "message": "The store does not stock that item.", "state": next_state}
	var purchases: Array = next_state.get("purchases", [])
	if purchases.has(item_id):
		return {"ok": false, "message": "This proof-build stock entry was already purchased.", "state": next_state}
	var resources: Dictionary = next_state.get("resources", {})
	var price := int(stock_entry.get("price", 0))
	if int(resources.get("marks", 0)) < price:
		return {"ok": false, "message": "Insufficient Marks. The item remains in stock.", "state": next_state}
	resources["marks"] = int(resources.get("marks", 0)) - price
	purchases.append(item_id)
	next_state["resources"] = resources
	next_state["purchases"] = purchases
	return {"ok": true, "message": "Purchased for %d Marks and filed directly into the uncapped Archive." % price, "item_id": item_id, "state": next_state}


func discover_lore(state: Dictionary, source_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var lore_fragments: Array = definition.get("lore_fragments", [])
	var discovered: Array = next_state.get("discovered_lore", [])
	if lore_fragments.is_empty():
		return {"ok": false, "message": "No authored lore is available.", "state": next_state}
	var seed_value := int((definition.get("kingdom", {}) as Dictionary).get("seed", 0))
	var start_index := _stable_text_number(source_id, seed_value) % lore_fragments.size()
	var selected: Dictionary = {}
	for offset in range(lore_fragments.size()):
		var candidate: Dictionary = lore_fragments[(start_index + offset) % lore_fragments.size()]
		if not discovered.has(String(candidate.get("id", ""))):
			selected = candidate
			break
	if selected.is_empty():
		selected = lore_fragments[start_index]
		return {"ok": true, "new": false, "message": "The kiosk repeats an archived fragment with great confidence.", "lore": selected.duplicate(true), "state": next_state}
	discovered.append(String(selected.get("id", "")))
	next_state["discovered_lore"] = discovered
	return {"ok": true, "new": true, "message": "Lore Sauce acquired. Reliability is labeled instead of implied.", "lore": selected.duplicate(true), "state": next_state}


func begin_dungeon(state: Dictionary, site_id: String) -> Dictionary:
	var next_state := normalize_state(state)
	var site := site_by_id(site_id)
	if site.is_empty() or String(site.get("type", "")) != "dungeon":
		return {"ok": false, "message": "This site is not a dungeon entrance.", "state": next_state}
	var dungeon: Dictionary = next_state.get("dungeon", {})
	dungeon["entrance_site"] = site_id
	dungeon["entrance_q"] = int(site.get("q", 0))
	dungeon["entrance_r"] = int(site.get("r", 0))
	dungeon["entered"] = true
	dungeon["return_pending"] = true
	next_state["dungeon"] = dungeon
	next_state["active_view"] = "dungeon"
	return {"ok": true, "message": "Expedition opened. The kingdom position is anchored to this exact hex.", "state": next_state}


func complete_dungeon_return(state: Dictionary) -> Dictionary:
	var next_state := normalize_state(state)
	var dungeon: Dictionary = next_state.get("dungeon", {})
	if not bool(dungeon.get("return_pending", false)):
		next_state["active_view"] = "kingdom"
		return {"ok": true, "rewarded": false, "message": "Returned to the kingdom map.", "state": next_state}
	next_state["q"] = int(dungeon.get("entrance_q", next_state.get("q", 0)))
	next_state["r"] = int(dungeon.get("entrance_r", next_state.get("r", 0)))
	next_state["selected_q"] = int(next_state["q"])
	next_state["selected_r"] = int(next_state["r"])
	dungeon["return_pending"] = false
	dungeon["completed_returns"] = int(dungeon.get("completed_returns", 0)) + 1
	next_state["dungeon"] = dungeon
	next_state["active_view"] = "kingdom"
	var rewarded := false
	var quest_id := String(site_by_id(String(dungeon.get("entrance_site", ""))).get("quest_id", ""))
	var quests: Dictionary = next_state.get("quests", {})
	if not quest_id.is_empty() and String(quests.get(quest_id, "")) == "accepted":
		quests[quest_id] = "completed"
		next_state["quests"] = quests
		var resources: Dictionary = next_state.get("resources", {})
		resources["marks"] = int(resources.get("marks", 0)) + 45
		resources["salvage"] = int(resources.get("salvage", 0)) + 12
		next_state["resources"] = resources
		rewarded = true
	return {
		"ok": true,
		"rewarded": rewarded,
		"message": "Returned to the exact entrance hex.%s" % (" Registry contract paid: +45 Marks, +12 Salvage." if rewarded else " The route remains available."),
		"state": next_state,
	}


func leave_dungeon_early(state: Dictionary) -> Dictionary:
	var next_state := normalize_state(state)
	var dungeon: Dictionary = next_state.get("dungeon", {})
	if not bool(dungeon.get("return_pending", false)):
		next_state["active_view"] = "kingdom"
		return {"ok": true, "message": "Returned to the kingdom map. No expedition was pending.", "state": next_state}
	next_state["q"] = int(dungeon.get("entrance_q", next_state.get("q", 0)))
	next_state["r"] = int(dungeon.get("entrance_r", next_state.get("r", 0)))
	next_state["selected_q"] = int(next_state["q"])
	next_state["selected_r"] = int(next_state["r"])
	dungeon["return_pending"] = false
	next_state["dungeon"] = dungeon
	next_state["active_view"] = "kingdom"
	return {
		"ok": true,
		"message": "Safely extracted to the exact entrance hex. All owned items and accepted quests remain. No completion reward was claimed.",
		"state": next_state,
	}


func lore_by_id(lore_id: String) -> Dictionary:
	_ensure_loaded()
	for raw_lore in definition.get("lore_fragments", []):
		var lore: Dictionary = raw_lore
		if String(lore.get("id", "")) == lore_id:
			return lore.duplicate(true)
	return {}


func is_discovered(state: Dictionary, coord: Vector2i) -> bool:
	return (state.get("discovered", []) as Array).has(_coord_key(coord))


func _reveal_around(state: Dictionary, center: Vector2i, radius: int) -> void:
	var discovered: Array = state.get("discovered", [])
	for r in range(int((definition.get("kingdom", {}) as Dictionary).get("height", 0))):
		for q in range(int((definition.get("kingdom", {}) as Dictionary).get("width", 0))):
			var coord := Vector2i(q, r)
			if _hex_distance(center, coord) <= radius:
				var key := _coord_key(coord)
				if not discovered.has(key):
					discovered.append(key)
	state["discovered"] = discovered


func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dr) + absi(dq + dr)) / 2


func _in_bounds(coord: Vector2i) -> bool:
	var kingdom: Dictionary = definition.get("kingdom", {})
	return coord.x >= 0 and coord.y >= 0 and coord.x < int(kingdom.get("width", 0)) and coord.y < int(kingdom.get("height", 0))


func _coord_key(coord: Vector2i) -> String:
	return "%d,%d" % [coord.x, coord.y]


func _stable_number(seed_value: int, q: int, r: int) -> int:
	var value := seed_value ^ (q * 73_856_093) ^ (r * 19_349_663)
	value = int((value ^ (value >> 13)) * 1_274_126_177)
	return absi(value ^ (value >> 16))


func _stable_text_number(value: String, seed_value: int) -> int:
	var result := seed_value
	for index in range(value.length()):
		result = int((result * 33 + value.unicode_at(index)) & 0x7fffffff)
	return absi(result)


func _ensure_loaded() -> void:
	if definition.is_empty():
		load_definition()
