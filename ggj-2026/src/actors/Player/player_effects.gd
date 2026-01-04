extends Node2D

class_name PlayerEffects

# 💡 Ideas
# respawned: Reset camera position, play respawn animation/particles, update checkpoint UI, grant temporary invincibility
# took_damage: Update health bar UI, play hurt sound/animation, flash screen red, trigger knockback
# died: Die sound, animation, respawn, remove lives

# jumped: Jump sound, particle effects, camera bump
# wall_jumped: Different sound than regular jump, wall dust particles
# landed: Landing sound, dust particles, screen shake (heavy landing), squash animation
# dash_recharged: Flash dash UI indicator, play subtle "ready" sound, show visual feedback

# attack_started: Swing sound, weapon trail effect
# attack_ended: Cleanup effects, cooldown UI
# attack_hit: Hit sound, impact particles, screen shake, damage numbers, freeze frame


## Handles effects for the player (responds to player signals)

@onready var _particle_manager: ParticleManager = $ParticleManager

# Player-specific particle scenes
@export_group("Particle Scenes")
@export var jump_particles: PackedScene
@export var land_particles: PackedScene

var _player: PlayerController

func _ready() -> void:
	# Get player reference
	_player = get_parent() as PlayerController
	_connect_signals()

## Connect to all player signals
func _connect_signals() -> void:
	_player.jumped.connect(_on_player_jumped)
	_player.landed.connect(_on_player_landed)
	_player.died.connect(_on_player_died)
	_player.respawned.connect(_on_player_respawned)

## === MOVEMENT EFFECTS ===
func _on_player_jumped() -> void:
	var pos := _player.global_position + Vector2(0, 8)
	_particle_manager.spawn_particle(jump_particles, pos, Vector2.DOWN)

func _on_player_landed() -> void:
	var pos := _player.global_position + Vector2(0, 8)

	# Scale based on fall velocity (heavier landing = more particles)
	var fall_velocity: float = abs(_player.velocity.y)
	var scale_multiplier: float = clamp(fall_velocity / 500.0, 0.5, 2.0)

	_particle_manager.spawn_particle(land_particles, pos, Vector2.DOWN, scale_multiplier)

## === STATUS EFFECTS ===
func _on_player_died() -> void:
	_particle_manager.cleanup_all_particles()

func _on_player_respawned() -> void:
	_particle_manager.cleanup_all_particles()
