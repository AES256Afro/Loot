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

var _generator := DungeonGenerator.new()
var _combat := CombatResolver.new()
var _reward_resolver := DeterministicRewardResolver.new()
var _sprite_factory := PixelSpriteFactory.new()
var _equipment := EquipmentService.new()
var _assets := GeneratedAssetLibrary.new()
var _dialogue := ReactiveDialogue.new()

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
var _generated_nodes: Array[Node] = []
var _enemy_visuals: Array[Sprite3D] = []
var _enemy_visual_by_index: Dictionary = {}
var _picket_visual: Sprite3D


func _ready() -> void:
	_connect_hud()
	if not Content.load_all():
		for content_error in Content.last_errors:
			push_error(content_error)
		hud.push_line("SYSTEM", "Content failed validation. Run tools/check.sh.")
		return
	_equipment_state = _equipment.create_default_state(Content.all_items())
	for dialogue_error in _dialogue.validate():
		push_error(dialogue_error)
		hud.push_line("SYSTEM", dialogue_error)
	_attach_picket_to_camera()
	if not _load_crawler_profile(false):
		_start_new_expedition(false)


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
		if event.physical_keycode in [KEY_I, KEY_ESCAPE]:
			if hud.archive_is_open():
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
	hud.archive_requested.connect(_open_archive)
	hud.archive_closed.connect(_close_archive)
	hud.archive_equip_requested.connect(_on_archive_equip_requested)
	hud.archive_favorite_requested.connect(_on_archive_favorite_requested)
	hud.save_loadout_requested.connect(_on_save_loadout_requested)
	hud.apply_loadout_requested.connect(_on_apply_loadout_requested)


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
	hud.clear_feed()
	hud.push_line("HERALD", "A four-person Claimant committee has entered the Gutterbloom. Consensus is not expected.")
	hud.push_line("PICKET", "The route contains six rooms and at least seven violations. The difference is structural creativity.")
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
		_start_combat(encounter_id)
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


func _start_combat(encounter_id: String) -> void:
	_mode = MODE_COMBAT
	_round_index = 1
	_enemies = _build_encounter(encounter_id)
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
	if opening_enemy_index >= 0 and opening_enemy_index < _enemies.size():
		var opening_enemy: Dictionary = _enemies[opening_enemy_index]
		_present_utterance(_dialogue.enemy_opening(String(opening_enemy.get("sprite_key", "filing_larva")), String(opening_enemy.get("name", "ENEMY"))), opening_enemy_index)
	var advice := _dialogue.strategy_line()
	if not String(advice.get("line", "")).is_empty():
		hud.push_line(String(advice.get("speaker", "PARTY")).to_upper(), String(advice.get("line", "")))
	_refresh_combat_hud()


func _build_encounter(encounter_id: String) -> Array:
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
		_finish_victory()
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


func _finish_victory() -> void:
	_cleared_rooms[_current_room] = true
	_clear_enemy_visuals()
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
	if String(_room_data(_current_room).get("type", "")) == "office":
		hud.push_line("HERALD", "The Auditor has been removed from office by a unanimous vote of weapons.")
		hud.push_line("PICKET", "The minutes will record a procedural disagreement and three avoidable leaks.")
	_save_profile(true)


func _close_reward() -> void:
	if _mode != MODE_REWARD:
		return
	hud.hide_reward()
	_mode = MODE_EXPLORATION
	_update_exploration_hud()


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
	_mode = MODE_HEARTHFOLD
	var summary := "[center][color=#8df5e5][b]EXPEDITION SECURED[/b][/color][/center]\n\nRooms discovered: %d / 6\nCombat rooms cleared: %d / 3\nArchive items: %d\nDefeats with item loss: 0\nPlanning deadlines violated: 0\n\nThe party is fully healed. Return to inspect this seed, or begin a new deterministic topology while retaining every reward." % [
		_visited_rooms.size(),
		_cleared_rooms.size(),
		_inventory.size(),
	]
	hud.show_hearthfold(summary)
	GameEvents.publish(&"hearthfold.entered", {"run_index": _run_index})
	_save_profile(true)


func _return_from_hearthfold() -> void:
	if _mode != MODE_HEARTHFOLD:
		return
	hud.hide_hearthfold()
	_mode = MODE_EXPLORATION
	_update_exploration_hud()


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
	if _picket_visual != null:
		_picket_visual.show()
	hud.set_equipment_context(_equipment_state, Content.all_items())
	hud.set_exploration(
		String(room.get("title", "Unknown Room")),
		"Rooms %d / 6  |  Encounters %d / 3  |  Facing %s" % [_visited_rooms.size(), _cleared_rooms.size(), FACING_NAMES[_facing]],
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
	_clear_enemy_visuals()
	_build_dungeon()
	_place_camera(false)
	hud.hide_hearthfold()
	hud.hide_reward()
	_mode = MODE_EXPLORATION
	hud.clear_feed()
	hud.push_line("SYSTEM", "Crawler profile restored%s." % (" from backup" if result.get("recovered_from_backup", false) else ""))
	_enter_current_room()
	return true
