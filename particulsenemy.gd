extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	# seguridad
	await get_tree().process_frame

	particles.emitting = true
	anim.play("esploxit")

	# destruir cuando termine animación
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(name):
	if name == "esploxit":
		queue_free()
