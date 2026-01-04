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

# === PARTICLE SCENE REFERENCES ===
@export_group("Particle Scenes")
@export var jump_particles: PackedScene
@export var land_particles: PackedScene

# === PARTICLE SETTINGS ===
@export_group("Particle Settings")
@export var enable_particles: bool = true
@export var particle_scale: float = 1.0
@export_range(0.0, 1.0) var particle_opacity: float = 1.0

# === STATE ===
var _player: PlayerController

# Particle pool for performance
var _particle_pool: Dictionary = {}
const POOL_SIZE: int = 20

func _ready() -> void:
	# Get player reference
	_player = get_parent() as PlayerController

	if not _player:
		push_error("PlayerEffects must be a child of PlayerController")
		return

	# Connect to all player signals
	_connect_signals()

	# Initialize particle pool
	_initialize_particle_pool()

func _process(_delta: float) -> void:
	if not enable_particles or not _player:
		return

## Connect to all player signals
func _connect_signals() -> void:
	# Movement signals
	_player.jumped.connect(_on_player_jumped)
	_player.landed.connect(_on_player_landed)

## Initialize particle object pool
func _initialize_particle_pool() -> void:
	var scenes: Array[PackedScene] = [
		jump_particles,
		land_particles,
	]

	for scene in scenes:
		if scene:
			_particle_pool[scene] = []

## === PARTICLE SPAWNING ===

## Gets the best parent node for spawning particles
func _get_particle_parent() -> Node:
	# Try current scene first (most common)
	var scene_tree := get_tree()
	if scene_tree and scene_tree.current_scene:
		return scene_tree.current_scene

	# Fallback to scene root
	if scene_tree and scene_tree.root:
		return scene_tree.root

	# Last resort: use this node as parent (particles will move with player)
	return self

## Spawns particles at a position (uses pooling)
func _spawn_particles(scene: PackedScene, pos: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	if not enable_particles or not scene:
		return

	var particles: GPUParticles2D = _get_pooled_particle(scene)

	if not particles:
		particles = scene.instantiate() as GPUParticles2D

	if not particles:
		return

	# Configure particles
	particles.global_position = pos
	particles.scale = Vector2.ONE * particle_scale
	particles.modulate.a = particle_opacity
	particles.emitting = true

	# Rotate based on direction if provided
	if direction.length() > 0:
		particles.rotation = direction.angle()

	# Add to scene - try multiple parent options
	var parent := _get_particle_parent()
	if not parent:
		push_warning("PlayerEffects: No valid parent found for particles")
		particles.queue_free()
		return

	parent.add_child(particles)

	# Auto-cleanup when finished (check if not already connected)
	if particles.one_shot:
		if not particles.finished.is_connected(_on_particle_finished):
			particles.finished.connect(_on_particle_finished.bind(particles, scene))

## Get particle from pool or create new
func _get_pooled_particle(scene: PackedScene) -> GPUParticles2D:
	if scene not in _particle_pool:
		_particle_pool[scene] = []

	var pool: Array = _particle_pool[scene]

	# Try to reuse existing particle (particles in pool are already finished and ready)
	if pool.size() > 0:
		var particle: GPUParticles2D = pool.pop_back()
		if is_instance_valid(particle):
			print("♻️ Reusing pooled particle (pool size: ", pool.size(), ")")
			return particle

	print("🆕 Creating new particle (pool size: ", pool.size(), ")")
	return null

## Return particle to pool when finished
func _on_particle_finished(particle: GPUParticles2D, scene: PackedScene) -> void:
	if not is_instance_valid(particle):
		return

	# Remove from parent
	if particle.get_parent():
		particle.get_parent().remove_child(particle)

	# Reset particle state
	particle.emitting = false
	particle.restart()

	# Add to pool if not full
	if scene in _particle_pool and _particle_pool[scene].size() < POOL_SIZE:
		_particle_pool[scene].append(particle)
		print("✅ Particle returned to pool (pool size now: ", _particle_pool[scene].size(), ")")
	else:
		particle.queue_free()
		print("🗑️ Pool full, particle freed")

## === MOVEMENT EFFECTS ===

## Called when player jumps
func _on_player_jumped() -> void:
	if jump_particles:
		var spawn_pos := _player.global_position + Vector2(0, 8) # Offset to feet
		_spawn_particles(jump_particles, spawn_pos, Vector2.DOWN)

## Called when player lands
func _on_player_landed() -> void:
	if land_particles:
		var spawn_pos := _player.global_position + Vector2(0, 8)

		# Scale based on fall velocity (heavier landing = more particles)
		var fall_velocity: float = abs(_player.velocity.y)
		var scale_multiplier: float = clamp(fall_velocity / 500.0, 0.5, 2.0)

		var temp_scale := particle_scale
		particle_scale *= scale_multiplier
		_spawn_particles(land_particles, spawn_pos, Vector2.DOWN)
		particle_scale = temp_scale

## === UTILITY ===

## Cleanup all active particles
func cleanup_all_particles() -> void:
	for pool in _particle_pool.values():
		for particle in pool:
			if is_instance_valid(particle):
				particle.queue_free()
		pool.clear()
