extends Node

var missions: Array[Mission] = []

func _ready():
	Gamedata.score_changed.connect(_on_score_changed)
	Gamedata.combo_changed.connect(_on_combo_changed)
	Gamedata.streak_changed.connect(_on_kill_changed)

	setup_missions()

func setup_missions():
	missions = [
		create_mission("Score 100", "score", 100),
		create_mission("10X Combos", "combo", 10),
		create_mission("20 Kills", "kills", 20)
	]

func create_mission(id: String, type: String, target: int) -> Mission:
	var m = Mission.new()
	m.setup(id, type, target)
	return m

func _on_score_changed(value):
	_update_mission("score", value)
	
func _on_combo_changed(value):
	for m in missions:
		if m.type == "combo" and value >= m.target and not m.completed:
			m.completed = true
			Gamedata.mission_completed.emit(m.id)

func _on_kill_changed(value):
	_update_mission("kills", value)
	
func _update_mission(type: String, value: int):
	for m in missions:
		if m.completed:
			continue

		if m.type == type:
			m.progress = value

			Gamedata.mission_progress_changed.emit(m.id, m.progress)

			if m.progress >= m.target:
				m.completed = true
				Gamedata.mission_completed.emit(m.id)
