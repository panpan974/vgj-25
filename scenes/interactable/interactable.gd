@tool
extends Area3D

@onready var ui_viewport_buttons: SubViewport = %ui_viewport_buttons
@onready var ui_viewport_buttonsCanvasLayer: UIViewportButtons = %ui_viewport_buttonsCanvasLayer
@onready var viewport_quad : MeshInstance3D = %viewport_quad

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    ui_viewport_buttons.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
    viewport_quad.material_override.albedo_texture = ui_viewport_buttons.get_texture()
    viewport_quad.visible = false
    ui_viewport_buttonsCanvasLayer.switch_ui(false)
    

#Player detection
func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("players"):
        print_debug("player entered")
        #Hide the ui_viewport_buttons
        viewport_quad.visible = true
        ui_viewport_buttonsCanvasLayer.switch_ui(true)

func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("players"):
        print_debug("player exited")
        viewport_quad.visible = false
        ui_viewport_buttonsCanvasLayer.switch_ui(false)



#Actions
func _press_randomly() -> void:
    pass