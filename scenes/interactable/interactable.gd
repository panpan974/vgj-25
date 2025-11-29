@tool
class_name Interactable extends Area3D

@onready var ui_viewport_buttons: SubViewport = %ui_viewport_buttons
@onready var ui_viewport_buttonsCanvasLayer: UIViewportButtons = %ui_viewport_buttonsCanvasLayer
@onready var viewport_quad : MeshInstance3D = %viewport_quad
@onready var tween := create_tween()

# Durée d'appui requise (en secondes)
@export var hold_duration: float = 3.0
@export var current_interactable_action:interactableActions = interactableActions.PressXActionSeconds
@export var needs_repair: bool = true

enum interactableActions {
	PressRandomly,
	PressXActionSeconds
}

var players_in_area := []
# Dictionnaire pour stocker le temps d'appui de chaque joueur
var player_hold_times := {}
var player_holding := {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	ui_viewport_buttons.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport_quad.material_override.albedo_texture = ui_viewport_buttons.get_texture()
	viewport_quad.visible = false
	ui_viewport_buttonsCanvasLayer.desactive_ui()
	

#Player detection
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		print_debug("player entered")
		if needs_repair:
			viewport_quad.visible = true
			ui_viewport_buttonsCanvasLayer.change_ui_state(ui_viewport_buttonsCanvasLayer.uiStates.Instructions)
			# Apparition élégante
			viewport_quad.scale = Vector3(0.1, 0.1, 0.1)
			tween.kill() # Stoppe tout tween précédent
			tween = create_tween()
			tween.tween_property(viewport_quad, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			viewport_quad.visible = false
			ui_viewport_buttonsCanvasLayer.desactive_ui()
		# Add the player in the zone
		add_player_to_area(body)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		print_debug("player exited")
		# Disparition élégante
		tween.kill()
		tween = create_tween()
		tween.tween_property(viewport_quad, "scale", Vector3(0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(Callable(viewport_quad, "hide_ui"))
		# viewport_quad.visible = false
		# ui_viewport_buttonsCanvasLayer.desactive_ui()
		#destroy player
		remove_player_to_area(body)

func hide_ui():
	viewport_quad.visible = false
	# ui_viewport_buttonsCanvasLayer.desactive_ui()


func add_player_to_area(player: Node3D) -> void:
	if not players_in_area.has(player):
		players_in_area.append(player)
		player.add_interactable_to_player(self)
		# print_debug("Players in area: ", players_in_area.size())

func remove_player_to_area(player: Node3D) -> void:
	if players_in_area.has(player):
		player.remove_interactable_from_player(self)
		players_in_area.erase(player)
		# print_debug("Players in area: ", players_in_area.size())

#Actions

func _press_x_action(player:Player) ->void:
	# Un joueur commence ou continue à appuyer
	if current_interactable_action == interactableActions.PressXActionSeconds:
		player_holding[player] = true
		if not player_hold_times.has(player):
			player_hold_times[player] = 0.0
		# Met à jour le slider à la valeur actuelle
		var progress = clamp(player_hold_times[player] / hold_duration, 0, 1)
		ui_viewport_buttonsCanvasLayer.modify_slider(progress * 100)


func _release_x_action(player:Player) ->void:
	# Un joueur relâche le bouton
	if current_interactable_action == interactableActions.PressXActionSeconds:
		player_holding[player] = false
		player_hold_times[player] = 0.0
		ui_viewport_buttonsCanvasLayer.modify_slider(0)

func _process(delta):
	# Met à jour le temps d'appui pour chaque joueur
	for player in players_in_area:
		if player_holding.get(player, false):
			player_hold_times[player] += delta
			var progress = clamp(player_hold_times[player] / hold_duration, 0, 1)
			ui_viewport_buttonsCanvasLayer.modify_slider(progress * 100)
			if player_hold_times[player] >= hold_duration:
				# print_debug("Player ", player.id, " a maintenu X pendant ", hold_duration, " secondes !")
				player_holding[player] = false # Empêche de re-déclencher
				player_hold_times[player] = 0.0
				ui_viewport_buttonsCanvasLayer.modify_slider(100)
				needs_repair = false
		else:
			player_hold_times[player] = 0.0