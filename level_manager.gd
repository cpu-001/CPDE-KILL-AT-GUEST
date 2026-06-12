extends Node

@onready var move = $"../Move"
@onready var enemy_spawner = $"../EnemySpawner"


func apply_level():
	match Gamedata.level:
		1:
			move.speed = 200
			enemy_spawner.spawn_rate = 2.0

		2:
			move.speed = 300
			enemy_spawner.spawn_rate = 1.2

		3:
			move.speed = 400
			enemy_spawner.spawn_rate = 0.8
