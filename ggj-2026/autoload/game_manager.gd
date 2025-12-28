extends Node
## Gestionnaire global du jeu
## Utiliser pour gérer l'état du jeu, les scores, etc.

signal game_started
signal game_over
signal score_changed(new_score: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var is_game_running: bool = false


func start_game() -> void:
	score = 0
	is_game_running = true
	game_started.emit()


func end_game() -> void:
	is_game_running = false
	game_over.emit()


func add_score(points: int) -> void:
	score += points
