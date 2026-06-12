extends CharacterBody2D

@export var speed := 850.0
@export var jump_force := -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing := 1
var has_key := false
@onready var player_name = $CanvasLayer/name
@onready var hand_right = $body/hand
@onready var colordaño = $WarnigUI/ColorRect
@onready var gun_point_left = $body/hand/Marker2D
@onready var lentes = [
	$Customs/Lentes03,
]
@onready var gorra = $Customs/Gorra2
@onready var face = $Customs/Cara02
@onready var colorbody = $body/ColorRect
@onready var colorhand1 = $body/hand/ColorRect3
@onready var colorhand2 = $body/hand/ColorRect5

const BULLET_SCENE = preload("res://Players/Bullet.tscn")


func _physics_process(delta):

	# gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("ui_left", "ui_right")

	# CAMBIO DE LADO (MANOS + MARKER)
	if direction > 0:
		facing = 1
		hand_right.visible = true

	elif direction < 0:
		facing = -1
		hand_right.visible = false

	# movimiento
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()


func _process(_delta):

	update_color()
	update_customs()

	player_name.text = Gamedata.player_name


	if Input.is_action_just_pressed("fire"):
		shoot()


func shoot():

	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	var gun_point = null

	if facing == 1:
		gun_point = gun_point_left

	if gun_point == null:
		print("ERROR: gun_point es null")
		return

	bullet.global_position = gun_point.global_position
	bullet.direction = facing


func show_warning():

	colordaño.visible = true

	await get_tree().create_timer(0.9).timeout

	colordaño.visible = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):

		var warning = get_tree().get_first_node_in_group("WarnigUI")

		if warning:
			warning.show_warning()

func update_customs():

	if face:
		face.visible = Gamedata.has_face
	# -------- GORRA --------
	if gorra:
		gorra.visible = Gamedata.has_cap

	# -------- LENTES (TOGGLE LIMPIO) --------
	for i in range(lentes.size()):
		lentes[i].visible = Gamedata.has_glasses

func update_color():
	colorbody.color = Gamedata.color_body
	colorhand1.color = Gamedata.color_arm
	colorhand2.color = Gamedata.color_detail
