extends CharacterBody2D

class_name PlayerController

## Script du joueur

# Signals
signal died

# Movement
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const ACCELERATION = 1500.0
const FRICTION = 1200.0

# Coyote Time & Jump Buffer
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.1
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# Attack
var is_attacking = false
var attack_duration = 0.3
var attack_timer = 0.0

# References
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/AttackShape
@onready var attack_sprite = $AttackArea/AttackColorRect
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	# Handle attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()
	
	# Update timers
	var was_on_floor = is_on_floor()
	
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
	
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Handle jump with Coyote Time and Jump Buffer
	if jump_buffer_timer > 0 and coyote_timer > 0 and not is_attacking:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()
	
	# Get the input direction
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Flip sprite based on direction
	if direction > 0:
		sprite.flip_h = false
		attack_area.position.x = abs(attack_area.position.x)
	elif direction < 0:
		sprite.flip_h = true
		attack_area.position.x = -abs(attack_area.position.x)
	
	# Handle movement (reduced speed while attacking)
	if direction != 0:
		var move_speed = SPEED * 0.5 if is_attacking else SPEED
		velocity.x = move_toward(velocity.x, direction * move_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	move_and_slide()

func start_attack():
	is_attacking = true
	attack_timer = attack_duration
	
	# Play attack animation if available
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
	else:
		# Fallback: manual activation
		attack_shape.disabled = false
		attack_sprite.visible = true

func end_attack():
	is_attacking = false
	
	# Only disable manually if not using animation
	if not animation_player or not animation_player.has_animation("attack"):
		attack_shape.disabled = true
		attack_sprite.visible = false

func _on_attack_hit():
	# Called by animation or manually
	# Check for enemies in attack area
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(10)
