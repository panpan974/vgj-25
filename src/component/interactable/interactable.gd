extends Area3D
class_name Interactable

@export var ui_data: InteractionUIData
@export var collision_shape: CollisionShape3D

var is_interactable: bool = true

var is_active: bool = false

signal on_activated()
signal on_deactivated()
signal on_is_active(delta: float)
signal on_action_realised(action: String, player: Player)
signal set_interaction_ui_state(state: InteractionUI.UIStates)

signal _on_player_button_pressed(action: String)
signal _on_player_button_released(action: String)
signal _on_player_button_pressed_time_update(action: String, time_held: float)

@onready var ui_canvas_layer: InteractionUI = %InteractionUI
@onready var ui_viewport: SubViewport = %UIViewport
@onready var viewport_quad: MeshInstance3D = %viewport_quad

var players_in_area := []
var players_buttons_pressed := {}


func _ready():
    add_to_group("interactables")
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    ui_viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
    viewport_quad.material_override = StandardMaterial3D.new()
    viewport_quad.material_override.flags_unshaded = true
    viewport_quad.material_override.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
    viewport_quad.material_override.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
    viewport_quad.material_override.albedo_texture = ui_viewport.get_texture()
    viewport_quad.visible = false
    if ui_data != null:
        ui_canvas_layer.setup_signals(self)
        ui_canvas_layer.interaction_ui_data = ui_data
        ui_canvas_layer.setup_all()
    on_activated.connect(show_quad)
    on_deactivated.connect(hide_ui)


func _process(delta: float) -> void:
    if is_active:
        on_is_active.emit(delta)
        for player in players_in_area:
            for action in players_buttons_pressed[player].keys():
                if players_buttons_pressed[player][action] >= 0:
                    players_buttons_pressed[player][action] += delta
                    _on_player_button_pressed_time_update.emit(action, players_buttons_pressed[player][action])

        
func show_quad():
    # Apparition élégante
    viewport_quad.scale = Vector3(0.1, 0.1, 0.1)
    viewport_quad.visible = true
    var tween = create_tween()
    tween.tween_property(viewport_quad, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_ui():
    var tween = create_tween()
    tween.tween_property(viewport_quad, "scale", Vector3(0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
    viewport_quad.visible = false
    

func _on_body_entered(body: Node3D):
    if body.is_in_group("players"):
        # print("Un joueur est entré dans la zone !")
        on_activated.emit()
        is_active = true
        viewport_quad.visible = true
        (body as Player).on_button_pressed.connect(_player_button_pressed.bind(body))
        (body as Player).on_button_released.connect(_player_button_released.bind(body))
        players_buttons_pressed[body] = {}
        players_in_area.append(body)


func _on_body_exited(body: Node3D):
    if body.is_in_group("players"):
        # print("Un joueur est sorti de la zone !")
        # emit_signal("on_button_deactivated")
        on_deactivated.emit()
        is_active = false
        (body as Player).on_button_pressed.disconnect(_player_button_pressed.bind(body))
        (body as Player).on_button_released.disconnect(_player_button_released.bind(body))
        players_in_area.erase(body)

func _player_button_pressed(action: String, player: Player) -> void:
    players_buttons_pressed[player][action] = 0
    _on_player_button_pressed.emit(action)

func _player_button_released(action: String, player: Player) -> void:
    players_buttons_pressed[player][action] = -1
    _on_player_button_released.emit(action)

func _is_button_pressed(action: String, player: Player) -> bool:
    if players_buttons_pressed.has(player):
        if players_buttons_pressed[player].has(action):
            return players_buttons_pressed[player][action]
    return false
