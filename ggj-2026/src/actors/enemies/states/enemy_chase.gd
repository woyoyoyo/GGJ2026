extends State
class_name EnemyChaseState

## État de poursuite - l'ennemi poursuit le joueur

@export var lose_range: float = 400.0

var _enemy: EnemyBase


func enter() -> void:
	_enemy = get_parent().get_parent() as EnemyBase


func physics_update(_delta: float) -> void:
	if not _enemy or not _enemy.target:
		transition_requested.emit(self, "Idle")
		return

	var distance = _enemy.global_position.distance_to(_enemy.target.global_position)

	# Perdu la cible
	if distance > lose_range:
		transition_requested.emit(self, "Idle")
		return

	# Se déplacer vers le joueur
	var direction = (_enemy.target.global_position - _enemy.global_position).normalized()
	_enemy.velocity = direction * _enemy.speed
