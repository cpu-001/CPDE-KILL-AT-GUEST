extends Node

# ---------------- TIME SYSTEM ----------------
var time_limit := 56
var time_left := 56

# ---------------- LEVEL ----------------
var level := 1
var unlocked_level := 1

# ---------------- PLAYER ----------------
var player_name := "Player"

# ---------------- CUSTOM ----------------

var has_cap := false
var has_glasses := false
var has_face := false

var color_body := Color(1, 1, 1)
var color_arm := Color(1, 1, 1)
var color_detail := Color(1, 1, 1)

var score: int = 0

var combo: int = 0
var kill_streak: int = 0

var combo_timer: float = 0.0
var combo_window: float = 1.5 # tiempo para mantener combo

signal score_changed(score)
signal combo_changed(combo)
signal streak_changed(streak)
signal mission_progress_changed(mission_id, progress)
signal mission_completed(mission_id)

func _process(delta):
	if combo > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			reset_combo()

func add_kill(base_points: int):
	kill_streak += 1
	streak_changed.emit(kill_streak)

	combo += 1
	combo_timer = combo_window
	combo_changed.emit(combo)

	var multiplier = 1 + (combo * 0.1)
	var final_score = int(base_points * multiplier)

	score += final_score
	score_changed.emit(score)

func reset_combo():
	combo = 0
	combo_timer = 0
	combo_changed.emit(combo)
