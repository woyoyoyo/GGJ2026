extends Area2D

## Données de l'attaque
var attack_data: AttackData = null

## Direction de déplacement
var direction: Vector2 = Vector2.RIGHT

## Timer interne pour l'auto-destruction
var lifetime: float = 0.0

func _ready() -> void:
	# Connecter le signal de détection d'aire
	area_entered.connect(_on_area_entered)

func initialize(data: AttackData, spawn_position: Vector2, move_direction: Vector2) -> void:
	attack_data = data
	global_position = spawn_position
	direction = move_direction.normalized()
	
	# Stocker l'attack_data en metadata pour le ChemistryManager
	set_meta("attack_data", attack_data)
	
	# Ajuster la taille de la collision si définie
	if attack_data.collision_radius > 0:
		var collision_shape = $CollisionShape2D
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = attack_data.collision_radius
	
	# Configurer l'apparence visuelle si définie
	if attack_data.visual_effect != null:
		var effect = attack_data.visual_effect.instantiate()
		add_child(effect)
	else:
		# Sprite par défaut pour visualiser l'attaque
		_create_default_visual()

func _create_default_visual() -> void:
	var sprite = Sprite2D.new()
	var size = int(attack_data.collision_radius * 2)
	
	# Créer une texture de couleur selon l'élément
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var color = _get_element_color()
	image.fill(color)
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	add_child(sprite)

func _get_element_color() -> Color:
	if attack_data == null:
		return Color.WHITE
	
	match attack_data.element_type:
		AttackData.ElementType.FIRE:
			# Si dissipation_time est courte, c'est une explosion (plus lumineuse)
			if attack_data.dissipation_time <= 2.5:
				return Color(1.0, 0.6, 0.0, 0.9)  # Orange vif (explosion)
			else:
				return Color(1.0, 0.3, 0.0, 0.7)  # Orange/Rouge (feu normal)
		AttackData.ElementType.GAS:
			return Color(0.5, 1.0, 0.5, 0.5)  # Vert semi-transparent
		AttackData.ElementType.WATER:
			return Color(0.2, 0.5, 1.0, 0.6)  # Bleu
		AttackData.ElementType.ELECTRIC:
			return Color(1.0, 1.0, 0.0, 0.8)  # Jaune
		AttackData.ElementType.WIND:
			return Color(0.8, 0.8, 0.8, 0.4)  # Gris clair
		_:
			return Color.WHITE

func _process(delta: float) -> void:
	if attack_data == null:
		return
	
	# Déplacement si speed > 0
	if attack_data.speed > 0:
		global_position += direction * attack_data.speed * delta
	
	# Gestion de la durée de vie
	lifetime += delta
	if lifetime >= attack_data.dissipation_time:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Vérifier si c'est une autre AttackInstance
	if area.has_meta("attack_data"):
		# Appeler le ChemistryManager pour résoudre l'interaction
		ChemistryManager.resolve(self, area)
