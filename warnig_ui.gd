extends CanvasLayer

func show_warning():

	visible = true

	await get_tree().create_timer(2.0).timeout

	visible = false
