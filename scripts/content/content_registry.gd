extends Node

## Loads immutable authored content definitions and rejects malformed data before
## gameplay systems consume it.

const ITEM_DOCUMENT_PATH := "res://content/items/spike_rewards.json"
const ENEMY_DOCUMENT_PATH := "res://content/enemies/crawler_enemies.json"
const VALID_RARITIES := ["common", "uncommon", "rare", "epic", "legendary", "mythic"]
const VALID_SLOTS := ["weapon", "head", "chest", "hands", "feet", "charm", "utility"]
const ID_PREFIX := "item."

var item_definitions: Dictionary = {}
var enemy_definitions: Dictionary = {}
var last_errors: PackedStringArray = []


func _ready() -> void:
	load_all()


func load_all() -> bool:
	item_definitions.clear()
	enemy_definitions.clear()
	last_errors.clear()
	var item_document := load_json_document(ITEM_DOCUMENT_PATH)
	if item_document.is_empty():
		last_errors.append("Could not load item document: %s" % ITEM_DOCUMENT_PATH)
	else:
		last_errors.append_array(validate_item_document(item_document))
	var enemy_document := load_json_document(ENEMY_DOCUMENT_PATH)
	if enemy_document.is_empty():
		last_errors.append("Could not load enemy document: %s" % ENEMY_DOCUMENT_PATH)
	else:
		last_errors.append_array(validate_enemy_document(enemy_document))
	if not last_errors.is_empty():
		return false
	for raw_item in item_document.get("items", []):
		var item: Dictionary = raw_item
		item_definitions[String(item["id"])] = item.duplicate(true)
	for raw_enemy in enemy_document.get("enemies", []):
		var enemy: Dictionary = raw_enemy
		enemy_definitions[String(enemy["id"])] = enemy.duplicate(true)
	return true


func load_json_document(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return (json.data as Dictionary).duplicate(true)


func validate_item_document(document: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if int(document.get("schema_version", 0)) != 1:
		errors.append("Item document schema_version must be 1.")
	var items_value: Variant = document.get("items", null)
	if typeof(items_value) != TYPE_ARRAY:
		errors.append("Item document must contain an items array.")
		return errors
	var seen_ids := {}
	for index in range((items_value as Array).size()):
		var raw_item: Variant = (items_value as Array)[index]
		if typeof(raw_item) != TYPE_DICTIONARY:
			errors.append("Item %d must be an object." % index)
			continue
		var item: Dictionary = raw_item
		var item_id := String(item.get("id", ""))
		var label := item_id if not item_id.is_empty() else "item[%d]" % index
		if not item_id.begins_with(ID_PREFIX) or item_id.count(".") < 2:
			errors.append("%s has an invalid immutable ID." % label)
		elif seen_ids.has(item_id):
			errors.append("Duplicate item ID: %s" % item_id)
		else:
			seen_ids[item_id] = true
		for field_name in ["display_name", "description", "power_id", "power_text"]:
			if String(item.get(field_name, "")).strip_edges().is_empty():
				errors.append("%s is missing %s." % [label, field_name])
		if not VALID_RARITIES.has(String(item.get("rarity", ""))):
			errors.append("%s has an invalid rarity." % label)
		if not VALID_SLOTS.has(String(item.get("slot", ""))):
			errors.append("%s has an invalid equipment slot." % label)
		var drop_weight: Variant = item.get("drop_weight", 0)
		if typeof(drop_weight) not in [TYPE_INT, TYPE_FLOAT] or float(drop_weight) <= 0.0:
			errors.append("%s must have a positive drop_weight." % label)
		var tags: Variant = item.get("tags", null)
		if typeof(tags) != TYPE_ARRAY or (tags as Array).is_empty():
			errors.append("%s must have at least one tag." % label)
		elif (tags as Array).duplicate().all(func(tag: Variant) -> bool: return typeof(tag) == TYPE_STRING and not String(tag).is_empty()) == false:
			errors.append("%s tags must be non-empty strings." % label)
	return errors


func validate_enemy_document(document: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if int(document.get("schema_version", 0)) != 1:
		errors.append("Enemy document schema_version must be 1.")
	var enemies_value: Variant = document.get("enemies", null)
	if typeof(enemies_value) != TYPE_ARRAY:
		errors.append("Enemy document must contain an enemies array.")
		return errors
	var seen_ids := {}
	for index in range((enemies_value as Array).size()):
		var raw_enemy: Variant = (enemies_value as Array)[index]
		if typeof(raw_enemy) != TYPE_DICTIONARY:
			errors.append("Enemy %d must be an object." % index)
			continue
		var enemy: Dictionary = raw_enemy
		var enemy_id := String(enemy.get("id", ""))
		var label := enemy_id if not enemy_id.is_empty() else "enemy[%d]" % index
		if not enemy_id.begins_with("enemy.") or enemy_id.count(".") < 2:
			errors.append("%s has an invalid immutable ID." % label)
		elif seen_ids.has(enemy_id):
			errors.append("Duplicate enemy ID: %s" % enemy_id)
		else:
			seen_ids[enemy_id] = true
		for field_name in ["display_name", "description", "sprite_key"]:
			if String(enemy.get(field_name, "")).strip_edges().is_empty():
				errors.append("%s is missing %s." % [label, field_name])
		for numeric_field in ["max_hp", "damage"]:
			var numeric_value: Variant = enemy.get(numeric_field, 0)
			if typeof(numeric_value) not in [TYPE_INT, TYPE_FLOAT] or float(numeric_value) <= 0.0:
				errors.append("%s must have a positive %s." % [label, numeric_field])
		var tags: Variant = enemy.get("tags", null)
		if typeof(tags) != TYPE_ARRAY or (tags as Array).is_empty():
			errors.append("%s must have at least one tag." % label)
	return errors


func get_item(item_id: StringName) -> Dictionary:
	return item_definitions.get(String(item_id), {}).duplicate(true)


func all_items() -> Dictionary:
	return item_definitions.duplicate(true)


func get_enemy(enemy_id: StringName) -> Dictionary:
	return enemy_definitions.get(String(enemy_id), {}).duplicate(true)


func all_enemies() -> Dictionary:
	return enemy_definitions.duplicate(true)
