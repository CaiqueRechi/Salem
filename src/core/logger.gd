extends Node

enum Category {
	PET,
	STATE,
	SAVE,
	EVENT,
	INTEGRATION,
	WINDOW,
	UI
}

var enabled := true
var enabled_categories := {
	Category.PET: true,
	Category.STATE: true,
	Category.SAVE: true,
	Category.EVENT: true,
	Category.INTEGRATION: true,
	Category.WINDOW: true,
	Category.UI: true
}

func info(category: Category, message: String) -> void:
	if not enabled or not enabled_categories.get(category, false):
		return
	print("[%s] %s" % [_category_name(category), message])

func warn(category: Category, message: String) -> void:
	if not enabled or not enabled_categories.get(category, false):
		return
	push_warning("[%s] %s" % [_category_name(category), message])

func _category_name(category: Category) -> String:
	return Category.keys()[category]
