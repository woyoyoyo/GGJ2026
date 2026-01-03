extends Node
## Centralized constants for the game
## Holds all hardcoded values like scene paths, audio bus names, etc.

class_name GameConstants

# Scene paths
const SCENE_MAIN_MENU: String = "res://src/ui/main_menu.tscn"
const SCENE_SETTINGS_MENU: String = "res://src/ui/settings_menu.tscn"
const SCENE_CONTROLS_SETTINGS: String = "res://src/ui/controls_settings.tscn"
const SCENE_CREDITS_MENU: String = "res://src/ui/credits_menu.tscn"
const SCENE_GAME_OVER: String = "res://src/ui/game_over.tscn"
const SCENE_PAUSE_MENU: String = "res://src/ui/pause_menu.tscn"
const SCENE_MAIN_GAME: String = "res://scenes/main.tscn"

# Audio bus names (already hardcoded in your code)
const AUDIO_BUS_MASTER: String = "Master"
const AUDIO_BUS_MUSIC: String = "Music"
const AUDIO_BUS_SFX: String = "SFX"

# Save settings keys
const SETTING_MASTER_VOLUME: String = "master_volume"
const SETTING_MUSIC_VOLUME: String = "music_volume"
const SETTING_SFX_VOLUME: String = "sfx_volume"
const SETTING_FULLSCREEN: String = "fullscreen"
const SETTING_VSYNC: String = "vsync"
