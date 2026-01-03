extends Node
## Gestionnaire de remapping des touches

signal input_remapped(action: String)

var default_inputs: Dictionary = {}


func _ready() -> void:
	# Sauvegarder les inputs par défaut
	save_default_inputs()
	# Charger les inputs personnalisés
	load_custom_inputs()


func save_default_inputs() -> void:
	var actions = ["move_left", "move_right", "move_up", "move_down", "jump", "action", "attack", "pause"]
	for action_name in actions:
		if InputMap.has_action(action_name):
			default_inputs[action_name] = InputMap.action_get_events(action_name).duplicate()


func get_action_display_name(action: String) -> String:
	var keys = {
		"move_left": "ACTION_MOVE_LEFT",
		"move_right": "ACTION_MOVE_RIGHT",
		"move_up": "ACTION_MOVE_UP",
		"move_down": "ACTION_MOVE_DOWN",
		"jump": "ACTION_JUMP",
		"action": "ACTION_ACTION",
		"attack": "ACTION_ATTACK",
		"pause": "ACTION_PAUSE"
	}
	return tr(keys.get(action, action))


func get_first_key_for_action(action: String) -> String:
	if not InputMap.has_action(action):
		return tr("KEY_UNASSIGNED")
	
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT: return tr("KEY_LEFT_CLICK")
				MOUSE_BUTTON_RIGHT: return tr("KEY_RIGHT_CLICK")
				MOUSE_BUTTON_MIDDLE: return tr("KEY_MIDDLE_CLICK")
	
	return tr("KEY_UNASSIGNED")


func remap_action(action: String, new_event: InputEvent) -> void:
	if not InputMap.has_action(action):
		return
	
	# Supprimer les anciens événements clavier/souris
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey or event is InputEventMouseButton:
			InputMap.action_erase_event(action, event)
	
	# Ajouter le nouveau
	InputMap.action_add_event(action, new_event)
	
	# Sauvegarder
	save_custom_inputs()
	input_remapped.emit(action)


func save_custom_inputs() -> void:
	var custom_inputs = {}
	var actions = ["move_left", "move_right", "move_up", "move_down", "jump", "action", "attack", "pause"]
	
	for action_name in actions:
		if not InputMap.has_action(action_name):
			continue
		
		var events = InputMap.action_get_events(action_name)
		var serialized_events = []
		
		for event in events:
			if event is InputEventKey:
				serialized_events.append({
					"type": "key",
					"keycode": event.physical_keycode
				})
			elif event is InputEventMouseButton:
				serialized_events.append({
					"type": "mouse",
					"button": event.button_index
				})
		
		custom_inputs[action_name] = serialized_events
	
	SaveManager.save_setting("custom_inputs", custom_inputs)


func load_custom_inputs() -> void:
	var custom_inputs = SaveManager.get_setting("custom_inputs", {})
	
	if custom_inputs.is_empty():
		return
	
	for action_name in custom_inputs:
		if not InputMap.has_action(action_name):
			continue
		
		# Supprimer les événements clavier/souris actuels
		var events = InputMap.action_get_events(action_name)
		for event in events:
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(action_name, event)
		
		# Ajouter les événements sauvegardés
		for event_data in custom_inputs[action_name]:
			var new_event: InputEvent
			
			if event_data["type"] == "key":
				new_event = InputEventKey.new()
				new_event.physical_keycode = event_data["keycode"]
			elif event_data["type"] == "mouse":
				new_event = InputEventMouseButton.new()
				new_event.button_index = event_data["button"]
			
			if new_event:
				InputMap.action_add_event(action_name, new_event)


func reset_to_defaults() -> void:
	for action_name in default_inputs:
		if not InputMap.has_action(action_name):
			continue
		
		# Supprimer tous les événements
		InputMap.action_erase_events(action_name)
		
		# Restaurer les événements par défaut
		for event in default_inputs[action_name]:
			InputMap.action_add_event(action_name, event)
	
	save_custom_inputs()
