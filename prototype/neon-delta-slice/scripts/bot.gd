extends RefCounted
# NEON DELTA — waypoint-following driver bot for the open world.
#
# No `class_name` (headless CI parses on a clean clone without the global class
# cache). A simple, robust steering bot: it chases a list of xz waypoints in
# order, advances when it gets close, and eases off the throttle before turns so
# the heavy cruiser doesn't plough through corners. Its job is to prove the world
# is traversable and to feed the self-check, not to judge feel.

var waypoints: PackedVector2Array = PackedVector2Array()
var wp_idx := 0

const SWITCH_DIST := 30.0     # advance to next waypoint within this many metres
const STEER_GAIN := 0.7       # low — a high gain makes the heavy car fishtail/oscillate
const MAX_SPEED := 26.0       # m/s ≈ 94 km/h cap; long straights let it sprint
const TURN_SLOWDOWN := 0.5    # speed factor when the next turn is sharp

func _init(wps: PackedVector2Array) -> void:
	waypoints = wps
	wp_idx = 0

# Advance the waypoint cursor if we are within SWITCH_DIST of the current target.
# Returns true exactly on the frame an advance happens (so the caller can count
# distinct waypoints visited).
func advance_if_close(pos: Vector2) -> bool:
	if wp_idx >= waypoints.size():
		return false
	if pos.distance_to(waypoints[wp_idx]) < SWITCH_DIST:
		wp_idx += 1
		return true
	return false

func _current() -> Vector2:
	if waypoints.is_empty():
		return Vector2.ZERO
	return waypoints[mini(wp_idx, waypoints.size() - 1)]

func _next() -> Vector2:
	if waypoints.is_empty():
		return Vector2.ZERO
	return waypoints[mini(wp_idx + 1, waypoints.size() - 1)]

func control(pos: Vector2, forward: Vector2, speed: float) -> Dictionary:
	var aim := _current()
	var to_aim := aim - pos
	var steer := 0.0
	if to_aim.length() > 0.001 and forward.length() > 0.001:
		var d := to_aim.normalized()
		var cross := forward.x * d.y - forward.y * d.x
		var dot := forward.dot(d)
		steer = clampf(atan2(cross, dot) * STEER_GAIN, -1.0, 1.0)

	# slow before turns: compare heading to current leg vs the next leg.
	# Only ramp down within 80 m of the waypoint so the car can cruise at
	# full speed in the middle of a long segment.
	var target := MAX_SPEED
	var leg := (aim - pos)
	var nxt := (_next() - aim)
	var leg_dist := leg.length()
	if leg_dist > 0.001 and nxt.length() > 0.001:
		var ang := absf(leg.normalized().angle_to(nxt.normalized()))
		var fac := clampf(1.0 - leg_dist / 55.0, 0.0, 1.0)   # 0 far, 1 within 55 m
		# only a genuine corner (not a slight kink) costs speed, and only as the
		# waypoint nears — long straights stay at full pace so the car can sprint
		if ang > 0.7:
			target = lerpf(MAX_SPEED, MAX_SPEED * TURN_SLOWDOWN, fac)
		if ang > 1.3:
			target = lerpf(MAX_SPEED, MAX_SPEED * 0.35, fac)
	# (no instantaneous-steer speed cut: with a low steer gain the steering is
	# smooth, and the angle-based slowdown above already handles real corners.)

	var throttle := 0.0
	var brake := 0.0
	if speed > target + 1.0:
		brake = clampf((speed - target) * 0.4, 0.0, 1.0)
	elif speed < target - 0.5:
		throttle = clampf((target - speed) * 0.3, 0.3, 1.0)
	else:
		throttle = 0.35
	return {"throttle": throttle, "brake": brake, "steer": steer}
