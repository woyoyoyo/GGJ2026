# Level 01 - Test Level

Ce niveau de test permet de tester les mécaniques de base du jeu :
- **Mouvement** : Touches A/D ou Flèches gauche/droite
- **Saut** : Barre d'espace
- **Attaque** : Clic gauche de la souris

## Contenu du niveau

- Sol principal
- 4 plateformes à différentes hauteurs
- Murs gauche et droite pour délimiter l'aire de jeu
- Caméra qui suit le joueur automatiquement

## Personnage / Player

Le joueur est un CharacterBody2D avec :
- **Mouvement latéral** : vitesse de 300 pixels/seconde
- **Saut** : vélocité de -500 (gravité par défaut du projet)
- **Attaque** : zone d'attaque devant le joueur (48x32 pixels)
  - Durée : 0.3 secondes
  - Ralentissement du mouvement pendant l'attaque
- **Sprite** : Rectangle bleu (32x64 pixels)
- **Caméra** : Camera2D avec lissage pour un suivi fluide

## Pour tester

1. Ouvrez le projet dans Godot
2. Lancez la scène `src/scenes/level_01.tscn`
3. Utilisez les contrôles pour explorer le niveau
