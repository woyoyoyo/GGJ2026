extends State
class_name EnemyAttackState

## État d'attaque - l'ennemi attaque le joueur

@export var attack_duration: float = 0.5  # Durée de l'animation d'attaque
@export var attack_cooldown: float = 1.0  # Temps entre les attaques
@export var attack_damage: int = 10

var _enemy: EnemyBase
var _timer: float = 0.0
var _has_hit: bool = false  # Éviter les multi-hits pendant une attaque


func enter() -> void:
	_enemy = get_parent().get_parent() as EnemyBase
	_enemy.velocity = Vector2.ZERO
	_timer = attack_duration
	_has_hit = false
	
	# Activer la hitbox d'attaque
	_enemy.enable_attack_hitbox(true)
	
	# Optionnel: jouer animation d'attaque
	# if _enemy.sprite:
	#     _enemy.animation_player.play("Attack")


func exit() -> void:
	# Désactiver la hitbox
	_enemy.enable_attack_hitbox(false)


func physics_update(delta: float) -> void:
	_timer -= delta
	
	if _timer <= 0:
		# Attaque terminée, retourner en Chase après cooldown
		transition_requested.emit(self, "Chase")


## Appelé quand la hitbox touche quelque chose
func on_attack_hit(body: Node2D) -> void:
	if _has_hit:
		return
	
	if body.is_in_group("player") and body.has_method("take_damage"):
		_has_hit = true
		body.take_damage(attack_damage)
		print("Enemy hit player for ", attack_damage, " damage!")
