extends CharacterBody2D

# ---------------- VARIABLES ----------------
var projectile_scene: PackedScene
var jump_scale_tween: Tween

var max_ammo := 30
var ammo := 30

var slide_speed := 0.0
var slide_friction := 5000.0
var max_slide_speed := 780.0

var max_health := 120
var health := 120

var knockback_force := 900
var knockback_dir := Vector2.ZERO
var is_knocked := false

var is_reloading := false
var is_firing := false

const SPEED := 900.0
const JUMP_VELOCITY := -500.0
const DEATH_FALL_SPEED := 350.0

var is_dead := false
var death_started := false

var god_mode_active := false

var score: int = 0

signal score_changed(new_score)

func add_score(value: int):
	score += value
	emit_signal("score_changed", score)

# ---------------- NODES ----------------
@onready var name_label = $CanvasLayer/Label
@onready var command_panel = $CanvasLayer/CommandPanel
@onready var command_input = $CanvasLayer/CommandPanel/Input
@onready var command_log = $CanvasLayer/CommandPanel/Log
@onready var anim_player = $AnimationPlayer
@onready var fire_point = $FirePoint
@onready var ammo_label = $CanvasLayer/AmmoLabel
@onready var hp_bar = $CanvasLayer/ProgressBar
@onready var damage_overlay = $"CanvasLayer2/DAÑO"
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var customs = $Customs
@onready var gorra = $Customs/Gorra
@onready var face = $Customs/Cara01
@onready var time_label = $CanvasLayer/TimeLabel
@onready var body = $Body
@onready var color1 = $Hands/ColorRect2/ColorRect6
@onready var color2 = $Hands/ColorRect3/ColorRect7
@onready var color3 = $Body/ColorRect
@onready var lentes = [
	$Customs/Lentes02,
]
# ---------------- READY ----------------
func _ready():

	for i in range(lentes.size()):
		lentes[i].visible = false

	if gorra:
		gorra.visible = false

	command_panel.visible = false
	command_input.connect("text_submitted", Callable(self, "_on_command_entered"))

	projectile_scene = preload("res://projectile/Projectile.tscn")

	update_ammo_ui()

	hp_bar.max_value = max_health
	hp_bar.value = health

	add_to_group("player")
	anim_player.play("idle")

# ---------------- PHYSICS ----------------
func _physics_process(delta):
	if is_dead:
		velocity.y += DEATH_FALL_SPEED * delta
		velocity.x = 0
		move_and_slide()
		return

	if is_on_floor() and velocity.y == 0 and anim_player.current_animation != "idle":
		anim_player.play("idle")

	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		slide_speed = velocity.x
	else:
		if abs(slide_speed) > 10:
			velocity.x = slide_speed
			slide_speed = move_toward(slide_speed, 0, slide_friction * delta)
		else:
			velocity.x = 0

	if is_knocked:
		velocity = knockback_dir * knockback_force
		is_knocked = false

	move_and_slide()

# ---------------- PROCESS ----------------
func _process(_delta):
	if is_dead:
		return

	var t = int(TimeManager.time_left)
	var minutes = t / 60
	var seconds = t % 60

	time_label.text = "%02d:%02d" % [minutes, seconds]

	update_color()
	update_customs()

	name_label.text = Gamedata.player_name

	if Input.is_action_just_pressed("ui_up"):
		command_panel.visible = not command_panel.visible
		if command_panel.visible:
			command_input.grab_focus()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_player.play("jump")

	if not is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("fire"):
		if is_firing or is_reloading or ammo <= 0:
			return
		shoot()

	if Input.is_action_just_pressed("reload"):
		start_reload()

# ---------------- SHOOT ----------------
func shoot():
	if is_firing or is_reloading or ammo <= 0:
		return

	is_firing = true
	anim_player.play("fire")

	spawn_projectile()

	ammo -= 1
	update_ammo_ui()

	await get_tree().create_timer(0.2).timeout
	is_firing = false

	if is_on_floor():
		anim_player.play("idle")

# ---------------- RELOAD ----------------
func start_reload():
	if is_reloading or ammo == max_ammo:
		return

	is_reloading = true
	anim_player.play("reload")

	await get_tree().create_timer(1.0).timeout

	ammo = max_ammo
	update_ammo_ui()

	is_reloading = false

	if is_on_floor():
		anim_player.play("idle")

# ---------------- PROJECTILE ----------------
func spawn_projectile():
	if not projectile_scene or not fire_point:
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = fire_point.global_position

	if projectile.has_method("set_velocity"):
		projectile.set_velocity(Vector2(0, -600))

# ---------------- DAMAGE ----------------
func take_damage(amount, source_node = null):
	if god_mode_active:
		return

	if source_node != null and source_node is Node:
		if source_node.is_in_group("boss"):
			return
		if not (source_node.is_in_group("enemy") or source_node.is_in_group("pich")):
			return

	health -= amount
	_apply_damage_ui()

func _apply_damage_ui():
	health = clamp(health, 0, max_health)
	hp_bar.value = health

	damage_flash()

	if health <= 0 and not death_started:
		death_started = true
		is_dead = true
		velocity = Vector2.ZERO

		if death_sfx:
			death_sfx.play()
			await death_sfx.finished

		call_deferred("_restart_scene")

func _restart_scene():
	var tree = get_tree()
	if tree:
		tree.reload_current_scene()

func damage_flash():
	damage_overlay.visible = true
	await get_tree().create_timer(0.5).timeout
	damage_overlay.visible = false

# ---------------- UI / CUSTOM ----------------
func update_color():
	color1.color = Gamedata.color_body
	color2.color = Gamedata.color_arm
	color3.color = Gamedata.color_detail

func update_customs():

	if face:
		face.visible = Gamedata.has_face
	# -------- GORRA --------
	if gorra:
		gorra.visible = Gamedata.has_cap

	# -------- LENTES (TOGGLE LIMPIO) --------
	for i in range(lentes.size()):
		lentes[i].visible = Gamedata.has_glasses

func update_ammo_ui():
	ammo_label.text = "Balas: " + str(ammo)

func set_preview_mode(value: bool):
	if has_node("CanvasLayer"):
		$CanvasLayer.visible = not value

# ---------------- COMMANDS ----------------
func _on_command_entered(cmd: String):
	match cmd.to_lower():
		"give_bullet":
			ammo = max_ammo
			update_ammo_ui()
			_add_log("Recargaste las balas")
		"kill_all":
			for e in get_tree().get_nodes_in_group("enemy"):
				e.queue_free()
			_add_log("Todos los enemigos eliminados")
		"god_mode":
			god_mode_active = !god_mode_active
			if god_mode_active:
				health = max_health
				hp_bar.value = health
				_add_log("God mode activado")
			else:
				_add_log("God mode desactivado")
		_:
			_add_log("Comando desconocido: " + cmd)

	command_input.text = ""

func _add_log(msg: String):
	command_log.text += msg + "\n"
	var lines = command_log.text.split("\n")
	if lines.size() > 20:
		lines = lines.slice(lines.size() - 20)
	command_log.text = "\n".join(lines)
	command_log.scroll_vertical = command_log.get_line_count()
