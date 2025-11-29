extends Node

@onready var player_scene: PackedScene = preload("uid://d0k1qanc30wcv")
var players: Array[Player] = []
var actual_game_players: Array[Player] = []
var is_accepting_players: bool = true

signal on_player_added(player: Player)

func _ready() -> void:
	InputMapper.on_controller_added.connect(spawn_player)
	# GlobalsEvents.start_game.connect(_on_start_game)

func _on_start_game() -> void:
	# Freeze the actual game players to prevent changes during the game
	actual_game_players = players.duplicate()
	# GlobalsEvents.start_game.disconnect(_on_start_game)
	InputMapper.on_controller_added.disconnect(spawn_player)

func spawn_player(device_id: int) -> Player:
	var new_player: Player = player_scene.instantiate()
	new_player.id = players.size() + 1
	# add_child(new_player)
	new_player.player_device_id = device_id
	players.append(new_player)
	print("Added new player: ", new_player.name, " with device ID: ", device_id)
	on_player_added.emit(new_player)
	return new_player

func get_random_player() -> Player:
	if players.size() == 0:
		return null
	return players.pick_random()
