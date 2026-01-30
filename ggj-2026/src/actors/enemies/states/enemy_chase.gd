extends State
class_name EnemyChaseState

@export var stop_distance: float = 100.0  # Stop moving when this close

var _enemy: EnemyBase

func enter() -> void:
	_enemy = get_parent().get_parent() as EnemyBase

func physics_update(_delta: float) -> void:
	if not _enemy or not _enemy.target:
		transition_requested.emit(self, "Idle")
		return
	
	var distance = _enemy.global_position.distance_to(_enemy.target.global_position)
	
	print("Distance: ", distance, " | stop_distance: ", stop_distance, " | attack_range: ", _enemy.attack_range)
	
	# Lost the player - return to Idle
	if distance > _enemy.detection_range:
		transition_requested.emit(self, "Idle")
		return
	
	# In attack range and can attack - do it
	if distance <= _enemy.attack_range and _enemy.can_attack():
		transition_requested.emit(self, "Attack")
		return
	
	# Movement: chase if too far, stop if close enough
	if distance > stop_distance:
		var direction = (_enemy.target.global_position - _enemy.global_position).normalized()
		_enemy.velocity = direction * _enemy.speed
	else:
		_enemy.velocity = Vector2.ZERO
