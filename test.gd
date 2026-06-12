extends Node

# ---------------- MULTIPLAYER ----------------
var peer: ENetMultiplayerPeer
const PORT := 7777
const HOST_IP := "192.168.1.36"

# ---------------- SCENES ----------------
var enemy_scene := preload("res://Enemy/enemy.tscn")
var player_scene := preload("res://Players/code/Player.tscn")
var vida_scene := preload("res://vida.tscn")  # Tu Area2D
var enemy_soldier_scene := preload("res://Enemy/Enemy_solder.tscn")

# ---------------- PLAYER REF ----------------
var player = null
var vida_spawned := false
var vida_speed := 150.0

# ---------------- NODES ----------------
@onready var players := $Players
@onready var deco1 := $deco1
@onready var deco2 := $deco2
@onready var deco3 := $deco3

# ---------------- GAME FLOW ----------------
var spawn_timer := 0.0
var spawn_interval := 1.0
const MAX_ENEMIES := 5
var soldier_alive := false
var soldier_cooldown := 6.0
var soldier_timer := 0.0

# ---------------- WAVES SYSTEM ----------------
var wave := 0
var wave_timer := 0.0


# =========================================================
# READY
# =========================================================
func _ready():
	TimeManager.start()
	apply_level()
	apply_decorations()

	_setup_network()

	TimeManager.time_finished.connect(level_complete)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	await get_tree().process_frame
	spawn_player(multiplayer.get_unique_id())


# =========================================================
# PROCESS
# =========================================================
func _process(delta):
	soldier_timer += delta
	# 🔥 buscar player seguro
	if player == null:
		if $Players.get_child_count() > 0:
			player = $Players.get_child(0)
		else:
			return

	# ---------------- VIDA SYSTEM ----------------
	if not vida_spawned and player.health <= player.max_health / 2:
		spawn_vida()

	for v in get_tree().get_nodes_in_group("vidas"):
		v.position.y += vida_speed * delta

		if v.position.y > 1000:
			v.queue_free()
			vida_spawned = false

	# ---------------- GAME SYSTEM ----------------
	if _is_time_master():

		TimeManager.process_time(delta)

		# SOLO NIVEL 2 GENERA ENEMIGOS
		if Gamedata.level == 2:
			_handle_waves(delta)
			_handle_enemy_spawning(delta)

	# ---------------- GAME SYSTEM ----------------
	if _is_time_master():
		TimeManager.process_time(delta)
		_handle_waves(delta)
		_handle_enemy_spawning(delta)


# =========================================================
# MULTIPLAYER NETWORK
# =========================================================
func _setup_network():
	if Global.multiplayer_mode:
		print("Modo multiplayer")
		if !_try_connect():
			_host_game()
	else:
		print("Modo singleplayer")
		_host_game()


func _try_connect() -> bool:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(HOST_IP, PORT)
	if err != OK:
		print("Error conectando al host")
		return false
	multiplayer.multiplayer_peer = peer
	print("Conectando al host...")
	return true


func _host_game():
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Servidor iniciado en puerto ", PORT)
	else:
		print("Error creando servidor")


# =========================================================
# WAVES SYSTEM (AAA EVENT SYSTEM)
# =========================================================
func _handle_waves(delta):
	wave_timer += delta
	if wave == 0 and TimeManager.time_left <= 35:
		_start_wave(1)
	elif wave == 1 and TimeManager.time_left <= 40:
		_start_wave(2)
	elif wave == 2 and TimeManager.time_left <= 25:
		_start_wave(3)
	elif wave == 3 and TimeManager.time_left <= 10:
		_start_wave(4)


func _start_wave(new_wave):
	if wave == new_wave:
		return
	wave = new_wave
	print("WAVE STARTED:", wave)
	match wave:
		1:
			spawn_interval = 1.2
			_spawn_wave_burst(3)
		2:
			spawn_interval = 0.9
			_spawn_wave_burst(5)
		3:
			spawn_interval = 0.6
			_spawn_wave_burst(8)
		4:
			spawn_interval = 0.2
			_spawn_wave_burst(18)


func _spawn_wave_burst(amount):
	for i in range(amount):
		spawn_enemy()


# =========================================================
# VIDA SYSTEM
# =========================================================
func spawn_vida():
	var vida_instance = vida_scene.instantiate()
	vida_instance.position = Vector2(randf_range(100, 800), -50)
	vida_instance.add_to_group("vidas")
	add_child(vida_instance)
	vida_spawned = true

	# conectar señal body_entered
	vida_instance.body_entered.connect(func(body):
		if body == player:
			player.health = min(player.health + player.max_health / 2, player.max_health)
			vida_instance.queue_free()
			vida_spawned = false
	)


# =========================================================
# TIME MASTER CHECK
# =========================================================
func _is_time_master() -> bool:

	if multiplayer == null:
		return true

	if multiplayer.multiplayer_peer == null:
		return true

	return multiplayer.is_server()
# =========================================================
# ENEMIES
# =========================================================
func _handle_enemy_spawning(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()


@onready var enemy_spawner = $EnemySpawner

func spawn_enemy():

	if not _is_time_master():
		return

	if get_enemy_count() >= MAX_ENEMIES:
		return

	var scene_to_spawn

	# ---------------- LEVEL LOGIC ----------------
	match Gamedata.level:

		1:
			scene_to_spawn = enemy_scene

		2, 3:

			var can_spawn_soldier = false

			if soldier_timer >= soldier_cooldown and not soldier_alive:
				can_spawn_soldier = true

			if randi() % 3 == 0 and can_spawn_soldier:
				scene_to_spawn = enemy_soldier_scene
				soldier_alive = true
				soldier_timer = 0.0
			else:
				scene_to_spawn = enemy_scene

		_:
			scene_to_spawn = enemy_scene

	var enemy = scene_to_spawn.instantiate()

	enemy.global_position = enemy_spawner.global_position + Vector2(
		randf_range(-80, 80),
		randf_range(-20, 20)
	)

	# 🔥 cuando muere el soldier libera el slot
	if scene_to_spawn == enemy_soldier_scene:
		enemy.tree_exited.connect(func():
			soldier_alive = false
		)

	get_tree().current_scene.add_child(enemy)

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()


# =========================================================
# PLAYERS
# =========================================================
func spawn_player(id):
	if players.has_node(str(id)):
		return
	var p = player_scene.instantiate()
	p.name = str(id)
	p.set_multiplayer_authority(id)
	players.add_child(p)
	p.global_position = Vector2(randf_range(200, 600), 300)


func _on_player_connected(id):
	spawn_player(id)


func _on_player_disconnected(id):
	for child in players.get_children():
		if child.name == str(id):
			child.queue_free()


# =========================================================
# LEVEL SYSTEM
# =========================================================
func apply_level():
	pass


func apply_decorations():
	deco1.visible = false
	deco2.visible = false
	deco3.visible = false

	match Gamedata.level:
		1:
			deco1.visible = true
		2:
			deco2.visible = true
		3:
			deco3.visible = true

func level_complete():
	
	# 🔥 asegurar progreso de nivel
	if Gamedata.level >= Gamedata.unlocked_level:
		Gamedata.unlocked_level = Gamedata.level + 1

	print("Nivel terminado:", Gamedata.level)
	print("Desbloqueado hasta:", Gamedata.unlocked_level)

	get_tree().change_scene_to_file("res://Menu.tscn")
