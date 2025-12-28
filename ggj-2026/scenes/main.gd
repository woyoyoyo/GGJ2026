extends Node2D

const GAME_DURATION = 10.0
var time_elapsed: float = 0.0

@onready var hud = $HUD


func _ready() -> void:
	print("Main scene _ready()")
	GameManager.start_game()
	hud.update_timer(0.0)


func _process(delta: float) -> void:
	if GameManager.is_game_running:
		time_elapsed += delta
		
		# Mettre à jour le HUD
		hud.update_timer(time_elapsed)
		
		# Augmenter le score au fil du temps
		GameManager.score = int(time_elapsed * 100)
		
		# Game over après 10 secondes
		if time_elapsed >= GAME_DURATION:
			GameManager.end_game()
