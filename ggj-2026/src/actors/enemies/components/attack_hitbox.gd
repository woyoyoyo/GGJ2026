extends Area2D
class_name EnemyAttackHitbox

## Hitbox d'attaque pour les ennemis
## Détecte les collisions avec le joueur pendant une attaque

signal hit_landed(body: Node2D)

@export var damage: int = 10
@export var knockback_force: float = 150.0

var _active: bool = false


func _ready() -> void:
	# Désactiver par défaut
	monitoring = false
	monitorable = false
	
	# Connecter le signal
	body_entered.connect(_on_body_entered)


func activate() -> void:
	_active = true
	monitoring = true
	monitorable = true


func deactivate() -> void:
	_active = false
	monitoring = false
	monitorable = false


func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	
	if body.is_in_group("player"):
		hit_landed.emit(body)
		
		# Appliquer knockback si le body a la méthode
		if body.has_method("apply_knockback"):
			var knockback_dir = (body.global_position - global_position).normalized()
			body.apply_knockback(knockback_dir, knockback_force)
