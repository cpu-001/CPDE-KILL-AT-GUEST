extends Node2D
var enemy_scene = preload("res://Enemy/enemy.tscn")

var spawn_rate = 2.0

@onready var timer = $Timer

func _ready():
	timer.wait_time = spawn_rate
	timer.start()

func _on_timer_timeout():
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = $Marker2D.global_position
