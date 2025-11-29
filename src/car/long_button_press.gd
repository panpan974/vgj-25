extends Node

@export var action_name: String = "Undefined Action"
@export var required_hold_time: float = 2.0 # Temps requis pour que l'action soit réalisée

var time_held: float = 0.0
var interactable: Interactable

func _ready() -> void:
    interactable = get_parent() as Interactable
    interactable._on_player_button_pressed_time_update.connect(_on_button_pressed_time_update)

func _on_button_pressed_time_update(action: String, time_held: float) -> void:
    if action == action_name:
        self.time_held = time_held
        if self.time_held >= required_hold_time:
            # Action réalisée
            interactable.on_action_realised.emit(action_name, get_tree().get_current_scene().get_node("Player")) # Assuming single player for simplicity
            self.time_held = 0.0 # Reset timer after action is realised