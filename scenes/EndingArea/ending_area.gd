extends Node

@onready var ui_ending: Control = %UI_Ending
@onready var target: TextureRect = %Target 
@onready var ending_area_3d: Node3D = get_parent()
@export var camera_3d: Camera3D

func _ready():
    ui_ending.visible = false


func switch_ending_ui(state:bool):
    ui_ending.visible = state


func _process(delta):
    if not ending_area_3d or not camera_3d:
        return

    var ending_pos = ending_area_3d.global_transform.origin
    var camera_pos = camera_3d.global_transform.origin

    # Direction du joueur vers la zone de fin
    var dir = (ending_pos - camera_pos).normalized()

    # Direction avant de la caméra (pour calculer l'angle)
    var cam_forward = -camera_3d.global_transform.basis.z.normalized()

    # Angle entre la direction caméra et la direction objectif (sur le plan XZ)
    var angle = atan2(dir.x, dir.z) - atan2(cam_forward.x, cam_forward.z)

    # Appliquer la rotation à l'icône (en radians)
    target.rotation = angle