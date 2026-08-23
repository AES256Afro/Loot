class_name CombatResolver
extends RefCounted

const ACTION_STRIKE := "strike"
const ACTION_POWER := "power"
const ACTION_GUARD := "guard"
const ACTION_UTILITY := "utility"
const ACTION_TAUNT := "taunt"
const PARTY_DAMAGE_TYPES := ["slash", "decay", "impact", "radiant"]

var _equipment := EquipmentService.new()


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
		"damage_type": String(definition.get("damage_type", "impact")),
		"sprite_key": String(definition.get("sprite_key", "filing_larva")),
		"weakened": 0,
		"exposed": 0,
		"taunted_by": -1,
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
		var taunted_by := int(enemy.get("taunted_by", -1))
		if taunted_by >= 0 and living_party.has(taunted_by):
			target_index = taunted_by
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
	environment_primed: bool,
	equipment_laws: Dictionary = {}
) -> Dictionary:
	var party: Array = party_input.duplicate(true)
	var enemies: Array = enemies_input.duplicate(true)
	var log_lines: Array[String] = []
	var effects: Array[Dictionary] = []
	var environment_consumed := false
	var first_strike_available := true
	var first_utility_available := true
	var guard_floor_available := true
	if round_index == 1:
		var opening_guard := _law_value(equipment_laws, "opening_guard")
		if opening_guard > 0:
			for member in party:
				if int(member.get("hp", 0)) > 0:
					member["guard"] = int(member.get("guard", 0)) + opening_guard
			log_lines.append(_law_line(equipment_laws, "opening_guard", -2, "Every living party member gains %d opening Guard." % opening_guard))
		for opening_member in range(party.size()):
			var self_guard := _law_value(equipment_laws, "opening_guard_self", opening_member)
			if self_guard > 0 and int(party[opening_member].get("hp", 0)) > 0:
				party[opening_member]["guard"] = int(party[opening_member].get("guard", 0)) + self_guard
				log_lines.append(_law_line(equipment_laws, "opening_guard_self", opening_member, "%s gains %d opening Guard." % [party[opening_member]["name"], self_guard]))
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
					var strike_damage := int(member["strike"])
					var relay_bonus := int(member.get("strike_boost", 0))
					if relay_bonus > 0:
						strike_damage += relay_bonus
						member["strike_boost"] = 0
						log_lines.append("Triage relay adds %d damage to %s's Strike." % [relay_bonus, member["name"]])
					if member_index == 0 and int(enemies[target_index].get("exposed", 0)) > 0:
						var breaker := _law_value(equipment_laws, "exposed_breaker", member_index)
						if breaker > 0:
							strike_damage += breaker
							log_lines.append(_law_line(equipment_laws, "exposed_breaker", member_index, "Dena adds %d damage against the Exposed target." % breaker))
					if member_index == 1 and int(enemies[target_index].get("weakened", 0)) > 0:
						var detonation := _law_value(equipment_laws, "weakness_detonation", member_index)
						if detonation > 0:
							strike_damage += detonation
							enemies[target_index]["weakened"] = maxi(0, int(enemies[target_index]["weakened"]) - 1)
							log_lines.append(_law_line(equipment_laws, "weakness_detonation", member_index, "Moss consumes 1 Weakening for %d bonus damage." % detonation))
					if first_strike_available:
						var first_strike := _law_value(equipment_laws, "first_strike")
						if first_strike > 0:
							strike_damage += first_strike
							log_lines.append(_law_line(equipment_laws, "first_strike", -2, "The first Strike gains %d damage." % first_strike))
						first_strike_available = false
					var critical := ((round_index * 17 + member_index * 7 + target_index * 3) % 11) == 0
					if critical:
						strike_damage *= 2
						log_lines.append("CRITICAL: %s finds the exact structural mistake the target was using as a skeleton." % member["name"])
					var damage := _deal_damage(enemies[target_index], strike_damage)
					effects.append(_hit_effect("enemy", target_index, "party", member_index, PARTY_DAMAGE_TYPES[member_index], damage, int(enemies[target_index]["max_hp"]), 0, critical))
					log_lines.append("%s strikes %s for %d." % [member["name"], enemies[target_index]["name"], damage])
			ACTION_POWER:
				var power_result := _resolve_power(member_index, party, enemies, target_index, environment_primed and not environment_consumed, equipment_laws)
				log_lines.append_array(power_result["log"])
				effects.append_array(power_result.get("effects", []))
				if power_result.get("environment_consumed", false):
					environment_consumed = true
			ACTION_UTILITY:
				if target_index >= 0:
					enemies[target_index]["exposed"] = 2
					log_lines.append("%s exposes %s. The next hit gains 2 damage." % [member["name"], enemies[target_index]["name"]])
					if member_index == 2:
						var echo := _law_value(equipment_laws, "salvage_echo", member_index)
						var echo_target := _next_living_enemy(enemies, target_index)
						if echo > 0 and echo_target >= 0:
							var echo_damage := _deal_damage(enemies[echo_target], echo)
							effects.append(_hit_effect("enemy", echo_target, "party", member_index, "impact", echo_damage, int(enemies[echo_target]["max_hp"]), 0, false))
							log_lines.append(_law_line(equipment_laws, "salvage_echo", member_index, "Vell splashes %d damage to %s." % [echo_damage, enemies[echo_target]["name"]]))
					if first_utility_available:
						var utility_echo := _law_value(equipment_laws, "utility_echo")
						var utility_target := _next_living_enemy(enemies, target_index)
						if utility_echo > 0 and utility_target >= 0:
							enemies[utility_target]["exposed"] = int(enemies[utility_target].get("exposed", 0)) + utility_echo
							log_lines.append(_law_line(equipment_laws, "utility_echo", -2, "%s gains %d Exposed." % [enemies[utility_target]["name"], utility_echo]))
						first_utility_available = false
					var utility_guard := _law_value(equipment_laws, "utility_guard", member_index)
					if utility_guard > 0:
						member["guard"] = int(member.get("guard", 0)) + utility_guard
						log_lines.append(_law_line(equipment_laws, "utility_guard", member_index, "Vell gains %d Guard after Utility." % utility_guard))
			ACTION_TAUNT:
				if target_index >= 0:
					enemies[target_index]["taunted_by"] = member_index
					enemies[target_index]["weakened"] = int(enemies[target_index].get("weakened", 0)) + 1
					if member_index == 0:
						member["guard"] = int(member.get("guard", 0)) + 2
					log_lines.append("%s taunts %s. Its next declared attack targets %s and loses 1 damage." % [member["name"], enemies[target_index]["name"], member["name"]])
			_:
				member["guard"] = int(member.get("guard", 0)) + 3
				log_lines.append("%s guards against 3 additional damage." % member["name"])
				if member_index == 1 and _law_value(equipment_laws, "guard_primes_hex_self", member_index) > 0:
					member["hex_primed"] = true
					log_lines.append(_law_line(equipment_laws, "guard_primes_hex_self", member_index, "Moss primes her next Power by gaining Guard."))
				if member_index == 0:
					_apply_targeted_cover(party, enemies, round_index, equipment_laws, log_lines)
				var guard_share := _law_value(equipment_laws, "guard_share")
				if guard_share > 0:
					var lowest_ally := _lowest_living(party)
					if lowest_ally >= 0:
						party[lowest_ally]["guard"] = int(party[lowest_ally].get("guard", 0)) + guard_share
						log_lines.append(_law_line(equipment_laws, "guard_share", -2, "%s gains %d shared Guard." % [party[lowest_ally]["name"], guard_share]))
	if _is_varied_plan(commands):
		var varied_guard := _law_value(equipment_laws, "varied_filing")
		if varied_guard > 0:
			for varied_member in party:
				if int(varied_member.get("hp", 0)) > 0:
					varied_member["guard"] = int(varied_member.get("guard", 0)) + varied_guard
					if String(_law_source(equipment_laws, "varied_filing")) == "Godless Vending Token":
						varied_member["strike_boost"] = int(varied_member.get("strike_boost", 0)) + 1
			log_lines.append(_law_line(equipment_laws, "varied_filing", -2, "The varied plan grants every living member %d Guard." % varied_guard))
	if _living_indices(enemies).is_empty():
		return _result(party, enemies, log_lines, effects, environment_consumed, true, false)
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
		if guard_floor_available:
			var guard_floor := _law_value(equipment_laws, "guard_floor")
			if guard_floor > 0:
				party[target_index]["guard"] = int(party[target_index].get("guard", 0)) + guard_floor
				log_lines.append(_law_line(equipment_laws, "guard_floor", -2, "%s gains %d Guard before the first declared hit." % [party[target_index]["name"], guard_floor]))
			guard_floor_available = false
		var guarded := int(party[target_index].get("guard", 0))
		var incoming := maxi(0, int(intent["damage"]) - guarded)
		party[target_index]["hp"] = maxi(0, int(party[target_index]["hp"]) - incoming)
		party[target_index]["guard"] = 0
		effects.append(_hit_effect("party", target_index, "enemy", int(intent["enemy_index"]), String(enemy.get("damage_type", "impact")), incoming, int(party[target_index]["max_hp"]), mini(guarded, int(intent["damage"])), false))
		log_lines.append("%s hits %s for %d%s." % [
			enemy["name"],
			party[target_index]["name"],
			incoming,
			" after Guard" if guarded > 0 else "",
		])
		if int(enemy.get("weakened", 0)) > 0:
				enemy["weakened"] = maxi(0, int(enemy["weakened"]) - 1)
		enemy["taunted_by"] = -1
		if target_index == 0 and guarded > 0 and int(party[0].get("hp", 0)) > 0:
			var counter := _law_value(equipment_laws, "guard_counter", 0)
			if counter > 0 and int(enemy.get("hp", 0)) > 0:
				var counter_damage := _deal_damage(enemy, counter)
				effects.append(_hit_effect("enemy", int(intent["enemy_index"]), "party", 0, "impact", counter_damage, int(enemy["max_hp"]), 0, false))
				log_lines.append(_law_line(equipment_laws, "guard_counter", 0, "Dena counters %s for %d damage." % [enemy["name"], counter_damage]))
	var victory_after_counter := _living_indices(enemies).is_empty()
	var defeated := _living_indices(party).is_empty()
	return _result(party, enemies, log_lines, effects, environment_consumed, victory_after_counter, defeated)


func _resolve_power(
	member_index: int,
	party: Array,
	enemies: Array,
	target_index: int,
	use_environment: bool,
	equipment_laws: Dictionary
) -> Dictionary:
	var lines: Array[String] = []
	var effects: Array[Dictionary] = []
	var consumed := false
	match member_index:
		0:
			if target_index >= 0:
				var damage := _deal_damage(enemies[target_index], 7)
				effects.append(_hit_effect("enemy", target_index, "party", member_index, "impact", damage, int(enemies[target_index]["max_hp"]), 0, false))
				party[member_index]["guard"] = 2
				lines.append("Dena uses Brace and Break for %d damage and gains 2 Guard." % damage)
		1:
			if target_index >= 0:
				var power_bonus := _law_value(equipment_laws, "power_bonus", member_index)
				var damage := _deal_damage(enemies[target_index], 4 + power_bonus)
				effects.append(_hit_effect("enemy", target_index, "party", member_index, "decay", damage, int(enemies[target_index]["max_hp"]), 0, false))
				enemies[target_index]["weakened"] = 2
				lines.append("Moss applies Mildew of Doubt for %d damage and weakens the target." % damage)
				if power_bonus > 0:
					lines.append(_law_line(equipment_laws, "power_bonus", member_index, "Mildew of Doubt gains %d damage." % power_bonus))
				var always_spread := _law_value(equipment_laws, "weakening_spread_always", member_index)
				var spread := always_spread if always_spread > 0 else _law_value(equipment_laws, "weakening_spread", member_index)
				var spread_ready := always_spread > 0 or bool(party[member_index].get("hex_primed", false))
				var spread_target := _next_living_enemy(enemies, target_index)
				if spread > 0 and spread_ready and spread_target >= 0:
					var spread_damage := _deal_damage(enemies[spread_target], spread)
					effects.append(_hit_effect("enemy", spread_target, "party", member_index, "decay", spread_damage, int(enemies[spread_target]["max_hp"]), 0, false))
					enemies[spread_target]["weakened"] = maxi(int(enemies[spread_target].get("weakened", 0)), 2 if always_spread > 0 else 1)
					lines.append(_law_line(equipment_laws, "weakening_spread_always" if always_spread > 0 else "weakening_spread", member_index, "The hex spreads for %d damage and Weakening to %s." % [spread_damage, enemies[spread_target]["name"]]))
					party[member_index]["hex_primed"] = false
				var weakened_guard := _law_value(equipment_laws, "weakened_guard", member_index)
				if weakened_guard > 0:
					party[member_index]["guard"] = int(party[member_index].get("guard", 0)) + weakened_guard
					lines.append(_law_line(equipment_laws, "weakened_guard", member_index, "Moss gains %d Guard after Weakening an enemy." % weakened_guard))
		2:
			if use_environment:
				consumed = true
				var pressure_bonus := _law_value(equipment_laws, "pressure_bonus", member_index)
				for enemy_index in range(enemies.size()):
					var enemy: Dictionary = enemies[enemy_index]
					if int(enemy.get("hp", 0)) > 0:
						var pressure_damage := _deal_damage(enemy, 5 + pressure_bonus)
						effects.append(_hit_effect("enemy", enemy_index, "party", member_index, "impact", pressure_damage, int(enemy["max_hp"]), 0, false))
				lines.append("Vell ruptures the primed pressure line for %d damage to every enemy." % (5 + pressure_bonus))
				if pressure_bonus > 0:
					lines.append(_law_line(equipment_laws, "pressure_bonus", member_index, "The pressure burst gains %d damage." % pressure_bonus))
				var exposure := _law_value(equipment_laws, "pressure_exposure", member_index)
				if exposure > 0:
					for enemy in enemies:
						if int(enemy.get("hp", 0)) > 0:
							enemy["exposed"] = exposure
					lines.append(_law_line(equipment_laws, "pressure_exposure", member_index, "Every surviving enemy gains %d Exposed." % exposure))
				var pressure_echo := _law_value(equipment_laws, "pressure_echo")
				if pressure_echo > 0:
					for enemy_index in range(enemies.size()):
						var enemy: Dictionary = enemies[enemy_index]
						if int(enemy.get("hp", 0)) > 0:
							var echo_damage := _deal_damage(enemy, pressure_echo)
							effects.append(_hit_effect("enemy", enemy_index, "party", member_index, "impact", echo_damage, int(enemy["max_hp"]), 0, false))
					lines.append(_law_line(equipment_laws, "pressure_echo", -2, "The environmental burst echoes for %d damage." % pressure_echo))
			elif target_index >= 0:
				var damage := _deal_damage(enemies[target_index], 6)
				effects.append(_hit_effect("enemy", target_index, "party", member_index, "impact", damage, int(enemies[target_index]["max_hp"]), 0, false))
				lines.append("Vell fires Valve Shot for %d damage." % damage)
		3:
			var heal_target := _lowest_living(party)
			if heal_target >= 0:
				var before := int(party[heal_target]["hp"])
				var heal_amount := 6 + _law_value(equipment_laws, "heal_bonus", member_index)
				party[heal_target]["hp"] = mini(int(party[heal_target]["max_hp"]), before + heal_amount)
				effects.append(_hit_effect("party", heal_target, "party", member_index, "healing", -(int(party[heal_target]["hp"]) - before), int(party[heal_target]["max_hp"]), 0, false))
				lines.append("Ilex applies Preventive Medicine to %s for %d healing." % [party[heal_target]["name"], int(party[heal_target]["hp"]) - before])
				var heal_bonus := _law_value(equipment_laws, "heal_bonus", member_index)
				if heal_bonus > 0:
					lines.append(_law_line(equipment_laws, "heal_bonus", member_index, "Preventive Medicine gains %d healing." % heal_bonus))
				var preventive_guard := _law_value(equipment_laws, "preventive_guard", member_index)
				if preventive_guard > 0:
					party[heal_target]["guard"] = int(party[heal_target].get("guard", 0)) + preventive_guard
					lines.append(_law_line(equipment_laws, "preventive_guard", member_index, "%s gains %d Guard." % [party[heal_target]["name"], preventive_guard]))
				var overheal := maxi(0, before + heal_amount - int(party[heal_target]["max_hp"]))
				var overheal_cap := _law_value(equipment_laws, "overheal_guard", member_index)
				if overheal > 0 and overheal_cap > 0:
					var converted := mini(overheal, overheal_cap)
					party[heal_target]["guard"] = int(party[heal_target].get("guard", 0)) + converted
					lines.append(_law_line(equipment_laws, "overheal_guard", member_index, "%d excess healing becomes Guard." % converted))
				var relay := _law_value(equipment_laws, "triage_relay", member_index)
				if relay > 0:
					party[heal_target]["strike_boost"] = int(party[heal_target].get("strike_boost", 0)) + relay
					lines.append(_law_line(equipment_laws, "triage_relay", member_index, "%s's next Strike gains %d damage." % [party[heal_target]["name"], relay]))
	return {"log": lines, "effects": effects, "environment_consumed": consumed}


func _deal_damage(enemy: Dictionary, base_damage: int) -> int:
	if int(enemy.get("hp", 0)) <= 0:
		return 0
	var bonus := int(enemy.get("exposed", 0))
	var damage := base_damage + bonus
	enemy["hp"] = maxi(0, int(enemy["hp"]) - damage)
	if bonus > 0:
		enemy["exposed"] = 0
	return damage


func _hit_effect(
	target_kind: String,
	target_index: int,
	source_kind: String,
	source_index: int,
	damage_type: String,
	amount: int,
	target_max_hp: int,
	blocked: int,
	critical: bool
) -> Dictionary:
	return {
		"target_kind": target_kind,
		"target_index": target_index,
		"source_kind": source_kind,
		"source_index": source_index,
		"damage_type": damage_type,
		"amount": amount,
		"target_max_hp": target_max_hp,
		"blocked": blocked,
		"critical": critical,
		"magnitude": float(abs(amount)) / float(maxi(1, target_max_hp)),
	}


func _apply_targeted_cover(
	party: Array,
	enemies: Array,
	round_index: int,
	equipment_laws: Dictionary,
	log_lines: Array[String]
) -> void:
	var cover := _law_value(equipment_laws, "targeted_cover", 0)
	if cover <= 0:
		return
	var best_target := -1
	var best_damage := -1
	for intent in enemy_intents(enemies, party, round_index):
		var candidate := int(intent.get("target_index", -1))
		var damage := int(intent.get("damage", 0))
		if candidate == 0 or candidate < 0 or int(party[candidate].get("hp", 0)) <= 0:
			continue
		if damage > best_damage:
			best_damage = damage
			best_target = candidate
	if best_target < 0:
		for candidate in range(1, party.size()):
			if int(party[candidate].get("hp", 0)) > 0:
				best_target = candidate
				break
	if best_target < 0:
		return
	party[best_target]["guard"] = int(party[best_target].get("guard", 0)) + cover
	log_lines.append(_law_line(equipment_laws, "targeted_cover", 0, "Dena grants %s %d Guard against declared danger." % [party[best_target]["name"], cover]))
	if best_target == 1 and _law_value(equipment_laws, "guard_primes_hex", 0) > 0:
		party[1]["hex_primed"] = true
		log_lines.append(_law_line(equipment_laws, "guard_primes_hex", 0, "Guard placed on Moss primes her next Power to spread."))
	if best_target == 1 and _law_value(equipment_laws, "guard_primes_hex_self", 1) > 0:
		party[1]["hex_primed"] = true
		log_lines.append(_law_line(equipment_laws, "guard_primes_hex_self", 1, "Moss converts received Guard into a primed hex."))


func _is_varied_plan(commands: Array) -> bool:
	var seen := {}
	for command in commands:
		if typeof(command) == TYPE_DICTIONARY:
			seen[String((command as Dictionary).get("action", ""))] = true
	return seen.has(ACTION_STRIKE) and seen.has(ACTION_POWER) and seen.has(ACTION_GUARD) and seen.has(ACTION_UTILITY)


func _next_living_enemy(enemies: Array, excluded_index: int) -> int:
	for index in range(enemies.size()):
		if index != excluded_index and int(enemies[index].get("hp", 0)) > 0:
			return index
	return -1


func _law_value(equipment_laws: Dictionary, law_id: String, member_index: int = -2) -> int:
	return _equipment.law_value(equipment_laws, law_id, member_index)


func _law_source(equipment_laws: Dictionary, law_id: String, member_index: int = -2) -> String:
	return _equipment.law_source(equipment_laws, law_id, member_index)


func _law_line(equipment_laws: Dictionary, law_id: String, member_index: int, detail: String) -> String:
	return "[%s] activates: %s" % [_law_source(equipment_laws, law_id, member_index), detail]


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


func _result(party: Array, enemies: Array, log_lines: Array[String], effects: Array[Dictionary], consumed: bool, victory: bool, defeat: bool) -> Dictionary:
	return {
		"party": party,
		"enemies": enemies,
		"log": log_lines,
		"effects": effects,
		"environment_consumed": consumed,
		"victory": victory,
		"defeat": defeat,
	}
