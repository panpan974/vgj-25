extends VehicleBody3D
class_name Car

# Mouvement constant sur X (vitesse variable) et rotation avec move_forward/move_backward
@export var move_speed: float = 2.0 # Vitesse constante sur X
@export var turn_speed: float = 1.5 # Vitesse de rotation (radians/sec)
@export var id: int = 1 # Pour l'InputMap
@export var engine_accel_curve: Curve
@export var engine_max_force_curve: Curve

@export var sfx_volant_problem: AudioStream = null
@export var sfx_repaired: AudioStream = null
@export var sfx_repair_in_progress: AudioStream = null

@onready var buttonDir_top: Interactable = %TopRotationInteractable
@onready var buttonDir_bottom: Interactable = %BottomRotationInteractable
@onready var button_accelerate: Interactable = %AccelerateInteractable
@onready var button_brake: Interactable = %BrakeInteractable
@onready var top_car: Marker3D = %top_car

@onready var fuel_tank: FuelTank = %FuelTank
@onready var volant: Interactable = %Volant
# @onready var direction_sprite: Sprite3D = %direction_sprite

# Node à faire tourner (exporté)
# @export var rotation_target: NodePath

# Variables d'état pour la rotation
var rotating_forward := false
var rotating_backward := false
# var _rotation_node: Node3D = null
var ending_node: Node = null
var problem_timer: Timer = Timer.new()

var time_engine_accel_held: float = 0.0

signal on_volant_broken()
signal on_volant_repaired_car()

func _ready():
	#Register this in GameRecuperator (autoload)
	GameRecuperator.register_car(self)
	GameRecuperator.all_systems_ready.connect(_on_all_systems_ready)

	# Connexion des signaux des boutons directionnels
	buttonDir_top.on_activated.connect(start_rotate_backward)
	buttonDir_top.on_deactivated.connect(stop_rotate_backward)
	buttonDir_bottom.on_activated.connect(start_rotate_forward)
	buttonDir_bottom.on_deactivated.connect(stop_rotate_forward)
	button_accelerate.on_is_active.connect(add_engine_force)
	button_accelerate.on_deactivated.connect(end_acceleration)
	button_brake.on_is_active.connect(slow_engine_force)
	button_accelerate.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
	button_brake.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
	PlayerManager.on_player_added.connect(spawn_player)
	fuel_tank.on_fuel_tank_repaired.connect(_on_fuel_tank_repaired)

	#volant setup
	volant.on_action_realised.connect(_on_volant_repaired)
	volant.set_broken(true) # FOR DEBUGING
	volant._on_player_button_pressed.connect(_on_player_button_pressed)

	problem_timer.wait_time = 30.0
	problem_timer.one_shot = false
	add_child(problem_timer)
	problem_timer.start()
	problem_timer.timeout.connect(_on_problem_timer_timeout)
	# # Récupérer le node à faire tourner
	# if rotation_target != NodePath(""):
	# 	_rotation_node = get_node(rotation_target)
	# else:
	# 	_rotation_node = self

func _on_player_button_pressed(action: String, player: Player) -> void:
	SodaAudioManager.play_sfx(sfx_repair_in_progress.resource_path, true)

func _on_all_systems_ready():
	ending_node = GameRecuperator.get_ending_node()
	# Tout est prêt, on peut démarrer les comportements dépendants si besoin

func _process(delta: float) -> void:
	if not ending_node:
		return
	if fuel_tank.interactable.is_broken:
		# Reduce speed if fuel tank is broken
		engine_force *= 0.999
	# print_debug("Engine force: ", engine_force)

var previous_velocities := []
var crashed := false


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
	# Detect big velocity changes (crash)
	previous_velocities.append(linear_velocity.length())
	if previous_velocities.size() > 5:
		previous_velocities.remove_at(0)
	if previous_velocities.size() == 5:
		var avg_velocity = 0.0
		for v in previous_velocities:
			avg_velocity += v
		avg_velocity /= previous_velocities.size()
		if avg_velocity - linear_velocity.length() > 20.0:
			if not crashed:
				_crash_car()

func _crash_car() -> void:
	# Handle car crash (e.g., play effects, reduce speed, etc.)
	crashed = true
	engine_force = 0
	await get_tree().create_timer(2.0).timeout
	crashed = false


func steering_clamp() -> void:
	# Clamp steering to reasonable values
	steering = deg_to_rad(clamp(rad_to_deg(steering), -45.0, 45.0))

func engine_clamp() -> void:
	# Clamp engine force to reasonable values
	var max_force = engine_max_force_curve.sample(time_engine_accel_held)
	engine_force = clamp(engine_force, -max_force, max_force)

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

func end_acceleration():
	time_engine_accel_held = 0.0

func add_engine_force(delta: float) -> void:
	if fuel_tank.interactable.is_broken:
		return
	time_engine_accel_held += delta
	# Use the curve to determine acceleration based on the time held
	engine_force -= engine_accel_curve.sample(time_engine_accel_held) * 10.0
	if button_accelerate.ui_data != null:
		button_accelerate.ui_data.info_text = "Accelerating...\nForce: " + str(round(-engine_force))

func slow_engine_force(delta: float) -> void:
	if fuel_tank.interactable.is_broken:
		return
	if engine_force < -1:
		engine_force *= 0.95
	else:
		engine_force += 100 * delta
	if button_brake.ui_data != null:
		button_brake.ui_data.info_text = "Braking...\nForce: " + str(round(-engine_force))

func get_top_car() -> Marker3D:
	return top_car

func spawn_player(new_player: Player) -> void:
	add_child(new_player)
	new_player.global_transform.origin = global_transform.origin + Vector3(0, 1, 0)

func _on_fuel_tank_repaired(action: String, player: Player) -> void:
	print_debug("Fuel tank repaired by player ", player.id)
	SodaAudioManager.play_sfx(sfx_repaired.resource_path, false)
	# fuel_tank.on_fuel_tank_repaired.emit()

func _on_volant_repaired(action: String, player: Player) -> void:
	volant.set_broken(false)
	print_debug("Volant repaired by player ", player.id)
	SodaAudioManager.play_sfx(sfx_repaired.resource_path, false)
	on_volant_repaired_car.emit()

func _on_problem_timer_timeout() -> void:
	problem_timer.wait_time = randf_range(25.0, 45.0)
	# Randomly 50% chance to break the fuel tank
	# if randi() % 2 == 0:
	# 	if not fuel_tank.is_broken:
	# 		fuel_tank.set_broken(true)
	# 		on_fuel_tank_broken.emit()
	if randi() % 2 == 0:
		if not volant.is_broken:
			volant.set_broken(true)
			SodaAudioManager.play_sfx(sfx_volant_problem.resource_path, true)
			on_volant_broken.emit()
