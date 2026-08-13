extends Node2D
class_name ObjectManager

signal object_action_requested(object_id: String, action_id: String)

const InteractiveObject = preload("res://src/objects/interactive_object.gd")

var _objects := {}

func setup(unlock_manager) -> void:
	for child in get_children():
		child.queue_free()
	_objects.clear()
	_add_if_unlocked(unlock_manager, "cardboard_box", "Box", "enter_box", Vector2(72, 212), Color("#D4A047"))
	_add_if_unlocked(unlock_manager, "laptop", "Laptop", "code", Vector2(206, 220), Color("#533D64"))
	_add_if_unlocked(unlock_manager, "cat_bed", "Bed", "sleep_bed", Vector2(326, 218), Color("#DB633A"))

func trigger_object_action(object_id: String) -> void:
	var object: InteractiveObject = _objects.get(object_id)
	if object == null:
		return
	EventBus.emit_notification("%s unlocked action: %s" % [object.display_name, object.unlocks_action])
	object_action_requested.emit(object.object_id, object.unlocks_action)

func _add_if_unlocked(unlock_manager, object_id: String, label: String, action: String, object_position: Vector2, color: Color) -> void:
	if not unlock_manager.is_unlocked(object_id):
		return
	var object := InteractiveObject.new()
	object.configure(object_id, label, action, color)
	object.position = object_position
	object.activated.connect(trigger_object_action)
	_objects[object_id] = object
	add_child(object)
