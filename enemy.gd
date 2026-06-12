extends CharacterBody2D

@export var base_points := 10
@export var death_particles_scene: PackedScene

var speed = 60
var target_node = null

@onready var body := $Body

func _ready():
	if not multiplayer.is_server():
		return

	target_node = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if target_node == null:
		target_node = get_tree().get_first_node_in_group("player")
		return

	var direction = (target_node.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func die():
	print("ENEMY DIE")

	spawn_death_effect()

	queue_free()

func spawn_death_effect():
	if death_particles_scene == null:
		return

	var fx = death_particles_scene.instantiate()

	get_tree().current_scene.add_child(fx)

	# 🔥 CLAVE ABSOLUTA
	fx.global_position = global_position

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(10, self)

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	if direction.x > 0:
		body.scale.x = 1
	elif direction.x < 0:
		body.scale.x = -1
