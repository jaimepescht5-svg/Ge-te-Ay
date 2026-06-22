extends RefCounted
class_name DriverBot

# A reference "proxy player": follows the racing line with pure pursuit and a
# lookahead speed planner (brake early for corners, not reactively at them).
# Its job is to answer measurable questions — is the track drivable, where does
# a normal line leave the road, is a lap completable in a sane time — NOT to
# judge whether driving feels good. That judgement is the human's.

var track: TrackGeometry
var steer_lookahead_base := 6.0
var steer_lookahead_speed := 0.35
var steer_gain := 1.9
var max_lat_accel := 2.0     # m/s^2 the bot believes it can hold (big low-grip car)
var brake_decel := 6.0       # m/s^2 it plans to brake at
var brake_horizon := 105.0   # how far ahead (m) it plans speed
var max_speed := 34.0        # m/s target cap on straights

func _init(track_: TrackGeometry) -> void:
	track = track_

func control(pos: Vector2, forward: Vector2, speed: float) -> Dictionary:
	var idx := track.nearest_index(pos)

	# --- steering: pure pursuit toward a look-ahead point on the line ---
	var look := steer_lookahead_base + speed * steer_lookahead_speed
	var aim := track.lookahead_point(idx, look)
	var to_aim := aim - pos
	var steer := 0.0
	if to_aim.length() > 0.001:
		var d := to_aim.normalized()
		var cross := forward.x * d.y - forward.y * d.x
		var dot := forward.dot(d)
		steer = clampf(atan2(cross, dot) * steer_gain, -1.0, 1.0)

	# --- speed planning: the slowest speed any upcoming point demands, given
	#     we must be able to brake down to it by the time we arrive ---
	var target := max_speed
	var n := track.points.size()
	var steps := int(brake_horizon / track.spacing)
	for s in range(0, steps):
		var i := (idx + s) % n
		var v_allow := _corner_speed(i)
		var dist := s * track.spacing
		var v_cap := sqrt(v_allow * v_allow + 2.0 * brake_decel * dist)
		target = minf(target, v_cap)

	var throttle := 0.0
	var brake := 0.0
	if speed > target + 0.5:
		brake = clampf((speed - target) * 0.5, 0.0, 1.0)
	elif speed < target - 0.5:
		throttle = clampf((target - speed) * 0.3, 0.2, 1.0)
	else:
		throttle = 0.3
	return {"throttle": throttle, "brake": brake, "steer": steer}

# Local corner speed limit from the centerline's curvature at index i.
func _corner_speed(i: int) -> float:
	var n := track.points.size()
	var a := track.points[(i - 2 + n) % n]
	var b := track.points[i]
	var c := track.points[(i + 2) % n]
	var t0 := (b - a)
	var t1 := (c - b)
	if t0.length() < 0.001 or t1.length() < 0.001:
		return max_speed
	var ang := absf(t0.normalized().angle_to(t1.normalized()))
	var arc := t0.length() + t1.length()
	if ang < 0.0001:
		return max_speed                       # effectively straight
	var radius := arc / ang
	return clampf(sqrt(max_lat_accel * radius), 6.0, max_speed)
