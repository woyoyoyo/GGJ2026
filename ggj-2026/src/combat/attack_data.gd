class_name AttackData
extends Resource

## Enumération des types d'éléments possibles
enum ElementType {
	NONE,
	FIRE,
	GAS,
	WATER,
	ELECTRIC,
	WIND
}

## Type d'élément de l'attaque
@export var element_type: ElementType = ElementType.NONE

## Dégâts infligés par l'attaque
@export var damage: float = 10.0

## Distance d'apparition par rapport au joueur
@export var range_distance: float = 50.0

## Durée de vie de la zone d'attaque (en secondes)
@export var dissipation_time: float = 3.0

## Temps de recharge avant de pouvoir réutiliser l'attaque
@export var cooldown: float = 1.0

## Vitesse de déplacement (0 = statique, >0 = projectile)
@export var speed: float = 0.0

## Rayon de la zone de collision
@export var collision_radius: float = 20.0

## Effet visuel (particules/sprites)
@export var visual_effect: PackedScene = null
