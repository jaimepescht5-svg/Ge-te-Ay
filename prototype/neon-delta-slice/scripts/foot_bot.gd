extends RefCounted
# Scripted "proxy player" for the verbs sandbox (the on-foot counterpart to
# bot.gd). It walks an ordered list of waypoints and — once those verbs exist —
# aims/fires at targets and trips "crimes" to exercise the Heat system.
#
# Like the driving bot, its job is to answer *measurable* questions (does the
# player move, reach a goal, can a target be hit, does Heat rise/decay) — NOT to
# judge whether any of it feels good. That judgement stays the human's.
#
# No `class_name` (see track.gd): resolved via preload so a clean clone parses
# without the gitignored `.godot/` class cache.

var waypoints: Array = []     # Array[Vector3]
var wp_index := 0
var reach_radius := 2.5

func _init(wps: Array) -> void:
	waypoints = wps

# Returns a control dict the sandbox applies to the player this physics step:
#   move:    Vector2 desired world-plane direction (x,z), unit or zero
#   run:     bool (sprint)
#   reached: bool (just hit a waypoint this step)
#   done:    bool (no waypoints left)
func control(pos: Vector3) -> Dictionary:
	if wp_index >= waypoints.size():
		return {"move": Vector2.ZERO, "run": false, "reached": false, "done": true}
	var target: Vector3 = waypoints[wp_index]
	var to := Vector2(target.x - pos.x, target.z - pos.z)
	if to.length() < reach_radius:
		wp_index += 1
		var done := wp_index >= waypoints.size()
		return {"move": Vector2.ZERO, "run": false, "reached": true, "done": done}
	return {"move": to.normalized(), "run": true, "reached": false, "done": false}
