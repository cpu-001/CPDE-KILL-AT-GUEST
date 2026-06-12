extends Control

# ---------------- AUDIO ----------------
@onready var master_slider: HSlider = $ControlMenu/MasterSlider
var is_paused := false  # Estado de pausa
# ---------------- BUTTONS ----------------
@onready var fullscreen_button: Button = $ControlMenu/FullscreenButton
@onready var back_button: Button = $ControlMenu/BackButton
@onready var control_menu = $ControlMenu  # Nodo que se mostrará al presionar el botón OPT
# ---------------- READY ----------------
func _ready():

	# cargar volumen actual del sistema
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

	# conectar señales
	master_slider.value_changed.connect(_on_volume_changed)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	back_button.pressed.connect(_on_back_pressed)


# =========================================================
# VOLUME CONTROL
# =========================================================
func _on_volume_changed(value: float):

	# convertir slider (0-1) a decibeles
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, db)


# =========================================================
# FULLSCREEN TOGGLE
# =========================================================
func _on_fullscreen_pressed():

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_windowscreen_button_pressed() -> void:

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# =========================================================
# BACK TO MENU
# =========================================================
func _on_back_pressed():
	control_menu.visible = false

	# Solo ocultar el nodo si existe en esta escena
	if $"../ColorRect84":
		$"../ColorRect84".visible = false
	
	toggle_pause()


func _on_opt_pressed() -> void:
	toggle_pause()
	control_menu.visible = true
	
	# Solo mostrar el nodo si existe en esta escena
	if $"../ColorRect84":
		$"../ColorRect84".visible = true
# =========================================================
# PAUSA / REANUDAR
# =========================================================
func toggle_pause():
	if is_paused:
		# Reanudar juego
		control_menu.visible = false
		Engine.time_scale = 1.0
		get_tree().paused = false
		is_paused = false
	else:
		# Pausar juego
		control_menu.visible = true
		Engine.time_scale = 0.0
		get_tree().paused = true
		is_paused = true
		
		# ❗ Asegurarse que el menú no se pause
		control_menu.process_mode = Node.PROCESS_MODE_ALWAYS
