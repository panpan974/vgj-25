extends Area3D

@onready var ui_ending: Control = %UI_Ending
@onready var target_texture: TextureRect = %Target 
@onready var ending_pointer: Marker3D = %ending_pointer
@onready var ending_area_3d: Node3D #Where it ends
@export var target_3d: Node3D #Where it begins
@export var camera: Camera3D


func _ready():
	body_entered.connect(_on_body_entered)
	ending_area_3d = self
	ui_ending.visible = false
	#get camera_3d from main camera
	GameRecuperator.register_ending_node(self)
	GameRecuperator.all_systems_ready.connect(_on_all_systems_ready)

func _on_body_entered(body: Node3D):
	if body.is_in_group("players"):
		print("Le joueur est entré dans la zone de fin !")
		switch_ending_ui(true)

func _on_all_systems_ready():
	#Let's get the camera
	target_3d = GameRecuperator.get_car()
	camera = GameRecuperator.get_camera()


func switch_ending_ui(state:bool):
	ui_ending.visible = state


func _process(delta):
	if not ending_area_3d or not target_3d:
		return

	var ending_pos = ending_pointer.global_transform.origin
	var car_pos = target_3d.global_transform.origin

	var direction_to_target = (ending_pos - car_pos).normalized()
	var angle_y = atan2(-direction_to_target.x, direction_to_target.z)

	target_texture.rotation_degrees = rad_to_deg(angle_y)



	




	# print_debug("Distance to car: ", to_car_distance, "dir: ", to_car_dir)
