class_name ReactiveDialogue
extends RefCounted

const DOCUMENT_PATH := "res://content/dialogue/combat_reactions.json"
const PARTY_NAMES := ["Dena", "Moss", "Vell", "Ilex"]

var _document: Dictionary = {}
var _seed := 0
var _counter := 0
var _used: Dictionary = {}


func _init() -> void:
	_document = _load_document()


func reset_encounter(seed: int, encounter_key: String) -> void:
	_seed = seed ^ int(encounter_key.hash())
	_counter = 0
	_used.clear()


func line_count() -> int:
	return _count_strings(_document)


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if _document.is_empty():
		errors.append("Combat reaction dialogue document could not be loaded.")
		return errors
	if int(_document.get("schema_version", 0)) != 1:
		errors.append("Combat reaction dialogue schema_version must be 1.")
	for category in ["enemy_opening", "tiny_hit", "heavy_hit", "electric", "critical_dealt", "taunts", "enemy_taunt_response", "strategy", "conversations"]:
		if not _document.has(category):
			errors.append("Combat reaction dialogue is missing %s." % category)
	if line_count() < 120:
		errors.append("Combat reaction dialogue requires at least 120 authored lines.")
	return errors


func enemy_opening(sprite_key: String, enemy_name: String) -> Dictionary:
	var opening: Dictionary = _document.get("enemy_opening", {})
	var line := _pick("opening.%s" % sprite_key, opening.get(sprite_key, []))
	return {"speaker": enemy_name, "line": line, "kind": "enemy"}


func taunt(member_index: int, enemy_name: String) -> Array[Dictionary]:
	var safe_index := clampi(member_index, 0, PARTY_NAMES.size() - 1)
	var member_name: String = String(PARTY_NAMES[safe_index])
	var taunts: Dictionary = _document.get("taunts", {})
	var result: Array[Dictionary] = [{
		"speaker": member_name,
		"line": _pick("taunt.%s" % member_name, taunts.get(member_name, [])).replace("{enemy}", enemy_name),
		"kind": "party",
	}]
	result.append({
		"speaker": enemy_name,
		"line": _pick("taunt.response", _document.get("enemy_taunt_response", [])),
		"kind": "enemy",
	})
	result.append_array(conversation("taunt"))
	return result


func reaction_to_effect(effect: Dictionary, party: Array, enemies: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var target_kind := String(effect.get("target_kind", ""))
	var target_index := int(effect.get("target_index", -1))
	var damage_type := String(effect.get("damage_type", "impact"))
	var magnitude := float(effect.get("magnitude", 0.0))
	var critical := bool(effect.get("critical", false))
	if target_kind == "party" and target_index >= 0 and target_index < party.size() and int(effect.get("amount", 0)) >= 0:
		var member_name := String(party[target_index].get("name", PARTY_NAMES[target_index]))
		var category := "electric" if damage_type == "electric" else ("tiny_hit" if magnitude <= 0.08 else ("heavy_hit" if magnitude >= 0.28 else ""))
		if not category.is_empty():
			var category_lines: Dictionary = _document.get(category, {})
			result.append({"speaker": member_name, "line": _pick("%s.%s" % [category, member_name], category_lines.get(member_name, [])), "kind": "party"})
			result.append_array(conversation(category))
	elif target_kind == "enemy" and critical:
		var source_index := int(effect.get("source_index", 0))
		var speaker: String = String(PARTY_NAMES[clampi(source_index, 0, PARTY_NAMES.size() - 1)])
		result.append({"speaker": speaker, "line": _pick("critical", _document.get("critical_dealt", [])), "kind": "party"})
		result.append_array(conversation("critical"))
	return result


func strategy_line() -> Dictionary:
	return {"speaker": "Ilex", "line": _pick("strategy", _document.get("strategy", [])), "kind": "party"}


func conversation(trigger: String) -> Array[Dictionary]:
	var candidates: Array = []
	for raw_conversation in _document.get("conversations", []):
		if typeof(raw_conversation) == TYPE_DICTIONARY and String((raw_conversation as Dictionary).get("trigger", "")) == trigger:
			candidates.append(raw_conversation)
	if candidates.is_empty() or ((_seed + _counter * 13) & 3) != 0:
		return []
	var chosen: Dictionary = candidates[_pick_index("conversation.%s" % trigger, candidates.size())]
	return [
		{"speaker": String(chosen.get("speaker", "PARTY")), "line": String(chosen.get("line", "")), "kind": "party"},
		{"speaker": String(chosen.get("reply_speaker", "PARTY")), "line": String(chosen.get("reply_line", "")), "kind": "party"},
	]


func _pick(category: String, raw_lines: Variant) -> String:
	if typeof(raw_lines) != TYPE_ARRAY or (raw_lines as Array).is_empty():
		return ""
	var lines: Array = raw_lines
	var index := _pick_index(category, lines.size())
	return String(lines[index])


func _pick_index(category: String, size: int) -> int:
	if size <= 0:
		return 0
	var prior := int(_used.get(category, -1))
	var index := posmod(_seed + int(category.hash()) + _counter * 7, size)
	if size > 1 and index == prior:
		index = (index + 1) % size
	_used[category] = index
	_counter += 1
	return index


func _load_document() -> Dictionary:
	if not FileAccess.file_exists(DOCUMENT_PATH):
		return {}
	var file := FileAccess.open(DOCUMENT_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return (json.data as Dictionary).duplicate(true)


func _count_strings(value: Variant) -> int:
	match typeof(value):
		TYPE_STRING:
			return 1
		TYPE_ARRAY:
			var array_total := 0
			for child in value:
				array_total += _count_strings(child)
			return array_total
		TYPE_DICTIONARY:
			var dictionary_total := 0
			for key in (value as Dictionary).keys():
				if String(key) not in ["schema_version", "trigger", "speaker", "reply_speaker"]:
					dictionary_total += _count_strings((value as Dictionary)[key])
			return dictionary_total
	return 0
