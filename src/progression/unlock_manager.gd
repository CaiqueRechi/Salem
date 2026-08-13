extends Node
class_name UnlockManager

const DEFAULT_UNLOCKED := ["cardboard_box", "laptop", "cat_bed"]

var unlocked_objects: Array[String] = []

func setup() -> void:
	if unlocked_objects.is_empty():
		unlocked_objects.assign(DEFAULT_UNLOCKED)

func unlock(object_id: String) -> void:
	if unlocked_objects.has(object_id):
		return
	unlocked_objects.append(object_id)
	EventBus.object_unlocked.emit(object_id)

func is_unlocked(object_id: String) -> bool:
	return unlocked_objects.has(object_id)

func apply_save(data: Dictionary) -> void:
	unlocked_objects.clear()
	for object_id in data.get("unlocked_objects", DEFAULT_UNLOCKED):
		unlocked_objects.append(str(object_id))
	setup()

func to_dictionary() -> Dictionary:
	return {"unlocked_objects": unlocked_objects}
