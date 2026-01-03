extends CharacterBody2D

class_name PlayerController

## Script du joueur

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0


func _physics_process(_delta: float) -> void:
	# Ajouter la gravité
	if not is_on_floor():
		velocity += get_gravity() * _delta

	# Gérer le saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Gérer le déplacement horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
