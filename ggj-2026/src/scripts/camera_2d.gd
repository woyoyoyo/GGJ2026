extends Camera2D

class_name Camera2DController

## Caméra 2D avec shake et follow smooth

@export var follow_target: Node2D
@export var follow_smoothness: float = 5.0
@export var shake_decay: float = 5.0

var _shake_strength: float = 0.0
var _shake_fade: float = 5.0


func _process(delta: float) -> void:
	# Follow target
	if follow_target:
		global_position = global_position.lerp(follow_target.global_position, follow_smoothness * delta)
	
	# Camera shake
	if _shake_strength > 0:
		_shake_strength = lerpf(_shake_strength, 0, shake_decay * delta)
		offset = Vector2(
			randf_range(-_shake_strength, _shake_strength),
			randf_range(-_shake_strength, _shake_strength)
		)


func shake(strength: float, fade_speed: float = 5.0) -> void:
	_shake_strength = strength
	_shake_fade = fade_speed
