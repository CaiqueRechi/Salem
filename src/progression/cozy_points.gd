extends Node
class_name CozyPoints

var total := 0

func add_points(amount: int) -> void:
	if amount <= 0:
		return
	total += amount
	EventBus.cozy_points_changed.emit(total, amount)

func apply_save(data: Dictionary) -> void:
	total = max(0, int(data.get("total", total)))
	EventBus.cozy_points_changed.emit(total, 0)

func to_dictionary() -> Dictionary:
	return {"total": total}
