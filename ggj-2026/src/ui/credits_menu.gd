extends Control

class_name CreditsMenu


func _on_back_pressed() -> void:
	SceneManager.change_scene(GameConstants.SCENE_MAIN_MENU)
