extends RefCounted
# Scripted "proxy player" for the verbs sandbox (the on-foot counterpart to
# bot.gd). A small phase machine that exercises the verbs in order:
#   walk  — march an ordered waypoint patrol (movement + collision)
#   shoot — face each target in turn and fire (shooting verb)
#   done  — nothing left; the sandbox ends the self-check
#
# Its job is to answer *measurable* questions (does the player move, reach a
# goal, can every target be hit) — NOT to judge whether it feels good.
#
# No `class_name` (see track.gd): resolved via preload so a clean clone parses
# without the gitignored `.godot/` class cache.

var waypoints: Array = []      # Array[Vector3]
var targets: Array = []        # Array[Vector3] target world positions
var wp_index := 0
var reach_radius := 2.5

var phase := "walk"
var shoot_index := 0
var fire_cooldown := 0.0
var fire_period := 0.5
var shots_at_current := 0
var shots_per_target := 2

func _init(wps: Array, tgts: Array) -> void:
	waypoints = wps
	targets = tgts

# Returns a control dict the sandbox applies this physics step:
#   move:    Vector2 desired world-plane direction (x,z), unit or zero
#   run:     bool
#   aim:     Vector3 unit aim direction (only in shoot phase)
#   fire:    bool (pull the trigger this step)
#   reached: bool (hit a waypoint this step)
#   done:    bool (no verbs left)
func control(pos: Vector3, delta: float) -> Dictionary:
	if phase == "walk":
		if wp_index >= waypoints.size():
			phase = "shoot"
		else:
			var wp: Vector3 = waypoints[wp_index]
			var to := Vector2(wp.x - pos.x, wp.z - pos.z)
			if to.length() < reach_radius:
				wp_index += 1
				return {"move": Vector2.ZERO, "run": false, "reached": true, "fire": false, "done": false}
			return {"move": to.normalized(), "run": true, "reached": false, "fire": false, "done": false}

	if phase == "shoot":
		if shoot_index >= targets.size():
			phase = "done"
			return {"move": Vector2.ZERO, "run": false, "fire": false, "reached": false, "done": true}
		var t: Vector3 = targets[shoot_index]
		var aim := (Vector3(t.x, t.y + 1.0, t.z) - (pos + Vector3.UP * 1.2)).normalized()
		fire_cooldown -= delta
		var fire := false
		if fire_cooldown <= 0.0:
			fire = true
			fire_cooldown = fire_period
			shots_at_current += 1
			if shots_at_current >= shots_per_target:
				shoot_index += 1
				shots_at_current = 0
		return {"move": Vector2.ZERO, "run": false, "aim": aim, "fire": fire, "reached": false, "done": false}

	return {"move": Vector2.ZERO, "run": false, "fire": false, "reached": false, "done": true}
