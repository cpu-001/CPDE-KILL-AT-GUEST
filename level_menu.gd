extends Control

@onready var lvl1_btn = $Node2D/level_1
@onready var lvl2_btn = $Node2D/level_2
@onready var lvl3_btn = $Node2D/level_3

@onready var lvl2_lock = $Node2D/locked2
@onready var lvl3_lock = $Node2D/locked3
var selected_level = 0

func _on_level_1_pressed():
	selected_level = 1
	$Node2D/Timer.start()
	$AnimationPlayer.play("transtitions")

func _on_level_2_pressed():
	selected_level = 2
	$Node2D/Timer.start()
	$AnimationPlayer.play("transtitions")
func _on_level_3_pressed():
	selected_level = 3
	$Node2D/Timer.start()
	$AnimationPlayer.play("transtitions")
func _ready():
	update_levels()


func update_levels():

	lvl1_btn.disabled = false

	if Gamedata.unlocked_level >= 2:
		lvl2_btn.disabled = false
		lvl2_lock.visible = false
	else:
		lvl2_btn.disabled = true
		lvl2_lock.visible = true

	if Gamedata.unlocked_level >= 3:
		lvl3_btn.disabled = false
		lvl3_lock.visible = false
	else:
		lvl3_btn.disabled = true
		lvl3_lock.visible = true


func _on_timer_timeout():

	Gamedata.player_name = $"../Node/Node2D/PlayerPreview/Label".text

	match selected_level:
		1:
			get_tree().change_scene_to_file("res://testRPG.tscn")

		2:
			get_tree().change_scene_to_file("res://test2RPG.tscn")

		3:
			get_tree().change_scene_to_file("res://test3RPG.tscn")
