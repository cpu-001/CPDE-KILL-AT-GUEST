extends Camera2D
var velocity := Vector2.ZERO

@export var target_path: NodePath
@export var smooth_speed := 6.0

@onready var target = get_node(target_path)

func _process(delta):

	if target == null:
		return

	var desired_position = target.global_position

	global_position = global_position.lerp(desired_position, smooth_speed * delta)

	var target_pos = target.global_position

	global_position = global_position.move_toward(
		target_pos,
		200 * delta
	)
