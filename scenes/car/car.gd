class_name Car extends CharacterBody3D


# Mouvement constant sur X (vitesse variable) et rotation avec move_forward/move_backward
@export var move_speed: float = 2.0 # Vitesse constante sur X
@export var turn_speed: float = 1.5 # Vitesse de rotation (radians/sec)
@export var id: int = 1 # Pour l'InputMap


@onready var buttonDir_top: ButtonDirection = %ButtonDirection_RotTop
@onready var buttonDir_bottom: ButtonDirection = %ButtonDirection2_RotBottom


# Node à faire tourner (exporté)
@export var rotation_target: NodePath

# Variables d'état pour la rotation
var rotating_forward := false
var rotating_backward := false
var _rotation_node: Node3D = null



func _ready():
	#Register this in GameRecuperator (autoload)
	GameRecuperator.register_car(self)
	

	# Connexion des signaux des boutons directionnels
	buttonDir_top.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
	buttonDir_top.on_rotate_backward_changed.connect(_on_rotate_backward_changed)
	buttonDir_bottom.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
	buttonDir_bottom.on_rotate_backward_changed.connect(_on_rotate_backward_changed)

	# Récupérer le node à faire tourner
	if rotation_target != NodePath(""):
		_rotation_node = get_node(rotation_target)
	else:
		_rotation_node = self

func _physics_process(delta):
	# Mouvement constant dans la direction de la rotation (avant local)
	var forward_dir = -transform.basis.z.normalized()
	velocity = forward_dir * move_speed

	_rotate_with_inputs(delta)

	move_and_slide()

func _rotate_with_inputs(delta):
	if _rotation_node == null:
		return
	if rotating_forward:
		_rotation_node.rotation.y -= turn_speed * delta
	if rotating_backward:
		_rotation_node.rotation.y += turn_speed * delta

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
