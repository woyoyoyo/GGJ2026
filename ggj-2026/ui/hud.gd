extends CanvasLayer

@onready var score_label: Label = $MarginContainer/ScoreLabel
@onready var timer_label: Label = $MarginContainer/TimerLabel


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func update_timer(time: float) -> void:
	var minutes = int(time) / 60.0
	var seconds = int(time) % 60
	timer_label.text = "Time: %d:%02d" % [minutes, seconds]
