extends Control



func _on_gorra_pressed():
	Gamedata.has_cap = !Gamedata.has_cap
func _on_lentes_pressed():
	Gamedata.has_glasses = !Gamedata.has_glasses

func _on_cara_pressed():
	Gamedata.has_face = !Gamedata.has_face

func _on_button_pressed():
	$ModdifyB.play("desaparicion")

func _on_red_pressed():
	Gamedata.color_body = Color(1, 0, 0)
	Gamedata.color_arm = Color(1, 0, 0)
	Gamedata.color_detail = Color(1, 0, 0)

func _on_blue_pressed():
	Gamedata.color_body = Color(0, 0, 1)
	Gamedata.color_detail = Color(0, 0, 1)
	Gamedata.color_arm = Color(0, 0, 1)

func _on_green_pressed():
	Gamedata.color_body = Color(0, 1, 0)
	Gamedata.color_arm = Color(0, 1, 0)
	Gamedata.color_detail = Color(0, 1, 0)


func _on_pink_pressed() -> void:
	Gamedata.color_body = Color(255, 0, 157)
	Gamedata.color_arm = Color(255, 0, 157)
	Gamedata.color_detail = Color(255, 0, 157)

func _on_white_pressed() -> void:
	Gamedata.color_body = Color(1, 1, 1)
	Gamedata.color_arm = Color(1, 1, 1)
	Gamedata.color_detail = Color(1, 1, 1)

func _on_black_pressed() -> void:
	Gamedata.color_body = Color(0.089, 0.089, 0.089, 1.0)
	Gamedata.color_arm = Color(0.089, 0.089, 0.089, 1.0)
	Gamedata.color_detail = Color(0.089, 0.089, 0.089, 1.0)


func _on_lentes_2_pressed() -> void:
	pass # Replace with function body.
