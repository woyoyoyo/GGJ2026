extends Node2D

@export var game_duration: float = 10.0

var _time_elapsed: float = 0.0
var _last_score: int = 0

@onready var hud: HUD = $HUD


func _ready() -> void:
	print("Main scene _ready()")
	GameManager.start_game()
	hud.update_timer(0.0)


func _process(delta: float) -> void:
	if GameManager.is_game_running:
		_time_elapsed += delta

		# Mettre à jour le HUD
		hud.update_timer(_time_elapsed)

		# Augmenter le score au fil du temps (seulement si changé)
		var new_score: int = int(_time_elapsed * 100)
		if new_score != _last_score:
			_last_score = new_score
			GameManager.score = new_score

		# Game over après la durée configurée
		if _time_elapsed >= game_duration:
			GameManager.end_game()
