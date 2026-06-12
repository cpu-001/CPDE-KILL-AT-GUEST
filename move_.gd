extends Control

var speed = 200
@onready var spawn_point = $Marker2D
@onready var container = self

var spike_scene = preload("res://Pich.tscn")

func _on_spawn_timer_timeout():
	var spike = spike_scene.instantiate()
	add_child(spike)

	spike.global_position = spawn_point.global_position
