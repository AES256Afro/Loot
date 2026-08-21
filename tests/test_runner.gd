extends SceneTree

const TEST_SAVE_PATH := "user://test_artifacts/atomic_save_test.json"

var _failures: Array[String] = []
var _assertion_count := 0


func _initialize() -> void:
	print("LOOT foundation tests")
	_test_content_registry()
	_test_deterministic_reward_resolution()
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
	_assert(registry.call("load_all"), "Authored spike item document validates.")
	var items: Dictionary = registry.get("item_definitions")
	_assert(items.size() == 3, "All three spike items enter the registry.")
	_assert(items.has("item.spike.pearl_of_the_unbothered_drain"), "Legendary definition is addressable by immutable ID.")
	var invalid_document := registry.call("load_json_document", "res://content/items/spike_rewards.json") as Dictionary
	var invalid_items: Array = invalid_document["items"]
	invalid_items.append((invalid_items[0] as Dictionary).duplicate(true))
	var errors: PackedStringArray = registry.call("validate_item_document", invalid_document)
	_assert(not errors.is_empty(), "Duplicate immutable item IDs fail validation.")
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
