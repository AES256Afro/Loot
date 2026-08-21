extends Node

## Loads immutable authored content definitions and rejects malformed data before
## gameplay systems consume it.

const ITEM_DOCUMENT_PATH := "res://content/items/spike_rewards.json"
const VALID_RARITIES := ["common", "uncommon", "rare", "epic", "legendary", "mythic"]
const VALID_SLOTS := ["weapon", "head", "chest", "hands", "feet", "charm", "utility"]
const ID_PREFIX := "item."

var item_definitions: Dictionary = {}
var last_errors: PackedStringArray = []


func _ready() -> void:
	load_all()


func load_all() -> bool:
	item_definitions.clear()
	last_errors.clear()
	var document := load_json_document(ITEM_DOCUMENT_PATH)
	if document.is_empty():
		last_errors.append("Could not load item document: %s" % ITEM_DOCUMENT_PATH)
		return false
	last_errors = validate_item_document(document)
	if not last_errors.is_empty():
		return false
	for raw_item in document.get("items", []):
		var item: Dictionary = raw_item
		item_definitions[String(item["id"])] = item.duplicate(true)
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


func get_item(item_id: StringName) -> Dictionary:
	return item_definitions.get(String(item_id), {}).duplicate(true)


func all_items() -> Dictionary:
	return item_definitions.duplicate(true)
