class_name ButtonDirection
extends Area3D

# Enum pour les actions de la voiture
enum carActions {
	RotateForward,
	RotateBackward,
	Accelerate,
	Brake
}

# Variable pour l'action courante
@export var currentCarAction: carActions = carActions.RotateForward
var is_active: bool = false

# Signaux pour chaque action
signal on_button_activated()
signal on_button_deactivated()
signal on_is_active(delta: float)

@onready var collision_shape: CollisionShape3D = %CollisionShape3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if is_active:
		on_is_active.emit(delta)

func _on_body_entered(body: Node3D):
	if body.is_in_group("players"):
		# print("Un joueur est entré dans la zone !")
		on_button_activated.emit()
		is_active = true

func _on_body_exited(body: Node3D):
	if body.is_in_group("players"):
		# print("Un joueur est sorti de la zone !")
		# emit_signal("on_button_deactivated")
		on_button_deactivated.emit()
		is_active = false
