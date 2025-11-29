extends CharacterBody3D


# Character controller 3D simple, sans saut ni caméra, avec gestion d'id pour l'InputMap
@export var speed: float = 5.0
@export var id: int = 1 # Utilisé pour différencier les inputs (ex: 1, 2, 3...)

func _physics_process(delta):
	# Construction dynamique des noms d'actions selon l'id
	var forward = "move_forward_%d" % id
	var backward = "move_backward_%d" % id
	var left = "move_left_%d" % id
	var right = "move_right_%d" % id

	# Récupérer la direction de déplacement
	var input_vector = Vector3.ZERO
	if Input.is_action_pressed(forward):
		input_vector.z -= 1
	if Input.is_action_pressed(backward):
		input_vector.z += 1
	if Input.is_action_pressed(left):
		input_vector.x -= 1
	if Input.is_action_pressed(right):
		input_vector.x += 1

	# Appliquer la direction selon l'orientation du personnage
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		var direction = (transform.basis * input_vector).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 10)

	# Pas de gestion de la gravité ni du saut
	move_and_slide()


