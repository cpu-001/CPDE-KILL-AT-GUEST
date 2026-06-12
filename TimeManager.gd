extends Node

# ---------------- TIME CONFIG ----------------
var time_limit := 56
var time_left := 56

# ---------------- INTERNAL ----------------
var _accumulator := 0.0
var active := false


# =========================================================
# START
# =========================================================
func start():
	time_left = time_limit
	_accumulator = 0.0
	active = true


# =========================================================
# UPDATE (CALL FROM SERVER ONLY)
# =========================================================
func process_time(delta):

	if not active:
		return

	_accumulator += delta

	if _accumulator >= 1.0:
		_accumulator -= 1.0

		time_left -= 1

		if time_left <= 0:
			time_left = 0
			active = false
			emit_signal("time_finished")


signal time_finished
