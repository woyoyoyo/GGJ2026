extends Node

## Signal émis lors d'une réaction chimique
signal reaction_occurred(reaction_type: String, position: Vector2)

## Structure d'une règle de réaction
class ReactionRule:
	var element_a: AttackData.ElementType
	var element_b: AttackData.ElementType
	var result_attack_data: String  # Chemin vers le .tres
	var reaction_name: String
	var destroy_both: bool = true
	
	func _init(elem_a: AttackData.ElementType, elem_b: AttackData.ElementType, result: String, name: String, destroy: bool = true):
		element_a = elem_a
		element_b = elem_b
		result_attack_data = result
		reaction_name = name
		destroy_both = destroy
	
	func matches(type_a: AttackData.ElementType, type_b: AttackData.ElementType) -> bool:
		return (type_a == element_a and type_b == element_b) or \
			   (type_a == element_b and type_b == element_a)

## Table des réactions (facile à étendre)
var reaction_rules: Array[ReactionRule] = []

## Cache des ressources
var attack_instance_scene: PackedScene = null
var cached_attack_data: Dictionary = {}

func _ready() -> void:
	# Initialiser les règles de réactions
	_setup_reaction_rules()
	
	# Précharger la scène d'attaque
	attack_instance_scene = load("res://src/combat/components/attack_instance.tscn")

## Configure toutes les règles de réactions
func _setup_reaction_rules() -> void:
	# FIRE + GAS = EXPLOSION
	reaction_rules.append(ReactionRule.new(
		AttackData.ElementType.FIRE,
		AttackData.ElementType.GAS,
		"res://src/combat/data/explosion_attack.tres",
		"FIRE_GAS_EXPLOSION"
	))
	
	# Ajouter d'autres réactions ici facilement:
	# WATER + ELECTRIC = ELECTRIFIED_WATER
	# reaction_rules.append(ReactionRule.new(
	#     AttackData.ElementType.WATER,
	#     AttackData.ElementType.ELECTRIC,
	#     "res://src/scripts/electrified_water.tres",
	#     "WATER_ELECTRIC_SHOCK"
	# ))
	
	# WIND + FIRE = FIRESTORM
	# reaction_rules.append(ReactionRule.new(
	#     AttackData.ElementType.WIND,
	#     AttackData.ElementType.FIRE,
	#     "res://src/scripts/firestorm.tres",
	#     "WIND_FIRE_STORM"
	# ))

## Résout l'interaction entre deux attaques
## Retourne true si une réaction s'est produite
func resolve(attack_a: Node2D, attack_b: Node2D) -> bool:
	# Vérifier que les deux nœuds ont une AttackData
	if not attack_a.has_meta("attack_data") or not attack_b.has_meta("attack_data"):
		return false
	
	var data_a: AttackData = attack_a.get_meta("attack_data")
	var data_b: AttackData = attack_b.get_meta("attack_data")
	
	# Chercher une règle correspondante
	for rule in reaction_rules:
		if rule.matches(data_a.element_type, data_b.element_type):
			_apply_reaction(attack_a, attack_b, rule)
			return true
	
	return false

## Applique une réaction selon la règle
func _apply_reaction(attack_a: Node2D, attack_b: Node2D, rule: ReactionRule) -> void:
	# Calculer la position de la réaction
	var reaction_position = (attack_a.global_position + attack_b.global_position) / 2.0
	
	# Détruire les attaques si nécessaire (différé pour éviter les conflits de collision)
	if rule.destroy_both:
		attack_a.call_deferred("queue_free")
		attack_b.call_deferred("queue_free")
	
	# Créer l'attaque résultante (différé aussi)
	call_deferred("_spawn_result_attack", reaction_position, rule)
	
	# Émettre le signal
	reaction_occurred.emit(rule.reaction_name, reaction_position)
	print("💥 Réaction: ", rule.reaction_name, " à ", reaction_position)

## Spawn l'attaque résultante d'une réaction
func _spawn_result_attack(position: Vector2, rule: ReactionRule) -> void:
	# Charger l'AttackData (avec cache)
	var result_data = _load_attack_data(rule.result_attack_data)
	
	if result_data == null or attack_instance_scene == null:
		return
	
	# Créer l'instance
	var result_attack = attack_instance_scene.instantiate()
	get_tree().current_scene.add_child(result_attack)
	result_attack.initialize(result_data, position, Vector2.ZERO)

## Charge une AttackData avec cache
func _load_attack_data(path: String) -> AttackData:
	if not cached_attack_data.has(path):
		cached_attack_data[path] = load(path)
	return cached_attack_data[path]

## Fonction utilitaire pour obtenir le nom d'un type d'élément
func get_element_name(element_type: AttackData.ElementType) -> String:
	match element_type:
		AttackData.ElementType.NONE: return "NONE"
		AttackData.ElementType.FIRE: return "FIRE"
		AttackData.ElementType.GAS: return "GAS"
		AttackData.ElementType.WATER: return "WATER"
		AttackData.ElementType.ELECTRIC: return "ELECTRIC"
		AttackData.ElementType.WIND: return "WIND"
		_: return "UNKNOWN"
