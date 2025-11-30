class_name UIViewportButtons extends CanvasLayer

@onready var icon: TextureRect = %icon
@onready var text: Label = %text
@onready var slider: HSlider = %slider
@onready var main_control: Control = %main_control
@onready var instruction_container: Control = %instruction_container
@onready var repaired_container: Control = %repaired_container

enum uiStates {
	Instructions,
	Repaired,
}
var current_ui_state: uiStates = uiStates.Instructions
func _ready() -> void:
	desactive_ui()

func desactive_ui() -> void:
	switch_ui_instructions(false)
	switch_ui_repaired(false)


func switch_ui_instructions(state: bool) -> void:
	instruction_container.visible = state

func switch_ui_repaired(state: bool) -> void:
	repaired_container.visible = state

func modify_icon(new_icon: Texture) -> void:
	icon.texture = new_icon

func modify_text(new_text: String) -> void:
	text.text = new_text

func modify_slider(new_value: float) -> void:
	slider.value = new_value
	if new_value >= slider.max_value:
		change_ui_state(uiStates.Repaired)


func change_ui_state(new_state: uiStates) -> void:
	current_ui_state = new_state
	match current_ui_state:
		uiStates.Instructions:
			switch_ui_instructions(true)
			switch_ui_repaired(false)
			modify_slider(0.0)
		uiStates.Repaired:
			switch_ui_instructions(false)
			switch_ui_repaired(true)
