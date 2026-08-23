extends Node

const BASE_RUN_SEED := 20_260_823
const ROOM_SPACING := 14.0
const ROOM_SIZE := 10.0
const CAMERA_HEIGHT := 1.7
const STEP_DURATION := 0.26
const TURN_DURATION := 0.18
const MODE_EXPLORATION := "exploration"
const MODE_MOVING := "moving"
const MODE_COMBAT := "combat"
const MODE_RESOLVING := "resolving"
const MODE_REWARD := "reward"
const MODE_HEARTHFOLD := "hearthfold"
const MODE_PARLEY := "parley"
const MODE_BAR := "bar"
const MODE_KINGDOM := "kingdom"
const MODE_TOWN := "town"
const PROFILE_MODE := "pixel_crawler"

const FACING_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]
const FACING_NAMES := ["NORTH", "EAST", "SOUTH", "WEST"]

@onready var dungeon_world: Node3D = $ViewportContainer/WorldViewport/DungeonWorld
@onready var camera: Camera3D = $ViewportContainer/WorldViewport/DungeonWorld/Camera3D
@onready var hud: CrawlerHUDV2 = $HUD
@onready var world_hud: KingdomHUD = $KingdomHUD

var _generator := DungeonGenerator.new()
var _combat := CombatResolver.new()
var _reward_resolver := DeterministicRewardResolver.new()
var _sprite_factory := PixelSpriteFactory.new()
var _equipment := EquipmentService.new()
var _assets := GeneratedAssetLibrary.new()
var _dialogue := ReactiveDialogue.new()
var _rivals := RivalService.new()
var _worlds := KingdomMapService.new()

var _layout: Dictionary = {}
var _run_seed := BASE_RUN_SEED
var _run_index := 0
var _current_room := 0
var _facing := 0
var _mode := MODE_EXPLORATION
var _party: Array = []
var _enemies: Array = []
var _commands: Array = []
var _active_member := -1
var _selected_target := 0
var _round_index := 1
var _cleared_rooms := {}
var _visited_rooms := {}
var _junction_used := false
var _pressure_primed := false
var _inventory: Array[String] = []
var _reward_roll_index := 0
var _defeat_count := 0
var _equipment_state: Dictionary = {}
var _rival_state: Dictionary = {}
var _social_context := ""
var _active_encounter_id := ""
var _active_encounter_modifiers: Dictionary = {}
var _last_round_result: Dictionary = {}
var _generated_nodes: Array[Node] = []
var _enemy_visuals: Array[Sprite3D] = []
var _enemy_visual_by_index: Dictionary = {}
var _picket_visual: Sprite3D
var _world_state: Dictionary = {}
var _world_cells: Array = []
var _world_return_view := ""


func _ready() -> void:
	_connect_hud()
	if not Content.load_all():
		for content_error in Content.last_errors:
			push_error(content_error)
		hud.push_line("SYSTEM", "Content failed validation. Run tools/check.sh.")
		return
	if not _worlds.load_definition():
		for world_error in _worlds.last_errors:
			push_error(world_error)
			hud.push_line("SYSTEM", world_error)
		return
	_world_cells = _worlds.generate_cells()
	_world_state = _worlds.create_default_state()
	_equipment_state = _equipment.create_default_state(Content.all_items())
	_rival_state = _rivals.create_default_state()
	for dialogue_error in _dialogue.validate():
		push_error(dialogue_error)
		hud.push_line("SYSTEM", dialogue_error)
	for rival_error in _rivals.validate():
		push_error(rival_error)
		hud.push_line("SYSTEM", rival_error)
	_attach_picket_to_camera()
	if not _load_crawler_profile(false):
		_start_new_expedition(false)
		_show_kingdom_map()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F5:
			_save_profile(false)
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_F9:
			_load_crawler_profile(true)
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_K and String(_world_state.get("active_view", "")) == "dungeon":
			_return_to_kingdom()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode in [KEY_I, KEY_ESCAPE]:
			if world_hud.is_world_visible():
				if event.physical_keycode == KEY_ESCAPE and world_hud.service_is_open():
					world_hud.hide_service()
				elif event.physical_keycode == KEY_I:
					_show_world_archive_summary()
				get_viewport().set_input_as_handled()
				return
			if hud.social_is_open() and event.physical_keycode == KEY_ESCAPE:
				_on_social_choice_selected("leave_bar" if _social_context == "bar" else "end_parley")
			elif hud.archive_is_open():
				_close_archive()
			elif event.physical_keycode == KEY_I:
				_open_archive()
			get_viewport().set_input_as_handled()
			return
		if hud.modal_open():
			return
		if _mode == MODE_EXPLORATION:
			_handle_exploration_key(event.physical_keycode)
		elif _mode == MODE_COMBAT:
			_handle_combat_key(event.physical_keycode)
	elif event is InputEventJoypadButton and event.pressed and not hud.modal_open():
		if _mode == MODE_EXPLORATION:
			match event.button_index:
				JOY_BUTTON_DPAD_UP:
					_try_step(1)
				JOY_BUTTON_DPAD_DOWN:
					_try_step(-1)
				JOY_BUTTON_DPAD_LEFT:
					_turn(-1)
				JOY_BUTTON_DPAD_RIGHT:
					_turn(1)
				JOY_BUTTON_A:
					_interact()


func _connect_hud() -> void:
	hud.action_selected.connect(_on_action_selected)
	hud.target_selected.connect(_on_target_selected)
	hud.resolve_requested.connect(_resolve_plan)
	hud.reset_plan_requested.connect(_reset_plan)
	hud.interact_requested.connect(_interact)
	hud.reward_closed.connect(_close_reward)
	hud.new_expedition_requested.connect(_on_new_expedition)
	hud.return_to_dungeon_requested.connect(_return_from_hearthfold)
	hud.return_to_kingdom_requested.connect(_return_to_kingdom)
	hud.bent_pipe_requested.connect(_open_bent_pipe)
	hud.social_choice_selected.connect(_on_social_choice_selected)
	hud.archive_requested.connect(_open_archive)
	hud.archive_closed.connect(_close_archive)
	hud.archive_equip_requested.connect(_on_archive_equip_requested)
	hud.archive_favorite_requested.connect(_on_archive_favorite_requested)
	hud.save_loadout_requested.connect(_on_save_loadout_requested)
	hud.apply_loadout_requested.connect(_on_apply_loadout_requested)
	world_hud.travel_requested.connect(_on_world_travel_requested)
	world_hud.site_action_requested.connect(_on_world_site_action_requested)
	world_hud.town_exit_requested.connect(_on_town_exit_requested)
	world_hud.town_location_action_requested.connect(_on_town_location_action_requested)
	world_hud.service_choice_selected.connect(_on_world_service_choice_selected)


func _handle_exploration_key(keycode: Key) -> void:
	match keycode:
		KEY_W, KEY_UP:
			_try_step(1)
		KEY_S, KEY_DOWN:
			_try_step(-1)
		KEY_A, KEY_LEFT:
			_turn(-1)
		KEY_D, KEY_RIGHT:
			_turn(1)
		KEY_E, KEY_SPACE, KEY_ENTER:
			_interact()


func _handle_combat_key(keycode: Key) -> void:
	match keycode:
		KEY_1:
			_on_action_selected(CombatResolver.ACTION_STRIKE)
		KEY_2:
			_on_action_selected(CombatResolver.ACTION_POWER)
		KEY_3:
			_on_action_selected(CombatResolver.ACTION_GUARD)
		KEY_4:
			_on_action_selected(CombatResolver.ACTION_UTILITY)
		KEY_5:
			_on_action_selected(CombatResolver.ACTION_TAUNT)
		KEY_LEFT, KEY_A:
			_cycle_target(-1)
		KEY_RIGHT, KEY_D:
			_cycle_target(1)
		KEY_ENTER, KEY_SPACE:
			if _active_member < 0:
				_resolve_plan()
		KEY_BACKSPACE, KEY_DELETE:
			_reset_plan()


func _start_new_expedition(increment_index: bool = true) -> void:
	if increment_index:
		_run_index += 1
	_run_seed = BASE_RUN_SEED + _run_index * 7_919
	_layout = _generator.generate(_run_seed, 6)
	_current_room = 0
	_facing = _initial_facing()
	_mode = MODE_EXPLORATION
	_social_context = ""
	_active_encounter_id = ""
	_active_encounter_modifiers.clear()
	_last_round_result.clear()
	_party = _combat.create_default_party()
	_ensure_demo_archive()
	_enemies.clear()
	_commands.clear()
	_cleared_rooms.clear()
	_visited_rooms = {0: true}
	_junction_used = false
	_pressure_primed = false
	_clear_enemy_visuals()
	_build_dungeon()
	_place_camera(false)
	hud.hide_hearthfold()
	hud.hide_reward()
	hud.hide_social()
	world_hud.hide_all()
	hud.show()
	hud.clear_feed()
	hud.push_line("HERALD", "A four-person Claimant committee has entered the Gutterbloom. Consensus is not expected.")
	hud.push_line("PICKET", "The route contains six rooms and at least seven violations. The difference is structural creativity.")
	if bool(_rival_state.get("valve_tip", false)):
		hud.push_line("SCRIP", "Second blue wheel past the cistern. Optional, unstable, and management-approved only after it works.")
	GameEvents.publish(&"expedition.started", {"seed": _run_seed, "run_index": _run_index})
	_enter_current_room()
	_save_profile(true)


func _try_step(sign_value: int) -> void:
	if _mode != MODE_EXPLORATION:
		return
	var direction := FACING_DIRECTIONS[_facing] * sign_value
	var next_room := _generator.neighbor_in_direction(_layout, _current_room, direction)
	if next_room < 0:
		hud.push_line("PICKET", "That direction is load-bearing wall. It has declined the expedition.")
		return
	_mode = MODE_MOVING
	var target_position := _room_world_position(next_room) + Vector3(0, CAMERA_HEIGHT, 0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", target_position, STEP_DURATION)
	await tween.finished
	_current_room = next_room
	_visited_rooms[_current_room] = true
	_save_profile(true)
	_enter_current_room()


func _turn(step_value: int) -> void:
	if _mode != MODE_EXPLORATION:
		return
	_mode = MODE_MOVING
	_facing = posmod(_facing + step_value, 4)
	var target_rotation := camera.rotation
	target_rotation.y = _facing_yaw(_facing)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "rotation", target_rotation, TURN_DURATION)
	await tween.finished
	_mode = MODE_EXPLORATION
	_update_exploration_hud()
	_save_profile(true)


func _enter_current_room() -> void:
	var room := _room_data(_current_room)
	var encounter_id := String(room.get("encounter", ""))
	if not encounter_id.is_empty() and not _cleared_rooms.has(_current_room):
		if encounter_id == "office" and _rivals.should_open_parley(_rival_state, _run_index):
			_start_rival_parley()
			return
		var pending := _rivals.pending_encounter(_rival_state, _run_index) if encounter_id == "office" else {}
		_start_combat(encounter_id, pending.get("modifiers", {}) if not pending.is_empty() else {})
		return
	_mode = MODE_EXPLORATION
	_update_exploration_hud()
	match String(room.get("type", "")):
		"junction":
			if not _junction_used:
				hud.push_line("PICKET", "Pressure manifold available. Interaction is optional. Consequences are professionally encouraged.")
		"anchor":
			hud.push_line("HERALD", "The Hearthfold anchor is open. The expedition may conclude whenever the committee is done pretending this was planned.")


func _interact() -> void:
	if _mode != MODE_EXPLORATION:
		return
	var room_type := String(_room_data(_current_room).get("type", ""))
	match room_type:
		"junction":
			if _junction_used:
				hud.push_line("PICKET", "The manifold remains primed. Additional wrenching would become a hobby.")
				return
			_junction_used = true
			_pressure_primed = true
			hud.push_line("PICKET", "Pressure redirected. Vell may rupture the line with Valve Shot during a later combat.")
			hud.push_line("HERALD", "The party has weaponized maintenance. Facilities has been notified and has chosen denial.")
			GameEvents.publish(&"dungeon.environment_primed", {"room_id": _current_room})
			_save_profile(true)
			_update_exploration_hud()
		"anchor":
			_open_hearthfold()
		_:
			hud.push_line("PICKET", "No approved interaction is present. This has never stopped anyone, but it stops this prototype.")


func _start_rival_parley() -> void:
	_mode = MODE_PARLEY
	_social_context = "parley"
	_active_encounter_id = "office"
	_active_encounter_modifiers.clear()
	_commands.clear()
	var definition := Content.get_enemy(RivalService.ORIGIN_ENEMY_ID)
	var preview_enemy := _combat.create_enemy(definition, 0)
	_enemies = [_rivals.apply_rival_growth(preview_enemy, _rival_state, {"growth_hp": 5, "growth_damage": 1})]
	_spawn_enemy_visuals()
	if _picket_visual != null:
		_picket_visual.hide()
	var opening := _rivals.return_opening(_rival_state)
	hud.show_social(
		"SCRIP, REPOSSESSED AUDITOR",
		"RETURN ENCOUNTER  |  WARNING POSTURE  |  THE REPLACEMENT OFFICE IS OVERLOADING",
		_rivals.memory_summary(_rival_state),
		opening,
		_rivals.parley_options(_rival_state),
		false
	)
	if not opening.is_empty():
		_show_enemy_speech(0, String((opening[0] as Dictionary).get("line", "")))
	GameEvents.publish(&"rival.parley_started", {"actor_id": RivalService.ACTOR_ID, "run_index": _run_index, "room_id": _current_room})
	_save_profile(true)


func _on_social_choice_selected(option_id: String) -> void:
	if _social_context == "parley" and _mode == MODE_PARLEY:
		hud.hide_social()
		var result := _rivals.resolve_parley(_rival_state, option_id, _run_index)
		if not result.get("ok", false):
			hud.push_line("SYSTEM", String(result.get("message", "Social choice failed.")))
			_start_rival_parley()
			return
		_rival_state = result.get("state", _rival_state)
		_save_profile(true)
		await _present_utterances(result.get("lines", []), 0)
		GameEvents.publish(&"rival.parley_resolved", {"actor_id": RivalService.ACTOR_ID, "choice": option_id, "outcome": result.get("outcome", "")})
		if String(result.get("outcome", "")) == RivalService.OUTCOME_SKIP_COMBAT:
			_rival_state = _rivals.clear_pending_encounter(_rival_state)
			_finish_victory({}, true)
			return
		_start_combat("office", result.get("modifiers", {}))
		_save_profile(true)
		return
	if _social_context == "bar" and _mode == MODE_BAR:
		hud.hide_social()
		var bar_result := _rivals.resolve_bar(_rival_state, option_id, _run_index)
		if not bar_result.get("ok", false):
			hud.push_line("SYSTEM", String(bar_result.get("message", "Bar conversation failed.")))
			_show_bent_pipe_conversation()
			return
		_rival_state = bar_result.get("state", _rival_state)
		_save_profile(true)
		await _present_utterances(bar_result.get("lines", []), 0)
		GameEvents.publish(&"rival.bar_resolved", {"actor_id": RivalService.ACTOR_ID, "choice": option_id, "outcome": bar_result.get("outcome", "")})
		_close_bent_pipe()


func _start_combat(encounter_id: String, modifiers: Dictionary = {}) -> void:
	_mode = MODE_COMBAT
	_social_context = ""
	_active_encounter_id = encounter_id
	_active_encounter_modifiers = modifiers.duplicate(true)
	_round_index = 1
	_enemies = _build_encounter(encounter_id, modifiers)
	var ally_effects: Array[Dictionary] = []
	if bool(modifiers.get("ally_assist", false)):
		var opening_guard := int(modifiers.get("opening_guard", 0))
		for member in _party:
			if int(member.get("hp", 0)) > 0:
				member["guard"] = int(member.get("guard", 0)) + opening_guard
		var opening_damage := int(modifiers.get("opening_damage", 0))
		for enemy_index in range(_enemies.size()):
			var enemy: Dictionary = _enemies[enemy_index]
			if int(enemy.get("hp", 0)) <= 0:
				continue
			var dealt := mini(opening_damage, int(enemy.get("hp", 0)))
			enemy["hp"] = int(enemy.get("hp", 0)) - dealt
			ally_effects.append({
				"target_kind": "enemy",
				"target_index": enemy_index,
				"source_kind": "ally",
				"source_index": 0,
				"damage_type": "electric",
				"amount": dealt,
				"target_max_hp": int(enemy.get("max_hp", 1)),
				"blocked": 0,
				"critical": false,
				"magnitude": float(dealt) / float(maxi(1, int(enemy.get("max_hp", 1)))),
			})
	_commands = _empty_commands()
	_active_member = _next_unplanned_member()
	_selected_target = _first_living_enemy()
	_spawn_enemy_visuals()
	if _picket_visual != null:
		_picket_visual.hide()
	_dialogue.reset_encounter(_run_seed + _round_index, encounter_id)
	match encounter_id:
		"nursery":
			hud.push_line("HERALD", "Filing Larvae approach. They have confused record retention with digestion.")
		"cistern":
			hud.push_line("PICKET", "Pipe Goblin present. Wrench count: one. Confidence count: medically significant.")
		"office":
			hud.push_line("HERALD", "Promoted encounter: the Form Auditor has achieved management without surviving competence.")
	GameEvents.publish(&"combat.started", {"encounter_id": encounter_id, "room_id": _current_room})
	var opening_enemy_index := _first_living_enemy()
	if opening_enemy_index >= 0 and opening_enemy_index < _enemies.size() and not bool(modifiers.get("rival_enemy", false)):
		var opening_enemy: Dictionary = _enemies[opening_enemy_index]
		_present_utterance(_dialogue.enemy_opening(String(opening_enemy.get("sprite_key", "filing_larva")), String(opening_enemy.get("name", "ENEMY"))), opening_enemy_index)
	var advice := _dialogue.strategy_line()
	if not String(advice.get("line", "")).is_empty():
		hud.push_line(String(advice.get("speaker", "PARTY")).to_upper(), String(advice.get("line", "")))
	if bool(modifiers.get("ally_assist", false)):
		for utterance in _rivals.ally_assist_lines(_rival_state):
			_present_utterance(utterance)
		call_deferred("_play_ally_effects", ally_effects)
	_refresh_combat_hud()


func _build_encounter(encounter_id: String, modifiers: Dictionary = {}) -> Array:
	var ids: Array[String] = []
	match encounter_id:
		"nursery":
			ids = ["enemy.gutterbloom.filing_larva", "enemy.gutterbloom.filing_larva"]
		"cistern":
			ids = ["enemy.gutterbloom.pipe_goblin", "enemy.gutterbloom.filing_larva"]
		_:
			ids = ["enemy.gutterbloom.form_auditor", "enemy.gutterbloom.pipe_goblin", "enemy.gutterbloom.filing_larva"]
	var result: Array = []
	for index in range(ids.size()):
		var definition := Content.get_enemy(ids[index])
		result.append(_combat.create_enemy(definition, index))
	if encounter_id == "office" and bool(modifiers.get("rival_enemy", false)) and not result.is_empty():
		result[0] = _rivals.apply_rival_growth(result[0], _rival_state, modifiers)
	return result


func _on_action_selected(action: String) -> void:
	if _mode != MODE_COMBAT or _active_member < 0:
		return
	_commands[_active_member] = {"action": action, "target": _selected_target}
	GameEvents.publish(&"combat.command_planned", {
		"member_index": _active_member,
		"action": action,
		"target": _selected_target,
	})
	_active_member = _next_unplanned_member()
	_refresh_combat_hud()


func _on_target_selected(target_index: int) -> void:
	if _mode != MODE_COMBAT or target_index < 0 or target_index >= _enemies.size():
		return
	if int(_enemies[target_index].get("hp", 0)) <= 0:
		return
	_selected_target = target_index
	_refresh_combat_hud()


func _cycle_target(direction_value: int) -> void:
	if _mode != MODE_COMBAT or _enemies.is_empty():
		return
	var candidate := _selected_target
	for unused in range(_enemies.size()):
		candidate = posmod(candidate + direction_value, _enemies.size())
		if int(_enemies[candidate].get("hp", 0)) > 0:
			_selected_target = candidate
			_refresh_combat_hud()
			return


func _reset_plan() -> void:
	if _mode != MODE_COMBAT:
		return
	_commands = _empty_commands()
	_active_member = _next_unplanned_member()
	_refresh_combat_hud()


func _resolve_plan() -> void:
	if _mode != MODE_COMBAT or _active_member >= 0:
		return
	_mode = MODE_RESOLVING
	hud.set_resolving()
	for member_index in range(_commands.size()):
		var command: Dictionary = _commands[member_index]
		if String(command.get("action", "")) == CombatResolver.ACTION_TAUNT:
			var taunt_target := int(command.get("target", 0))
			if taunt_target >= 0 and taunt_target < _enemies.size():
				await _present_utterances(_dialogue.taunt(member_index, String(_enemies[taunt_target].get("name", "ENEMY"))), taunt_target)
	var equipment_laws := _equipment.compile_laws(_equipment_state, Content.all_items())
	var result := _combat.resolve_round(_party, _enemies, _commands, _round_index, _pressure_primed, equipment_laws)
	_last_round_result = result.duplicate(true)
	_party = result["party"]
	_enemies = result["enemies"]
	if result.get("environment_consumed", false):
		_pressure_primed = false
	for log_line in result.get("log", []):
		hud.push_line("RESOLVE", String(log_line))
		await get_tree().create_timer(0.08).timeout
	for raw_effect in result.get("effects", []):
		var effect: Dictionary = raw_effect
		if String(effect.get("target_kind", "")) == "party":
			await hud.play_party_hit(effect)
		else:
			await _play_enemy_hit(effect)
		await _present_utterances(_dialogue.reaction_to_effect(effect, _party, _enemies), int(effect.get("target_index", -1)) if String(effect.get("target_kind", "")) == "enemy" else -1)
	_spawn_enemy_visuals()
	GameEvents.publish(&"combat.round_resolved", {
		"round": _round_index,
		"victory": result.get("victory", false),
		"defeat": result.get("defeat", false),
	})
	if result.get("victory", false):
		_finish_victory(result)
		return
	if result.get("defeat", false):
		_recover_from_defeat()
		return
	_round_index += 1
	_commands = _empty_commands()
	_active_member = _next_unplanned_member()
	_selected_target = _first_living_enemy()
	_mode = MODE_COMBAT
	_refresh_combat_hud()


func _finish_victory(result: Dictionary = {}, noncombat: bool = false) -> void:
	_cleared_rooms[_current_room] = true
	var room_type := String(_room_data(_current_room).get("type", ""))
	if room_type == "office" and not _rivals.has_actor(_rival_state) and not noncombat:
		var promotion := _rivals.promote_form_auditor(_rival_state, _rival_defeat_context(result))
		_rival_state = promotion.get("state", _rival_state)
		for utterance in promotion.get("lines", []):
			_present_utterance(utterance, 0)
		if promotion.get("promoted", false):
			hud.push_line("PICKET", "Scrip escaped through a complaint hatch. The survival was witnessed, named, and saved without retroactive ambiguity.")
			GameEvents.publish(&"rival.promoted", {"actor_id": RivalService.ACTOR_ID, "memory": _rival_defeat_context(result)})
	if room_type == "office" and bool(_active_encounter_modifiers.get("ally_assist", false)):
		_rival_state = _rivals.complete_shared_danger(_rival_state)
		hud.push_line("SCRIP", "Shared danger survived. I object to how much that resembles trust.")
	_rival_state = _rivals.clear_pending_encounter(_rival_state)
	_clear_enemy_visuals()
	if noncombat:
		hud.push_line("PICKET", "Dialogue cleared the encounter. The critical route and baseline reward remain unchanged.")
	var reward := _reward_resolver.roll_item(Content.all_items(), _run_seed, _reward_roll_index)
	_reward_roll_index += 1
	if not reward.is_empty():
		_inventory.append(String(reward["id"]))
		GameEvents.publish(&"reward.granted", {
			"item_id": reward["id"],
			"source_room": _current_room,
			"baseline_reward": true,
		})
		hud.push_line("LOOT", "%s secured. Repeating encounters never reduces this baseline roll." % reward["display_name"])
		hud.show_reward(reward, _inventory.size())
		_mode = MODE_REWARD
	if room_type == "office":
		if noncombat:
			hud.push_line("HERALD", "The office has been closed by citation. Violence has filed a disappointed appeal.")
			hud.push_line("PICKET", "The minutes will record an accurate memory used for an almost responsible purpose.")
		elif bool(_active_encounter_modifiers.get("ally_assist", false)):
			hud.push_line("HERALD", "The replacement staff has been removed by a coalition nobody authorized and everyone survived.")
			hud.push_line("PICKET", "Shared danger is not friendship. It is, however, admissible evidence at a bar.")
		else:
			hud.push_line("HERALD", "The Auditor has been removed from office by a unanimous vote of weapons.")
			hud.push_line("PICKET", "The minutes will record a procedural disagreement and three avoidable leaks.")
	_active_encounter_modifiers.clear()
	_active_encounter_id = ""
	_save_profile(true)


func _close_reward() -> void:
	if _mode != MODE_REWARD:
		return
	hud.hide_reward()
	_mode = MODE_EXPLORATION
	_update_exploration_hud()


func _rival_defeat_context(result: Dictionary) -> Dictionary:
	var finisher_index := 0
	var finisher_damage_type := "impact"
	var result_enemies: Array = result.get("enemies", [])
	var effects: Array = result.get("effects", [])
	for reverse_index in range(effects.size() - 1, -1, -1):
		var effect: Dictionary = effects[reverse_index]
		if String(effect.get("target_kind", "")) != "enemy" or String(effect.get("source_kind", "")) != "party" or int(effect.get("amount", 0)) <= 0:
			continue
		var target_index := int(effect.get("target_index", -1))
		if target_index != 0 or target_index >= result_enemies.size() or int((result_enemies[target_index] as Dictionary).get("hp", 1)) > 0:
			continue
		finisher_index = clampi(int(effect.get("source_index", 0)), 0, maxi(0, _party.size() - 1))
		finisher_damage_type = String(effect.get("damage_type", "impact"))
		break
	var finishing_action := "strike"
	if finisher_index < _commands.size() and typeof(_commands[finisher_index]) == TYPE_DICTIONARY:
		finishing_action = String((_commands[finisher_index] as Dictionary).get("action", "strike"))
	var taunt_participated := false
	for command in _commands:
		if typeof(command) == TYPE_DICTIONARY and String((command as Dictionary).get("action", "")) == CombatResolver.ACTION_TAUNT:
			taunt_participated = true
			break
	var critical_participated := false
	for raw_effect in effects:
		if typeof(raw_effect) == TYPE_DICTIONARY and bool((raw_effect as Dictionary).get("critical", false)):
			critical_participated = true
			break
	var named_law_participated := false
	for raw_line in result.get("log", []):
		if String(raw_line).contains("activates:"):
			named_law_participated = true
			break
	return {
		"run_index": _run_index,
		"seed": _run_seed,
		"room_role": "Promoted Office",
		"finisher_member": String((_party[finisher_index] as Dictionary).get("name", "Dena")) if not _party.is_empty() else "Dena",
		"finishing_action": finishing_action,
		"damage_type": finisher_damage_type,
		"pressure_participated": bool(result.get("environment_consumed", false)),
		"taunt_participated": taunt_participated,
		"critical_participated": critical_participated,
		"named_law_participated": named_law_participated,
	}


func _recover_from_defeat() -> void:
	_defeat_count += 1
	for member in _party:
		member["hp"] = member["max_hp"]
		member["guard"] = 0
	_current_room = 0
	_facing = _initial_facing()
	_clear_enemy_visuals()
	_place_camera(false)
	_mode = MODE_EXPLORATION
	hud.push_line("HERALD", "The committee has been returned to Intake with all owned items and considerably revised confidence.")
	hud.push_line("PICKET", "No equipment was lost. The dungeon has been asked to preserve the incident for training purposes.")
	_save_profile(true)
	_update_exploration_hud()


func _open_hearthfold() -> void:
	for member in _party:
		member["hp"] = member["max_hp"]
		member["guard"] = 0
	# Keep the expedition header behind the modal synchronized with relationship
	# changes made in The Bent Pipe.
	_update_exploration_hud()
	_mode = MODE_HEARTHFOLD
	var current_actor := _rivals.actor(_rival_state)
	var relationship_line := "No recurring actor has entered the local relationship ledger."
	if not current_actor.is_empty():
		relationship_line = "%s  |  %s  |  Appearances %d  |  Bar visits %d" % [
			current_actor.get("display_name", "Scrip"),
			String(current_actor.get("posture", "unknown")).replace("_", " ").capitalize(),
			int(current_actor.get("appearance_count", 0)),
			int(current_actor.get("bar_visits", 0)),
		]
	var summary := "[center][color=#8df5e5][b]EXPEDITION SECURED[/b][/color][/center]\n\nRooms discovered: %d / 6\nCombat rooms cleared: %d / 3\nArchive items: %d\nDefeats with item loss: 0\nPlanning deadlines violated: 0\n\n[color=#f0c96f][b]GRUDGE WEB PROOF[/b][/color]\n%s\n\nThe party is fully healed. Return to this seed, visit neutral ground when available, or begin another topology with every reward retained." % [
		_visited_rooms.size(),
		_cleared_rooms.size(),
		_inventory.size(),
		relationship_line,
	]
	var bar_available := _rivals.can_visit_bar(_rival_state, _run_index)
	hud.show_hearthfold(summary, bar_available, "Scrip is available under neutral-ground rules." if bar_available else "The Bent Pipe has no new recurring-actor conversation this expedition.", not _world_state.is_empty())
	GameEvents.publish(&"hearthfold.entered", {"run_index": _run_index})
	_save_profile(true)


func _return_from_hearthfold() -> void:
	if _mode != MODE_HEARTHFOLD:
		return
	hud.hide_hearthfold()
	_mode = MODE_EXPLORATION
	_update_exploration_hud()


func _show_kingdom_map() -> void:
	_world_state = _worlds.normalize_state(_world_state)
	_world_state["active_view"] = "kingdom"
	_mode = MODE_KINGDOM
	hud.hide_hearthfold()
	hud.hide_reward()
	hud.hide_social()
	hud.hide()
	world_hud.show_kingdom(_worlds.definition, _world_cells, _world_state, _inventory.size())
	_save_profile(true)


func _show_town_map() -> void:
	_world_state = _worlds.normalize_state(_world_state)
	_world_state["active_view"] = "town"
	_mode = MODE_TOWN
	hud.hide()
	world_hud.show_town(_worlds.definition, _world_state, _inventory.size())
	_save_profile(true)


func _on_world_travel_requested(q: int, r: int) -> void:
	if _mode != MODE_KINGDOM:
		return
	var result := _worlds.travel(_world_state, Vector2i(q, r))
	_world_state = result.get("state", _world_state)
	_show_kingdom_map()
	if not bool(result.get("ok", false)):
		_show_message_service("TRAVEL NOT FILED", "Kingdom route service", String(result.get("message", "The route could not be resolved.")))


func _on_world_site_action_requested(site_id: String, action: String) -> void:
	if _mode != MODE_KINGDOM:
		return
	match action:
		"enter_town":
			_show_town_map()
		"claim_resource":
			var result := _worlds.claim_resource(_world_state, site_id)
			_world_state = result.get("state", _world_state)
			_save_profile(true)
			_show_message_service("REGIONAL COLLECTION", "Resource site remains permanently mapped", String(result.get("message", "No resource was collected.")))
		"inspect_event":
			_show_event_service(site_id)
		"enter_dungeon":
			_show_dungeon_briefing(site_id)
		"discover_lore":
			_discover_and_show_lore(site_id)
		"enter_hearthfold":
			_heal_party()
			_save_profile(true)
			world_hud.show_service(
				"HEARTHFOLD ROAD ANCHOR",
				"Portable home threshold  |  Sanctuary  |  Upgrade foundation",
				"[color=#87e8d7][b]The party is fully healed and the profile is saved.[/b][/color]\n\nThis threshold is the persistent public edge of the Hearthfold. Future upgrades attach here and follow the party between kingdoms. No storage tax, decay timer, or abandonment penalty is active.",
				[_close_option()]
			)
		"inspect_social":
			world_hud.show_service(
				"SKIP NALL'S CARAVAN REST",
				"Semi-safe social camp  |  Rumors are reported, not guaranteed",
				"Skip Nall has three parcels, five chairs, and no confidence about which category the chairs currently occupy.\n\n[color=#f0ca73][b]PICKET:[/b][/color] The camp is temporary. The relationships are not.",
				[{"label": "ASK FOR LORE SAUCE", "action": "discover_lore", "payload": {"source_id": site_id}}, _close_option()]
			)
		"inspect_shrine":
			world_hud.show_service(
				"SHRINE OF PRIOR ARRIVAL",
				"Semi-safe divine site  |  Folklore provenance",
				"The shrine requests proof that you have already arrived. The party points at itself. The shrine asks for something less argumentative.\n\nFuture god and demigod relationships will use visible favor, remembered conduct, and dialogue checks here.",
				[{"label": "REQUEST A FILED OMEN", "action": "discover_lore", "payload": {"source_id": site_id}}, _close_option()]
			)
		"inspect_border":
			world_hud.show_service(
				"EASTERN CLAIM GATE",
				"Future kingdom connection  |  Safe border site",
				"The gate is open. The paperwork is not. Additional authored kingdoms will connect here without resetting this map, its towns, or its relationships.\n\n[color=#f0ca73][b]HERALD:[/b][/color] Congratulations on reaching content that has been clearly labeled as future content.",
				[_close_option()]
			)


func _on_town_exit_requested() -> void:
	if _mode != MODE_TOWN:
		return
	_world_state["town_position"] = world_hud.town_position()
	_show_kingdom_map()


func _on_town_location_action_requested(location_id: String) -> void:
	if _mode != MODE_TOWN:
		return
	_world_state["town_position"] = world_hud.town_position()
	var location := _worlds.location_by_id(location_id)
	match String(location.get("type", "")):
		"store":
			_show_store_service()
		"guild", "quests":
			_show_quest_service(String(location.get("display_name", "CONTRACT BOARD")))
		"bar":
			_open_town_bar()
		"safe_room":
			_heal_party()
			_save_profile(true)
			world_hud.show_service(
				"ANCHOR HOUSE",
				"Safe room  |  Hearthfold threshold  |  Atomic profile verified",
				"[color=#87e8d7][b]The party is fully healed. Owned gear, purchases, map position, lore, quests, and relationships are saved.[/b][/color]\n\nFuture room upgrades will travel with the party. This foundation applies no rent, capacity gate, or upgrade loss.",
				[_close_option()]
			)
		"information":
			_discover_and_show_lore(location_id)
		_:
			world_hud.show_service(
				"COMMON ROOF PLAZA",
				"Safe social area  |  Persistent civic relationships",
				"A guild courier argues with a fungus about right-of-way while a municipal monster sells soup under a valid temporary permit. Nobody attacks because this is a social area and the soup is surprisingly good.\n\n[color=#f0ca73][b]PICKET:[/b][/color] Civilization is combat with chairs and appeal procedures.",
				[{"label": "LISTEN FOR LOCAL LORE", "action": "discover_lore", "payload": {"source_id": location_id}}, _close_option()]
			)


func _on_world_service_choice_selected(action: String, payload: Dictionary) -> void:
	match action:
		"close":
			world_hud.hide_service()
		"event_choice":
			var result := _worlds.resolve_event(_world_state, String(payload.get("site_id", "")), String(payload.get("choice_id", "")))
			_world_state = result.get("state", _world_state)
			_save_profile(true)
			_show_message_service("EVENT DECISION FILED" if bool(result.get("resolved", false)) else "EVENT LEFT AVAILABLE", "Consequences persist. Unresolved content does not expire.", String(result.get("message", "The event remains.")))
		"buy_item":
			var result := _worlds.buy_item(_world_state, String(payload.get("item_id", "")))
			_world_state = result.get("state", _world_state)
			if bool(result.get("ok", false)):
				_inventory.append(String(result.get("item_id", "")))
			_save_profile(true)
			_show_store_service(String(result.get("message", "Purchase request processed.")))
		"accept_quest":
			var result := _worlds.accept_quest(_world_state, String(payload.get("quest_id", "")))
			_world_state = result.get("state", _world_state)
			_save_profile(true)
			_show_quest_service("CONTRACT BOARD", String(result.get("message", "Contract request processed.")))
		"begin_dungeon":
			_enter_dungeon_from_world(String(payload.get("site_id", "")))
		"discover_lore":
			_discover_and_show_lore(String(payload.get("source_id", "world.service")))
		"return_kingdom":
			_show_kingdom_map()


func _show_event_service(site_id: String) -> void:
	var site := _worlds.site_by_id(site_id)
	var resolved_choice := String((_world_state.get("resolved_events", {}) as Dictionary).get(site_id, ""))
	var body := "%s\n\n[color=#9eb1b3]This situation waits indefinitely. Choices state their consequences before commitment.[/color]" % String(site.get("description", ""))
	var options: Array = []
	for raw_choice in site.get("choices", []):
		var choice: Dictionary = raw_choice
		var choice_id := String(choice.get("id", ""))
		options.append({
			"label": "%s%s" % [String(choice.get("label", "CHOOSE")).to_upper(), "  [FILED]" if choice_id == resolved_choice else ""],
			"action": "event_choice",
			"payload": {"site_id": site_id, "choice_id": choice_id},
			"disabled": not resolved_choice.is_empty(),
			"tooltip": String(choice.get("result", "")),
		})
	options.append(_close_option())
	world_hud.show_service(String(site.get("display_name", "PERSISTENT EVENT")), "Visible choice outcomes  |  No expiration", body, options)


func _show_dungeon_briefing(site_id: String) -> void:
	var site := _worlds.site_by_id(site_id)
	var quest_id := String(site.get("quest_id", ""))
	var quest := _worlds.quest_by_id(quest_id)
	var quest_status := String((_world_state.get("quests", {}) as Dictionary).get(quest_id, "not accepted"))
	world_hud.show_service(
		String(site.get("display_name", "DUNGEON")),
		"First-person shaded pixel dungeon  |  Stopped-time party combat",
		"%s\n\n[color=#f0ca73][b]%s[/b][/color]\n%s\n\nQuest status: %s\nReward contract: %s\n\nThe party returns to this exact hex. Owned items are never deleted on defeat." % [site.get("description", ""), quest.get("display_name", "REGIONAL EXPEDITION"), quest.get("summary", "Enter and return."), quest_status.replace("_", " ").capitalize(), quest.get("reward", "Baseline loot")],
		[{"label": "BEGIN NEW EXPEDITION", "action": "begin_dungeon", "payload": {"site_id": site_id}}, _close_option()]
	)


func _enter_dungeon_from_world(site_id: String) -> void:
	var result := _worlds.begin_dungeon(_world_state, site_id)
	if not bool(result.get("ok", false)):
		_show_message_service("DUNGEON ENTRY FAILED", "The route remains available", String(result.get("message", "Entry failed.")))
		return
	_world_state = result.get("state", _world_state)
	world_hud.hide_all()
	hud.show()
	_start_new_expedition(true)
	hud.push_line("PICKET", "Kingdom route anchored. The Hearthfold can return us to this exact entrance hex when the expedition is secured.")
	_save_profile(true)


func _return_to_kingdom() -> void:
	if _world_state.is_empty() or String(_world_state.get("active_view", "")) != "dungeon":
		return
	if _mode in [MODE_MOVING, MODE_RESOLVING]:
		hud.push_line("PICKET", "Extraction waits until the current motion resolves. This is physics, not policy.")
		return
	var result := _worlds.complete_dungeon_return(_world_state) if _mode == MODE_HEARTHFOLD else _worlds.leave_dungeon_early(_world_state)
	_world_state = result.get("state", _world_state)
	hud.hide_hearthfold()
	hud.hide_reward()
	hud.hide_social()
	_show_kingdom_map()
	_show_message_service("KINGDOM RETURN FILED", "Exact-position restoration  |  Zero item loss", String(result.get("message", "Returned to the kingdom.")))


func _show_store_service(notice: String = "") -> void:
	var store: Dictionary = _worlds.definition.get("store", {})
	var resources: Dictionary = _world_state.get("resources", {})
	var purchased: Array = _world_state.get("purchases", [])
	var options: Array = []
	for raw_stock in store.get("stock", []):
		var stock: Dictionary = raw_stock
		var item_id := String(stock.get("item_id", ""))
		var item := Content.get_item(item_id)
		var price := int(stock.get("price", 0))
		var owned_stock := purchased.has(item_id)
		options.append({
			"label": "%s  |  %s  |  %d MARKS%s" % [item.get("display_name", item_id), String(item.get("rarity", "common")).to_upper(), price, "  |  PURCHASED" if owned_stock else ""],
			"action": "buy_item",
			"payload": {"item_id": item_id},
			"disabled": owned_stock or int(resources.get("marks", 0)) < price,
			"tooltip": "%s  %s" % [item.get("description", ""), item.get("power_text", "")],
		})
	options.append(_close_option())
	var body := "%s%s\n\n[color=#9eb1b3]Purchases enter the uncapped Archive immediately. Stock has no real-money purchase path and does not disappear for being ignored.[/color]" % [("[color=#87e8d7]%s[/color]\n\n" % notice) if not notice.is_empty() else "", "Available Marks: %d" % int(resources.get("marks", 0))]
	world_hud.show_service(String(store.get("display_name", "GENERAL STORE")), "Regional stock  |  Inspect tooltips for powers", body, options)


func _show_quest_service(source_title: String, notice: String = "") -> void:
	var statuses: Dictionary = _world_state.get("quests", {})
	var options: Array = []
	var body_lines := PackedStringArray()
	if not notice.is_empty():
		body_lines.append("[color=#87e8d7]%s[/color]" % notice)
	for raw_quest in _worlds.definition.get("quests", []):
		var quest: Dictionary = raw_quest
		var quest_id := String(quest.get("id", ""))
		var status := String(statuses.get(quest_id, "available"))
		body_lines.append("[color=#f0ca73][b]%s[/b][/color]  [%s]\n%s\nReward: %s" % [quest.get("display_name", quest_id), status.replace("_", " ").to_upper(), quest.get("summary", ""), quest.get("reward", "")])
		options.append({
			"label": "%s  |  %s" % [quest.get("display_name", quest_id), status.replace("_", " ").to_upper()],
			"action": "accept_quest",
			"payload": {"quest_id": quest_id},
			"disabled": status != "available",
			"tooltip": "%s  Consequence: %s" % [quest.get("risk", "Risk visible"), quest.get("consequence", "Consequences persist")],
		})
	options.append(_close_option())
	world_hud.show_service(source_title.to_upper(), "Six visible opportunities  |  No real-world deadlines", "\n\n".join(body_lines), options)


func _discover_and_show_lore(source_id: String) -> void:
	var result := _worlds.discover_lore(_world_state, source_id)
	_world_state = result.get("state", _world_state)
	_save_profile(true)
	var lore: Dictionary = result.get("lore", {})
	world_hud.show_service(
		"LORE SAUCE  |  %s" % String(lore.get("category", "regional")).to_upper(),
		"Reliability: %s  |  %s" % [String(lore.get("reliability", "unknown")).to_upper(), "NEW ARCHIVE ENTRY" if bool(result.get("new", false)) else "ALREADY ARCHIVED"],
		"[color=#e8d79d][b]%s[/b][/color]\n\n[color=#82d9cc]Usable hint:[/color] %s\n\n[color=#9eb1b3]%s[/color]" % [lore.get("text", "No fragment was returned."), lore.get("hint", "No mechanical hint filed."), result.get("message", "")],
		[_close_option()]
	)


func _show_world_archive_summary() -> void:
	var unique := {}
	for item_id in _inventory:
		unique[item_id] = true
	world_hud.show_service(
		"THE ARCHIVE",
		"Uncapped persistent inventory  |  Full equipment screen available inside the dungeon",
		"Entries: %d\nUnique items: %d\nDiscovered lore: %d\n\nNothing is deleted for traveling, losing a fight, changing zones, or leaving an event unresolved. The strategic-layer equipment shortcut is scheduled after this vertical proof; all current equipment remains active and saved." % [_inventory.size(), unique.size(), (_world_state.get("discovered_lore", []) as Array).size()],
		[_close_option()]
	)


func _open_town_bar() -> void:
	if not _rivals.can_visit_bar(_rival_state, _run_index):
		world_hud.show_service(
			"THE BENT PIPE",
			"Semi-safe bar  |  Weapons checked  |  Insults unrestricted",
			"The regulars exchange route rumors, monster impressions, and one detailed theory about why the east tap is legally a demigod.\n\nNo recurring rival has a new authored conversation this expedition. The bar remains open anyway because social spaces do not exist only to dispense quests.",
			[{"label": "ASK THE REGULARS FOR LORE", "action": "discover_lore", "payload": {"source_id": "town.bent_pipe"}}, _close_option()]
		)
		return
	_world_return_view = "town"
	world_hud.hide_all()
	hud.show()
	_mode = MODE_BAR
	_social_context = "bar"
	_build_bent_pipe_world()
	_show_bent_pipe_conversation()
	_save_profile(true)


func _show_message_service(title_text: String, subtitle_text: String, message: String) -> void:
	world_hud.show_service(title_text, subtitle_text, message, [_close_option()])


func _close_option() -> Dictionary:
	return {"label": "CLOSE", "action": "close", "payload": {}}


func _heal_party() -> void:
	for member in _party:
		member["hp"] = member.get("max_hp", member.get("hp", 1))
		member["guard"] = 0


func _open_bent_pipe() -> void:
	if _mode != MODE_HEARTHFOLD or not _rivals.can_visit_bar(_rival_state, _run_index):
		hud.push_line("PICKET", "The Bent Pipe is open, but no recurring guest has filed a new conversation this expedition.")
		return
	hud.hide_hearthfold()
	_mode = MODE_BAR
	_social_context = "bar"
	_build_bent_pipe_world()
	_show_bent_pipe_conversation()
	GameEvents.publish(&"rival.bar_entered", {"actor_id": RivalService.ACTOR_ID, "run_index": _run_index})
	_save_profile(true)


func _show_bent_pipe_conversation() -> void:
	var current_actor := _rivals.actor(_rival_state)
	hud.show_social(
		"THE BENT PIPE  |  SEMI-SAFE BAR",
		"%s  |  %s  |  VIOLENCE IS OUTSIDE'S ADMINISTRATIVE PROBLEM" % [current_actor.get("display_name", "Scrip"), String(current_actor.get("posture", "unknown")).replace("_", " ").to_upper()],
		_rivals.memory_summary(_rival_state),
		_rivals.bar_opening(_rival_state),
		_rivals.bar_options(_rival_state),
		true
	)


func _close_bent_pipe() -> void:
	hud.hide_social()
	_social_context = ""
	_clear_enemy_visuals()
	_build_dungeon()
	_place_camera(false)
	if _picket_visual != null:
		_picket_visual.show()
	if _world_return_view == "town":
		_world_return_view = ""
		_show_town_map()
	else:
		_mode = MODE_HEARTHFOLD
		_open_hearthfold()


func _build_bent_pipe_world() -> void:
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.free()
	_generated_nodes.clear()
	_clear_enemy_visuals()
	var bar := Node3D.new()
	bar.name = "TheBentPipe"
	dungeon_world.add_child(bar)
	_generated_nodes.append(bar)
	var timber := Color("4b2d25")
	var brass := Color("a56f38")
	var plum := Color("3b2238")
	_add_box(bar, Vector3(0, -0.25, 0), Vector3(12, 0.5, 12), Color("261d1d"), Color.TRANSPARENT, _assets.dungeon_material(1))
	_add_box(bar, Vector3(0, 4.5, 0), Vector3(12, 0.35, 12), Color("171016"), Color.TRANSPARENT, _assets.dungeon_material(2))
	_add_box(bar, Vector3(0, 2.0, -5.8), Vector3(12, 4.5, 0.4), plum, Color.TRANSPARENT, _assets.dungeon_material(0))
	_add_box(bar, Vector3(-5.8, 2.0, 0), Vector3(0.4, 4.5, 12), timber, Color.TRANSPARENT, _assets.dungeon_material(0))
	_add_box(bar, Vector3(5.8, 2.0, 0), Vector3(0.4, 4.5, 12), timber, Color.TRANSPARENT, _assets.dungeon_material(0))
	_add_box(bar, Vector3(0, 1.15, -2.6), Vector3(7.6, 2.3, 1.0), timber, brass)
	_add_box(bar, Vector3(0, 2.38, -2.6), Vector3(8.0, 0.18, 1.25), brass, Color("c77b42"))
	for stool_x in [-2.5, -0.85, 0.85, 2.5]:
		_add_box(bar, Vector3(stool_x, 0.65, -0.55), Vector3(0.55, 1.3, 0.55), Color("3b2924"))
		_add_box(bar, Vector3(stool_x, 1.35, -0.55), Vector3(0.9, 0.18, 0.9), Color("704537"))
	for bottle_x in [-2.9, -1.9, 1.8, 2.7]:
		_add_glow_orb(bar, Vector3(bottle_x, 2.72, -2.55), Color("d46ab3") if bottle_x < 0 else Color("62d8c6"), 0.11)
	for lamp_x in [-3.4, 3.4]:
		_add_glow_orb(bar, Vector3(lamp_x, 3.55, -1.9), Color("f0a84f"), 0.30)
		var light := OmniLight3D.new()
		light.position = Vector3(lamp_x, 3.3, -1.7)
		light.light_color = Color("ffbb68")
		light.light_energy = 5.0
		light.omni_range = 7.5
		bar.add_child(light)
	var sign_label := Label3D.new()
	sign_label.text = "THE BENT PIPE\nWEAPONS CHECKED  |  STORIES SUSPECT"
	sign_label.position = Vector3(0, 3.45, -5.5)
	sign_label.font_size = 34
	sign_label.pixel_size = 0.006
	sign_label.outline_size = 8
	sign_label.modulate = Color("f2cc77")
	sign_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar.add_child(sign_label)
	camera.position = Vector3(0, CAMERA_HEIGHT, 4.2)
	camera.rotation = Vector3.ZERO
	var scrip_visual := Sprite3D.new()
	scrip_visual.position = Vector3(0.9, 2.65, -2.25)
	scrip_visual.texture = _assets.enemy_portrait("form_auditor")
	scrip_visual.pixel_size = 0.0048
	scrip_visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	scrip_visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scrip_visual.modulate = Color("ffd5a8")
	dungeon_world.add_child(scrip_visual)
	_enemy_visuals.append(scrip_visual)
	_enemy_visual_by_index[0] = scrip_visual
	if _picket_visual != null:
		_picket_visual.hide()


func _open_archive() -> void:
	if _mode in [MODE_MOVING, MODE_COMBAT, MODE_RESOLVING]:
		hud.push_line("PICKET", "The Archive does not permit wardrobe changes during an active disagreement. Finish the filed combat plan first.")
		return
	hud.set_equipment_context(_equipment_state, Content.all_items())
	hud.show_archive(Content.all_items(), _inventory, _equipment_state)


func _close_archive() -> void:
	if not hud.archive_is_open():
		return
	hud.hide_archive()
	_save_profile(true)


func _on_archive_equip_requested(item_id: String, destination_kind: String, destination_index: int) -> void:
	var result: Dictionary
	if destination_kind == "relic":
		result = _equipment.equip_relic(_equipment_state, Content.all_items(), _inventory, item_id, destination_index)
	else:
		result = _equipment.equip_member(_equipment_state, Content.all_items(), _inventory, item_id, destination_index)
	_equipment_state = result.get("state", _equipment_state)
	hud.push_line("LOOT" if result.get("ok", false) else "SYSTEM", String(result.get("message", "Equipment request failed.")))
	hud.refresh_archive(Content.all_items(), _inventory, _equipment_state)
	_save_profile(true)


func _on_archive_favorite_requested(item_id: String) -> void:
	_equipment_state = _equipment.toggle_favorite(_equipment_state, Content.all_items(), item_id)
	var item := Content.get_item(item_id)
	var now_favorite := (_equipment_state.get("favorites", []) as Array).has(item_id)
	hud.push_line("LOOT", "%s %s favorites. This changes no drop odds and consumes nothing." % [item.get("display_name", item_id), "added to" if now_favorite else "removed from"])
	hud.refresh_archive(Content.all_items(), _inventory, _equipment_state)
	_save_profile(true)


func _on_save_loadout_requested(loadout_name: String) -> void:
	var result := _equipment.save_loadout(_equipment_state, Content.all_items(), loadout_name)
	_equipment_state = result.get("state", _equipment_state)
	hud.push_line("LOOT", String(result.get("message", "Loadout save failed.")))
	hud.refresh_archive(Content.all_items(), _inventory, _equipment_state)
	_save_profile(true)


func _on_apply_loadout_requested(loadout_name: String) -> void:
	var result := _equipment.apply_loadout(_equipment_state, Content.all_items(), _inventory, loadout_name)
	_equipment_state = result.get("state", _equipment_state)
	hud.push_line("LOOT" if result.get("ok", false) else "SYSTEM", String(result.get("message", "Loadout apply failed.")))
	hud.refresh_archive(Content.all_items(), _inventory, _equipment_state)
	_save_profile(true)


func _ensure_demo_archive() -> void:
	for item_id in _equipment.starter_inventory(Content.all_items()):
		if not _inventory.has(item_id):
			_inventory.append(item_id)
	_equipment_state = _equipment.normalize_state(_equipment_state, Content.all_items())


func _on_new_expedition() -> void:
	if _mode != MODE_HEARTHFOLD:
		return
	_start_new_expedition(true)


func _refresh_combat_hud() -> void:
	var intents := _combat.enemy_intents(_enemies, _party, _round_index)
	hud.set_equipment_context(_equipment_state, Content.all_items())
	hud.set_combat(
		_party,
		_enemies,
		intents,
		_round_index,
		_active_member,
		_commands,
		_selected_target,
		_pressure_primed
	)


func _update_exploration_hud() -> void:
	var room := _room_data(_current_room)
	var current_actor := _rivals.actor(_rival_state)
	var rival_progress := ""
	if not current_actor.is_empty():
		rival_progress = "  |  Scrip %s" % String(current_actor.get("posture", "unknown")).replace("_", " ").to_upper()
	if _picket_visual != null:
		_picket_visual.show()
	hud.set_equipment_context(_equipment_state, Content.all_items())
	hud.set_exploration(
		String(room.get("title", "Unknown Room")),
		"Rooms %d / 6  |  Encounters %d / 3  |  Facing %s%s" % [_visited_rooms.size(), _cleared_rooms.size(), FACING_NAMES[_facing], rival_progress],
		_map_text(),
		_room_hint(room),
		_party,
		_inventory.size(),
		_run_seed
	)


func _room_hint(room: Dictionary) -> String:
	match String(room.get("type", "")):
		"junction":
			return "[color=#f3c968][b]OPTIONAL ENVIRONMENT[/b][/color]\n%s" % (
				"Pressure line primed for Vell's next Power." if _junction_used else "Press E to redirect pressure into a later encounter. Ignoring it never reduces rewards."
			)
		"anchor":
			return "[color=#76efdd][b]HEARTHFOLD ANCHOR[/b][/color]\nPress E to heal, save, review the run, or begin another seed."
		"intake":
			return "[color=#9cb3c2][b]SAFE INTAKE[/b][/color]\nFollow connected rooms. Time advances only during movement and explicit combat resolution."
		_:
			return "[color=#9cb3c2][b]ROOM SECURED[/b][/color]\nExplore connected passages. Combat rewards are granted automatically and cannot be missed."


func _map_text() -> String:
	var rooms: Array = _layout.get("rooms", [])
	var min_x := 0
	var max_x := 0
	var min_y := 0
	var max_y := 0
	for room in rooms:
		var coord: Vector2i = room["coord"]
		min_x = mini(min_x, coord.x)
		max_x = maxi(max_x, coord.x)
		min_y = mini(min_y, coord.y)
		max_y = maxi(max_y, coord.y)
	var lines: PackedStringArray = ["MAP  @ YOU  x CLEAR  H HOME"]
	for y in range(min_y, max_y + 1):
		var row := ""
		for x in range(min_x, max_x + 1):
			var room_index := _room_at_coord(Vector2i(x, y))
			if room_index < 0:
				row += "   "
			elif room_index == _current_room:
				row += " @ "
			elif not _visited_rooms.has(room_index):
				row += " ? "
			elif String(_room_data(room_index).get("type", "")) == "anchor":
				row += " H "
			elif _cleared_rooms.has(room_index):
				row += " x "
			else:
				row += " o "
		lines.append(row)
	return "\n".join(lines)


func _build_dungeon() -> void:
	for node in _generated_nodes:
		if is_instance_valid(node):
			node.free()
	_generated_nodes.clear()
	for room_data in _layout.get("rooms", []):
		var room: Dictionary = room_data
		var room_node := Node3D.new()
		room_node.name = "Room_%d_%s" % [int(room["id"]), String(room["type"])]
		room_node.position = _room_world_position(int(room["id"]))
		dungeon_world.add_child(room_node)
		_generated_nodes.append(room_node)
		_build_room(room_node, room)


func _build_room(parent: Node3D, room: Dictionary) -> void:
	var palette := _room_palette(String(room["type"]))
	_add_box(parent, Vector3(0, -0.25, 0), Vector3(ROOM_SIZE, 0.5, ROOM_SIZE), palette["floor"], Color.TRANSPARENT, _assets.dungeon_material(1))
	_add_box(parent, Vector3(0, 4.25, 0), Vector3(ROOM_SIZE, 0.35, ROOM_SIZE), palette["ceiling"], Color.TRANSPARENT, _assets.dungeon_material(2))
	for direction in FACING_DIRECTIONS:
		_build_wall(parent, int(room["id"]), direction, palette["wall"], _assets.dungeon_material(0))
		if direction in [Vector2i(1, 0), Vector2i(0, 1)]:
			var neighbor := _generator.neighbor_in_direction(_layout, int(room["id"]), direction)
			if neighbor >= 0:
				_build_corridor(parent, direction, palette)
	_add_room_decor(parent, String(room["type"]), palette)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 3.25, 0)
	light.light_color = palette["light"]
	light.light_energy = 5.5
	light.omni_range = 10.0
	parent.add_child(light)


func _build_wall(parent: Node3D, room_index: int, direction: Vector2i, color: Color, texture: Texture2D) -> void:
	var connected := _generator.neighbor_in_direction(_layout, room_index, direction) >= 0
	var horizontal := direction.x == 0
	var center := Vector3(direction.x * ROOM_SIZE * 0.5, 2.0, direction.y * ROOM_SIZE * 0.5)
	if not connected:
		_add_box(parent, center, Vector3(ROOM_SIZE if horizontal else 0.4, 4.5, 0.4 if horizontal else ROOM_SIZE), color, Color.TRANSPARENT, texture)
		return
	if horizontal:
		_add_box(parent, center + Vector3(-3.25, 0, 0), Vector3(3.5, 4.5, 0.4), color, Color.TRANSPARENT, texture)
		_add_box(parent, center + Vector3(3.25, 0, 0), Vector3(3.5, 4.5, 0.4), color, Color.TRANSPARENT, texture)
	else:
		_add_box(parent, center + Vector3(0, 0, -3.25), Vector3(0.4, 4.5, 3.5), color, Color.TRANSPARENT, texture)
		_add_box(parent, center + Vector3(0, 0, 3.25), Vector3(0.4, 4.5, 3.5), color, Color.TRANSPARENT, texture)


func _build_corridor(parent: Node3D, direction: Vector2i, palette: Dictionary) -> void:
	var center := Vector3(direction.x * 7.0, 0, direction.y * 7.0)
	var along_x := direction.x != 0
	_add_box(parent, center + Vector3(0, -0.25, 0), Vector3(4.0 if along_x else 3.0, 0.5, 3.0 if along_x else 4.0), palette["floor"], Color.TRANSPARENT, _assets.dungeon_material(1))
	_add_box(parent, center + Vector3(0, 4.25, 0), Vector3(4.0 if along_x else 3.0, 0.35, 3.0 if along_x else 4.0), palette["ceiling"], Color.TRANSPARENT, _assets.dungeon_material(2))
	if along_x:
		_add_box(parent, center + Vector3(0, 2, -1.5), Vector3(4.0, 4.5, 0.3), palette["wall"], Color.TRANSPARENT, _assets.dungeon_material(0))
		_add_box(parent, center + Vector3(0, 2, 1.5), Vector3(4.0, 4.5, 0.3), palette["wall"], Color.TRANSPARENT, _assets.dungeon_material(0))
	else:
		_add_box(parent, center + Vector3(-1.5, 2, 0), Vector3(0.3, 4.5, 4.0), palette["wall"], Color.TRANSPARENT, _assets.dungeon_material(0))
		_add_box(parent, center + Vector3(1.5, 2, 0), Vector3(0.3, 4.5, 4.0), palette["wall"], Color.TRANSPARENT, _assets.dungeon_material(0))


func _add_room_decor(parent: Node3D, room_type: String, palette: Dictionary) -> void:
	match room_type:
		"nursery":
			for position_value in [Vector3(-4.3, 2.6, -3.2), Vector3(4.3, 2.1, 2.6), Vector3(-3.8, 2.8, 3.9)]:
				_add_glow_orb(parent, position_value, Color("d649ae"), 0.32)
		"junction":
			_add_box(parent, Vector3(0, 1.0, -3.6), Vector3(5.2, 2.0, 0.8), Color("70513a"))
			_add_glow_orb(parent, Vector3(0, 2.0, -3.0), Color("f0a642"), 0.38)
		"cistern":
			_add_box(parent, Vector3(0, 0.02, 0), Vector3(6.0, 0.08, 5.0), Color("165f59"), Color("0b2e32"))
			_add_glow_orb(parent, Vector3(-3.5, 1.0, 3.5), Color("62e3c8"), 0.35)
		"office":
			_add_box(parent, Vector3(0, 0.25, -3.2), Vector3(5.0, 0.5, 2.2), Color("63354e"))
			_add_glow_orb(parent, Vector3(0, 1.5, -4.0), Color("c54b9a"), 0.5)
		"anchor":
			_add_box(parent, Vector3(0, 1.9, -3.8), Vector3(4.6, 3.8, 0.45), Color("102b31"), Color("2d8c85"))
			_add_box(parent, Vector3(0, 1.9, -3.5), Vector3(2.8, 2.8, 0.18), Color("1e6c68"), Color("48b9aa"))
		_:
			_add_glow_orb(parent, Vector3(0, 2.3, -3.8), palette["light"], 0.32)


func _add_box(
	parent: Node3D,
	position_value: Vector3,
	size: Vector3,
	color: Color,
	emission: Color = Color.TRANSPARENT,
	texture: Texture2D = null
) -> void:
	var instance := MeshInstance3D.new()
	instance.position = position_value
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if texture != null:
		material.albedo_texture = texture
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.roughness = 0.82
	if emission.a > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 0.72
	instance.material_override = material
	parent.add_child(instance)


func _add_glow_orb(parent: Node3D, position_value: Vector3, color: Color, radius: float) -> void:
	var instance := MeshInstance3D.new()
	instance.position = position_value
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.22)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.72
	instance.material_override = material
	parent.add_child(instance)


func _room_palette(room_type: String) -> Dictionary:
	match room_type:
		"nursery":
			return {"floor": Color("24383a"), "wall": Color("30293b"), "ceiling": Color("171b29"), "light": Color("d449ac")}
		"junction":
			return {"floor": Color("40372d"), "wall": Color("493829"), "ceiling": Color("211d1a"), "light": Color("e5a24b")}
		"cistern":
			return {"floor": Color("183538"), "wall": Color("233d40"), "ceiling": Color("101d24"), "light": Color("53d5c5")}
		"office":
			return {"floor": Color("3b2834"), "wall": Color("4a2d43"), "ceiling": Color("1f1724"), "light": Color("d34f91")}
		"anchor":
			return {"floor": Color("15373a"), "wall": Color("19464a"), "ceiling": Color("0c2024"), "light": Color("64ecd8")}
		_:
			return {"floor": Color("27343d"), "wall": Color("2d3d48"), "ceiling": Color("151e27"), "light": Color("e4a84e")}


func _spawn_enemy_visuals() -> void:
	_clear_enemy_visuals()
	var room_center := _room_world_position(_current_room)
	var forward2 := FACING_DIRECTIONS[_facing]
	var forward := Vector3(forward2.x, 0, forward2.y)
	var right := Vector3(-forward.z, 0, forward.x)
	var living_count := 0
	for enemy in _enemies:
		if int(enemy.get("hp", 0)) > 0:
			living_count += 1
	var visible_index := 0
	for enemy_index in range(_enemies.size()):
		var enemy: Dictionary = _enemies[enemy_index]
		if int(enemy.get("hp", 0)) <= 0:
			continue
		var offset := (float(visible_index) - float(living_count - 1) * 0.5) * 1.9
		var sprite := Sprite3D.new()
		sprite.position = room_center + forward * 3.1 + right * offset + Vector3(0, 1.55, 0)
		sprite.texture = _assets.enemy_portrait(String(enemy.get("sprite_key", "filing_larva")))
		sprite.pixel_size = 0.0045
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.modulate = Color.WHITE
		dungeon_world.add_child(sprite)
		_enemy_visuals.append(sprite)
		_enemy_visual_by_index[enemy_index] = sprite
		visible_index += 1


func _clear_enemy_visuals() -> void:
	for visual in _enemy_visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	_enemy_visuals.clear()
	_enemy_visual_by_index.clear()


func _play_enemy_hit(effect: Dictionary) -> void:
	var enemy_index := int(effect.get("target_index", -1))
	var sprite := _enemy_visual_by_index.get(enemy_index) as Sprite3D
	if sprite == null or not is_instance_valid(sprite):
		return
	var amount := int(effect.get("amount", 0))
	if amount <= 0:
		return
	var magnitude := clampf(float(effect.get("magnitude", 0.0)), 0.0, 1.0)
	var damage_type := String(effect.get("damage_type", "impact"))
	var base_position := sprite.position
	var base_scale := sprite.scale
	var amplitude := 0.025 + magnitude * 0.28
	var duration := 0.045 + magnitude * 0.08
	var tween := create_tween()
	match damage_type:
		"electric":
			for flash in range(2 + ceili(magnitude * 4.0)):
				var direction := -1.0 if flash % 2 == 0 else 1.0
				tween.tween_property(sprite, "position", base_position + Vector3(direction * amplitude, amplitude * 0.4, 0), duration * 0.55)
				tween.parallel().tween_property(sprite, "modulate", Color("7eefff") if flash % 2 == 0 else Color("fff39b"), duration * 0.4)
		"decay", "acid":
			tween.tween_property(sprite, "modulate", Color("c267e4") if damage_type == "decay" else Color("7ce35a"), duration * 1.5)
			tween.parallel().tween_property(sprite, "scale", base_scale * (1.0 - magnitude * 0.12), duration * 1.5)
		"slash":
			tween.tween_property(sprite, "position", base_position + Vector3(-amplitude, amplitude * 0.35, 0), duration)
			tween.parallel().tween_property(sprite, "modulate", Color("ff8585"), duration)
		_:
			tween.tween_property(sprite, "position", base_position + Vector3(amplitude, 0, 0), duration)
			tween.parallel().tween_property(sprite, "scale", base_scale * (1.0 + magnitude * 0.18), duration)
	if bool(effect.get("critical", false)):
		tween.parallel().tween_property(sprite, "scale", base_scale * 1.28, duration)
		tween.parallel().tween_property(sprite, "modulate", Color("fff1a2"), duration)
	tween.tween_property(sprite, "position", base_position, duration)
	tween.parallel().tween_property(sprite, "scale", base_scale, duration * 1.4)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, duration * 1.4)
	await tween.finished


func _play_ally_effects(effects: Array) -> void:
	for raw_effect in effects:
		if typeof(raw_effect) == TYPE_DICTIONARY:
			await _play_enemy_hit(raw_effect)


func _present_utterances(utterances: Array, enemy_index: int = -1) -> void:
	for raw_utterance in utterances:
		if typeof(raw_utterance) != TYPE_DICTIONARY:
			continue
		_present_utterance(raw_utterance, enemy_index)
		await get_tree().create_timer(0.34).timeout


func _present_utterance(utterance: Dictionary, enemy_index: int = -1) -> void:
	var line := String(utterance.get("line", ""))
	if line.is_empty():
		return
	var speaker := String(utterance.get("speaker", "VOICE"))
	hud.push_line(speaker.to_upper(), line)
	if String(utterance.get("kind", "party")) == "enemy" and enemy_index >= 0:
		_show_enemy_speech(enemy_index, line)


func _show_enemy_speech(enemy_index: int, line: String) -> void:
	var sprite := _enemy_visual_by_index.get(enemy_index) as Sprite3D
	if sprite == null or not is_instance_valid(sprite):
		return
	var speech := Label3D.new()
	speech.text = line
	speech.position = sprite.position + Vector3(0, 2.25, 0)
	speech.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	speech.no_depth_test = true
	speech.font_size = 30
	speech.pixel_size = 0.0052
	speech.outline_size = 8
	speech.modulate = Color("fff0b5")
	speech.width = 680.0
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dungeon_world.add_child(speech)
	var tween := create_tween()
	tween.tween_interval(1.7)
	tween.tween_property(speech, "modulate", Color("fff0b500"), 0.35)
	tween.tween_callback(speech.queue_free)


func _attach_picket_to_camera() -> void:
	var picket := Sprite3D.new()
	picket.name = "Picket"
	picket.position = Vector3(1.9, -0.98, -2.8)
	picket.texture = _sprite_factory.picket_texture()
	picket.pixel_size = 0.012
	picket.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	picket.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	picket.no_depth_test = true
	camera.add_child(picket)
	_picket_visual = picket


func _empty_commands() -> Array:
	var result: Array = []
	for member in _party:
		result.append({} if int(member.get("hp", 0)) > 0 else {"action": "skip", "target": 0})
	return result


func _next_unplanned_member() -> int:
	for index in range(_party.size()):
		if int(_party[index].get("hp", 0)) > 0 and (commands_empty_at(index)):
			return index
	return -1


func commands_empty_at(index: int) -> bool:
	return index >= _commands.size() or typeof(_commands[index]) != TYPE_DICTIONARY or (_commands[index] as Dictionary).is_empty()


func _first_living_enemy() -> int:
	for index in range(_enemies.size()):
		if int(_enemies[index].get("hp", 0)) > 0:
			return index
	return 0


func _initial_facing() -> int:
	var direction := _generator.connection_direction(_layout, 0, 1)
	return maxi(0, FACING_DIRECTIONS.find(direction))


func _place_camera(animate: bool) -> void:
	var position_value := _room_world_position(_current_room) + Vector3(0, CAMERA_HEIGHT, 0)
	var rotation_value := Vector3(0, _facing_yaw(_facing), 0)
	if not animate:
		camera.position = position_value
		camera.rotation = rotation_value


func _facing_yaw(facing_index: int) -> float:
	var direction := FACING_DIRECTIONS[facing_index]
	return atan2(-float(direction.x), -float(direction.y))


func _room_world_position(room_index: int) -> Vector3:
	var coord: Vector2i = _room_data(room_index).get("coord", Vector2i.ZERO)
	return Vector3(coord.x * ROOM_SPACING, 0, coord.y * ROOM_SPACING)


func _room_data(room_index: int) -> Dictionary:
	var rooms: Array = _layout.get("rooms", [])
	if room_index < 0 or room_index >= rooms.size():
		return {}
	return rooms[room_index]


func _room_at_coord(coord: Vector2i) -> int:
	for room in _layout.get("rooms", []):
		if (room as Dictionary).get("coord", Vector2i.ZERO) == coord:
			return int((room as Dictionary).get("id", -1))
	return -1


func _save_profile(automatic: bool) -> void:
	if _layout.is_empty():
		return
	var profile := {
		"mode": PROFILE_MODE,
		"run": {
			"seed": _run_seed,
			"run_index": _run_index,
			"current_room": _current_room,
			"facing": _facing,
			"reward_roll_index": _reward_roll_index,
			"defeat_count": _defeat_count,
			"cleared_rooms": _cleared_rooms.keys(),
			"visited_rooms": _visited_rooms.keys(),
			"junction_used": _junction_used,
			"pressure_primed": _pressure_primed,
		},
		"party": _party.duplicate(true),
		"inventory": _inventory.duplicate(),
		"equipment": _equipment_state.duplicate(true),
		"rival": _rival_state.duplicate(true),
		"world": _world_state.duplicate(true),
	}
	var result := Saves.write_atomic(profile)
	if not result.get("ok", false):
		hud.push_line("SYSTEM", "Save failed: %s" % result.get("message", "Unknown error"))
	elif not automatic:
		hud.push_line("SYSTEM", "Atomic profile save verified.")


func _load_crawler_profile(report_result: bool) -> bool:
	var result := Saves.load_profile()
	if not result.get("ok", false):
		if report_result:
			hud.push_line("SYSTEM", "No valid crawler profile is available.")
		return false
	var data: Dictionary = result.get("data", {})
	if String(data.get("mode", "")) != PROFILE_MODE:
		for item_id in data.get("inventory", []):
			_inventory.append(String(item_id))
		if report_result:
			hud.push_line("SYSTEM", "Historical action-spike save detected. Its inventory was imported into a new crawler expedition.")
		return false
	var run: Dictionary = data.get("run", {})
	_run_seed = int(run.get("seed", BASE_RUN_SEED))
	_run_index = int(run.get("run_index", 0))
	_current_room = int(run.get("current_room", 0))
	_facing = clampi(int(run.get("facing", 0)), 0, 3)
	_reward_roll_index = int(run.get("reward_roll_index", 0))
	_defeat_count = int(run.get("defeat_count", 0))
	_junction_used = bool(run.get("junction_used", false))
	_pressure_primed = bool(run.get("pressure_primed", false))
	_cleared_rooms.clear()
	for room_id in run.get("cleared_rooms", []):
		_cleared_rooms[int(room_id)] = true
	_visited_rooms.clear()
	for room_id in run.get("visited_rooms", []):
		_visited_rooms[int(room_id)] = true
	_layout = _generator.generate(_run_seed, 6)
	_party = data.get("party", _combat.create_default_party())
	if _party.size() != 4:
		_party = _combat.create_default_party()
	_inventory.clear()
	for item_id in data.get("inventory", []):
		_inventory.append(String(item_id))
	_ensure_demo_archive()
	_equipment_state = _equipment.normalize_state(data.get("equipment", _equipment_state), Content.all_items())
	_rival_state = _rivals.normalize_state(data.get("rival", _rival_state))
	_world_state = _worlds.normalize_state(data.get("world", {}))
	_social_context = ""
	_active_encounter_id = ""
	_active_encounter_modifiers.clear()
	_last_round_result.clear()
	_clear_enemy_visuals()
	_build_dungeon()
	_place_camera(false)
	hud.hide_hearthfold()
	hud.hide_reward()
	hud.hide_social()
	_mode = MODE_EXPLORATION
	hud.clear_feed()
	hud.push_line("SYSTEM", "Crawler profile restored%s." % (" from backup" if result.get("recovered_from_backup", false) else ""))
	match String(_world_state.get("active_view", "kingdom")):
		"town":
			_show_town_map()
		"dungeon":
			world_hud.hide_all()
			hud.show()
			_enter_current_room()
		_:
			_show_kingdom_map()
	return true
