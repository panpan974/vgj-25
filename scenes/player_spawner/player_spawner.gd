extends Node

func _ready() -> void:
    PlayerManager.on_player_added.connect(_on_player_added)

func _on_player_added(player:Player) -> void:
    add_child(player)