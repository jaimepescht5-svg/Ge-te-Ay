extends RefCounted
# Scripted "proxy player" for the verbs sandbox (the on-foot counterpart to
# bot.gd). A phase machine that exercises every verb in order:
#   walk   — march an ordered waypoint patrol (movement + collision)
#   shoot  — face each target in turn and fire (shooting verb)
#   to_car — walk to the parked car and request to get in (enter/exit verb)
#   drive  — throttle + steer the car for a few seconds, then request to get out
#   done   — nothing left; the sandbox ends the self-check
#
# It answers *measurable* questions (does the player move/reach/hit, can it get
# in a car and drive it out and get back out) — NOT whether it feels good.
#
# No `class_name` (see track.gd): resolved via preload so a clean clone parses
# without the gitignored `.godot/` class cache.

var waypoints: Array = []      # Array[Vector3]
var targets: Array = []        # Array[Vector3]
var car_pos: Vector3 = Vector3.ZERO
var wp_index := 0
var reach_radius := 2.5

var phase := "walk"
var shoot_index := 0
var fire_cooldown := 0.0
var fire_period := 0.5
var shots_at_current := 0
var shots_per_target := 2
var drive_timer := 5.0

func _init(wps: Array, tgts: Array, car_position: Vector3) -> void:
	waypoints = wps
	targets = tgts
	car_pos = car_position

# Foot phases return {move,run,aim,fire,reached,request,done}; the drive phase
# returns {throttle,brake,steer,request,done}. The sandbox interprets by mode.
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
			phase = "to_car"
		else:
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

	if phase == "to_car":
		var to := Vector2(car_pos.x - pos.x, car_pos.z - pos.z)
		if to.length() < 3.2:
			phase = "drive"
			return {"move": Vector2.ZERO, "run": false, "request": "enter", "fire": false, "done": false}
		return {"move": to.normalized(), "run": true, "fire": false, "done": false}

	if phase == "drive":
		drive_timer -= delta
		if drive_timer <= 0.0:
			phase = "done"
			return {"throttle": 0.0, "brake": 1.0, "steer": 0.0, "request": "exit", "done": false}
		return {"throttle": 1.0, "brake": 0.0, "steer": 0.3, "done": false}

	return {"move": Vector2.ZERO, "run": false, "fire": false, "done": true}
