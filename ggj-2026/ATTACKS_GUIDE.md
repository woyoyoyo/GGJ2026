# Guide des Attaques et Interactions - GGJ2026

## 🎭 Masques et Attaques Principales

### 🔥 FIRE (Feu)
- **Dégâts**: 15.0
- **Vitesse**: 400.0 (très rapide)
- **Portée**: 60.0
- **Cooldown**: 1.5s
- **Type**: Projectile rapide

### 💨 GAS (Gaz)
- **Dégâts**: 8.0
- **Vitesse**: 50.0 (très lent)
- **Portée**: 80.0
- **Cooldown**: 0.0 (spam possible)
- **Type**: Projectile lent inversé (va vers l'arrière)
- **Trainée**: Laisse du gaz statique tous les 20 pixels

### 💧 WATER (Eau)
- **Dégâts**: 8.0
- **Vitesse**: 400.0 (très rapide)
- **Portée**: 100.0 (2x plus loin que le feu)
- **Cooldown**: 1.5s
- **Type**: Projectile rapide
- **Trainée**: Laisse de l'eau statique tous les 25 pixels

### ❄️ ICE (Glace)
- **Dégâts**: 12.0
- **Vitesse**: 300.0
- **Portée**: 100.0
- **Cooldown**: 2.0s
- **Type**: Projectile moyen

### ⚡ LIGHTNING (Électricité)
- **Dégâts**: 18.0
- **Vitesse**: 0.0 (statique)
- **Portée**: 0.0 (spawn sur le joueur)
- **Rayon**: 250.0 (zone énorme)
- **Cooldown**: 2.5s
- **Durée**: 0.3s (très rapide)
- **Type**: Onde d'expansion autour du joueur
- **Spécial**: Ignore l'axe Y (touche sur toute la hauteur)

---

## 🧪 Zones Statiques

### 💨 GAS_STATIC
- **Dégâts**: 5.0
- **Durée**: 10.0s
- **Rayon**: 20.0

### 💧 WATER_STATIC
- **Dégâts**: 0.0 (aucun)
- **Durée**: 15.0s
- **Rayon**: 20.0

### ❄️ ICE_STATIC
- **Dégâts**: 0.0 (aucun)
- **Durée**: 12.0s
- **Rayon**: 20.0

### ⚡ LIGHTNING_STATIC
- **Dégâts**: 15.0
- **Durée**: 3.0s (court mais puissant)
- **Rayon**: 30.0

### 🧊💨 GAS_BLOCK (Gaz gelé)
- **Dégâts**: 5.0
- **Durée**: 999999.0s (quasiment infini)
- **Rayon**: 30.0

---

## 💥 Réactions Chimiques

### ❌ Annulation
| Éléments | Résultat | Description |
|----------|----------|-------------|
| 🔥 FEU + 💧 EAU | Rien | Les deux se détruisent mutuellement |

### 💥 Explosions
| Éléments | Résultat | Dégâts | Rayon | Durée | Description |
|----------|----------|--------|-------|-------|-------------|
| 🔥 FEU + 💨 GAZ | 💥 EXPLOSION | 25.0 | 60.0 | 1.5s | Le feu reste, le gaz explose |
| 💨 GAZ + ⚡ ÉLECTRICITÉ | 🔥💥 FIRE_EXPLOSION | 30.0 | 80.0 | 1.2s | Explosion de feu |
| 🔥 FEU + ⚡ ÉLECTRICITÉ | ⚡🔥 PLASMA | 37.0 | 50.0 | 0.5s | État le plus chaud de la matière |

### 🧊 Gel
| Éléments | Résultat | Description |
|----------|----------|-------------|
| 💨 GAZ + ❄️ GLACE | 🧊💨 GAS_BLOCK | Bloc de gaz gelé permanent |
| 💧 EAU + ❄️ GLACE | ❄️ ICE_STATIC | L'eau gèle au contact |

### 💧 Séparation
| Éléments | Résultat | Description |
|----------|----------|-------------|
| 💨 GAZ + 💧 EAU | 💧💧 2x WATER_STATIC | Crée 2 zones d'eau séparées de 40px |

### ⚡ Électrification
| Éléments | Résultat | Description |
|----------|----------|-------------|
| 💧 EAU + ⚡ ÉLECTRICITÉ | ⚡ LIGHTNING_STATIC | Zone électrique (15 dégâts pendant 3s) |
| ❄️ GLACE + ⚡ ÉLECTRICITÉ | ❄️💥 4x ICE_STATIC | Explosion en 4 zones de glace |

---

## 📊 Tableau Récapitulatif des Interactions

|  | 🔥 FEU | 💨 GAZ | 💧 EAU | ❄️ GLACE | ⚡ ÉLECTRICITÉ |
|---|---|---|---|---|---|
| **🔥 FEU** | - | 💥 EXPLOSION (25) | ❌ Annulation | - | ⚡🔥 PLASMA (37) |
| **💨 GAZ** | 💥 EXPLOSION (25) | - | 💧💧 2x Eau | 🧊💨 Bloc gelé | 🔥💥 Explosion feu (30) |
| **💧 EAU** | ❌ Annulation | 💧💧 2x Eau | - | ❄️ Glace | ⚡ Zone électrique (15) |
| **❄️ GLACE** | - | 🧊💨 Bloc gelé | ❄️ Glace | - | ❄️💥 4x Glace |
| **⚡ ÉLECTRICITÉ** | ⚡🔥 PLASMA (37) | 🔥💥 Explosion feu (30) | ⚡ Zone électrique (15) | ❄️💥 4x Glace | - |

**Légende:**
- `-` : Aucune interaction (se traversent)
- `(nombre)` : Dégâts de la réaction

---

## 🎮 Ordre de Puissance des Attaques

1. **⚡🔥 PLASMA** - 37 dégâts (FEU + ÉLECTRICITÉ)
2. **🔥💥 FIRE_EXPLOSION** - 30 dégâts (GAZ + ÉLECTRICITÉ)
3. **💥 EXPLOSION** - 25 dégâts (FEU + GAZ)
4. **⚡ LIGHTNING** - 18 dégâts (attaque principale)
5. **🔥 FIRE** - 15 dégâts (attaque principale)
6. **⚡ LIGHTNING_STATIC** - 15 dégâts (zone)
7. **❄️ ICE** - 12 dégâts (attaque principale)
8. **💧 WATER** - 8 dégâts (attaque principale)
9. **💨 GAS** - 8 dégâts (attaque principale)
10. **💨 GAS_STATIC** - 5 dégâts (zone)
11. **🧊💨 GAS_BLOCK** - 5 dégâts (zone permanente)
12. **💧 WATER_STATIC** - 0 dégâts (zone passive)
13. **❄️ ICE_STATIC** - 0 dégâts (zone passive)

---

## 💡 Stratégies Recommandées

### Combo Offensif Maximum
1. Poser du gaz derrière soi
2. Lancer de l'électricité dedans
3. **Résultat**: Explosion de feu (30 dégâts) + zone électrique

### Combo Défensif
1. Lancer de l'eau au sol
2. Lancer de la glace dessus
3. **Résultat**: Mur de glace statique

### Combo Zone Control
1. Spammer du gaz (CD 0)
2. Créer des trainées de gaz partout
3. **Résultat**: Zone toxique persistante (10s)

### Combo Burst Damage
1. Lancer du feu
2. Lancer de l'électricité au même endroit
3. **Résultat**: PLASMA ultra-puissant (37 dégâts en 0.5s)
