extends CanvasLayer

class_name PauseMenu


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	SceneManager.reload_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene(GameConstants.SCENE_MAIN_MENU)
