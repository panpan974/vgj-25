extends Node

@onready var ui_ending: Control = %UI_Ending
@onready var target: TextureRect = %Target 
@onready var ending_area_3d: Node3D = get_parent()
var camera_3d: Camera3D
var car: Car

func _ready():
	ui_ending.visible = false
	#get camera_3d from main camera
	camera_3d = get_viewport().get_camera_3d()
	GameRecuperator.register_ending_node(self)
	GameRecuperator.all_systems_ready.connect(_on_all_systems_ready)

func _on_all_systems_ready():
	#Let's get the camera
	car = GameRecuperator.get_car()


func switch_ending_ui(state:bool):
	ui_ending.visible = state


func _process(delta):
	if not ending_area_3d or not car:
		return

	var ending_pos = ending_area_3d.global_transform.origin
	var car_pos = car.global_transform.origin

	# Direction de la voiture vers la zone de fin (Y ignoré)
	var dir = ending_pos - car_pos
	dir.y = 0
	if dir.length() > 0:
		dir = dir.normalized()

	# Avant de la voiture (Y ignoré)
	var car_forward = -car.global_transform.basis.z
	car_forward.y = 0
	if car_forward.length() > 0:
		car_forward = car_forward.normalized()

	# Angle entre l'avant de la voiture et la direction objectif (sur le plan XZ)
	var angle = atan2(dir.x, dir.z) - atan2(car_forward.x, car_forward.z)

	# Appliquer la rotation à l'icône (en radians)
	target.rotation = angle
