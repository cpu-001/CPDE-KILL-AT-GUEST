extends Control


var player_scene = preload("res://Players/code/Player.tscn")
@onready var enu = $enu
@onready var preview_holder = $Node/Node2D/PlayerPreview
@onready var ainmdd = $Node2D/animationplayer

func _ready():
	var player = player_scene.instantiate()
	preview_holder.add_child(player)

	# ❌ desactivar control
	player.set_multiplayer_authority(0)
	player.set_process_input(false)
	player.set_physics_process(false)
	player.set_preview_mode(true)

func _on_jugar_pressed():
	enu.play("APAPA")
	if ainmdd != null:
		ainmdd.play("EASY")
	$PointLight2D.visible = false
	$Node/Node2D/OptionsMenu.visible = false
	$Node/Node2D/detro.visible = false
	$LevelMenu.visible = true
	$Node/Node2D/MENUD.visible = false
	$Node/Node2D/Button.visible = false
	$Node/Node2D/Button2.visible = false
	$Node/Node2D/Button3.visible = false
	$Node/Node2D/Button4.visible = false
	$Node/Node2D/Preview.visible = false
	$Node/Node2D/PlayerPreview.visible = false
	$Node/Node2D/Label.visible = false

func _on_multiplayer_on_pressed():
	Global.multiplayer_mode = true
	get_tree().change_scene_to_file("res://Test.tscn")

func _on_multiplayer_off_pressed():
	Global.multiplayer_mode = false
	get_tree().change_scene_to_file("res://Test.tscn")

func _on_salir_pressed():
	get_tree().quit()

@onready var name_input = $LineEdit

func _on_line_edit_text_changed(text):
	Gamedata.player_name = text

func _on_moddify_pressed():
	$ModdifyA.play("aparicion")


func set_preview_mode(value: bool):
	$CanvasLayer.visible = not value
	$Label.visible = not value
