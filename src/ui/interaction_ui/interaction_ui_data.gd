extends Resource
class_name InteractionUIData

@export var info_text: String = ""
@export var has_info_value: bool = false
@export var info_value: float = 0.0

@export var instruction_icon: Texture
@export var instruction_text: String = ""
@export var has_instruction_slider: bool = false
@export var instruction_value: float = 0.0
@export var has_instruction_element_array: bool = false
@export var instruction_element_array: Array[PackedScene] = []

@export var repaired_icon: Texture
@export var repaired_text: String = ""
