class_name EquipmentService
extends RefCounted

const MEMBER_NAMES := ["Dena", "Moss", "Vell", "Ilex"]
const MEMBER_ROLES := ["dena", "moss", "vell", "ilex"]
const MEMBER_SLOTS := ["weapon", "chest", "utility", "charm"]
const RELIC_SLOT_COUNT := 2


func starter_inventory(definitions: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var item_ids: Array = definitions.keys()
	item_ids.sort()
	for raw_id in item_ids:
		var item: Dictionary = definitions[raw_id]
		if item.has("role"):
			result.append(String(raw_id))
	return result


func create_default_state(definitions: Dictionary) -> Dictionary:
	var state := _empty_state()
	for member_index in range(MEMBER_ROLES.size()):
		for slot in MEMBER_SLOTS:
			state["members"][member_index][slot] = _first_starter(definitions, MEMBER_ROLES[member_index], slot)
	var relic_starters: Array[String] = []
	var item_ids: Array = definitions.keys()
	item_ids.sort()
	for raw_id in item_ids:
		var item: Dictionary = definitions[raw_id]
		if bool(item.get("starter", false)) and String(item.get("role", "")) == "shared" and String(item.get("slot", "")) == "relic":
			relic_starters.append(String(raw_id))
	for index in range(mini(RELIC_SLOT_COUNT, relic_starters.size())):
		state["relics"][index] = relic_starters[index]
	state["loadouts"]["A"] = equipment_snapshot(state)
	state["loadouts"]["B"] = _burst_pipe_snapshot(state, definitions)
	return state


func normalize_state(raw_state: Variant, definitions: Dictionary) -> Dictionary:
	var fallback := create_default_state(definitions)
	if typeof(raw_state) != TYPE_DICTIONARY:
		return fallback
	var state: Dictionary = (raw_state as Dictionary).duplicate(true)
	if typeof(state.get("members")) != TYPE_ARRAY or (state["members"] as Array).size() != MEMBER_ROLES.size():
		state["members"] = fallback["members"]
	for member_index in range(MEMBER_ROLES.size()):
		if typeof(state["members"][member_index]) != TYPE_DICTIONARY:
			state["members"][member_index] = fallback["members"][member_index]
		for slot in MEMBER_SLOTS:
			var item_id := String((state["members"][member_index] as Dictionary).get(slot, ""))
			if not _compatible_member_item(definitions.get(item_id, {}), member_index, slot):
				state["members"][member_index][slot] = String(fallback["members"][member_index].get(slot, ""))
	if typeof(state.get("relics")) != TYPE_ARRAY or (state["relics"] as Array).size() != RELIC_SLOT_COUNT:
		state["relics"] = fallback["relics"]
	for relic_index in range(RELIC_SLOT_COUNT):
		var relic_id := String(state["relics"][relic_index])
		if not _compatible_relic(definitions.get(relic_id, {})):
			state["relics"][relic_index] = String(fallback["relics"][relic_index])
	if typeof(state.get("favorites")) != TYPE_ARRAY:
		state["favorites"] = []
	else:
		var valid_favorites: Array[String] = []
		for raw_id in state["favorites"]:
			var item_id := String(raw_id)
			if definitions.has(item_id) and not valid_favorites.has(item_id):
				valid_favorites.append(item_id)
		state["favorites"] = valid_favorites
	if typeof(state.get("loadouts")) != TYPE_DICTIONARY:
		state["loadouts"] = fallback["loadouts"]
	for loadout_name in ["A", "B"]:
		if typeof(state["loadouts"].get(loadout_name)) != TYPE_DICTIONARY:
			state["loadouts"][loadout_name] = equipment_snapshot(state)
	state["active_loadout"] = String(state.get("active_loadout", "A"))
	if not ["A", "B", "CUSTOM"].has(state["active_loadout"]):
		state["active_loadout"] = "CUSTOM"
	return state


func equipment_snapshot(state: Dictionary) -> Dictionary:
	return {
		"members": state.get("members", []).duplicate(true),
		"relics": state.get("relics", []).duplicate(true),
	}


func equip_member(
	state_input: Dictionary,
	definitions: Dictionary,
	inventory: Array,
	item_id: String,
	member_index: int
) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	if not inventory.has(item_id):
		return _failure(state, "That item is not in the Archive.")
	var item: Dictionary = definitions.get(item_id, {})
	var slot := String(item.get("slot", ""))
	if not _compatible_member_item(item, member_index, slot):
		return _failure(state, "%s cannot equip that item." % MEMBER_NAMES[clampi(member_index, 0, MEMBER_NAMES.size() - 1)])
	state["members"][member_index][slot] = item_id
	state["active_loadout"] = "CUSTOM"
	return {"ok": true, "state": state, "message": "%s equipped %s." % [MEMBER_NAMES[member_index], item.get("display_name", item_id)]}


func equip_relic(
	state_input: Dictionary,
	definitions: Dictionary,
	inventory: Array,
	item_id: String,
	relic_index: int
) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	if not inventory.has(item_id):
		return _failure(state, "That relic is not in the Archive.")
	var item: Dictionary = definitions.get(item_id, {})
	if relic_index < 0 or relic_index >= RELIC_SLOT_COUNT or not _compatible_relic(item):
		return _failure(state, "That item cannot occupy the selected Shared Relic slot.")
	state["relics"][relic_index] = item_id
	state["active_loadout"] = "CUSTOM"
	return {"ok": true, "state": state, "message": "Shared Relic %d equipped %s." % [relic_index + 1, item.get("display_name", item_id)]}


func toggle_favorite(state_input: Dictionary, definitions: Dictionary, item_id: String) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	if not definitions.has(item_id):
		return state
	var favorites: Array = state["favorites"]
	if favorites.has(item_id):
		favorites.erase(item_id)
	else:
		favorites.append(item_id)
	state["favorites"] = favorites
	return state


func save_loadout(state_input: Dictionary, definitions: Dictionary, loadout_name: String) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	if not ["A", "B"].has(loadout_name):
		return _failure(state, "Only Loadout A and Loadout B exist in this proof.")
	state["loadouts"][loadout_name] = equipment_snapshot(state)
	state["active_loadout"] = loadout_name
	return {"ok": true, "state": state, "message": "Loadout %s saved." % loadout_name}


func apply_loadout(
	state_input: Dictionary,
	definitions: Dictionary,
	inventory: Array,
	loadout_name: String
) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	if not ["A", "B"].has(loadout_name) or typeof(state["loadouts"].get(loadout_name)) != TYPE_DICTIONARY:
		return _failure(state, "Loadout %s is unavailable." % loadout_name)
	var snapshot: Dictionary = state["loadouts"][loadout_name]
	var candidate := state.duplicate(true)
	candidate["members"] = snapshot.get("members", []).duplicate(true)
	candidate["relics"] = snapshot.get("relics", []).duplicate(true)
	candidate = normalize_state(candidate, definitions)
	for item_id in equipped_item_ids(candidate):
		if not inventory.has(item_id):
			return _failure(state, "Loadout %s references an item no longer present in the Archive." % loadout_name)
	candidate["active_loadout"] = loadout_name
	return {"ok": true, "state": candidate, "message": "Loadout %s applied." % loadout_name}


func equipped_item_ids(state: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for member_state in state.get("members", []):
		if typeof(member_state) != TYPE_DICTIONARY:
			continue
		for slot in MEMBER_SLOTS:
			var item_id := String((member_state as Dictionary).get(slot, ""))
			if not item_id.is_empty():
				result.append(item_id)
	for raw_id in state.get("relics", []):
		var item_id := String(raw_id)
		if not item_id.is_empty():
			result.append(item_id)
	return result


func compile_laws(state_input: Dictionary, definitions: Dictionary) -> Dictionary:
	var state := normalize_state(state_input, definitions)
	var entries: Array[Dictionary] = []
	for member_index in range(MEMBER_ROLES.size()):
		for slot in MEMBER_SLOTS:
			var item_id := String(state["members"][member_index].get(slot, ""))
			_append_law(entries, definitions.get(item_id, {}), item_id, member_index, slot)
	for relic_index in range(RELIC_SLOT_COUNT):
		var item_id := String(state["relics"][relic_index])
		_append_law(entries, definitions.get(item_id, {}), item_id, -1, "relic")
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return "%02d:%s:%s" % [int(a["member_index"]), a["slot"], a["item_id"]] < "%02d:%s:%s" % [int(b["member_index"]), b["slot"], b["item_id"]]
	)
	return {"entries": entries}


func law_entries(laws: Dictionary, law_id: String, member_index: int = -2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_entry in laws.get("entries", []):
		var entry: Dictionary = raw_entry
		if String(entry.get("law_id", "")) != law_id:
			continue
		if member_index != -2 and int(entry.get("member_index", -99)) not in [member_index, -1]:
			continue
		result.append(entry)
	return result


func law_value(laws: Dictionary, law_id: String, member_index: int = -2) -> int:
	var value := 0
	for entry in law_entries(laws, law_id, member_index):
		value += int(entry.get("value", 0))
	return value


func law_source(laws: Dictionary, law_id: String, member_index: int = -2) -> String:
	var entries := law_entries(laws, law_id, member_index)
	if entries.is_empty():
		return "Unknown Equipment"
	return String(entries[0].get("item_name", "Unknown Equipment"))


func item_comparison(item: Dictionary, state: Dictionary, definitions: Dictionary, destination_index: int) -> Dictionary:
	var slot := String(item.get("slot", ""))
	var equipped_id := ""
	if slot == "relic":
		if destination_index >= 0 and destination_index < RELIC_SLOT_COUNT:
			equipped_id = String(state.get("relics", ["", ""])[destination_index])
	elif destination_index >= 0 and destination_index < MEMBER_ROLES.size():
		equipped_id = String(state.get("members", [])[destination_index].get(slot, ""))
	return definitions.get(equipped_id, {}).duplicate(true)


func _empty_state() -> Dictionary:
	var members: Array[Dictionary] = []
	for unused in MEMBER_ROLES:
		var slots := {}
		for slot in MEMBER_SLOTS:
			slots[slot] = ""
		members.append(slots)
	return {
		"members": members,
		"relics": ["", ""],
		"favorites": [],
		"loadouts": {},
		"active_loadout": "A",
	}


func _first_starter(definitions: Dictionary, role: String, slot: String) -> String:
	var item_ids: Array = definitions.keys()
	item_ids.sort()
	for raw_id in item_ids:
		var item: Dictionary = definitions[raw_id]
		if bool(item.get("starter", false)) and String(item.get("role", "")) == role and String(item.get("slot", "")) == slot:
			return String(raw_id)
	return ""


func _burst_pipe_snapshot(state: Dictionary, definitions: Dictionary) -> Dictionary:
	var snapshot := equipment_snapshot(state)
	var preferred := [
		{
			"weapon": "item.gutterbloom.overtime_cleaver",
			"chest": "item.gutterbloom.wall_with_sleeves",
			"utility": "item.gutterbloom.counterclaim_buckler",
			"charm": "item.gutterbloom.charm_of_shared_liability",
		},
		{
			"weapon": "item.gutterbloom.hexecutive_pointer",
			"chest": "item.gutterbloom.cloak_of_plausible_denial",
			"utility": "item.gutterbloom.second_opinion_jar",
			"charm": "item.gutterbloom.sympathetic_rust",
		},
		{
			"weapon": "item.gutterbloom.mayor_of_wrenches",
			"chest": "item.gutterbloom.regulation_poncho",
			"utility": "item.gutterbloom.salvage_echo_box",
			"charm": "item.gutterbloom.charm_of_just_one_more_valve",
		},
		{
			"weapon": "item.gutterbloom.staff_of_the_last_reasonable_person",
			"chest": "item.gutterbloom.wardens_raincoat",
			"utility": "item.gutterbloom.preemptive_bandage_launcher",
			"charm": "item.gutterbloom.overheal_receipt",
		},
	]
	for member_index in range(preferred.size()):
		for slot in MEMBER_SLOTS:
			var item_id := String(preferred[member_index][slot])
			if definitions.has(item_id):
				snapshot["members"][member_index][slot] = item_id
	var relic_ids := [
		"item.gutterbloom.relic_pearl_of_the_second_drain",
		"item.gutterbloom.relic_red_tape_mobius",
	]
	for index in range(relic_ids.size()):
		if definitions.has(relic_ids[index]):
			snapshot["relics"][index] = relic_ids[index]
	return snapshot


func _compatible_member_item(item: Dictionary, member_index: int, slot: String) -> bool:
	if member_index < 0 or member_index >= MEMBER_ROLES.size() or not MEMBER_SLOTS.has(slot):
		return false
	return not item.is_empty() and String(item.get("slot", "")) == slot and String(item.get("role", "")) in [MEMBER_ROLES[member_index], "any"]


func _compatible_relic(item: Dictionary) -> bool:
	return not item.is_empty() and String(item.get("slot", "")) == "relic" and String(item.get("role", "")) == "shared"


func _append_law(entries: Array[Dictionary], item: Dictionary, item_id: String, member_index: int, slot: String) -> void:
	if item.is_empty() or String(item.get("law_id", "")).is_empty():
		return
	entries.append({
		"law_id": String(item["law_id"]),
		"value": int(item.get("law_value", 0)),
		"item_id": item_id,
		"item_name": String(item.get("display_name", item_id)),
		"member_index": member_index,
		"slot": slot,
	})


func _failure(state: Dictionary, message: String) -> Dictionary:
	return {"ok": false, "state": state, "message": message}
