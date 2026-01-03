extends Camera2D

class_name CameraController

## Contrôleur de caméra qui suit une cible

@export var target: Node2D
@export var smoothing_speed: float = 5.0
@export var offset_y: float = -50.0  # Offset vertical pour voir plus haut

func _ready() -> void:
	enabled = true
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed
	
	# Debug
	if target:
		print("Camera target found: ", target.name)
	else:
		print("Camera target is null!")

func _process(_delta: float) -> void:
	if target:
		global_position = Vector2(target.global_position.x, target.global_position.y + offset_y)
