extends RefCounted
# NOTE: intentionally no `class_name`. Global class names resolve via Godot's
# `.godot/` cache, which is gitignored and absent on a fresh clone — so a clean
# headless/CI run would fail to parse. Consumers `preload` this script instead.

# A closed rounded-rectangle racing line on the ground (X/Z) plane.
# Used for three things the engine doesn't give us for free:
#   - off-track detection (distance from the racing line)
#   - lap timing via ordered checkpoints
#   - a centerline the bot can chase with pure pursuit
# Points are resampled to uniform arc-length spacing so "look 14 m ahead"
# is just "walk N points ahead", independent of corner vs. straight.

var points: PackedVector2Array = PackedVector2Array()   # uniform-spaced centerline (X,Z)
var total_length: float = 0.0
var spacing: float = 1.0
var road_width: float = 17.0
var checkpoints: PackedInt32Array = PackedInt32Array()   # indices into points

func _init(half_w: float, half_h: float, corner_r: float,
		road_width_: float, samples: int, checkpoint_count: int) -> void:
	road_width = road_width_
	var dense := _build_dense(half_w, half_h, corner_r)
	_resample_uniform(dense, samples)
	for i in checkpoint_count:
		checkpoints.append(int(round(float(i) / checkpoint_count * points.size())) % points.size())

func _build_dense(a: float, b: float, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var step_straight := 1.0
	var step_arc := 0.04  # radians
	# Top edge (+Z), moving +X
	_add_line(pts, Vector2(-(a - r), b), Vector2(a - r, b), step_straight)
	_add_arc(pts, Vector2(a - r, b - r), r, PI / 2, 0.0, step_arc)
	# Right edge (+X), moving -Z
	_add_line(pts, Vector2(a, b - r), Vector2(a, -(b - r)), step_straight)
	_add_arc(pts, Vector2(a - r, -(b - r)), r, 0.0, -PI / 2, step_arc)
	# Bottom edge (-Z), moving -X
	_add_line(pts, Vector2(a - r, -b), Vector2(-(a - r), -b), step_straight)
	_add_arc(pts, Vector2(-(a - r), -(b - r)), r, -PI / 2, -PI, step_arc)
	# Left edge (-X), moving +Z
	_add_line(pts, Vector2(-a, -(b - r)), Vector2(-a, b - r), step_straight)
	_add_arc(pts, Vector2(-(a - r), b - r), r, PI, PI / 2, step_arc)
	return pts

func _add_line(pts: PackedVector2Array, p0: Vector2, p1: Vector2, step: float) -> void:
	var d := p0.distance_to(p1)
	var n := maxi(1, int(d / step))
	for i in n:
		pts.append(p0.lerp(p1, float(i) / n))

func _add_arc(pts: PackedVector2Array, c: Vector2, r: float,
		a0: float, a1: float, step: float) -> void:
	var n := maxi(1, int(abs(a1 - a0) / step))
	for i in n:
		var ang := lerpf(a0, a1, float(i) / n)
		pts.append(c + Vector2(cos(ang), sin(ang)) * r)

func _resample_uniform(dense: PackedVector2Array, samples: int) -> void:
	# cumulative arc length of the closed dense polyline
	var cum := PackedFloat32Array()
	cum.append(0.0)
	for i in range(1, dense.size()):
		cum.append(cum[i - 1] + dense[i - 1].distance_to(dense[i]))
	var loop_len: float = cum[cum.size() - 1] + dense[dense.size() - 1].distance_to(dense[0])
	total_length = loop_len
	spacing = loop_len / samples
	points = PackedVector2Array()
	var seg := 0
	for i in samples:
		var target := i * spacing
		while seg < cum.size() - 1 and cum[seg + 1] < target:
			seg += 1
		var seg_start: float = cum[seg]
		var seg_len: float = (cum[seg + 1] if seg + 1 < cum.size() else loop_len) - seg_start
		var t: float = 0.0 if seg_len <= 0.0 else (target - seg_start) / seg_len
		var p0 := dense[seg]
		var p1 := dense[(seg + 1) % dense.size()]
		points.append(p0.lerp(p1, t))

func nearest_index(p: Vector2) -> int:
	var best := 0
	var best_d := INF
	for i in points.size():
		var d := points[i].distance_squared_to(p)
		if d < best_d:
			best_d = d
			best = i
	return best

func distance_to_line(p: Vector2) -> float:
	return sqrt(points[nearest_index(p)].distance_squared_to(p))

func is_off_track(p: Vector2) -> bool:
	return distance_to_line(p) > road_width * 0.5

func lookahead_point(from_index: int, dist: float) -> Vector2:
	var steps := maxi(1, int(dist / spacing))
	return points[(from_index + steps) % points.size()]
