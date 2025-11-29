class_name Car extends CharacterBody3D


# Mouvement constant sur X (vitesse variable) et rotation avec move_forward/move_backward
@export var move_speed: float = 2.0 # Vitesse constante sur X
@export var turn_speed: float = 1.5 # Vitesse de rotation (radians/sec)
@export var id: int = 1 # Pour l'InputMap


@onready var buttonDir_top: ButtonDirection = %ButtonDirection_RotTop
@onready var buttonDir_bottom: ButtonDirection = %ButtonDirection2_RotBottom
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
	buttonDir_top.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
	buttonDir_top.on_rotate_backward_changed.connect(_on_rotate_backward_changed)
	buttonDir_bottom.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
	buttonDir_bottom.on_rotate_backward_changed.connect(_on_rotate_backward_changed)

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
	_rotate_with_inputs(delta)

	move_and_slide()
	# print_debug("Car position: ", global_transform.origin)

func _rotate_with_inputs(delta):
	# if _rotation_node == null:
	# 	return
	if rotating_forward:
		GameRecuperator.on_rotate.emit(1)
		# _rotation_node.rotation.y -= turn_speed * delta
	if rotating_backward:
		GameRecuperator.on_rotate.emit(-1)
		# _rotation_node.rotation.y += turn_speed * delta

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

# Fonctions de callback pour les signaux
func _on_rotate_forward_changed(state: bool):
	rotating_forward = state

func _on_rotate_backward_changed(state: bool):
	rotating_backward = state

func get_top_car() -> Marker3D:
	return top_car
