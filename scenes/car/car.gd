extends CharacterBody3D


# Mouvement constant sur X (vitesse variable) et rotation avec move_forward/move_backward
@export var move_speed: float = 2.0 # Vitesse constante sur X
@export var turn_speed: float = 1.5 # Vitesse de rotation (radians/sec)
@export var id: int = 1 # Pour l'InputMap

func _physics_process(delta):
	var forward = "move_forward_%d" % id
	var backward = "move_backward_%d" % id

	# Mouvement constant dans la direction de la rotation (avant local)
	var forward_dir = -transform.basis.z.normalized()
	velocity = forward_dir * move_speed

	# # Rotation avec les inputs
	# if Input.is_action_pressed(forward):
	# 	rotation.y -= turn_speed * delta
	# if Input.is_action_pressed(backward):
	# 	rotation.y += turn_speed * delta

	move_and_slide()
