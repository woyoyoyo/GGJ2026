extends Node2D

var EcranTitre = "res://src/ui/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BackgroundNoirEtBlanc.visible = true
	$BackgroundCouleur.visible = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$ArcEnCiel.position.y += 20

	if $ArcEnCiel.position.y > 1050:
		$BackgroundCouleur.visible = true
		$BackgroundNoirEtBlanc.visible = true


func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("validate"):
		$SonIntro.stop()
		_on_son_intro_finished()

func _on_son_intro_finished() -> void:
	get_tree().change_scene_to_file(EcranTitre)
