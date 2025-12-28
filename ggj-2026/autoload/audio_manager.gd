extends Node
## Gestionnaire audio centralisé
## Facilite la gestion de la musique et des effets sonores

@onready var music_player := AudioStreamPlayer.new()
@onready var sfx_player := AudioStreamPlayer.new()

var music_volume: float = 0.8
var sfx_volume: float = 1.0


func _ready() -> void:
	add_child(music_player)
	add_child(sfx_player)
	music_player.bus = "Music"
	sfx_player.bus = "SFX"


func play_music(stream: AudioStream, fade_in: bool = true) -> void:
	if fade_in:
		music_player.volume_db = -80
		music_player.stream = stream
		music_player.play()
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), 1.0)
	else:
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()


func stop_music(fade_out: bool = true) -> void:
	if fade_out:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 1.0)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())
