extends Control


func _ready() -> void:
	_update_texts()
	LocalizationManager.language_changed.connect(_on_language_changed)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _update_texts() -> void:
	$VBoxContainer/Title.text = tr("MAIN_MENU_TITLE")
	$VBoxContainer/StartButton.text = tr("BTN_START")
	$VBoxContainer/SettingsButton.text = tr("BTN_SETTINGS")
	$VBoxContainer/CreditsButton.text = tr("BTN_CREDITS")
	$VBoxContainer/QuitButton.text = tr("BTN_QUIT")


func _on_language_changed(_locale: String) -> void:
	_update_texts()


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://scenes/main.tscn")


func _on_settings_pressed() -> void:
	SceneManager.change_scene("res://ui/settings_menu.tscn")


func _on_credits_pressed() -> void:
	SceneManager.change_scene("res://ui/credits_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
