extends Control

class_name MainMenu


func _ready() -> void:
	AudioManager.play_music(preload(GameConstants.MUSIC_LOGO))
	_update_texts()
	_initialize_signals()


func _update_texts() -> void:
	$VBoxContainer/Title.text = tr("MAIN_MENU_TITLE")
	$VBoxContainer/StartButton.text = tr("BTN_START")
	$VBoxContainer/SettingsButton.text = tr("BTN_SETTINGS")
	$VBoxContainer/CreditsButton.text = tr("BTN_CREDITS")
	$VBoxContainer/QuitButton.text = tr("BTN_QUIT")


func _initialize_signals() -> void:
	LocalizationManager.language_changed.connect(_on_language_changed)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_language_changed(_locale: String) -> void:
	_update_texts()


func _on_start_pressed() -> void:
	SceneManager.change_scene(GameConstants.SCENE_MAIN_GAME)


func _on_settings_pressed() -> void:
	SceneManager.change_scene(GameConstants.SCENE_SETTINGS_MENU)


func _on_credits_pressed() -> void:
	SceneManager.change_scene(GameConstants.SCENE_CREDITS_MENU)


func _on_quit_pressed() -> void:
	get_tree().quit()
