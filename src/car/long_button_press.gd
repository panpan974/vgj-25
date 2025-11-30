extends Node

@export var action_name: String = "Undefined Action"
@export var required_hold_time: float = 2.0 # Temps requis pour que l'action soit réalisée
@export var ui_data: InteractionUIData

var player_time_helds := {}
var interactable: Interactable

func _ready() -> void:
    interactable = get_parent() as Interactable
    interactable._on_player_button_pressed_time_update.connect(_on_button_pressed_time_update)
    interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
    interactable.on_broken_state_changed.connect(_on_broken_state_changed)

func _on_broken_state_changed(state: bool) -> void:
    if state:
        interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Instructions)
    else:
        interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
        player_time_helds.clear()

func _on_button_pressed_time_update(action: String, time_held: float, player: Player) -> void:
    if action == action_name:
        if not player_time_helds.has(player):
            player_time_helds[player] = 0.0
        player_time_helds[player] = time_held
        if player_time_helds[player] >= required_hold_time:
            # Action réalisée
            interactable.on_action_realised.emit(action_name, player)
            player_time_helds[player] = 0.0 # Reset timer after action is realised
        # Edit the value of the most advanced player holding time in the UI
        var last_holding_player = null
        var max_time_held = 0.0
        for p in player_time_helds.keys():
            if player_time_helds[p] > max_time_held:
                max_time_held = player_time_helds[p]
                last_holding_player = p
        if last_holding_player != null:
            ui_data.instruction_value = player_time_helds[last_holding_player] / required_hold_time * 100.0
