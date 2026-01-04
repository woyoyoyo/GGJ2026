extends CharacterBody2D

class_name PlayerController

## Script du joueur (mécanique de mouvement style Celeste)

# Signals
# Life cycle
signal died
signal respawned(position: Vector2)
signal took_damage(damage: int, health_remaining: int)

# Movement events
signal jumped
signal wall_jumped
signal landed
signal dashed
signal dash_recharged
signal wall_slide_started

# Combat
signal attack_started
signal attack_ended
signal attack_hit(target: Node2D)

# === MOVEMENT CONSTANTS ===
# Ground Movement
const SPEED: float = 300.0
const ACCELERATION: float = 1500.0
const FRICTION: float = 1200.0
const AIR_FRICTION: float = 400.0

# Jump
const JUMP_VELOCITY: float = -600.0
const JUMP_CUT_MULTIPLIER: float = 0.5 # Reduce jump height when releasing jump button
const VARIABLE_JUMP_HEIGHT: bool = true

# Coyote Time & Jump Buffer
const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.1

# Dash Mechanics (Celeste-style)
const DASH_SPEED: float = 800.0
const DASH_DURATION: float = 0.15
const DASH_COOLDOWN: float = 0.2
const MAX_DASHES: int = 1 # Reset when on the ground or on a wall

# Wall Slide & Wall Jump
const WALL_SLIDE_SPEED: float = 100.0
const WALL_JUMP_VELOCITY: Vector2 = Vector2(400.0, -500.0)
const WALL_CLIMB_SPEED: float = -120.0

# Gravity
const GRAVITY_SCALE: float = 1.0
const FALL_GRAVITY_MULTIPLIER: float = 1.5 # Fall faster than rising
const MAX_FALL_SPEED: float = 1000.0

# Attack
const ATTACK_DURATION: float = 0.3
const ATTACK_SPEED_MULTIPLIER: float = 0.5

# === STATE VARIABLES ===
# Timers
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _attack_timer: float = 0.0

# State flags
var _is_attacking: bool = false
var _is_dashing: bool = false
var _is_wall_sliding: bool = false
var _dashes_remaining: int = MAX_DASHES
var _dash_direction: Vector2 = Vector2.ZERO

# Wall detection
var _wall_normal: Vector2 = Vector2.ZERO

# References
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/AttackShape
@onready var attack_sprite: ColorRect = $AttackArea/AttackColorRect
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Physics
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var enable_dash: bool = true
@export var enable_wall_mechanics: bool = true


func _ready() -> void:
	# Initialize dash count
	_dashes_remaining = MAX_DASHES


func _physics_process(delta: float) -> void:
	# Update timers first
	_update_timers(delta)

	# Handle different movement states
	if _is_dashing:
		_handle_dash_movement(delta)
	else:
		# Check for wall slide
		if enable_wall_mechanics:
			_update_wall_slide()

		# Apply gravity
		_apply_gravity(delta)

		# Handle input
		_handle_jump_input()
		_handle_dash_input()
		_handle_attack_input()

		# Handle horizontal movement
		_handle_horizontal_movement(delta)

	# Move the character
	move_and_slide()

	# Post-movement updates
	_update_dash_recharge()
	_update_sprite_direction()


## Updates all timers
func _update_timers(delta: float) -> void:
	# Attack timer
	if _is_attacking:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_end_attack()

	# Coyote time and landing detection
	var was_on_floor := _coyote_timer >= COYOTE_TIME
	if is_on_floor():
		if not was_on_floor:
			landed.emit()
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer -= delta

	# Jump buffer
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta

	# Dash timers
	if _dash_timer > 0:
		_dash_timer -= delta
		if _dash_timer <= 0:
			_end_dash()

	if _dash_cooldown_timer > 0:
		_dash_cooldown_timer -= delta


## Applies gravity with variable fall speed (Celeste-style)
func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	# Apply different gravity when falling vs rising
	var gravity_multiplier: float = GRAVITY_SCALE
	if velocity.y > 0: # Falling
		gravity_multiplier *= FALL_GRAVITY_MULTIPLIER

	velocity.y += gravity * gravity_multiplier * delta

	# Cap fall speed
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Wall slide reduces fall speed
	if _is_wall_sliding:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)


## Handles jump input with coyote time, jump buffer, and variable height
func _handle_jump_input() -> void:
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_TIME

	# Ground jump or wall jump
	if _jump_buffer_timer > 0:
		# Wall jump
		if enable_wall_mechanics and _is_wall_sliding and not is_on_floor():
			_perform_wall_jump()
			_jump_buffer_timer = 0
			return

		# Normal jump with coyote time
		if _coyote_timer > 0 and not _is_attacking:
			_perform_jump()
			_jump_buffer_timer = 0
			_coyote_timer = 0

	# Variable jump height - cut jump short when releasing button
	if VARIABLE_JUMP_HEIGHT and Input.is_action_just_released("jump"):
		if velocity.y < 0: # Only if moving upward
			velocity.y *= JUMP_CUT_MULTIPLIER


## Performs a normal jump
func _perform_jump() -> void:
	velocity.y = JUMP_VELOCITY
	jumped.emit()


## Performs a wall jump
func _perform_wall_jump() -> void:
	# Jump away from wall
	velocity.x = _wall_normal.x * WALL_JUMP_VELOCITY.x
	velocity.y = WALL_JUMP_VELOCITY.y
	_is_wall_sliding = false
	wall_jumped.emit()


## Handles dash input and execution
func _handle_dash_input() -> void:
	if not enable_dash or _is_attacking:
		return

	# Check if can dash
	if Input.is_action_just_pressed("action"):
		if _dashes_remaining > 0 and _dash_cooldown_timer <= 0:
			_perform_dash()


## Performs a dash in the input direction
func _perform_dash() -> void:
	# Get dash direction from input
	var input_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# Default to horizontal direction if no input
	if input_dir.length() < 0.1:
		input_dir = Vector2(1 if not sprite.flip_h else -1, 0)
	else:
		input_dir = input_dir.normalized()

	_dash_direction = input_dir
	_is_dashing = true
	_dash_timer = DASH_DURATION
	_dashes_remaining -= 1

	dashed.emit()


## Handles movement during dash
func _handle_dash_movement(_delta: float) -> void:
	velocity = _dash_direction * DASH_SPEED


## Ends the dash state
func _end_dash() -> void:
	_is_dashing = false
	_dash_cooldown_timer = DASH_COOLDOWN
	# Preserve some momentum
	velocity *= 0.5


## Updates wall slide state
func _update_wall_slide() -> void:
	if is_on_floor() or _is_dashing:
		if _is_wall_sliding:
			_is_wall_sliding = false
		return

	# Check for wall contact
	var was_wall_sliding := _is_wall_sliding
	_is_wall_sliding = false

	if is_on_wall():
		_wall_normal = get_wall_normal()

		# Only slide if moving into the wall or falling
		var input_dir := Input.get_axis("ui_left", "ui_right")
		var moving_into_wall: bool = sign(input_dir) == -sign(_wall_normal.x)

		if moving_into_wall and velocity.y > 0:
			_is_wall_sliding = true
			if not was_wall_sliding:
				wall_slide_started.emit()


## Recharges dash when on floor or wall
func _update_dash_recharge() -> void:
	if is_on_floor() or (_is_wall_sliding and enable_wall_mechanics):
		if _dashes_remaining < MAX_DASHES:
			_dashes_remaining = MAX_DASHES
			dash_recharged.emit()


## Handles horizontal movement with acceleration/friction
func _handle_horizontal_movement(delta: float) -> void:
	if _is_dashing:
		return

	var direction := Input.get_axis("ui_left", "ui_right")

	# Apply movement or friction
	if direction != 0:
		var target_speed := SPEED

		# Reduce speed when attacking
		if _is_attacking:
			target_speed *= ATTACK_SPEED_MULTIPLIER

		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
	else:
		# Use different friction for air vs ground
		var friction_value := FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction_value * delta)


## Updates sprite flip based on movement direction
func _update_sprite_direction() -> void:
	# Only update direction if moving significantly or has input
	var input_dir := Input.get_axis("ui_left", "ui_right")

	if input_dir > 0:
		sprite.flip_h = false
		attack_area.position.x = abs(attack_area.position.x)
	elif input_dir < 0:
		sprite.flip_h = true
		attack_area.position.x = - abs(attack_area.position.x)


## Handles attack input
func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_start_attack()


## Starts an attack
func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = ATTACK_DURATION
	attack_started.emit()

	# Play attack animation if available
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
	else:
		# Fallback: manual activation
		if attack_shape:
			attack_shape.disabled = false
		if attack_sprite:
			attack_sprite.visible = true


## Ends an attack
func _end_attack() -> void:
	_is_attacking = false
	attack_ended.emit()

	# Only disable manually if not using animation
	if not animation_player or not animation_player.has_animation("attack"):
		if attack_shape:
			attack_shape.disabled = true
		if attack_sprite:
			attack_sprite.visible = false


## Called when attack hits - can be triggered by animation or manually
func _on_attack_hit() -> void:
	if not attack_area:
		return

	var bodies: Array[Node2D] = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(10)
			attack_hit.emit(body)


## Respawns the player at a specific position
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_is_dashing = false
	_is_wall_sliding = false
	_is_attacking = false
	_dashes_remaining = MAX_DASHES
	respawned.emit(spawn_position)


## Handles taking damage (optional health system integration)
func take_damage(damage: int) -> void:
	# This is a placeholder - implement your health system here
	# Example with a health variable:
	# _health -= damage
	# took_damage.emit(damage, _health)
	# if _health <= 0:
	#     die()
	took_damage.emit(damage, 0)  # Placeholder with 0 health


## Triggers death
func die() -> void:
	died.emit()
	# You might want to disable input, play animation, etc.
	# set_physics_process(false)
