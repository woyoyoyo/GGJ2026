extends CharacterBody2D

class_name PlayerController

## Script du joueur (mouvement fluide avec inertie et rotation)

# Signals
signal died
signal respawned(position: Vector2)
signal took_damage(damage: int, health_remaining: int)
signal dashed
signal attack_started
signal attack_ended

# === MOVEMENT CONSTANTS ===
@export var speed: float = 200.0
@export var speed_boost: float = 1.5  # Multiplicateur de vitesse
@export var inertia: float = 0.15  # 0.0 = lourd, 1.0 = aérien

# Dash
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

# Attack
@export var attack_duration: float = 0.3
@export var attack_offset: float = 30.0  # Distance de spawn de l'attaque

# Attack Data pour tests
var fire_attack_data: AttackData = preload("res://src/combat/data/fire_attack.tres")
var gas_static_data: AttackData = preload("res://src/combat/data/gas_static.tres")

# === STATE VARIABLES ===
var direction: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _is_boosted: bool = false  # Pour un boost de vitesse (dash/skill)

# Timers
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _attack_timer: float = 0.0

# State flags
var _is_attacking: bool = false
var _is_dashing: bool = false

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	if animation_player and animation_player.has_animation("swim"):
		animation_player.play("swim")


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	
	# Ne pas traiter les inputs si en train d'attaquer ou de dasher
	if not _is_attacking and not _is_dashing:
		_handle_input()
	
	# Appliquer le mouvement
	_apply_movement(delta)
	
	# Rotation du sprite vers la direction
	if _velocity.length() > 10:
		sprite.rotation = _velocity.angle() + deg_to_rad(-90)
	
	set_velocity(_velocity)
	move_and_slide()


func _update_timers(delta: float) -> void:
	# Attack timer
	if _is_attacking:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_end_attack()
	
	# Dash timers
	if _dash_timer > 0:
		_dash_timer -= delta
		if _dash_timer <= 0:
			_end_dash()
	
	if _dash_cooldown_timer > 0:
		_dash_cooldown_timer -= delta


func _handle_input() -> void:
	# Lecture des inputs de déplacement
	direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	# Dash
	if Input.is_action_just_pressed("dash") and _dash_cooldown_timer <= 0:
		_perform_dash()
	
	# Test attacks
	if Input.is_action_just_pressed("ui_accept"):  # Espace - Gaz statique
		_spawn_attack(gas_static_data)
	
	if Input.is_action_just_pressed("attack"):  # Attack - Boule de feu
		_spawn_attack(fire_attack_data)


func _apply_movement(_delta: float) -> void:
	if _is_dashing:
		# En dash, maintenir la vitesse constante
		_velocity = _velocity
	else:
		# Calculer la vitesse cible
		var speed_multiplier = speed_boost if _is_boosted else 1.0
		var target_velocity = direction * speed * speed_multiplier
		
		# Interpolation fluide avec inertie
		_velocity = lerp(_velocity, target_velocity, inertia)


func _perform_dash() -> void:
	# Direction du dash (input ou direction actuelle)
	var dash_dir = direction if direction.length() > 0.1 else Vector2(cos(sprite.rotation + deg_to_rad(90)), sin(sprite.rotation + deg_to_rad(90)))
	
	_velocity = dash_dir.normalized() * dash_speed
	_is_dashing = true
	_dash_timer = dash_duration
	_dash_cooldown_timer = dash_cooldown
	dashed.emit()


func _end_dash() -> void:
	_is_dashing = false


func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_duration
	attack_started.emit()


func _end_attack() -> void:
	_is_attacking = false
	attack_ended.emit()


## Active un boost de vitesse temporaire
func set_speed_boost(enabled: bool) -> void:
	_is_boosted = enabled


## Obtient la direction du regard pour les attaques
func get_facing_direction() -> Vector2:
	# Direction basée sur la rotation du sprite
	return Vector2(cos(sprite.rotation + deg_to_rad(90)), sin(sprite.rotation + deg_to_rad(90)))


## Respawns the player at a specific position
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	_velocity = Vector2.ZERO
	_is_dashing = false
	_is_attacking = false
	respawned.emit(spawn_position)


## Handles taking damage (optional health system integration)
func take_damage(damage: int) -> void:
	took_damage.emit(damage, 0)


## Triggers death
func die() -> void:
	died.emit()


## Spawn une attaque à partir d'AttackData
func _spawn_attack(attack_data: AttackData) -> void:
	# Position de spawn devant le joueur
	var spawn_position = global_position + get_facing_direction() * attack_offset
	
	# Utiliser le ChemistryManager pour spawn (disponible pour tous les acteurs)
	ChemistryManager.spawn_attack(attack_data, spawn_position, get_facing_direction())
