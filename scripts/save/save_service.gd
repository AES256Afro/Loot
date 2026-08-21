extends Node

## Local profile persistence with a write, flush, parse, rotate, and commit
## transaction. Existing valid data is retained if any step fails.

const DEFAULT_SAVE_PATH := "user://profiles/spike_save.json"
const SAVE_SCHEMA_VERSION := 1


func write_atomic(save_data: Dictionary, final_path: String = DEFAULT_SAVE_PATH) -> Dictionary:
	var parent_path := final_path.get_base_dir()
	var absolute_parent := ProjectSettings.globalize_path(parent_path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_parent)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return _result(false, "Could not create save directory: %s" % error_string(directory_error))
	var temp_path := final_path + ".tmp"
	var backup_path := final_path + ".bak"
	var envelope := save_data.duplicate(true)
	envelope["schema_version"] = SAVE_SCHEMA_VERSION
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return _result(false, "Could not open temporary save file: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(envelope, "  ", false))
	file.flush()
	file.close()
	var verification := _read_dictionary(temp_path)
	if not verification.get("ok", false):
		_remove_if_present(temp_path)
		return _result(false, "Temporary save verification failed.")
	if FileAccess.file_exists(backup_path):
		_remove_if_present(backup_path)
	if FileAccess.file_exists(final_path):
		var rotate_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(final_path),
			ProjectSettings.globalize_path(backup_path)
		)
		if rotate_error != OK:
			_remove_if_present(temp_path)
			return _result(false, "Could not rotate prior save: %s" % error_string(rotate_error))
	var commit_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path),
		ProjectSettings.globalize_path(final_path)
	)
	if commit_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(backup_path),
				ProjectSettings.globalize_path(final_path)
			)
		_remove_if_present(temp_path)
		return _result(false, "Could not commit save: %s" % error_string(commit_error))
	return _result(true, "Saved atomically.", final_path)


func load_profile(final_path: String = DEFAULT_SAVE_PATH) -> Dictionary:
	var primary := _read_dictionary(final_path)
	if primary.get("ok", false):
		return primary
	var backup_path := final_path + ".bak"
	var backup := _read_dictionary(backup_path)
	if backup.get("ok", false):
		backup["recovered_from_backup"] = true
		return backup
	return _result(false, "No valid primary or backup save exists.")


func _read_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _result(false, "File does not exist.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _result(false, "Could not open file.")
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		return _result(false, "Save is not valid JSON data.")
	var data: Dictionary = (json.data as Dictionary).duplicate(true)
	if int(data.get("schema_version", 0)) != SAVE_SCHEMA_VERSION:
		return _result(false, "Unsupported save schema.")
	return {"ok": true, "message": "Loaded save.", "data": data, "path": path}


func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _result(ok: bool, message: String, path: String = "") -> Dictionary:
	return {"ok": ok, "message": message, "path": path}
