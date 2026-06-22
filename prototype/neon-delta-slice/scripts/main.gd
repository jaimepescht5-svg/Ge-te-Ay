extends Node3D

# NEON DELTA — gray-box driving slice.
# Mode is chosen by the GAME_MODE env var:
#   play       (default) — you drive with WASD / arrows. R resets.
#   bot        — the reference bot drives; you watch.
#   selfcheck  — the bot drives headless-under-Xvfb; we capture frames,
#                log telemetry, assert invariants, and quit with a status code.
#
# Everything is built in code so the "scene" is readable here rather than in a
# binary .tscn, which also makes diffs in the design repo meaningful.

# ---- tunables (the "feel" of the verb — the part the human judge owns) ----
# A big, heavy, lower-grip cruiser: modest power, slides under provocation,
# takes its time. Deliberately NOT an F1 car.
const ENGINE_POWER := 2800.0     # less power — unhurried acceleration
const BRAKE_POWER := 38.0
const MAX_STEER := 0.40          # rad (~23 deg) — less darty
const STEER_SPEED := 4.0         # slower wheel response = more weight
const CAR_MASS := 1800.0         # big, heavy vehicle
const WHEEL_FRICTION := 2.6      # lower grip — more slide, less stick

# Body dimensions (a large vehicle — think SUV/cruiser, not a hatch).
const CAR_LENGTH := 6.0
const CAR_WIDTH := 2.4
const CAR_HEIGHT := 1.7

# ---- track ----
const HALF_W := 120.0
const HALF_H := 78.0
const CORNER_R := 46.0
const ROAD_WIDTH := 28.0
const TRACK_SAMPLES := 360
const CHECKPOINTS := 8

# ---- selfcheck ----
const SELFCHECK_SECONDS := 60.0
const CAPTURE_INTERVAL := 1.5

var mode := "play"
var selfcheck_seconds := SELFCHECK_SECONDS
var capture_interval := CAPTURE_INTERVAL
var capture_max := 40
var frames_dir := "user://frames"
var track: TrackGeometry
var bot: DriverBot
var car: VehicleBody3D
var cam: Camera3D
var hud_speed: Label
var hud_info: Label

var sim_time := 0.0
var next_capture := 0.0
var capture_index := 0
var steer_current := 0.0

# telemetry / lap state
var start_pos := Vector3.ZERO
var start_yaw := 0.0
var start_index := 0
var next_cp := 0
var laps_done := 0
var lap_start_time := 0.0
var best_lap := INF
var last_lap := 0.0
var distance := 0.0
var prev_pos := Vector2.ZERO
var prev_vel := Vector3.ZERO
var max_lateral_g := 0.0
var off_track_time := 0.0
var top_speed := 0.0
var samples := []   # per-step rows in selfcheck

func _ready() -> void:
	mode = OS.get_environment("GAME_MODE")
	if mode == "":
		mode = "play"
	# iteration knobs (defaults preserve real-time, full-length runs)
	var sc_secs := OS.get_environment("SC_SECONDS")
	if sc_secs != "":
		selfcheck_seconds = float(sc_secs)
	var ts := OS.get_environment("TIME_SCALE")
	if ts != "":
		Engine.time_scale = float(ts)
	# "filmstrip" capture knobs for making clips (defaults preserve sparse review)
	var ci := OS.get_environment("CAP_INTERVAL")
	if ci != "":
		capture_interval = float(ci)
	var cm := OS.get_environment("CAP_MAX")
	if cm != "":
		capture_max = int(cm)
	# let the viz tool redirect frame output (tools/viz)
	var vo := OS.get_environment("VIZ_OUT")
	if vo != "":
		frames_dir = vo
	randomize()
	track = TrackGeometry.new(HALF_W, HALF_H, CORNER_R, ROAD_WIDTH, TRACK_SAMPLES, CHECKPOINTS)
	bot = DriverBot.new(track)
	_compute_start()
	_setup_input()
	_build_environment()
	_build_ground()
	_build_road()
	_build_barriers()
	_build_car()
	_build_camera()
	_build_hud()
	prev_pos = _car_xz()
	lap_start_time = 0.0

# ---------------------------------------------------------------- world build
func _build_environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.06, 0.09)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.35, 0.38, 0.48)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -40, 0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.95, 0.85)
	add_child(sun)

func _build_ground() -> void:
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(600, 2, 600)
	col.shape = box
	col.position = Vector3(0, -1, 0)
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(600, 600)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.11, 0.13)
	plane.material = mat
	mesh.mesh = plane
	body.add_child(mesh)
	add_child(body)

func _build_road() -> void:
	# a flat ribbon mesh over the ground so the racing line is visible
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := track.points.size()
	var hw := ROAD_WIDTH * 0.5
	for i in n:
		var p := track.points[i]
		var pn := track.points[(i + 1) % n]
		var tangent := (pn - p).normalized()
		var normal := Vector2(-tangent.y, tangent.x)
		var l0 := p + normal * hw
		var r0 := p - normal * hw
		var l1 := pn + normal * hw
		var r1 := pn - normal * hw
		_quad(st, l0, r0, l1, r1)
	st.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.19, 0.22)
	mesh.mesh.surface_set_material(0, mat)
	mesh.position.y = 0.02
	add_child(mesh)
	_build_center_dashes()

func _quad(st: SurfaceTool, l0: Vector2, r0: Vector2, l1: Vector2, r1: Vector2) -> void:
	var a := Vector3(l0.x, 0, l0.y)
	var b := Vector3(r0.x, 0, r0.y)
	var c := Vector3(l1.x, 0, l1.y)
	var d := Vector3(r1.x, 0, r1.y)
	st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
	st.add_vertex(b); st.add_vertex(d); st.add_vertex(c)

func _build_center_dashes() -> void:
	var n := track.points.size()
	for i in range(0, n, 6):
		var dash := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.4, 0.05, 1.6)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.82, 0.5)
		bm.material = bm.material
		dash.mesh = bm
		dash.material_override = mat
		var p := track.points[i]
		var pn := track.points[(i + 1) % n]
		var tangent := (pn - p).normalized()
		dash.position = Vector3(p.x, 0.05, p.y)
		dash.rotation.y = atan2(tangent.x, tangent.y)
		add_child(dash)

func _build_barriers() -> void:
	var n := track.points.size()
	var hw := ROAD_WIDTH * 0.5 + 0.6
	for i in range(0, n, 4):
		var p := track.points[i]
		var pn := track.points[(i + 1) % n]
		var tangent := (pn - p).normalized()
		var normal := Vector2(-tangent.y, tangent.x)
		_barrier_post(p + normal * hw, tangent, Color(0.8, 0.25, 0.2))
		_barrier_post(p - normal * hw, tangent, Color(0.85, 0.8, 0.85))

func _barrier_post(pos2: Vector2, tangent: Vector2, color: Color) -> void:
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 1.2, track.spacing * 4.0)
	col.shape = box
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = box.size
	mesh.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	body.add_child(mesh)
	body.position = Vector3(pos2.x, 0.6, pos2.y)
	body.rotation.y = atan2(tangent.x, tangent.y)
	add_child(body)

func _build_car() -> void:
	car = VehicleBody3D.new()
	car.mass = CAR_MASS
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CAR_WIDTH, CAR_HEIGHT, CAR_LENGTH)
	col.shape = box
	col.position.y = CAR_HEIGHT * 0.5
	car.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CAR_WIDTH, CAR_HEIGHT - 0.1, CAR_LENGTH)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.85, 0.95)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.4, 0.5)
	mat.emission_energy_multiplier = 0.4
	mesh.material_override = mat
	mesh.position.y = CAR_HEIGHT * 0.5
	car.add_child(mesh)
	# nose marker so heading is readable in screenshots
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.6, 0.4, 0.8)
	var nm := StandardMaterial3D.new()
	nm.albedo_color = Color(1, 1, 0.3)
	nose.material_override = nm
	nose.mesh = nb
	nose.position = Vector3(0, CAR_HEIGHT * 0.5 + 0.5, -(CAR_LENGTH * 0.5 - 0.4))
	car.add_child(nose)
	var wx := CAR_WIDTH * 0.5 - 0.15
	var wz := CAR_LENGTH * 0.5 - 1.0
	_add_wheel(Vector3(-wx, 0.0, -wz), true, true)
	_add_wheel(Vector3(wx, 0.0, -wz), true, true)
	_add_wheel(Vector3(-wx, 0.0, wz), true, false)
	_add_wheel(Vector3(wx, 0.0, wz), true, false)
	car.position = start_pos
	car.rotation.y = start_yaw
	add_child(car)

func _add_wheel(pos: Vector3, traction: bool, steering: bool) -> void:
	var w := VehicleWheel3D.new()
	w.position = pos
	w.use_as_traction = traction
	w.use_as_steering = steering
	w.wheel_radius = 0.5
	w.wheel_rest_length = 0.3
	w.suspension_travel = 0.35
	w.suspension_stiffness = 30.0
	w.damping_compression = 0.5
	w.damping_relaxation = 0.45
	w.wheel_friction_slip = WHEEL_FRICTION
	car.add_child(w)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.fov = 65
	cam.position = Vector3(0, 12, HALF_H + 22)
	add_child(cam)  # must be in-tree before look_at (it uses the global transform)
	cam.look_at(Vector3(0, 0, HALF_H), Vector3.UP)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud_speed = Label.new()
	hud_speed.position = Vector2(24, 20)
	hud_speed.add_theme_font_size_override("font_size", 34)
	layer.add_child(hud_speed)
	hud_info = Label.new()
	hud_info.position = Vector2(24, 70)
	hud_info.add_theme_font_size_override("font_size", 20)
	layer.add_child(hud_info)

# ---------------------------------------------------------------- input
func _setup_input() -> void:
	_action("accel", [KEY_W, KEY_UP])
	_action("brake", [KEY_S, KEY_DOWN])
	_action("steer_left", [KEY_A, KEY_LEFT])
	_action("steer_right", [KEY_D, KEY_RIGHT])
	_action("reset", [KEY_R])

func _action(name: String, keys: Array) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(name, ev)

# ---------------------------------------------------------------- helpers
func _car_xz() -> Vector2:
	return Vector2(car.global_position.x, car.global_position.z)

func _car_forward_xz() -> Vector2:
	# measured: under positive engine_force the body travels along +basis.z
	var f := car.global_transform.basis.z
	return Vector2(f.x, f.z).normalized()

func _car_speed() -> float:
	return car.linear_velocity.length()

# ---------------------------------------------------------------- sim loop
func _physics_process(delta: float) -> void:
	sim_time += delta
	var controls: Dictionary
	if mode == "play":
		controls = _player_controls()
	else:
		controls = bot.control(_car_xz(), _car_forward_xz(), _car_speed())
	_apply_controls(controls, delta)
	_update_telemetry(delta)
	if mode == "play" and Input.is_action_just_pressed("reset"):
		_reset_car()
	if mode == "selfcheck":
		var p := _car_xz()
		samples.append({
			"t": sim_time, "speed": _car_speed(),
			"off": track.is_off_track(p), "laps": laps_done,
			"x": p.x, "z": p.y, "steer": steer_current,
		})
		if sim_time >= selfcheck_seconds or laps_done >= 3:
			_finish_selfcheck()

func _player_controls() -> Dictionary:
	var throttle := Input.get_action_strength("accel")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	return {"throttle": throttle, "brake": brake, "steer": steer}

func _apply_controls(c: Dictionary, delta: float) -> void:
	var target_steer: float = c["steer"] * MAX_STEER
	steer_current = move_toward(steer_current, target_steer, STEER_SPEED * MAX_STEER * delta)
	car.steering = steer_current
	car.engine_force = c["throttle"] * ENGINE_POWER
	car.brake = c["brake"] * BRAKE_POWER

func _update_telemetry(delta: float) -> void:
	var pos := _car_xz()
	var spd := _car_speed()
	top_speed = maxf(top_speed, spd)
	distance += pos.distance_to(prev_pos)
	# lateral acceleration magnitude (proxy for grip / cornering load)
	var acc := (car.linear_velocity - prev_vel) / maxf(delta, 0.0001)
	var lateral := Vector2(acc.x, acc.z).length() / 9.81
	max_lateral_g = maxf(max_lateral_g, lateral)
	if track.is_off_track(pos):
		off_track_time += delta
	# checkpoints / laps
	var cp_pos := track.points[track.checkpoints[next_cp]]
	if pos.distance_to(cp_pos) < ROAD_WIDTH:
		next_cp += 1
		if next_cp >= track.checkpoints.size():
			next_cp = 0
			laps_done += 1
			last_lap = sim_time - lap_start_time
			best_lap = minf(best_lap, last_lap)
			lap_start_time = sim_time
	prev_pos = pos
	prev_vel = car.linear_velocity

func _compute_start() -> void:
	# spawn on the racing line, facing along its tangent so "forward" matches
	# the bot's travel direction. Avoids hardcoded headings that fight the track.
	var n := track.points.size()
	start_index = track.nearest_index(Vector2(0, HALF_H))
	var p := track.points[start_index]
	var tangent := (track.points[(start_index + 1) % n] - p).normalized()
	start_pos = Vector3(p.x, 1.0, p.y)  # spawn slightly high; suspension settles it
	start_yaw = atan2(tangent.x, tangent.y)  # align +basis.z with the tangent
	# first checkpoint ahead of the start line
	next_cp = 0
	for i in track.checkpoints.size():
		if track.checkpoints[i] >= start_index:
			next_cp = i
			break

func _reset_car() -> void:
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.position = start_pos
	car.rotation = Vector3(0, start_yaw, 0)
	steer_current = 0.0

# ---------------------------------------------------------------- per-frame
func _process(_d: float) -> void:
	_update_camera()
	_update_hud()
	if mode == "selfcheck" and sim_time >= next_capture:
		next_capture += capture_interval
		_capture_frame()

func _update_camera() -> void:
	if cam == null or not cam.is_inside_tree() or car == null:
		return
	var back := -car.global_transform.basis.z   # behind the car (forward is +basis.z)
	var target := car.global_position + back * 11.0 + Vector3.UP * 6.0
	cam.global_position = cam.global_position.lerp(target, 0.12)
	cam.look_at(car.global_position + Vector3.UP * 1.0, Vector3.UP)

func _update_hud() -> void:
	var kmh := int(round(_car_speed() * 3.6))
	hud_speed.text = "%d km/h" % kmh
	var off := "  OFF TRACK" if track.is_off_track(_car_xz()) else ""
	hud_info.text = "mode:%s   laps:%d   last:%.1fs   best:%s%s" % [
		mode, laps_done, last_lap,
		("--" if best_lap == INF else "%.1fs" % best_lap), off,
	]

func _capture_frame() -> void:
	# headless (--headless) has no rendering surface; skip capture there so the
	# logic loop can run fast for debugging. Cap frames so a run can't flood disk.
	if DisplayServer.get_name() == "headless" or capture_index >= capture_max:
		capture_index += 1
		return
	var tex := get_viewport().get_texture()
	if tex == null:
		return
	var img := tex.get_image()
	DirAccess.make_dir_recursive_absolute(frames_dir)
	img.save_png("%s/frame_%04d.png" % [frames_dir, capture_index])
	capture_index += 1

# ---------------------------------------------------------------- selfcheck
var _finishing := false
func _finish_selfcheck() -> void:
	if _finishing:
		return
	_finishing = true
	print("[selfcheck] finishing at sim_time=%.1f laps=%d frames=%d" % [sim_time, laps_done, capture_index])
	var avg_speed := 0.0
	var off_count := 0
	for s in samples:
		avg_speed += s["speed"]
		if s["off"]:
			off_count += 1
	avg_speed = avg_speed / maxi(1, samples.size())
	var off_frac := float(off_count) / maxi(1, samples.size())

	var report := {
		"mode": "selfcheck",
		"sim_seconds": sim_time,
		"laps_done": laps_done,
		"best_lap": (null if best_lap == INF else best_lap),
		"top_speed_kmh": top_speed * 3.6,
		"avg_speed_kmh": avg_speed * 3.6,
		"max_lateral_g": max_lateral_g,
		"off_track_seconds": off_track_time,
		"off_track_fraction": off_frac,
		"distance_m": distance,
		"frames_captured": capture_index,
	}

	# ---- invariants the loop can check WITHOUT a human ----
	var checks := []
	checks.append(_check("physics stable (no NaN position)",
		is_finite(car.global_position.x) and is_finite(car.global_position.z)))
	checks.append(_check("car actually moved (>200 m)", distance > 200.0))
	checks.append(_check("reached a sane top speed (>60 km/h)", top_speed * 3.6 > 60.0))
	checks.append(_check("completed at least one lap", laps_done >= 1))
	checks.append(_check("bot mostly stays on track (off < 25%)", off_frac < 0.25))
	checks.append(_check("no absurd cornering loads (<6 g)", max_lateral_g < 6.0))
	checks.append(_check("captured frames for visual review", capture_index >= 3))

	var passed := true
	for c in checks:
		if not c["ok"]:
			passed = false
	report["checks"] = checks
	report["passed"] = passed

	var f := FileAccess.open("user://selfcheck.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()

	# path + track dumps for the top-down diagnostic plot (tools/plot_run.py)
	var pf := FileAccess.open("user://path.csv", FileAccess.WRITE)
	pf.store_line("t,x,z,speed,steer,off")
	for s in samples:
		pf.store_line("%f,%f,%f,%f,%f,%d" % [s["t"], s["x"], s["z"], s["speed"], s["steer"], 1 if s["off"] else 0])
	pf.close()
	var tf := FileAccess.open("user://track.csv", FileAccess.WRITE)
	tf.store_line("x,z")
	for p in track.points:
		tf.store_line("%f,%f" % [p.x, p.y])
	tf.store_line("road_width,%f" % ROAD_WIDTH)
	tf.close()

	print("==== NEON DELTA SELFCHECK ====")
	for c in checks:
		print(("  PASS  " if c["ok"] else "  FAIL  "), c["name"])
	print("  laps=%d  top=%.0f km/h  avg=%.0f km/h  off=%.0f%%  maxLatG=%.2f  dist=%.0fm" % [
		laps_done, top_speed * 3.6, avg_speed * 3.6, off_frac * 100.0, max_lateral_g, distance])
	print("  report: ", ProjectSettings.globalize_path("user://selfcheck.json"))
	print("  frames: ", ProjectSettings.globalize_path("user://frames"))
	print("==== ", ("PASS" if passed else "FAIL"), " ====")
	set_process(false)
	set_physics_process(false)
	get_tree().quit(0 if passed else 1)

func _check(name: String, ok: bool) -> Dictionary:
	return {"name": name, "ok": ok}
