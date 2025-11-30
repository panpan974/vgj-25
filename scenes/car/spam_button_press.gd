extends Node

# Pour la gestion de l'interaction et du UI
@export var ui_data: InteractionUIData
var interactable: Interactable

# Nom de l'action à spammer (ex: "ui_accept")
@export var action_name: String = "Undefined Action"
@export var required_duration: float = 3.0 # Temps à spammer (secondes)
@export var min_spam_per_second: float = 4.0 # Nombre minimal de pressions par seconde
@export var reset_delay: float = 0.5 # Temps max entre deux pressions avant reset



# Gestion par joueur (dictionnaire)
var player_spam_data := {}
@export var required_clicks: int = 10 # Nombre de clics nécessaires pour compléter

signal on_spam_success()


func _ready():
    interactable = get_parent() as Interactable
    if interactable:
        interactable._on_player_button_pressed_time_update.connect(_on_button_pressed)
        interactable._on_player_button_released.connect(_on_button_released)
        interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
        interactable.on_broken_state_changed.connect(_on_broken_state_changed)
    player_spam_data.clear()

func _on_button_released(action: String, player: Player) -> void:
    if action != action_name:
        return
    if not player_spam_data.has(player):
        return
    var data = player_spam_data[player]
    if data.success:
        return
    if data.pressed:
        data.clicks += 1
        data.pressed = false

func _on_button_pressed(action: String, time_held: float, player: Player) -> void:
    if action != action_name:
        return
    if not player_spam_data.has(player):
        player_spam_data[player] = {
            "clicks": 0,
            "success": false,
            "pressed": false
        }
    var data = player_spam_data[player]
    data.pressed = true

func _on_broken_state_changed(state: bool) -> void:
    if state:
        interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Instructions)
    else:
        interactable.set_interaction_ui_state.emit(InteractionUI.UIStates.Info)
        player_spam_data.clear()


# Gestion du spam par joueur
func _on_player_spam_press(player: Player):
    pass

func _process(_delta):
    for player in player_spam_data.keys():
        var data = player_spam_data[player]
        if data.success:
            continue
        var completion = float(data.clicks) / float(required_clicks)
        if data.clicks >= required_clicks:
            data.success = true
            if interactable:
                interactable.on_action_realised.emit(action_name, player)
            emit_signal("on_spam_success", player)
        if player == get_tree().get_first_node_in_group("players"): # ou autre critère pour le joueur local
            ui_data.instruction_value = clamp(completion, 0, 1) * 100.0