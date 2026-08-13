extends Node

const GameManager = preload("res://src/core/game_manager.gd")

var _game_manager: Node

func _ready() -> void:
	_game_manager = GameManager.new()
	_game_manager.name = "GameManager"
	add_child(_game_manager)
