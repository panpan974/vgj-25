extends Control

@onready var play_button: Button = %play_button
@export var scene_to_load: PackedScene

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed():
	var scene_to_load_string:String = scene_to_load.resource_path
	get_tree().change_scene_to_file(scene_to_load_string)
