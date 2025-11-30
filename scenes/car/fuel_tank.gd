extends Node3D
class_name FuelTank

@export var sfx_fuel_problem: AudioStream = null
@export var action_name: String = "Refuel Tank"
@export var max_fuel_value: float = 100.0
@export var fuel_value: float = 100.0
@onready var interactable: Interactable = %Interactable
@export var low_fuel_material: Material
@export var normal_fuel_material: Material
@export var fuel_gradient: Gradient
# @onready var fuel_tank_mesh: MeshInstance3D = $Mesh

signal on_fuel_tank_broken()
signal on_fuel_tank_repaired()

func _ready() -> void:
    interactable._on_player_button_pressed_time_update.connect(_on_button_pressed_time_update)
    interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)

func _on_button_pressed_time_update(action: String, time_held: float, player: Player) -> void:
    if interactable.is_broken:
        return
    if action == action_name:
        fuel_value += 0.08
        fuel_value = clamp(fuel_value, 0.0, max_fuel_value)

func _process(delta: float) -> void:
    fuel_value -= delta * 6.0 # Consume fuel over time
    fuel_value = clamp(fuel_value, 0.0, max_fuel_value)
    if fuel_value <= 0.0 and not interactable.is_broken:
        fuel_tank_broken()
        # fuel_tank_mesh.material_override = low_fuel_material
    interactable.ui_data.info_value = (fuel_value / max_fuel_value) * 100.0
    fuel_gradient.set_offset(1, 1 - (fuel_value / max_fuel_value) + 0.01)
    fuel_gradient.set_offset(0, 1 - (fuel_value / max_fuel_value) - 0.01)
    fuel_gradient.set_color(0, Color.WHITE)
    fuel_gradient.set_color(1, Color.YELLOW)
    fuel_gradient.set_color(2, Color.YELLOW)
    # fuel_gradient.set_offset(0, (fuel_value / max_fuel_value))

func fuel_tank_broken() -> void:
    interactable.set_broken(true)
    on_fuel_tank_broken.emit()
    SodaAudioManager.play_sfx(sfx_fuel_problem.resource_path, true)
    interactable.on_action_realised.connect(_on_fuel_tank_repaired)

func _on_fuel_tank_repaired(action: String, player: Player) -> void:
    interactable.set_broken(false)
    fuel_value = max_fuel_value
    # fuel_tank_mesh.material_override = normal_fuel_material
    on_fuel_tank_repaired.emit()