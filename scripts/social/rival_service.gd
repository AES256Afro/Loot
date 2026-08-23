class_name RivalService
extends RefCounted

const DIALOGUE_PATH := "res://content/dialogue/scrip_rival.json"
const ACTOR_ID := "actor.rival.gutterbloom.scrip"
const ORIGIN_ENEMY_ID := "enemy.gutterbloom.form_auditor"
const MAX_MEMORIES := 4

const POSTURE_RETURN_PENDING := "return_pending"
const POSTURE_RIVAL := "rival"
const POSTURE_WARY_NEUTRAL := "wary_neutral"
const POSTURE_TEMPORARY_ALLY := "temporary_ally"
const POSTURE_ALLY := "ally"
const POSTURE_FRIEND := "friend"
const POSTURE_PAID_NEUTRAL := "paid_neutral"

const OUTCOME_SKIP_COMBAT := "skip_combat"
const OUTCOME_ALLY_COMBAT := "ally_combat"
const OUTCOME_RIVAL_COMBAT := "rival_combat"

var _dialogue: Dictionary = {}


func create_default_state() -> Dictionary:
	return {
		"schema_version": 1,
		"social_stats": {
			"presence": 4,
			"insight": 5,
			"guile": 4,
		},
		"actor": {},
		"valve_tip": false,
		"pending_encounter": {},
	}


func normalize_state(input: Variant) -> Dictionary:
	var state := create_default_state()
	if typeof(input) != TYPE_DICTIONARY:
		return state
	var supplied: Dictionary = input
	var supplied_stats: Dictionary = supplied.get("social_stats", {})
	for stat_id in ["presence", "insight", "guile"]:
		state["social_stats"][stat_id] = clampi(int(supplied_stats.get(stat_id, state["social_stats"][stat_id])), 0, 20)
	state["valve_tip"] = bool(supplied.get("valve_tip", false))
	var pending: Variant = supplied.get("pending_encounter", {})
	if typeof(pending) == TYPE_DICTIONARY:
		state["pending_encounter"] = (pending as Dictionary).duplicate(true)
	var supplied_actor: Variant = supplied.get("actor", {})
	if typeof(supplied_actor) == TYPE_DICTIONARY and not (supplied_actor as Dictionary).is_empty():
		state["actor"] = _normalize_actor(supplied_actor)
	return state


func validate() -> PackedStringArray:
	_load_dialogue()
	var errors := PackedStringArray()
	if _dialogue.is_empty():
		errors.append("Could not load Scrip rival dialogue.")
		return errors
	if int(_dialogue.get("schema_version", 0)) != 1:
		errors.append("Scrip rival dialogue schema_version must be 1.")
	if String(_dialogue.get("actor_id", "")) != ACTOR_ID:
		errors.append("Scrip rival dialogue actor_id is invalid.")
	for category in [
		"promotion_escape",
		"return_opening",
		"cite_record_party",
		"cite_record_success",
		"partnership_party",
		"partnership_success",
		"taunt_party",
		"taunt_success",
		"leave_parley",
		"ally_assist",
		"bar_opening_rival",
		"bar_opening_ally",
		"bar_opening_friend",
		"share_booth",
		"paid_neutrality",
		"buy_information",
		"trade_insults",
		"bar_leave",
	]:
		var entries: Variant = _dialogue.get(category, null)
		if typeof(entries) != TYPE_ARRAY or (entries as Array).size() < 2:
			errors.append("Scrip rival dialogue category %s needs at least two lines." % category)
			continue
		for entry in entries:
			if typeof(entry) != TYPE_DICTIONARY or String((entry as Dictionary).get("speaker", "")).is_empty() or String((entry as Dictionary).get("line", "")).is_empty():
				errors.append("Scrip rival dialogue category %s contains a malformed line." % category)
	if line_count() < 90:
		errors.append("Scrip rival dialogue needs at least 90 authored lines.")
	return errors


func line_count() -> int:
	_load_dialogue()
	var count := 0
	for value in _dialogue.values():
		if typeof(value) != TYPE_ARRAY:
			continue
		for entry in value:
			if typeof(entry) == TYPE_DICTIONARY and not String((entry as Dictionary).get("line", "")).is_empty():
				count += 1
	return count


func has_actor(state_input: Variant) -> bool:
	return not actor(state_input).is_empty()


func actor(state_input: Variant) -> Dictionary:
	var state := normalize_state(state_input)
	return (state.get("actor", {}) as Dictionary).duplicate(true)


func social_stats(state_input: Variant) -> Dictionary:
	return (normalize_state(state_input).get("social_stats", {}) as Dictionary).duplicate(true)


func promote_form_auditor(state_input: Variant, context_input: Dictionary) -> Dictionary:
	var state := normalize_state(state_input)
	if has_actor(state):
		return {"state": state, "promoted": false, "lines": []}
	var context := _normalize_memory(context_input)
	var new_actor := {
		"actor_id": ACTOR_ID,
		"origin_definition_id": ORIGIN_ENEMY_ID,
		"display_name": "Scrip, Repossessed Auditor",
		"posture": POSTURE_RETURN_PENDING,
		"current_place_id": "place.gutterbloom.complaint_hatch",
		"current_role": "next_office_challenger",
		"motive_id": "motive.survive_mandatory_management",
		"growth_budget": 1,
		"technique_ids": ["technique.rival.backdated_capacitor"],
		"appearance_marks": [_mark_for_damage(String(context.get("damage_type", "impact")))],
		"relationship": {
			"grievance": 3,
			"fear": 2,
			"respect": 1,
			"debt": 0,
			"greed": 2,
		},
		"memories": [context],
		"appearance_count": 0,
		"bar_visits": 0,
		"last_bar_run_index": -1,
		"last_outcome": "escaped",
		"promise": "",
	}
	state["actor"] = new_actor
	return {
		"state": state,
		"promoted": true,
		"lines": _select_lines("promotion_escape", context, 1, 3),
	}


func should_open_parley(state_input: Variant, run_index: int) -> bool:
	var current_actor := actor(state_input)
	if current_actor.is_empty() or String(current_actor.get("current_role", "")) != "next_office_challenger":
		return false
	var memories: Array = current_actor.get("memories", [])
	if memories.is_empty():
		return false
	return run_index > int((memories[0] as Dictionary).get("run_index", run_index))


func return_opening(state_input: Variant) -> Array[Dictionary]:
	var current_actor := actor(state_input)
	if current_actor.is_empty():
		return []
	var context := _primary_memory(current_actor)
	return _select_lines("return_opening", context, 2, int(current_actor.get("appearance_count", 0)) + 5)


func memory_summary(state_input: Variant) -> String:
	var current_actor := actor(state_input)
	if current_actor.is_empty():
		return "No recurring actor is recorded."
	var memory := _primary_memory(current_actor)
	var relationship: Dictionary = current_actor.get("relationship", {})
	return "[color=#f0c96f][b]REMEMBERED DEFEAT[/b][/color]\n%s  |  Expedition %d\nFinisher: %s using %s\nDamage: %s%s\n\n[color=#78e7d5][b]CURRENT PRESSURES[/b][/color]\nGrievance %d  Fear %d  Respect %d  Debt %d  Greed %d\nGrowth: Backdated Capacitor +1" % [
		String(memory.get("room_role", "Unknown place")),
		int(memory.get("run_index", 0)) + 1,
		String(memory.get("finisher_member", "Unknown")),
		String(memory.get("finishing_action", "unknown action")).capitalize(),
		String(memory.get("damage_type", "impact")).capitalize(),
		_flag_summary(memory),
		int(relationship.get("grievance", 0)),
		int(relationship.get("fear", 0)),
		int(relationship.get("respect", 0)),
		int(relationship.get("debt", 0)),
		int(relationship.get("greed", 0)),
	]


func parley_options(state_input: Variant) -> Array[Dictionary]:
	var state := normalize_state(state_input)
	var current_actor: Dictionary = state.get("actor", {})
	if current_actor.is_empty():
		return []
	var stats: Dictionary = state.get("social_stats", {})
	var relationship: Dictionary = current_actor.get("relationship", {})
	return [
		_checked_option(
			"cite_record",
			"CITE THE RECORD",
			"insight",
			int(stats.get("insight", 0)),
			"Fear",
			int(relationship.get("fear", 0)),
			6,
			"Success ends combat and still grants the baseline reward."
		),
		_checked_option(
			"offer_partnership",
			"OFFER PARTNERSHIP",
			"guile",
			int(stats.get("guile", 0)),
			"Greed + Respect",
			int(relationship.get("greed", 0)) + int(relationship.get("respect", 0)),
			7,
			"Success makes Scrip an ally against the replacement staff."
		),
		_checked_option(
			"taunt_audit",
			"TAUNT THE AUDIT",
			"presence",
			int(stats.get("presence", 0)),
			"Grievance",
			int(relationship.get("grievance", 0)),
			6,
			"Combat begins. Scrip is stronger but starts Weakened and Exposed."
		),
		{
			"id": "end_parley",
			"label": "END PARLEY",
			"checked": false,
			"available": true,
			"prediction": "NO CHECK",
			"detail": "Start the legal encounter without a hidden penalty.",
		},
	]


func resolve_parley(state_input: Variant, option_id: String, run_index: int = -1) -> Dictionary:
	var state := normalize_state(state_input)
	var current_actor: Dictionary = state.get("actor", {})
	if current_actor.is_empty():
		return {"ok": false, "state": state, "message": "No recurring actor is available."}
	var option := _option_by_id(parley_options(state), option_id)
	if option.is_empty() or not bool(option.get("available", false)):
		return {"ok": false, "state": state, "message": "That social option is unavailable."}
	current_actor["appearance_count"] = int(current_actor.get("appearance_count", 0)) + 1
	current_actor["current_place_id"] = "place.gutterbloom.promoted_office"
	current_actor["current_role"] = "bar_guest"
	var relationship: Dictionary = current_actor.get("relationship", {})
	var passed := bool(option.get("passed", true))
	var outcome := OUTCOME_RIVAL_COMBAT
	var modifiers := {"rival_enemy": true, "growth_hp": 5, "growth_damage": 1}
	var line_category := "leave_parley"
	match option_id:
		"cite_record":
			line_category = "cite_record_success" if passed else "partnership_failure"
			if passed:
				outcome = OUTCOME_SKIP_COMBAT
				modifiers = {}
				current_actor["posture"] = POSTURE_WARY_NEUTRAL
				relationship["fear"] = _bounded_relationship(relationship, "fear", 1)
				relationship["respect"] = _bounded_relationship(relationship, "respect", 1)
		"offer_partnership":
			line_category = "partnership_success" if passed else "partnership_failure"
			if passed:
				outcome = OUTCOME_ALLY_COMBAT
				modifiers = {"ally_assist": true, "opening_guard": 2, "opening_damage": 3}
				current_actor["posture"] = POSTURE_TEMPORARY_ALLY
				current_actor["promise"] = "survive_shared_danger"
				relationship["respect"] = _bounded_relationship(relationship, "respect", 1)
			else:
				current_actor["posture"] = POSTURE_RIVAL
		"taunt_audit":
			line_category = "taunt_success"
			current_actor["posture"] = POSTURE_RIVAL
			modifiers["opening_weakened"] = 2 if passed else 0
			modifiers["opening_exposed"] = 1 if passed else 0
			relationship["grievance"] = _bounded_relationship(relationship, "grievance", 1)
		"end_parley":
			current_actor["posture"] = POSTURE_RIVAL
	current_actor["relationship"] = relationship
	current_actor["last_outcome"] = option_id
	state["actor"] = current_actor
	state["pending_encounter"] = {
		"run_index": run_index,
		"outcome": outcome,
		"modifiers": modifiers.duplicate(true),
	} if outcome != OUTCOME_SKIP_COMBAT else {}
	var context := _primary_memory(current_actor)
	var party_category: String = String({
		"cite_record": "cite_record_party",
		"offer_partnership": "partnership_party",
		"taunt_audit": "taunt_party",
	}.get(option_id, "leave_parley"))
	var lines := _select_lines(party_category, context, 1, int(current_actor["appearance_count"]))
	lines.append_array(_select_lines(line_category, context, 1, int(current_actor["appearance_count"]) + 11))
	return {
		"ok": true,
		"state": state,
		"outcome": outcome,
		"modifiers": modifiers,
		"passed": passed,
		"lines": lines,
		"message": String(option.get("detail", "Social choice resolved.")),
	}


func pending_encounter(state_input: Variant, run_index: int) -> Dictionary:
	var state := normalize_state(state_input)
	var pending: Dictionary = state.get("pending_encounter", {})
	if pending.is_empty() or int(pending.get("run_index", -2)) != run_index:
		return {}
	return pending.duplicate(true)


func clear_pending_encounter(state_input: Variant) -> Dictionary:
	var state := normalize_state(state_input)
	state["pending_encounter"] = {}
	return state


func complete_shared_danger(state_input: Variant) -> Dictionary:
	var state := normalize_state(state_input)
	var current_actor: Dictionary = state.get("actor", {})
	if String(current_actor.get("posture", "")) != POSTURE_TEMPORARY_ALLY:
		return state
	var relationship: Dictionary = current_actor.get("relationship", {})
	current_actor["posture"] = POSTURE_ALLY
	current_actor["promise"] = "shared_danger_survived"
	current_actor["last_outcome"] = "alliance_honored"
	relationship["debt"] = _bounded_relationship(relationship, "debt", 2)
	relationship["respect"] = _bounded_relationship(relationship, "respect", 2)
	current_actor["relationship"] = relationship
	state["actor"] = current_actor
	return state


func ally_assist_lines(state_input: Variant) -> Array[Dictionary]:
	var current_actor := actor(state_input)
	return _select_lines("ally_assist", _primary_memory(current_actor), 2, int(current_actor.get("appearance_count", 0)) + 23)


func can_visit_bar(state_input: Variant, run_index: int) -> bool:
	var current_actor := actor(state_input)
	if current_actor.is_empty() or int(current_actor.get("appearance_count", 0)) <= 0:
		return false
	return int(current_actor.get("last_bar_run_index", -1)) != run_index


func bar_opening(state_input: Variant) -> Array[Dictionary]:
	var current_actor := actor(state_input)
	if current_actor.is_empty():
		return []
	var category := "bar_opening_rival"
	if String(current_actor.get("posture", "")) == POSTURE_FRIEND:
		category = "bar_opening_friend"
	elif String(current_actor.get("posture", "")) in [POSTURE_TEMPORARY_ALLY, POSTURE_ALLY]:
		category = "bar_opening_ally"
	return _select_lines(category, _primary_memory(current_actor), 1, int(current_actor.get("bar_visits", 0)) + 31)


func bar_options(state_input: Variant) -> Array[Dictionary]:
	var state := normalize_state(state_input)
	var current_actor: Dictionary = state.get("actor", {})
	if current_actor.is_empty():
		return []
	var stats: Dictionary = state.get("social_stats", {})
	var relationship: Dictionary = current_actor.get("relationship", {})
	var posture := String(current_actor.get("posture", ""))
	var shared_danger := posture == POSTURE_ALLY and String(current_actor.get("promise", "")) == "shared_danger_survived"
	var result: Array[Dictionary] = []
	result.append({
		"id": "share_booth",
		"label": "SHARE THE BOOTH",
		"checked": false,
		"available": shared_danger,
		"prediction": "AVAILABLE" if shared_danger else "LOCKED",
		"detail": "Requires the shared danger to have been survived together. Becomes friendship.",
	})
	result.append(_checked_option(
		"paid_neutrality",
		"PROPOSE PAID NEUTRALITY",
		"guile",
		int(stats.get("guile", 0)),
		"Greed",
		int(relationship.get("greed", 0)),
		5,
		"Success suspends rivalry. No owned item is consumed."
	))
	result.append(_checked_option(
		"buy_information",
		"ASK ABOUT THE VALVES",
		"insight",
		int(stats.get("insight", 0)),
		"Respect",
		int(relationship.get("respect", 0)),
		6,
		"Success reveals the next pressure route without making it mandatory."
	))
	result.append(_checked_option(
		"trade_insults",
		"TRADE INSULTS",
		"presence",
		int(stats.get("presence", 0)),
		"Respect",
		int(relationship.get("respect", 0)),
		5,
		"Success increases respect. Violence remains prohibited."
	))
	result.append({
		"id": "leave_bar",
		"label": "LEAVE THE BENT PIPE",
		"checked": false,
		"available": true,
		"prediction": "NO CHECK",
		"detail": "Return to the Hearthfold with the relationship unchanged.",
	})
	return result


func resolve_bar(state_input: Variant, option_id: String, run_index: int) -> Dictionary:
	var state := normalize_state(state_input)
	var current_actor: Dictionary = state.get("actor", {})
	var option := _option_by_id(bar_options(state), option_id)
	if current_actor.is_empty() or option.is_empty() or not bool(option.get("available", false)):
		return {"ok": false, "state": state, "message": "That bar conversation is unavailable."}
	current_actor["bar_visits"] = int(current_actor.get("bar_visits", 0)) + 1
	current_actor["last_bar_run_index"] = run_index
	current_actor["current_place_id"] = "place.gutterbloom.bent_pipe"
	var relationship: Dictionary = current_actor.get("relationship", {})
	var passed := bool(option.get("passed", true))
	var category := "bar_leave"
	var outcome := "unchanged"
	match option_id:
		"share_booth":
			category = "share_booth"
			outcome = "friend"
			current_actor["posture"] = POSTURE_FRIEND
			current_actor["current_role"] = "wandering_friend"
			current_actor["promise"] = "show_up_when_promised"
			relationship["respect"] = _bounded_relationship(relationship, "respect", 2)
			relationship["debt"] = _bounded_relationship(relationship, "debt", 1)
			relationship["grievance"] = _bounded_relationship(relationship, "grievance", -2)
		"paid_neutrality":
			category = "paid_neutrality"
			outcome = "paid_neutrality" if passed else "unchanged"
			if passed:
				current_actor["posture"] = POSTURE_PAID_NEUTRAL
				current_actor["current_role"] = "neutral_informant"
				relationship["grievance"] = _bounded_relationship(relationship, "grievance", -1)
		"buy_information":
			category = "buy_information" if passed else "bar_leave"
			outcome = "valve_tip" if passed else "unchanged"
			if passed:
				state["valve_tip"] = true
				relationship["respect"] = _bounded_relationship(relationship, "respect", 1)
		"trade_insults":
			category = "trade_insults"
			outcome = "mutual_respect" if passed else "unchanged"
			if passed:
				relationship["respect"] = _bounded_relationship(relationship, "respect", 1)
		"leave_bar":
			pass
	current_actor["relationship"] = relationship
	current_actor["last_outcome"] = outcome
	state["actor"] = current_actor
	return {
		"ok": true,
		"state": state,
		"outcome": outcome,
		"passed": passed,
		"lines": _select_lines(category, _primary_memory(current_actor), 6 if option_id == "share_booth" else 2, int(current_actor["bar_visits"]) + 41),
		"message": String(option.get("detail", "Bar conversation resolved.")),
	}


func apply_rival_growth(enemy_input: Dictionary, state_input: Variant, modifiers: Dictionary) -> Dictionary:
	var enemy := enemy_input.duplicate(true)
	var current_actor := actor(state_input)
	if current_actor.is_empty():
		return enemy
	enemy["name"] = String(current_actor.get("display_name", "Scrip"))
	enemy["instance_id"] = "%s.return" % ACTOR_ID
	enemy["hp"] = int(enemy.get("hp", 1)) + int(modifiers.get("growth_hp", 5))
	enemy["max_hp"] = enemy["hp"]
	enemy["damage"] = int(enemy.get("damage", 1)) + int(modifiers.get("growth_damage", 1))
	enemy["weakened"] = int(modifiers.get("opening_weakened", 0))
	enemy["exposed"] = int(modifiers.get("opening_exposed", 0))
	return enemy


func format_option(option: Dictionary) -> String:
	if not bool(option.get("checked", false)):
		return "%s\n%s  |  %s" % [option.get("label", "OPTION"), option.get("prediction", "NO CHECK"), option.get("detail", "")]
	return "%s\n%s %d + %s %d = %d  vs  %d  [%s]\n%s" % [
		option.get("label", "CHECK"),
		String(option.get("stat", "stat")).to_upper(),
		int(option.get("stat_value", 0)),
		String(option.get("relationship_label", "Relationship")).to_upper(),
		int(option.get("relationship_value", 0)),
		int(option.get("total", 0)),
		int(option.get("difficulty", 0)),
		String(option.get("prediction", "UNKNOWN")),
		option.get("detail", ""),
	]


func _checked_option(
	id: String,
	label: String,
	stat: String,
	stat_value: int,
	relationship_label: String,
	relationship_value: int,
	difficulty: int,
	detail: String
) -> Dictionary:
	var total := stat_value + relationship_value
	return {
		"id": id,
		"label": label,
		"checked": true,
		"available": true,
		"stat": stat,
		"stat_value": stat_value,
		"relationship_label": relationship_label,
		"relationship_value": relationship_value,
		"total": total,
		"difficulty": difficulty,
		"passed": total >= difficulty,
		"prediction": "PASS" if total >= difficulty else "FAIL",
		"detail": detail,
	}


func _option_by_id(options: Array, option_id: String) -> Dictionary:
	for option in options:
		if typeof(option) == TYPE_DICTIONARY and String((option as Dictionary).get("id", "")) == option_id:
			return (option as Dictionary).duplicate(true)
	return {}


func _normalize_actor(actor_input: Variant) -> Dictionary:
	var current_actor: Dictionary = (actor_input as Dictionary).duplicate(true)
	current_actor["actor_id"] = ACTOR_ID
	current_actor["origin_definition_id"] = ORIGIN_ENEMY_ID
	current_actor["display_name"] = String(current_actor.get("display_name", "Scrip, Repossessed Auditor"))
	current_actor["posture"] = String(current_actor.get("posture", POSTURE_RETURN_PENDING))
	current_actor["current_place_id"] = String(current_actor.get("current_place_id", "place.gutterbloom.complaint_hatch"))
	current_actor["current_role"] = String(current_actor.get("current_role", "next_office_challenger"))
	current_actor["motive_id"] = String(current_actor.get("motive_id", "motive.survive_mandatory_management"))
	current_actor["growth_budget"] = clampi(int(current_actor.get("growth_budget", 1)), 0, 3)
	current_actor["appearance_count"] = maxi(0, int(current_actor.get("appearance_count", 0)))
	current_actor["bar_visits"] = maxi(0, int(current_actor.get("bar_visits", 0)))
	current_actor["last_bar_run_index"] = int(current_actor.get("last_bar_run_index", -1))
	current_actor["last_outcome"] = String(current_actor.get("last_outcome", "escaped"))
	current_actor["promise"] = String(current_actor.get("promise", ""))
	var relationship_input: Dictionary = current_actor.get("relationship", {})
	var relationship := {}
	for dimension in ["grievance", "fear", "respect", "debt", "greed"]:
		relationship[dimension] = clampi(int(relationship_input.get(dimension, 0)), 0, 10)
	current_actor["relationship"] = relationship
	var memories: Array = []
	for memory in current_actor.get("memories", []):
		if typeof(memory) == TYPE_DICTIONARY:
			memories.append(_normalize_memory(memory))
		if memories.size() >= MAX_MEMORIES:
			break
	current_actor["memories"] = memories
	var techniques: Array = current_actor.get("technique_ids", ["technique.rival.backdated_capacitor"])
	current_actor["technique_ids"] = techniques.slice(0, 2)
	var marks: Array = current_actor.get("appearance_marks", ["mark.cracked_seal"])
	current_actor["appearance_marks"] = marks.slice(0, 2)
	return current_actor


func _normalize_memory(context_input: Variant) -> Dictionary:
	var context: Dictionary = context_input if typeof(context_input) == TYPE_DICTIONARY else {}
	return {
		"event_type": "rival.defeat_survived",
		"run_index": maxi(0, int(context.get("run_index", 0))),
		"seed": int(context.get("seed", 0)),
		"room_role": String(context.get("room_role", "Promoted Office")),
		"finisher_member": String(context.get("finisher_member", "Dena")),
		"finishing_action": String(context.get("finishing_action", "strike")),
		"damage_type": String(context.get("damage_type", "impact")),
		"pressure_participated": bool(context.get("pressure_participated", false)),
		"taunt_participated": bool(context.get("taunt_participated", false)),
		"critical_participated": bool(context.get("critical_participated", false)),
		"named_law_participated": bool(context.get("named_law_participated", false)),
	}


func _primary_memory(current_actor: Dictionary) -> Dictionary:
	var memories: Array = current_actor.get("memories", [])
	return (memories[0] as Dictionary).duplicate(true) if not memories.is_empty() else _normalize_memory({})


func _bounded_relationship(relationship: Dictionary, dimension: String, delta: int) -> int:
	return clampi(int(relationship.get(dimension, 0)) + delta, 0, 10)


func _mark_for_damage(damage_type: String) -> String:
	match damage_type:
		"electric":
			return "mark.fused_margin"
		"decay":
			return "mark.moss_burn"
		"slash":
			return "mark.split_seal"
		_:
			return "mark.cracked_stamp"


func _flag_summary(memory: Dictionary) -> String:
	var flags: PackedStringArray = []
	if bool(memory.get("pressure_participated", false)):
		flags.append("Pressure")
	if bool(memory.get("taunt_participated", false)):
		flags.append("Taunt")
	if bool(memory.get("critical_participated", false)):
		flags.append("Critical")
	if bool(memory.get("named_law_participated", false)):
		flags.append("Named Law")
	return "  |  " + ", ".join(flags) if not flags.is_empty() else ""


func _select_lines(category: String, context: Dictionary, count: int, salt: int) -> Array[Dictionary]:
	_load_dialogue()
	var entries: Array = _dialogue.get(category, [])
	var result: Array[Dictionary] = []
	if entries.is_empty():
		return result
	var start := posmod(int(context.get("seed", 0)) + salt * 17, entries.size())
	for offset in range(mini(count, entries.size())):
		var line: Dictionary = (entries[(start + offset) % entries.size()] as Dictionary).duplicate(true)
		line["line"] = _fill_tokens(String(line.get("line", "")), context)
		result.append(line)
	return result


func _fill_tokens(line: String, context: Dictionary) -> String:
	return line.replace("{member}", String(context.get("finisher_member", "Dena"))).replace(
		"{action}", String(context.get("finishing_action", "strike")).capitalize()
	).replace(
		"{damage_type}", String(context.get("damage_type", "impact")).capitalize()
	).replace(
		"{room}", String(context.get("room_role", "Promoted Office"))
	).replace(
		"{run}", str(int(context.get("run_index", 0)) + 1)
	)


func _load_dialogue() -> void:
	if not _dialogue.is_empty() or not FileAccess.file_exists(DIALOGUE_PATH):
		return
	var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
		_dialogue = (json.data as Dictionary).duplicate(true)
