extends CanvasLayer

class_name GameOver

@onready var control: Control = $Control
@onready var title_label: Label = $Control/VBoxContainer/Title
@onready var score_label: Label = $Control/VBoxContainer/ScoreLabel
@onready var best_score_label: Label = $Control/VBoxContainer/BestScoreLabel
@onready var restart_button: Button = $Control/VBoxContainer/ButtonsContainer/RestartButton
@onready var main_menu_button: Button = $Control/VBoxContainer/ButtonsContainer/MainMenuButton
@onready var quit_button: Button = $Control/VBoxContainer/ButtonsContainer/QuitButton

var current_scene_path: String = ""


func _ready() -> void:
	control.hide()
	GameManager.game_over.connect(_on_game_over)
	LocalizationManager.language_changed.connect(_update_texts)
	_update_texts()


func _update_texts(_locale: String = "") -> void:
	title_label.text = tr("GAME_OVER_TITLE")
	restart_button.text = tr("GAME_OVER_REPLAY")
	main_menu_button.text = tr("PAUSE_MAIN_MENU")
	quit_button.text = tr("BTN_QUIT")


func _on_game_over() -> void:
	if SceneManager.current_scene:
		current_scene_path = SceneManager.current_scene.scene_file_path
	score_label.text = tr("GAME_OVER_SCORE") % GameManager.score
	
	# Charger et afficher le meilleur score
	var best_score = SaveManager.get_best_score()
	if GameManager.score > best_score:
		SaveManager.save_best_score(GameManager.score)
		best_score = GameManager.score
	
	best_score_label.text = tr("GAME_OVER_BEST_SCORE") % best_score
	control.show()
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	control.hide()
	SceneManager.reload_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	control.hide()
	SceneManager.change_scene(GameConstants.SCENE_MAIN_MENU)


func _on_quit_pressed() -> void:
	get_tree().quit()
