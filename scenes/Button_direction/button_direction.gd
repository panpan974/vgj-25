
class_name ButtonDirection
extends Area3D

# Enum pour les actions de la voiture
enum carActions {
	RotateForward,
	RotateBackward
}

# Variable pour l'action courante
@export var currentCarAction : carActions = carActions.RotateForward

# Signaux pour chaque action
signal on_rotate_forward_changed(state: bool)
signal on_rotate_backward_changed(state: bool)

@onready var collision_shape:CollisionShape3D = %CollisionShape3D

#link the collision shape to the signal
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D):
	if body.is_in_group("players"):
		print("Un joueur est entré dans la zone !")
		if currentCarAction == carActions.RotateForward:
			emit_signal("on_rotate_forward_changed", true)
		elif currentCarAction == carActions.RotateBackward:
			emit_signal("on_rotate_backward_changed", true)

func _on_body_exited(body: Node3D):
	if body.is_in_group("players"):
		print("Un joueur est sorti de la zone !")
		if currentCarAction == carActions.RotateForward:
			emit_signal("on_rotate_forward_changed", false)
		elif currentCarAction == carActions.RotateBackward:
			emit_signal("on_rotate_backward_changed", false)
# N'oublie pas de connecter le signal body_entered à _on_body_entered dans l'éditeur ou par code.
