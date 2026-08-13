extends Node

const SAVE_VERSION := 1
const SAVE_PATH := "user://save.json"

var _last_error := ""

func save_game(data: Dictionary) -> bool:
	var save_data := data.duplicate(true)
	save_data["version"] = SAVE_VERSION
	save_data["saved_at_unix"] = Time.get_unix_time_from_system()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_last_error = "Could not open save file for writing."
		_log_warn(_last_error)
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	_log_info("Save written to %s" % SAVE_PATH)
	return true

func load_game(default_data: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		_log_info("No save file found. Using defaults.")
		return default_data.duplicate(true)

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_last_error = "Could not open save file for reading."
		_log_warn(_last_error)
		return default_data.duplicate(true)

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_last_error = "Save file is invalid JSON."
		_log_warn(_last_error)
		return default_data.duplicate(true)

	if int(parsed.get("version", 0)) > SAVE_VERSION:
		_last_error = "Save file version is newer than this build."
		_log_warn(_last_error)
		return default_data.duplicate(true)

	return _merge_defaults(default_data, parsed)

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	_log_info("Save reset requested.")

func get_last_error() -> String:
	return _last_error

func _merge_defaults(default_data: Dictionary, loaded_data: Dictionary) -> Dictionary:
	var merged := default_data.duplicate(true)
	for key in loaded_data.keys():
		if typeof(loaded_data[key]) == TYPE_DICTIONARY and typeof(merged.get(key)) == TYPE_DICTIONARY:
			merged[key] = _merge_defaults(merged[key], loaded_data[key])
		else:
			merged[key] = loaded_data[key]
	return merged

func _log_info(message: String) -> void:
	var logger := _get_logger()
	if logger != null:
		logger.info(logger.Category.SAVE, message)

func _log_warn(message: String) -> void:
	var logger := _get_logger()
	if logger != null:
		logger.warn(logger.Category.SAVE, message)

func _get_logger() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return null
	return tree.root.get_node_or_null("AppLog")
