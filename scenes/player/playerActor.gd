extends CharacterBody3D
class_name Player

# Character controller 3D simple, sans saut ni caméra, avec gestion d'id pour l'InputMap
@export var speed: float = 5.0
@export var id: int = 1 # Utilisé pour différencier les inputs (ex: 1, 2, 3...)
@export var player_device_id: int = -1
var player_deadzone: float = 0.1

var is_listening_action_action: bool = true
var is_listening_input: bool = true
var input_vector: Vector2 = Vector2.ZERO

signal on_movement_vector(movement: Vector2)
signal on_validate_pressed()
signal on_cancel_pressed()
signal on_button_pressed(action: String)
signal on_button_released(action: String)

func _ready():
	add_to_group("players")
	on_movement_vector.connect(_on_movement_vector)
	on_button_pressed.connect(player_input_pressed)

func player_input_pressed(action: String) -> void:
	# Example handling of input actions
	if action == InputMapper.X_ACTION:
		print_debug("Player ", id, " pressed X action")
	elif action == InputMapper.Y_ACTION:
		print_debug("Player ", id, " pressed Y action")

func _on_movement_vector(movement: Vector2) -> void:
	input_vector = movement

func _physics_process(delta):
	# Appliquer la direction dans le repère global (contrôles non affectés par la rotation du parent)
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		# Utilise la base globale pour que le parent n'influence pas la direction
		# var direction = (global_transform.basis * input_vector).normalized()
		velocity.x = input_vector.x * speed
		velocity.z = input_vector.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 10)

	# Pas de gestion de la gravité ni du saut
	move_and_slide()


func _process(delta: float) -> void:
	var movement: Vector2 = Input.get_vector("joy_" + str(player_device_id) + "_move_up", "joy_" + str(player_device_id) + "_move_down",
					 "joy_" + str(player_device_id) + "_move_right", "joy_" + str(player_device_id) + "_move_left")
	if movement.length() > player_deadzone:
		# print_debug("Player ", player_name, " movement: ", movement)
		emit_signal("on_movement_vector", movement)
	else:
		emit_signal("on_movement_vector", Vector2.ZERO)
	
func _input(event: InputEvent) -> void:
	if event.device != player_device_id:
		return
	if not is_listening_input and not is_listening_action_action:
		return
	if event is InputEventJoypadButton:
		if event.pressed:
			on_button_pressed.emit(InputMapper.get_action_from_button(event.button_index, event.device))
			if event.button_index == InputMapper.ACTION_MAP_DEFAULT[InputMapper.ACTION_ACTION]["button"]:
				on_validate_pressed.emit()
			elif event.button_index == InputMapper.ACTION_MAP_DEFAULT[InputMapper.CANCEL_ACTION]["button"]:
				on_cancel_pressed.emit()
		else:
			on_button_released.emit(InputMapper.get_action_from_button(event.button_index, event.device))
