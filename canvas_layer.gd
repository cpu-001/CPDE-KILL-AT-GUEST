extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var combo_label = $ComboLabel
@onready var anim = $AnimationPlayer

func _ready():
	Gamedata.score_changed.connect(_on_score)
	Gamedata.combo_changed.connect(_on_combo)
	Gamedata.streak_changed.connect(_on_streak)
	
	Gamedata.mission_completed.connect(_on_completed)
	Gamedata.mission_progress_changed.connect(_on_progress)

	refresh()

func _on_score(value):
	score_label.text = "Score: %d" % value
	anim.play("score_pop")

func _on_combo(value):
	if value > 1:
		combo_label.text = "COMBO x%d" % value
		anim.play("combo_pop")
	else:
		combo_label.text = ""

func _on_streak(value):
	if value > 5:
		anim.play("streak_warning")

@onready var list = $MissionList

func refresh():
	# Borrar todos los hijos del VBoxContainer
	for child in list.get_children():
		child.queue_free()

	# Volver a crear las labels
	for m in MissionManager.missions:
		var label = Label.new()
		label.text = _format_mission(m)
		list.add_child(label)

func _on_progress(id, progress):
	refresh()
	
func _on_completed(id):
	refresh()
	
func _format_mission(m):
	var status = "✔" if m.completed else "⏳"
	return "%s %s: %d/%d" % [status, m.id, m.progress, m.target]

var mission_labels = {}


func setup_ui():
	for m in MissionManager.missions:
		var label = Label.new()
		label.text = _format_mission(m)
		list.add_child(label)
		mission_labels[m.id] = label
