extends VehicleBody3D
class_name Car

# Mouvement constant sur X (vitesse variable) et rotation avec move_forward/move_backward
@export var move_speed: float = 2.0 # Vitesse constante sur X
@export var turn_speed: float = 1.5 # Vitesse de rotation (radians/sec)
@export var id: int = 1 # Pour l'InputMap


@onready var buttonDir_top: ButtonDirection = %ButtonDirection_RotTop
@onready var buttonDir_bottom: ButtonDirection = %ButtonDirection2_RotBottom
@onready var button_accelerate: ButtonDirection = %ButtonAccelerate
@onready var button_brake: ButtonDirection = %ButtonBrake
@onready var top_car: Marker3D = %top_car
# @onready var direction_sprite: Sprite3D = %direction_sprite


# Node à faire tourner (exporté)
# @export var rotation_target: NodePath

# Variables d'état pour la rotation
var rotating_forward := false
var rotating_backward := false
# var _rotation_node: Node3D = null
var ending_node: Node = null


func _ready():
	#Register this in GameRecuperator (autoload)
	GameRecuperator.register_car(self)
	GameRecuperator.all_systems_ready.connect(_on_all_systems_ready)

	# Connexion des signaux des boutons directionnels
	buttonDir_top.on_button_activated.connect(start_rotate_forward)
	buttonDir_top.on_button_deactivated.connect(stop_rotate_forward)
	buttonDir_bottom.on_button_activated.connect(start_rotate_backward)
	buttonDir_bottom.on_button_deactivated.connect(stop_rotate_backward)
	button_accelerate.on_is_active.connect(add_engine_force)
	button_brake.on_is_active.connect(slow_engine_force)
	PlayerManager.on_player_added.connect(spawn_player)

	# # Récupérer le node à faire tourner
	# if rotation_target != NodePath(""):
	# 	_rotation_node = get_node(rotation_target)
	# else:
	# 	_rotation_node = self

func _on_all_systems_ready():
	ending_node = GameRecuperator.get_ending_node()
	# Tout est prêt, on peut démarrer les comportements dépendants si besoin

func _process(delta: float) -> void:
	if not ending_node:
		return
	# Rotate the y of the direction sprite to always face the ending node
	# var to_ending = (ending_node.global_transform.origin - global_transform.origin).normalized()
	# var target_rotation = atan2(to_ending.x, to_ending.z)
	# direction_sprite.global_rotation.y = - target_rotation

func _physics_process(delta):
	#disable just for testing
	# Mouvement constant dans la direction de la rotation (avant local)
	# var forward_dir = - transform.basis.z.normalized()
	# velocity = forward_dir * move_speed
	# engine_force = -150
	_rotate_with_inputs(delta)

	# move_and_slide()
	# print_debug("Car position: ", global_transform.origin)
	engine_clamp()

func steering_clamp() -> void:
	# Clamp steering to reasonable values
	steering = deg_to_rad(clamp(rad_to_deg(steering), -45.0, 45.0))

func engine_clamp() -> void:
	# Clamp engine force to reasonable values
	engine_force = clamp(engine_force, -400, 400)

func _rotate_with_inputs(delta):
	# if _rotation_node == null:
	# 	return
	if rotating_forward:
		# GameRecuperator.on_rotate.emit(1)
		steering -= turn_speed * delta
		# _rotation_node.rotation.y -= turn_speed * delta
	if rotating_backward:
		steering += turn_speed * delta
	steering_clamp()

# Fonctions pour déclencher/arrêter la rotation
# Fonctions pour déclencher/arrêter la rotation
func start_rotate_forward():
	rotating_forward = true

func stop_rotate_forward():
	rotating_forward = false

func start_rotate_backward():
	rotating_backward = true

func stop_rotate_backward():
	rotating_backward = false

func add_engine_force(delta: float) -> void:
	engine_force -= 100 * delta

func slow_engine_force(delta: float) -> void:
	engine_force += 100 * delta

func get_top_car() -> Marker3D:
	return top_car

func spawn_player(new_player: Player) -> void:
	add_child(new_player)
	new_player.global_transform.origin = global_transform.origin + Vector3(0, 1, 0)
