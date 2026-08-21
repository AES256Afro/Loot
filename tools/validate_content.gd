extends SceneTree


func _initialize() -> void:
	var registry_script := load("res://scripts/content/content_registry.gd")
	if registry_script == null:
		printerr("CONTENT VALIDATION FAILED: could not load registry script.")
		quit(1)
		return
	var registry: Node = registry_script.new()
	var valid: bool = registry.call("load_all")
	var errors: PackedStringArray = registry.get("last_errors")
	if not valid:
		printerr("CONTENT VALIDATION FAILED")
		for validation_error in errors:
			printerr("  - %s" % validation_error)
		registry.free()
		quit(1)
		return
	var definitions: Dictionary = registry.get("item_definitions")
	print("CONTENT VALIDATION PASSED: %d spike item definitions." % definitions.size())
	registry.free()
	quit(0)
