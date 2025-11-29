class_name UIViewportButtons extends CanvasLayer

@onready var icon:TextureRect = %icon
@onready var text:Label = %text
@onready var slider:HSlider = %slider
@onready var main_control:Control = %main_control

func _ready() -> void:
    switch_ui(false)

func switch_ui(state:bool) -> void:
    main_control.visible = state

func modify_icon(new_icon:Texture) -> void:
    icon.texture = new_icon

func modify_text(new_text:String) -> void:
    text.text = new_text

func modify_slider(new_value:float) -> void:
    slider.value = new_value