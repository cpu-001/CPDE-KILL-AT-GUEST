extends CharacterBody2D

@export var speed := 150.0
@export var jump_force := -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var death_particles_scene: PackedScene

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):

	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	velocity.x = direction.x * speed

	move_and_slide()

func spawn_death_effect():
	if death_particles_scene == null:
		return

	var fx = death_particles_scene.instantiate()

	get_tree().current_scene.add_child(fx)

	# 🔥 CLAVE ABSOLUTA
	fx.global_position = global_position


func die():
	spawn_death_effect()
	queue_free()
