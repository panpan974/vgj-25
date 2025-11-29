extends Control

@onready var play_button: Button = %play_button

func _ready():
    play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
    get_tree().change_scene_to_file("res://scenes/testing_player_controller.tscn")