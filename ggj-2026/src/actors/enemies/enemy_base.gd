extends CharacterBody2D
class_name EnemyBase

## Script de base pour les ennemis (beat'em up)

signal died(enemy: EnemyBase)

# === EXPORTS ===
@export var speed: float = 80.0
@export var attack_range: float = 50.0
@export var detection_range: float = 300.0
@export var score_value: int = 100
@export var knockback_friction: float = 1.0
@export var knockback_force: float = 20.0

# === REFERENCES ===
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite2D

# === STATE ===
var target: Node2D = null
var _knockback_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("enemies")
	y_sort_enabled = true
	health_component.died.connect(_on_died)

	# Trouver le joueur dans la scène
	await get_tree().process_frame
	target = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	# Appliquer la décélération du knockback
	_knockback_velocity = lerp(_knockback_velocity, Vector2.ZERO, knockback_friction)

	# Combiner le mouvement AI avec le knockback
	velocity += _knockback_velocity
	move_and_slide()

	# Mise à jour du z_index pour le tri visuel
	z_index = int(global_position.y)

	# Orienter le sprite selon la direction
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func apply_knockback(direction: Vector2, force: float = knockback_force) -> void:
	_knockback_velocity = direction.normalized() * force


func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	health_component.take_damage(amount)

	if knockback_dir != Vector2.ZERO:
		apply_knockback(knockback_dir)

	if state_machine and state_machine.states.has("Hurt"):
		state_machine._on_transition_requested(state_machine.current_state, "Hurt")


func _on_died() -> void:
	GameManager.score += score_value
	died.emit(self)
	queue_free()


func get_facing_direction() -> Vector2:
	return Vector2(-1, 0) if sprite.flip_h else Vector2(1, 0)
