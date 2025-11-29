extends Node3D

@onready var top_car: Marker3D = %top_car
@onready var buttonDir_top: ButtonDirection = %ButtonDirection_RotTop
@onready var buttonDir_bottom: ButtonDirection = %ButtonDirection2_RotBottom

var rotating_forward := false
var rotating_backward := false

# Follow the car body
var offset = Vector3(-0.793, -0.658, 0)

func _ready() -> void:
    buttonDir_top.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
    buttonDir_top.on_rotate_backward_changed.connect(_on_rotate_backward_changed)
    buttonDir_bottom.on_rotate_forward_changed.connect(_on_rotate_forward_changed)
    buttonDir_bottom.on_rotate_backward_changed.connect(_on_rotate_backward_changed)

func _rotate_with_inputs(delta):
    # if _rotation_node == null:
    # 	return
    if rotating_forward:
        GameRecuperator.on_rotate.emit(1)
        # _rotation_node.rotation.y -= turn_speed * delta
    if rotating_backward:
        GameRecuperator.on_rotate.emit(-1)
        # steering -= turn_speed * delta

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

func _process(delta: float) -> void:
    var car = GameRecuperator.get_car()
    if car:
        global_transform.origin = car.global_transform.origin + offset
        global_transform.basis = car.global_transform.basis
    _rotate_with_inputs(delta)