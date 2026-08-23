extends SceneTree

const TEST_SAVE_PATH := "user://test_artifacts/atomic_save_test.json"

var _failures: Array[String] = []
var _assertion_count := 0


func _initialize() -> void:
	print("LOOT crawler foundation tests")
	_test_content_registry()
	_test_deterministic_reward_resolution()
	_test_dungeon_generation()
	_test_stopped_time_combat()
	_test_equipment_changes_the_party()
	_test_reactive_dialogue()
	_test_pixel_sprite_factory()
	_test_event_stream()
	_test_atomic_save_and_backup_recovery()
	if _failures.is_empty():
		print("TESTS PASSED: %d assertions." % _assertion_count)
		quit(0)
		return
	printerr("TESTS FAILED: %d of %d assertions." % [_failures.size(), _assertion_count])
	for failure in _failures:
		printerr("  - %s" % failure)
	quit(1)


func _test_content_registry() -> void:
	var registry_script := load("res://scripts/content/content_registry.gd")
	_assert(registry_script != null, "Content registry script loads.")
	if registry_script == null:
		return
	var registry: Node = registry_script.new()
	_assert(registry.call("load_all"), "Authored item and enemy documents validate.")
	var items: Dictionary = registry.get("item_definitions")
	var enemies: Dictionary = registry.get("enemy_definitions")
	_assert(items.size() == 35, "All 32 crawler equipment items and three foundation rewards enter the registry.")
	_assert(enemies.size() == 3, "All three crawler enemies enter the registry.")
	_assert(items.has("item.spike.pearl_of_the_unbothered_drain"), "Legendary definition is addressable by immutable ID.")
	_assert(enemies.has("enemy.gutterbloom.form_auditor"), "Promoted enemy definition is addressable by immutable ID.")
	var invalid_document := registry.call("load_json_document", "res://content/items/spike_rewards.json") as Dictionary
	var invalid_items: Array = invalid_document["items"]
	invalid_items.append((invalid_items[0] as Dictionary).duplicate(true))
	var errors: PackedStringArray = registry.call("validate_item_document", invalid_document)
	_assert(not errors.is_empty(), "Duplicate immutable item IDs fail validation.")
	var invalid_enemy_document := registry.call("load_json_document", "res://content/enemies/crawler_enemies.json") as Dictionary
	var invalid_enemies: Array = invalid_enemy_document["enemies"]
	invalid_enemies.append((invalid_enemies[0] as Dictionary).duplicate(true))
	var enemy_errors: PackedStringArray = registry.call("validate_enemy_document", invalid_enemy_document)
	_assert(not enemy_errors.is_empty(), "Duplicate immutable enemy IDs fail validation.")
	registry.free()


func _test_deterministic_reward_resolution() -> void:
	var registry_script := load("res://scripts/content/content_registry.gd")
	var registry: Node = registry_script.new()
	registry.call("load_all")
	var resolver := DeterministicRewardResolver.new()
	var first := resolver.roll_item(registry.get("item_definitions"), 442_901, 7)
	var repeated := resolver.roll_item(registry.get("item_definitions"), 442_901, 7)
	_assert(not first.is_empty(), "Seeded reward resolver returns an item.")
	_assert(first.get("id") == repeated.get("id"), "Same seed and roll index return the same item.")
	registry.free()


func _test_dungeon_generation() -> void:
	var generator := DungeonGenerator.new()
	var layout := generator.generate(442_901)
	var repeated := generator.generate(442_901)
	var rooms: Array = layout.get("rooms", [])
	var connections: Array = layout.get("connections", [])
	_assert(rooms.size() == 6, "Crawler expedition generates six authored-role rooms.")
	_assert(connections.size() == 5, "Six-room expedition is connected by a minimal spanning tree.")
	_assert(generator.signature(layout) == generator.signature(repeated), "Same expedition seed produces the same dungeon signature.")
	var occupied := {}
	var ordered_roles: PackedStringArray = []
	for room in rooms:
		var data: Dictionary = room
		occupied[data["coord"]] = true
		ordered_roles.append(String(data["type"]))
	_assert(occupied.size() == rooms.size(), "Generated dungeon never overlaps room coordinates.")
	_assert(ordered_roles == PackedStringArray(["intake", "nursery", "junction", "cistern", "office", "anchor"]), "Procedural topology preserves the expedition's authored room cadence.")
	var ordered_path := true
	for index in range(connections.size()):
		var ordered_edge: Dictionary = connections[index]
		if int(ordered_edge["a"]) != index or int(ordered_edge["b"]) != index + 1:
			ordered_path = false
	_assert(ordered_path, "Generated critical path cannot expose the Hearthfold before its authored encounters.")
	var reached := {0: true}
	var changed := true
	while changed:
		changed = false
		for connection in connections:
			var edge: Dictionary = connection
			var a := int(edge["a"])
			var b := int(edge["b"])
			if reached.has(a) and not reached.has(b):
				reached[b] = true
				changed = true
			elif reached.has(b) and not reached.has(a):
				reached[a] = true
				changed = true
	_assert(reached.size() == rooms.size(), "Every generated room is reachable from the intake.")
	var first_edge: Dictionary = connections[0]
	var direction := generator.connection_direction(layout, int(first_edge["a"]), int(first_edge["b"]))
	_assert(generator.neighbor_in_direction(layout, int(first_edge["a"]), direction) == int(first_edge["b"]), "Cardinal navigation resolves a connected neighbor.")
	_assert(generator.neighbor_in_direction(layout, int(first_edge["b"]), -direction) == int(first_edge["a"]), "Cardinal navigation resolves the return path.")


func _test_stopped_time_combat() -> void:
	var resolver := CombatResolver.new()
	var party := resolver.create_default_party()
	_assert(party.size() == 4, "Default crawler party contains four distinct roles.")
	var enemy_definition := {
		"id": "enemy.test.pipe_goblin",
		"display_name": "Test Goblin",
		"max_hp": 14,
		"damage": 4,
		"sprite_key": "pipe_goblin",
	}
	var enemy := resolver.create_enemy(enemy_definition, 0)
	var intents := resolver.enemy_intents([enemy], party, 1)
	_assert(intents.size() == 1, "Enemy intent is visible before a combat round resolves.")
	_assert(String(intents[0].get("text", "")).contains("intends"), "Visible intent identifies the planned enemy action.")
	var guard_commands := [
		{"action": CombatResolver.ACTION_GUARD, "target": 0},
		{"action": CombatResolver.ACTION_GUARD, "target": 0},
		{"action": CombatResolver.ACTION_GUARD, "target": 0},
		{"action": CombatResolver.ACTION_GUARD, "target": 0},
	]
	var party_snapshot := party.duplicate(true)
	var enemy_snapshot := enemy.duplicate(true)
	var guarded := resolver.resolve_round(party, [enemy], guard_commands, 1, false)
	var guarded_repeat := resolver.resolve_round(party, [enemy], guard_commands, 1, false)
	_assert(guarded == guarded_repeat, "Identical stopped-time plans resolve deterministically.")
	_assert(party == party_snapshot and enemy == enemy_snapshot, "Combat resolution does not mutate planning inputs.")
	var guarded_party: Array = guarded["party"]
	_assert(int(guarded_party[0].get("hp", 0)) >= int(party[0].get("hp", 0)) - 1, "Guard reduces the declared four-damage enemy hit by three.")
	var pressure_enemies := [
		resolver.create_enemy(enemy_definition, 0),
		resolver.create_enemy(enemy_definition, 1),
	]
	var pressure_commands := guard_commands.duplicate(true)
	pressure_commands[2] = {"action": CombatResolver.ACTION_POWER, "target": 0}
	var pressure_result := resolver.resolve_round(party, pressure_enemies, pressure_commands, 1, true)
	var damaged_enemies: Array = pressure_result["enemies"]
	_assert(pressure_result.get("environment_consumed", false), "Vell can consume a primed environmental pressure line.")
	_assert(int(damaged_enemies[0]["hp"]) == 9 and int(damaged_enemies[1]["hp"]) == 9, "Pressure-line power damages every living enemy once.")
	var fragile_enemy := resolver.create_enemy(enemy_definition, 2)
	fragile_enemy["hp"] = 3
	var victory := resolver.resolve_round(party, [fragile_enemy], [{"action": CombatResolver.ACTION_STRIKE, "target": 0}], 1, false)
	_assert(victory.get("victory", false), "Party victory resolves before defeated enemies can retaliate.")
	var fragile_party := resolver.create_default_party()
	for member in fragile_party:
		member["hp"] = 1
	var lethal_definition := enemy_definition.duplicate(true)
	lethal_definition["damage"] = 100
	var lethal_enemies: Array = []
	for index in range(4):
		lethal_enemies.append(resolver.create_enemy(lethal_definition, index))
	var defeat := resolver.resolve_round(fragile_party, lethal_enemies, guard_commands, 1, false)
	_assert(defeat.get("defeat", false), "Full party defeat is reported without deleting progression state.")
	var electric_definition := enemy_definition.duplicate(true)
	electric_definition["damage_type"] = "electric"
	var electric_enemy := resolver.create_enemy(electric_definition, 9)
	var taunt_commands := guard_commands.duplicate(true)
	taunt_commands[3] = {"action": CombatResolver.ACTION_TAUNT, "target": 0}
	var taunted := resolver.resolve_round(party, [electric_enemy], taunt_commands, 1, false)
	var taunted_effects: Array = taunted.get("effects", [])
	var found_electric_ilex_hit := false
	for raw_effect in taunted_effects:
		var effect: Dictionary = raw_effect
		if String(effect.get("target_kind", "")) == "party" and int(effect.get("target_index", -1)) == 3 and String(effect.get("damage_type", "")) == "electric":
			found_electric_ilex_hit = true
	_assert(found_electric_ilex_hit, "Taunt changes the declared target and preserves the enemy's electrical damage type for presentation.")


func _test_equipment_changes_the_party() -> void:
	var registry_script := load("res://scripts/content/content_registry.gd")
	var registry: Node = registry_script.new()
	registry.call("load_all")
	var definitions: Dictionary = registry.get("item_definitions")
	var equipment := EquipmentService.new()
	var inventory := equipment.starter_inventory(definitions)
	var state := equipment.create_default_state(definitions)
	_assert(inventory.size() == 32, "The proof Archive begins with all 32 crawler equipment definitions and has no capacity gate.")
	_assert((state.get("members", []) as Array).size() == 4 and (state.get("relics", []) as Array).size() == 2, "Equipment state provides four members and two Shared Relic slots.")
	_assert(equipment.equipped_item_ids(state).size() == 18, "Each member starts with four equipped items and the party starts with two relics.")
	var laws_a := equipment.compile_laws(state, definitions)
	_assert((laws_a.get("entries", []) as Array).size() == 18, "Equipped items compile into 18 deterministic law entries.")
	var incompatible := equipment.equip_member(state, definitions, inventory, "item.gutterbloom.denas_union_edge", 1)
	_assert(not incompatible.get("ok", true), "A role-locked Dena weapon cannot be equipped by Moss.")
	var favorited := equipment.toggle_favorite(state, definitions, "item.gutterbloom.denas_union_edge")
	_assert((favorited.get("favorites", []) as Array).has("item.gutterbloom.denas_union_edge"), "Archive favorites persist in equipment state without consuming the item.")
	var saved := equipment.save_loadout(favorited, definitions, "A")
	_assert(saved.get("ok", false), "Loadout A snapshots the current equipment state.")
	var applied_b := equipment.apply_loadout(saved.get("state", {}), definitions, inventory, "B")
	_assert(applied_b.get("ok", false) and String((applied_b.get("state", {}) as Dictionary).get("active_loadout", "")) == "B", "Supplied Loadout B applies from the persistent Archive.")
	var resolver := CombatResolver.new()
	var enemy_definition := {"id": "enemy.test.auditor", "display_name": "Training Auditor", "max_hp": 60, "damage": 6, "damage_type": "electric", "sprite_key": "form_auditor"}
	var enemies := [resolver.create_enemy(enemy_definition, 0), resolver.create_enemy(enemy_definition, 1), resolver.create_enemy(enemy_definition, 2)]
	var commands := [
		{"action": CombatResolver.ACTION_GUARD, "target": 0},
		{"action": CombatResolver.ACTION_POWER, "target": 0},
		{"action": CombatResolver.ACTION_POWER, "target": 1},
		{"action": CombatResolver.ACTION_UTILITY, "target": 2},
	]
	var result_a := resolver.resolve_round(resolver.create_default_party(), enemies, commands, 1, true, laws_a)
	var laws_b := equipment.compile_laws(applied_b.get("state", {}), definitions)
	var result_b := resolver.resolve_round(resolver.create_default_party(), enemies, commands, 1, true, laws_b)
	_assert(result_a != result_b, "Municipal Phalanx and Burst Pipe Choir produce different state and traces from the same encounter plan.")
	_assert(String("\n".join(result_a.get("log", []))).contains("activates:"), "Combat traces name activated equipment instead of hiding its contribution.")
	registry.free()


func _test_reactive_dialogue() -> void:
	var dialogue := ReactiveDialogue.new()
	_assert(dialogue.validate().is_empty(), "Reactive combat dialogue validates its required categories and authored inventory.")
	_assert(dialogue.line_count() >= 120, "Reactive combat dialogue contains at least 120 authored lines and exchanges.")
	dialogue.reset_encounter(81_231, "office")
	var first := dialogue.enemy_opening("form_auditor", "Form Auditor")
	dialogue.reset_encounter(81_231, "office")
	var repeated := dialogue.enemy_opening("form_auditor", "Form Auditor")
	_assert(first == repeated and not String(first.get("line", "")).is_empty(), "The same encounter context selects the same non-empty monster opening.")
	var electric_reactions := dialogue.reaction_to_effect({"target_kind": "party", "target_index": 2, "damage_type": "electric", "amount": 6, "magnitude": 0.32}, CombatResolver.new().create_default_party(), [])
	_assert(not electric_reactions.is_empty() and String(electric_reactions[0].get("speaker", "")) == "Vell", "Electrical damage selects a victim-specific reaction instead of a generic hit line.")
	var taunts := dialogue.taunt(1, "Form Auditor")
	_assert(taunts.size() >= 2 and String(taunts[1].get("kind", "")) == "enemy", "Taunt produces party dialogue and an enemy response while changing combat state separately.")


func _test_pixel_sprite_factory() -> void:
	var factory := PixelSpriteFactory.new()
	for sprite_key in ["filing_larva", "pipe_goblin", "form_auditor"]:
		var texture := factory.enemy_texture(sprite_key)
		var image := texture.get_image()
		_assert(image.get_width() == 32 and image.get_height() == 40, "%s sprite uses the 32 by 40 low-resolution canvas." % sprite_key)
		_assert(not image.is_invisible(), "%s sprite contains visible shaded pixels." % sprite_key)
	var picket := factory.picket_texture().get_image()
	_assert(picket.get_width() == 32 and picket.get_height() == 40 and not picket.is_invisible(), "Picket portrait is generated as visible low-resolution art.")


func _test_event_stream() -> void:
	var stream_script := load("res://scripts/core/event_stream.gd")
	_assert(stream_script != null, "Event stream script loads.")
	if stream_script == null:
		return
	var stream: Node = stream_script.new()
	var observed: Array[Dictionary] = []
	stream.event_emitted.connect(func(event: Dictionary) -> void: observed.append(event))
	var published: Dictionary = stream.call("publish", &"test.event", {"value": 3})
	_assert(published.get("type") == "test.event", "Published event retains its canonical type.")
	_assert(observed.size() == 1, "Event subscribers observe one publication.")
	_assert((observed[0].get("payload", {}) as Dictionary).get("value") == 3, "Event payload is preserved.")
	stream.free()


func _test_atomic_save_and_backup_recovery() -> void:
	_cleanup_test_save()
	var save_script := load("res://scripts/save/save_service.gd")
	_assert(save_script != null, "Save service script loads.")
	if save_script == null:
		return
	var service: Node = save_script.new()
	var first_write: Dictionary = service.call("write_atomic", {"marker": "first", "inventory": ["a"]}, TEST_SAVE_PATH)
	_assert(first_write.get("ok", false), "First atomic save commits.")
	var second_write: Dictionary = service.call("write_atomic", {"marker": "second", "inventory": ["a", "b"]}, TEST_SAVE_PATH)
	_assert(second_write.get("ok", false), "Second atomic save commits and rotates a backup.")
	_assert(FileAccess.file_exists(TEST_SAVE_PATH + ".bak"), "Prior valid save exists as a backup.")
	var loaded: Dictionary = service.call("load_profile", TEST_SAVE_PATH)
	_assert(loaded.get("ok", false), "Committed primary save loads.")
	_assert((loaded.get("data", {}) as Dictionary).get("marker") == "second", "Primary save contains the newest transaction.")
	var corrupt_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	if corrupt_file != null:
		corrupt_file.store_string("{not valid json")
		corrupt_file.flush()
		corrupt_file.close()
	var recovered: Dictionary = service.call("load_profile", TEST_SAVE_PATH)
	_assert(recovered.get("ok", false), "Invalid primary save recovers through its backup.")
	_assert(recovered.get("recovered_from_backup", false), "Recovery result identifies backup use.")
	_assert((recovered.get("data", {}) as Dictionary).get("marker") == "first", "Recovery returns the last rotated valid transaction.")
	service.free()
	_cleanup_test_save()


func _cleanup_test_save() -> void:
	for suffix in ["", ".tmp", ".bak"]:
		var path: String = TEST_SAVE_PATH + String(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _assert(condition: bool, message: String) -> void:
	_assertion_count += 1
	if condition:
		print("  PASS  %s" % message)
	else:
		_failures.append(message)
