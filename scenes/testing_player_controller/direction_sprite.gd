extends Node3D

var ending_node: Node
@export var car_node: Node3D
var offset_to_car: Vector3 = Vector3.ZERO

func _ready() -> void:
	# if car_node:
	#     offset_to_car = global_transform.origin - car_node.global_transform.origin
	ending_node = GameRecuperator.get_ending_node()

func _process(delta: float) -> void:
	if not ending_node or not car_node:
		return
	# Suivre la voiture en maintenant l'offset SANS rotation (offset fixe dans l'espace monde)
	# global_transform.origin = car_node.global_transform.origin + offset_to_car

	# Calculer la direction vers le point de fin depuis la position actuelle du sprite
	var to_ending: Vector3 = (ending_node.global_transform.origin - global_transform.origin).normalized()
	# Calculer la rotation pour pointer vers le point de fin
	# La rotation 0 de la flèche correspond à -Z, donc on utilise -z dans atan2
	var target_rotation: float = atan2(to_ending.x, to_ending.z)
	global_rotation.y = target_rotation
