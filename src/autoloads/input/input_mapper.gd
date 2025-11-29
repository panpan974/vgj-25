extends Node

var inputs: Dictionary[String, String]

var input_ids: Array = []

const MOVE_LEFT_ACTION: String = "move_left"
const MOVE_RIGHT_ACTION: String = "move_right"
const MOVE_UP_ACTION: String = "move_up"
const MOVE_DOWN_ACTION: String = "move_down"
const ACTION_ACTION: String = "action"
const CANCEL_ACTION: String = "cancel"
const UP_BUTTON_ACTION: String = "up"
const DOWN_BUTTON_ACTION: String = "down"
const LEFT_BUTTON_ACTION: String = "left"
const RIGHT_BUTTON_ACTION: String = "right"
const VALIDATE_ACTION: String = "validate"

const ACTION_MAP_DEFAULT: Dictionary[String, Dictionary] = {
	MOVE_LEFT_ACTION: {"axis": JOY_AXIS_LEFT_X, "type": "axis", "value": - 1.0},
	MOVE_RIGHT_ACTION: {"axis": JOY_AXIS_LEFT_X, "type": "axis", "value": 1.0},
	MOVE_UP_ACTION: {"axis": JOY_AXIS_LEFT_Y, "type": "axis", "value": - 1.0},
	MOVE_DOWN_ACTION: {"axis": JOY_AXIS_LEFT_Y, "type": "axis", "value": 1.0},
	ACTION_ACTION: {"button": JOY_BUTTON_A, "type": "button"},
	CANCEL_ACTION: {"button": JOY_BUTTON_B, "type": "button"},
	UP_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_UP, "type": "button"},
	DOWN_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_DOWN, "type": "button"},
	LEFT_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_LEFT, "type": "button"},
	RIGHT_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_RIGHT, "type": "button"},
	VALIDATE_ACTION: {"button": JOY_BUTTON_X, "type": "button"},
}

# Map for spectial controllers based on the guid
const ACTION_MAP_DEVICE_SPECIFIC: Dictionary[String, Dictionary] = {
	# Example for Steam Deck (uncomment and fill if needed)
	"0300fa675e0400008e02000002017801": {
		MOVE_LEFT_ACTION: {"axis": JOY_AXIS_LEFT_X, "type": "axis", "value": - 1.0},
		MOVE_RIGHT_ACTION: {"axis": JOY_AXIS_LEFT_X, "type": "axis", "value": 1.0},
		MOVE_UP_ACTION: {"axis": JOY_AXIS_LEFT_Y, "type": "axis", "value": - 1.0},
		MOVE_DOWN_ACTION: {"axis": JOY_AXIS_LEFT_Y, "type": "axis", "value": 1.0},
		ACTION_ACTION: {"button": JOY_BUTTON_A, "type": "button"},
		CANCEL_ACTION: {"button": JOY_BUTTON_B, "type": "button"},
		UP_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_UP, "type": "button"},
		DOWN_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_DOWN, "type": "button"},
		LEFT_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_LEFT, "type": "button"},
		RIGHT_BUTTON_ACTION: {"button": JOY_BUTTON_DPAD_RIGHT, "type": "button"},
		VALIDATE_ACTION: {"button": JOY_BUTTON_Y, "type": "button"},
	},
}

signal on_controller_added(device_id: int)

func _ready() -> void:
	# Input.joy_connection_changed.connect(_on_joy_connection_changed)
	# If there are already connected devices, create action maps for them
	# if SteamManager.is_on_steam_deck:
	# 	print_debug(Steam.getConnectedControllers())
	# 	Steam.input_device_connected.connect(_on_joy_connection_changed)
	print_debug("Connected devices: ", Input.get_connected_joypads())
	for device_id in Input.get_connected_joypads():
		print_debug(Input.get_joy_info(device_id), " - ", Input.get_joy_name(device_id), " - ", Input.get_joy_guid(device_id))
	# 	if device_id not in input_ids:
	# 		input_ids.append(device_id)
	# 		_create_action_map_for_device(device_id)
	# 		on_controller_added.emit(device_id)

func _unhandled_input(event: InputEvent) -> void:
	# print_debug("Unhandled input event: ", event)
	# If our device is not in the input_ids it's a new controller
	if event is InputEventJoypadButton:
		if event.device not in input_ids:
			input_ids.append(event.device)
			_create_action_map_for_device(event.device)
			on_controller_added.emit(event.device)

# Wait for the first input event to really add the controller
# func detect_first_input_event() -> void:
# func _unhandled_input(event: InputEvent) -> void:
# 	# Debug input to test which button we can map
# 	if event is InputEventJoypadMotion:
# 		# Only if value > 0.5 to avoid noise
# 		if not abs(event.axis_value) > 0.5:
# 			return
# 	print("New Input: ", event)
	# Try to cast to enum string
	# var event_name: String
	# if event is InputEventJoypadButton:
	# 	event_name = "joy_" + str(event.device) + "_" + get_action_from_button(event.button_index)
	# elif event is InputEventJoypadMotion:
	# 	event_name = "joy_" + str(event.device) + "_" + event.axis
	# else:
	# 	return
	# print("Event Name: ", event_name)
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Stop rumble on all devices when the window is closed
		for device_id in input_ids:
			Input.stop_joy_vibration(device_id)

func _create_action_map_for_device(device_id: int):
	var action_map: Dictionary = get_action_map_for_device(device_id)
	for action in action_map.keys():
		var action_name: String = "joy_" + str(device_id) + "_" + action
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event: InputEvent
			match action_map[action]["type"]:
				"axis":
					var axis: int = action_map[action]["axis"]
					event = InputEventJoypadMotion.new()
					event.axis = axis
					event.axis_value = action_map[action]["value"]
				"button":
					var button: int = action_map[action]["button"]
					event = InputEventJoypadButton.new()
					event.button_index = button
					print_debug("Mapping button ", button, " to action ", action_name, " for device ID: ", device_id)
			event.device = device_id
			InputMap.action_add_event(action_name, event)
	# Add in default ui_action event for the first device
	if device_id == input_ids[0] and InputMap.has_action("ui_accept"):
		var ui_accept_event: InputEventJoypadButton = InputEventJoypadButton.new()
		ui_accept_event.button_index = action_map[ACTION_ACTION]["button"]
		ui_accept_event.device = device_id
		if not InputMap.action_has_event("ui_accept", ui_accept_event):
			InputMap.action_add_event("ui_accept", ui_accept_event)
	# print_debug("Action map created for device ID: ", device_id)
	# for action in InputMap.get_actions():
	# 	if action.begins_with("joy_" + str(device_id) + "_"):
	# 		print_debug("Action: ", action, " is mapped for device ID: ", device_id)

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		print("Device connected: ", device_id)
		print_debug("Device info: ", Input.get_joy_guid(device_id), " - ", Input.get_joy_name(device_id))
		if device_id not in input_ids:
			input_ids.append(device_id)
			_create_action_map_for_device(device_id)
			on_controller_added.emit(device_id)
	else:
		print("Device disconnected: ", device_id)
		if device_id in input_ids:
			input_ids.erase(device_id)
			print("Removed device: ", device_id)

func get_action_from_button(button: int, device_id: int) -> String:
	var action_map: Dictionary = get_action_map_for_device(device_id)
	for action in action_map.keys():
		if action_map[action]["type"] == "button" and action_map[action]["button"] == button:
			return action
	return ""

func get_action_map_for_device(device_id: int) -> Dictionary:
	var guid: String = Input.get_joy_guid(device_id)
	if guid in ACTION_MAP_DEVICE_SPECIFIC.keys():
		return ACTION_MAP_DEVICE_SPECIFIC[guid]
	return ACTION_MAP_DEFAULT