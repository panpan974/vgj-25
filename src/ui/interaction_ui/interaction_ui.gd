extends CanvasLayer
class_name InteractionUI

@export var interaction_ui_data: InteractionUIData

@onready var info_container: Control = %Info
@onready var instruction_container: Control = %Instruction
@onready var repaired_container: Control = %Repaired

@onready var info_text: RichTextLabel = %InfoText
@onready var info_value_slider: Slider = %InfoValueSlider

@onready var instruction_icon: TextureRect = %InstructionIcon
@onready var instruction_text: Label = %InstructionText
@onready var instruction_slider: Slider = %InstructionValueSlider
@onready var instruction_element_array: Control = %InstructionElementArray

@onready var repaired_icon: TextureRect = %RepairedIcon
@onready var repaired_text: Label = %RepairedText

enum UIStates {
    Info,
	Instructions,
	Repaired,
}

var current_ui_state: UIStates = UIStates.Info

func _ready() -> void:
    disable_all()

func setup_signals(interactable: Interactable) -> void:
    interactable.set_interaction_ui_state.connect(switch_to_state)

func setup_all() -> void:
    setup_info()
    setup_instructions()
    setup_repaired()

func setup_info() -> void:
    info_text.text = interaction_ui_data.info_text
    if interaction_ui_data.has_info_value:
        info_value_slider.visible = true
        info_value_slider.value = interaction_ui_data.info_value
    else:
        info_value_slider.visible = false

func setup_instructions() -> void:
    instruction_icon.texture = interaction_ui_data.instruction_icon
    instruction_text.text = interaction_ui_data.instruction_text
    if interaction_ui_data.has_instruction_slider:
        instruction_slider.visible = true
        instruction_slider.value = interaction_ui_data.instruction_value
    else:
        instruction_slider.visible = false
    if interaction_ui_data.has_instruction_element_array:
        instruction_element_array.visible = true
        instruction_element_array.clear_children()
        for element_scene in interaction_ui_data.instruction_element_array:
            var element_instance = element_scene.instantiate()
            instruction_element_array.add_child(element_instance)
    else:
        instruction_element_array.visible = false

func setup_repaired() -> void:
    repaired_icon.texture = interaction_ui_data.repaired_icon
    repaired_text.text = interaction_ui_data.repaired_text

func disable_all() -> void:
    info_container.visible = false
    instruction_container.visible = false
    repaired_container.visible = false

func switch_to_info() -> void:
    info_container.visible = true
    current_ui_state = UIStates.Info
    print("Switched to Info UI")
    
func switch_to_instructions() -> void:
    instruction_container.visible = true
    current_ui_state = UIStates.Instructions

func switch_to_repaired() -> void:
    repaired_container.visible = true
    current_ui_state = UIStates.Repaired

func switch_to_state(new_state: UIStates) -> void:
    disable_all()
    match new_state:
        UIStates.Info:
            switch_to_info()
        UIStates.Instructions:
            switch_to_instructions()
        UIStates.Repaired:
            switch_to_repaired()


func update_info_value() -> void:
    if current_ui_state == UIStates.Info and interaction_ui_data:
        info_text.text = interaction_ui_data.info_text
        info_value_slider.value = interaction_ui_data.info_value
    
func update_instruction_value() -> void:
    if current_ui_state == UIStates.Instructions and interaction_ui_data:
        instruction_text.text = interaction_ui_data.instruction_text
        instruction_slider.value = interaction_ui_data.instruction_value
    
func _process(delta: float) -> void:
    match current_ui_state:
        UIStates.Info:
            update_info_value()
        UIStates.Instructions:
            update_instruction_value()