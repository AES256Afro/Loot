class_name CombatResolver
extends RefCounted

const ACTION_STRIKE := "strike"
const ACTION_POWER := "power"
const ACTION_GUARD := "guard"
const ACTION_UTILITY := "utility"


func create_default_party() -> Array[Dictionary]:
	return [
		_member("Dena", "Bulwark", 24, 5, "Brace and Break", "#e3a33b"),
		_member("Moss", "Hexer", 17, 3, "Mildew of Doubt", "#b973d9"),
		_member("Vell", "Scavenger", 19, 4, "Valve Shot", "#54c7c0"),
		_member("Ilex", "Warden", 18, 3, "Preventive Medicine", "#78c875"),
	]


func create_enemy(definition: Dictionary, instance_index: int) -> Dictionary:
	return {
		"instance_id": "%s.%d" % [String(definition.get("id", "enemy.unknown")), instance_index],
		"definition_id": String(definition.get("id", "enemy.unknown")),
		"name": String(definition.get("display_name", "Unknown Enemy")),
		"hp": int(definition.get("max_hp", 1)),
		"max_hp": int(definition.get("max_hp", 1)),
		"damage": int(definition.get("damage", 1)),
		"sprite_key": String(definition.get("sprite_key", "filing_larva")),
		"weakened": 0,
		"exposed": 0,
	}


func enemy_intents(enemies_input: Array, party_input: Array, round_index: int) -> Array[Dictionary]:
	var intents: Array[Dictionary] = []
	var living_party := _living_indices(party_input)
	if living_party.is_empty():
		return intents
	for enemy_index in range(enemies_input.size()):
		var enemy: Dictionary = enemies_input[enemy_index]
		if int(enemy.get("hp", 0)) <= 0:
			continue
		var target_index: int = living_party[(round_index + enemy_index - 1) % living_party.size()]
		var damage := maxi(1, int(enemy.get("damage", 1)) - int(enemy.get("weakened", 0)))
		intents.append({
			"enemy_index": enemy_index,
			"target_index": target_index,
			"damage": damage,
			"text": "%s intends %d damage to %s" % [enemy["name"], damage, party_input[target_index]["name"]],
		})
	return intents


func resolve_round(
	party_input: Array,
	enemies_input: Array,
	commands: Array,
	round_index: int,
	environment_primed: bool
) -> Dictionary:
	var party: Array = party_input.duplicate(true)
	var enemies: Array = enemies_input.duplicate(true)
	var log_lines: Array[String] = []
	var environment_consumed := false
	for member_index in range(party.size()):
		var member: Dictionary = party[member_index]
		if int(member.get("hp", 0)) <= 0:
			continue
		var command: Dictionary = commands[member_index] if member_index < commands.size() else {}
		var action := String(command.get("action", ACTION_GUARD))
		var target_index := _valid_enemy_target(enemies, int(command.get("target", 0)))
		match action:
			ACTION_STRIKE:
				if target_index >= 0:
					var damage := _deal_damage(enemies[target_index], int(member["strike"]))
					log_lines.append("%s strikes %s for %d." % [member["name"], enemies[target_index]["name"], damage])
			ACTION_POWER:
				var power_result := _resolve_power(member_index, party, enemies, target_index, environment_primed and not environment_consumed)
				log_lines.append_array(power_result["log"])
				if power_result.get("environment_consumed", false):
					environment_consumed = true
			ACTION_UTILITY:
				if target_index >= 0:
					enemies[target_index]["exposed"] = 2
					log_lines.append("%s exposes %s. The next hit gains 2 damage." % [member["name"], enemies[target_index]["name"]])
			_:
				member["guard"] = 3
				log_lines.append("%s guards against 3 damage." % member["name"])
	if _living_indices(enemies).is_empty():
		return _result(party, enemies, log_lines, environment_consumed, true, false)
	var intents := enemy_intents(enemies, party, round_index)
	for intent in intents:
		var enemy: Dictionary = enemies[int(intent["enemy_index"])]
		if int(enemy.get("hp", 0)) <= 0:
			continue
		var target_index := int(intent["target_index"])
		if target_index < 0 or target_index >= party.size() or int(party[target_index].get("hp", 0)) <= 0:
			target_index = _first_living(party)
		if target_index < 0:
			break
		var guarded := int(party[target_index].get("guard", 0))
		var incoming := maxi(0, int(intent["damage"]) - guarded)
		party[target_index]["hp"] = maxi(0, int(party[target_index]["hp"]) - incoming)
		party[target_index]["guard"] = 0
		log_lines.append("%s hits %s for %d%s." % [
			enemy["name"],
			party[target_index]["name"],
			incoming,
			" after Guard" if guarded > 0 else "",
		])
		if int(enemy.get("weakened", 0)) > 0:
			enemy["weakened"] = maxi(0, int(enemy["weakened"]) - 1)
	var defeated := _living_indices(party).is_empty()
	return _result(party, enemies, log_lines, environment_consumed, false, defeated)


func _resolve_power(
	member_index: int,
	party: Array,
	enemies: Array,
	target_index: int,
	use_environment: bool
) -> Dictionary:
	var lines: Array[String] = []
	var consumed := false
	match member_index:
		0:
			if target_index >= 0:
				var damage := _deal_damage(enemies[target_index], 7)
				party[member_index]["guard"] = 2
				lines.append("Dena uses Brace and Break for %d damage and gains 2 Guard." % damage)
		1:
			if target_index >= 0:
				var damage := _deal_damage(enemies[target_index], 4)
				enemies[target_index]["weakened"] = 2
				lines.append("Moss applies Mildew of Doubt for %d damage and weakens the target." % damage)
		2:
			if use_environment:
				consumed = true
				for enemy in enemies:
					if int(enemy.get("hp", 0)) > 0:
						_deal_damage(enemy, 5)
				lines.append("Vell ruptures the primed pressure line for 5 damage to every enemy.")
			elif target_index >= 0:
				var damage := _deal_damage(enemies[target_index], 6)
				lines.append("Vell fires Valve Shot for %d damage." % damage)
		3:
			var heal_target := _lowest_living(party)
			if heal_target >= 0:
				var before := int(party[heal_target]["hp"])
				party[heal_target]["hp"] = mini(int(party[heal_target]["max_hp"]), before + 6)
				lines.append("Ilex applies Preventive Medicine to %s for %d healing." % [party[heal_target]["name"], int(party[heal_target]["hp"]) - before])
	return {"log": lines, "environment_consumed": consumed}


func _deal_damage(enemy: Dictionary, base_damage: int) -> int:
	if int(enemy.get("hp", 0)) <= 0:
		return 0
	var bonus := int(enemy.get("exposed", 0))
	var damage := base_damage + bonus
	enemy["hp"] = maxi(0, int(enemy["hp"]) - damage)
	if bonus > 0:
		enemy["exposed"] = 0
	return damage


func _member(name: String, role: String, max_hp: int, strike: int, power: String, color: String) -> Dictionary:
	return {
		"name": name,
		"role": role,
		"hp": max_hp,
		"max_hp": max_hp,
		"strike": strike,
		"power": power,
		"color": color,
		"guard": 0,
	}


func _valid_enemy_target(enemies: Array, preferred: int) -> int:
	if preferred >= 0 and preferred < enemies.size() and int(enemies[preferred].get("hp", 0)) > 0:
		return preferred
	return _first_living(enemies)


func _first_living(entries: Array) -> int:
	for index in range(entries.size()):
		if int(entries[index].get("hp", 0)) > 0:
			return index
	return -1


func _lowest_living(entries: Array) -> int:
	var result := -1
	var lowest_ratio := 2.0
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if int(entry.get("hp", 0)) <= 0:
			continue
		var ratio := float(entry["hp"]) / float(entry["max_hp"])
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			result = index
	return result


func _living_indices(entries: Array) -> Array[int]:
	var living: Array[int] = []
	for index in range(entries.size()):
		if int(entries[index].get("hp", 0)) > 0:
			living.append(index)
	return living


func _result(party: Array, enemies: Array, log_lines: Array[String], consumed: bool, victory: bool, defeat: bool) -> Dictionary:
	return {
		"party": party,
		"enemies": enemies,
		"log": log_lines,
		"environment_consumed": consumed,
		"victory": victory,
		"defeat": defeat,
	}
