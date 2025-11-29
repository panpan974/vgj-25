extends Node

signal all_systems_ready()
signal game_ready_to_start()

signal on_rotate(direction: String)

var ending_node: Node = null
var car: Car = null
var camera: Camera3D = null

var _systems_ready: Dictionary = {
	"car_ready": false,
	"ending_node_ready": false,
	"camera_ready": false
}

func _mark_system_ready(system_name: String):
	_systems_ready[system_name] = true
	_check_all_systems_ready()


# 🆕 Vérifier si tous les systèmes sont prêts
func _check_all_systems_ready():
	var all_ready = true
	var ready_systems = []
	var pending_systems = []
	
	for system_name in _systems_ready:
		if _systems_ready[system_name]:
			ready_systems.append(system_name)
		else:
			pending_systems.append(system_name)
			all_ready = false
	
	if pending_systems.size() > 0:
		pass
		# print_debug("Systems pending: ", pending_systems)
	
	if all_ready:
		# Petit délai pour s'assurer que tout est vraiment initialisé
		await get_tree().process_frame
		all_systems_ready.emit()


### CAR ###
func register_car(car_instance: Car):
	car = car_instance
	_mark_system_ready("car_ready")
	print_debug("Car registered in GameRecuperator")

func get_car() -> Car:
	return car

### ENDING NODE ###
func register_ending_node(ending_node_instance: Node):
	ending_node = ending_node_instance
	_mark_system_ready("ending_node_ready")
	print_debug("Ending node registered in GameRecuperator")

func get_ending_node() -> Node:
	return ending_node
## Register camera ##
func register_camera(camera_instance: Camera3D):
	camera = camera_instance
	_mark_system_ready("camera_ready")
	print_debug("Camera registered in GameRecuperator")

func get_camera() -> Camera3D:
	if camera:
		return camera
	return null
