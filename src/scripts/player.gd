extends CharacterBody2D

# Movement
const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const ACCELERATION = 1500.0
const FRICTION = 1200.0

# Attack
var is_attacking = false
var attack_duration = 0.3
var attack_timer = 0.0

# References
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/AttackShape
@onready var attack_sprite = $AttackArea/AttackSprite
@onready var sprite = $Sprite2D
@onready var camera = $Camera2D

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Enable camera smoothing
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0

func _physics_process(delta):
	# Handle attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()
	
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
	
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
	attack_shape.disabled = false
	attack_sprite.visible = true
	
	# Check for enemies in attack area
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(10)

func end_attack():
	is_attacking = false
	attack_shape.disabled = true
	attack_sprite.visible = false
