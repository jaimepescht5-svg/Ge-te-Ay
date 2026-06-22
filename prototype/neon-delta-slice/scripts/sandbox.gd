extends Node3D

# NEON DELTA — gray-box "verbs" sandbox.
#
# The driving slice (Main.tscn / main.gd) proves the *driving* verb. This scene
# proves the on-foot verbs of a crime sandbox, added one at a time, each with a
# headless self-check:
#   1. ON FOOT   — walk/run a CharacterBody3D with gravity + collision   (this commit)
#   2. SHOOTING  — raycast gun + destructible targets                    (next)
#   3. HEAT      — a 0–5 wanted level that spawns a pursuer              (next)
#
# Mode is chosen by GAME_MODE, exactly like the driving slice:
#   play       (default) — WASD/arrows move, Shift runs, R resets.
#   bot        — the scripted foot-bot walks the waypoints; you watch.
#   selfcheck  — the bot drives headless-under-Xvfb; we capture frames, log
#                telemetry, assert invariants, and quit with a status code.
#
# Built entirely in code (no binary .tscn content) so diffs stay meaningful.

const FootBot := preload("res://scripts/foot_bot.gd")

# ---- feel tunables (the human's to judge) ----
const WALK_SPEED := 5.5
const RUN_SPEED := 9.5
const GROUND_ACCEL := 45.0   # how fast we reach target velocity
const GRAVITY := 24.0
const TURN_SPEED := 10.0      # how fast the body faces its travel direction

# ---- arena ----
const ARENA := 60.0          # half-extent of the walled flat ground

# ---- selfcheck ----
const SELFCHECK_SECONDS := 45.0
const CAPTURE_INTERVAL := 1.5

var mode := "play"
var selfcheck_seconds := SELFCHECK_SECONDS
var capture_interval := CAPTURE_INTERVAL
var capture_max := 40
var frames_dir := "user://frames_foot"

var player: CharacterBody3D
var player_yaw := 0.0
var cam: Camera3D
var hud: Label
var bot

# ---- shooting verb ----
const GUN_RANGE := 90.0
var aim_dir := Vector3(0, 0, 1)     # current aim (world unit vector)
var target_bodies: Array = []       # Array[StaticBody3D]
var target_meshes: Array = []       # Array[MeshInstance3D]
var target_alive: Array = []        # Array[bool]
var target_pos: Array = []          # Array[Vector3]
var shots_fired := 0
var shots_hit := 0
var targets_destroyed := 0

# ---- wanted / Heat verb ----
const HEAT_PER_CRIME := 1.2
const HEAT_MAX := 5.0
const HEAT_DECAY := 0.25          # stars/sec once "clean"
const HEAT_CLEAN_DELAY := 2.0     # seconds after last crime before decay starts
const PURSUER_SPEED := 7.5
const PURSUER_CAP := 3
const OBSERVE_SECONDS := 7.0      # watch Heat/pursuers after the bot is done
var heat := 0.0
var heat_peak := 0.0
var heat_clean_timer := 0.0
var pursuers: Array = []
var pursuers_spawned := 0
var pursuer_min_dist := INF
var done_time := -1.0

# telemetry / state
var sim_time := 0.0
var next_capture := 0.0
var capture_index := 0
var start_pos := Vector3.ZERO
var distance := 0.0
var prev_pos := Vector3.ZERO
var top_speed := 0.0
var min_y := INF
var max_y := -INF
var nan_seen := false
var waypoints: Array = []
var waypoints_reached := 0
var bot_done := false
var samples: Array = []

func _ready() -> void:
	mode = OS.get_environment("GAME_MODE")
	if mode == "":
		mode = "play"
	var sc := OS.get_environment("SC_SECONDS")
	if sc != "":
		selfcheck_seconds = float(sc)
	var ci := OS.get_environment("CAP_INTERVAL")
	if ci != "":
		capture_interval = float(ci)
	var cm := OS.get_environment("CAP_MAX")
	if cm != "":
		capture_max = int(cm)
	var vo := OS.get_environment("VIZ_OUT")
	if vo != "":
		frames_dir = vo

	_build_environment()
	_build_ground()
	_build_walls()
	_build_obstacles()
	_build_targets()
	_build_player()
	_build_camera()
	_build_hud()
	_setup_input()

	# a square patrol the bot walks (also the human-readable "goal" in play mode)
	waypoints = [
		Vector3(30, 0, 0), Vector3(30, 0, 30),
		Vector3(-30, 0, 30), Vector3(-30, 0, -30),
		Vector3(0, 0, 0),
	]
	bot = FootBot.new(waypoints, target_pos)

	start_pos = player.global_position
	prev_pos = start_pos

# ----------------------------------------------------------------- world build
func _build_environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.06, 0.09)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.35, 0.38, 0.48)
	e.ambient_light_energy = 0.7
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
	box.size = Vector3(ARENA * 2.0, 2.0, ARENA * 2.0)
	col.shape = box
	col.position = Vector3(0, -1, 0)
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(ARENA * 2.0, ARENA * 2.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.11, 0.13)
	plane.material = mat
	mesh.mesh = plane
	body.add_child(mesh)
	add_child(body)

func _build_walls() -> void:
	# four perimeter walls so the player (and pursuers) are contained.
	var t := ARENA
	_wall(Vector3(0, 1.5, t), Vector3(t * 2 + 2, 3, 1))
	_wall(Vector3(0, 1.5, -t), Vector3(t * 2 + 2, 3, 1))
	_wall(Vector3(t, 1.5, 0), Vector3(1, 3, t * 2 + 2))
	_wall(Vector3(-t, 1.5, 0), Vector3(1, 3, t * 2 + 2))

func _wall(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.18, 0.24)
	mesh.mesh = bm
	mesh.material_override = mat
	body.add_child(mesh)
	body.position = pos
	add_child(body)

func _build_obstacles() -> void:
	# a few blocks to bump into / route around (collision coverage for the bot).
	for spec in [
		[Vector3(12, 1.5, 12), Vector3(4, 3, 4)],
		[Vector3(-16, 1.5, 8), Vector3(6, 3, 3)],
		[Vector3(8, 1.5, -18), Vector3(3, 3, 8)],
	]:
		_wall(spec[0], spec[1])

func _build_targets() -> void:
	# shoot-the-dummy targets with clear line-of-sight from the arena centre
	# (where the walk patrol ends and the shooting phase begins).
	var positions := [
		Vector3(0, 1, 24), Vector3(22, 1, 12), Vector3(24, 1, -8),
		Vector3(-22, 1, -10), Vector3(-16, 1, 22),
	]
	for p in positions:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var cap := CapsuleShape3D.new()
		cap.radius = 0.6
		cap.height = 2.0
		col.shape = cap
		col.position.y = 1.0
		body.add_child(col)
		var mesh := MeshInstance3D.new()
		var cm := CapsuleMesh.new()
		cm.radius = 0.6
		cm.height = 2.0
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.95, 0.85, 0.2)        # NEON DELTA yellow
		mat.emission_enabled = true
		mat.emission = Color(0.95, 0.85, 0.2)
		mat.emission_energy_multiplier = 0.6
		mesh.mesh = cm
		mesh.material_override = mat
		mesh.position.y = 1.0
		body.add_child(mesh)
		body.position = p
		add_child(body)
		target_bodies.append(body)
		target_meshes.append(mesh)
		target_alive.append(true)
		target_pos.append(p)

func _build_player() -> void:
	player = CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	player.add_child(col)
	var mesh := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.4
	cm.height = 1.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.16, 0.43)          # NEON DELTA pink
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.16, 0.43)
	mat.emission_energy_multiplier = 0.5
	mesh.mesh = cm
	mesh.material_override = mat
	mesh.position.y = 0.9
	player.add_child(mesh)
	# a little "nose" so facing is visible
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.2, 0.2, 0.5)
	nose.mesh = nb
	nose.position = Vector3(0, 1.2, 0.45)
	player.add_child(nose)
	player.position = Vector3(0, 1.0, 0)
	add_child(player)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.fov = 70.0
	cam.position = Vector3(0, 6, 10)
	add_child(cam)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16, 12)
	hud.add_theme_font_size_override("font_size", 22)
	hud.add_theme_color_override("font_color", Color(0.02, 0.85, 0.91))
	layer.add_child(hud)

func _setup_input() -> void:
	for action in ["mv_fwd", "mv_back", "mv_left", "mv_right", "run", "reset", "fire"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_bind("mv_fwd", [KEY_W, KEY_UP])
	_bind("mv_back", [KEY_S, KEY_DOWN])
	_bind("mv_left", [KEY_A, KEY_LEFT])
	_bind("mv_right", [KEY_D, KEY_RIGHT])
	_bind("run", [KEY_SHIFT])
	_bind("reset", [KEY_R])
	var mb := InputEventMouseButton.new()
	mb.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("fire", mb)

func _bind(action: String, keys: Array) -> void:
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)

# ------------------------------------------------------------------- main loop
func _physics_process(delta: float) -> void:
	sim_time += delta
	var c: Dictionary
	if mode == "play":
		c = _player_controls()
	else:
		c = bot.control(player.global_position, delta)
		if c.get("reached", false):
			waypoints_reached += 1
		if c.get("done", false):
			bot_done = true
	_apply_movement(c, delta)
	# aim: bot supplies an explicit aim vector; the player aims along facing.
	if c.has("aim"):
		aim_dir = c["aim"]
	else:
		aim_dir = Vector3(sin(player_yaw), 0, cos(player_yaw))
	if c.get("fire", false):
		_shoot()
	_update_telemetry(delta)
	_update_heat(delta)
	_update_pursuers(delta)

	if mode == "play" and Input.is_action_just_pressed("reset"):
		_reset_player()

	if mode == "selfcheck":
		var p := player.global_position
		samples.append({"t": sim_time, "x": p.x, "z": p.z, "y": p.y, "speed": _planar_speed(), "heat": heat})
		if bot_done and done_time < 0.0:
			done_time = sim_time
		var observed := done_time >= 0.0 and sim_time >= done_time + OBSERVE_SECONDS
		if sim_time >= selfcheck_seconds or observed:
			_finish_selfcheck()

func _player_controls() -> Dictionary:
	var mv := Vector2.ZERO
	mv.y -= Input.get_action_strength("mv_fwd")
	mv.y += Input.get_action_strength("mv_back")
	mv.x -= Input.get_action_strength("mv_left")
	mv.x += Input.get_action_strength("mv_right")
	if mv.length() > 1.0:
		mv = mv.normalized()
	return {"move": mv, "run": Input.is_action_pressed("run"),
			"fire": Input.is_action_just_pressed("fire")}

func _shoot() -> void:
	shots_fired += 1
	var from := player.global_position + Vector3.UP * 1.2 + aim_dir * 0.6
	var to := from + aim_dir * GUN_RANGE
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.exclude = [player.get_rid()]
	var hit := space.intersect_ray(q)
	var hit_point: Vector3 = to
	if hit.has("position"):
		hit_point = hit["position"]
		var collider = hit.get("collider")
		var idx := target_bodies.find(collider)
		if idx != -1 and target_alive[idx]:
			target_alive[idx] = false
			targets_destroyed += 1
			shots_hit += 1
			target_meshes[idx].visible = false
			target_bodies[idx].set_collision_layer_value(1, false)
			_commit_crime()
	_spawn_tracer(from, hit_point)

func _commit_crime() -> void:
	heat = minf(HEAT_MAX, heat + HEAT_PER_CRIME)
	heat_peak = maxf(heat_peak, heat)
	heat_clean_timer = 0.0

func _update_heat(delta: float) -> void:
	heat_clean_timer += delta
	if heat_clean_timer > HEAT_CLEAN_DELAY and heat > 0.0:
		heat = maxf(0.0, heat - HEAT_DECAY * delta)
	# spawn pursuers proportional to the wanted level
	var want: int = mini(PURSUER_CAP, int(floor(heat)))
	while pursuers.size() < want:
		_spawn_pursuer()

func _spawn_pursuer() -> void:
	var cop := CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	cop.add_child(col)
	var mesh := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.4
	cm.height = 1.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.85, 0.91)         # NEON DELTA cyan = the law
	mat.emission_enabled = true
	mat.emission = Color(0.05, 0.85, 0.91)
	mat.emission_energy_multiplier = 0.6
	mesh.mesh = cm
	mesh.position.y = 0.9
	mesh.material_override = mat
	cop.add_child(mesh)
	# spawn at an arena corner away from the player
	var p := player.global_position
	var corner := Vector3(ARENA - 4, 1.0, ARENA - 4)
	if p.x > 0: corner.x = -(ARENA - 4)
	if p.z > 0: corner.z = -(ARENA - 4)
	cop.position = corner
	add_child(cop)
	pursuers.append(cop)
	pursuers_spawned += 1

func _update_pursuers(delta: float) -> void:
	var p := player.global_position
	for cop: CharacterBody3D in pursuers:
		var to: Vector3 = p - cop.global_position
		var flat := Vector2(to.x, to.z)
		var dist := flat.length()
		pursuer_min_dist = minf(pursuer_min_dist, dist)
		var dir := flat.normalized() if dist > 0.001 else Vector2.ZERO
		var v: Vector3 = cop.velocity
		v.x = dir.x * PURSUER_SPEED
		v.z = dir.y * PURSUER_SPEED
		if not cop.is_on_floor():
			v.y -= GRAVITY * delta
		else:
			v.y = maxf(v.y, -0.1)
		cop.velocity = v
		cop.move_and_slide()
		cop.rotation.y = atan2(dir.x, dir.y) if dir.length() > 0.1 else cop.rotation.y

func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	# visual only; skipped headless. Brief glowing line + muzzle flash.
	if DisplayServer.get_name() == "headless":
		return
	var mid := (from + to) * 0.5
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.06, 0.06, from.distance_to(to))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.98, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(0.98, 0.98, 0.5)
	mat.emission_energy_multiplier = 3.0
	mesh.mesh = bm
	mesh.material_override = mat
	mesh.position = mid
	mesh.look_at_from_position(mid, to, Vector3.UP)
	add_child(mesh)
	get_tree().create_timer(0.06).timeout.connect(mesh.queue_free)

func _apply_movement(c: Dictionary, delta: float) -> void:
	var wish: Vector2 = c.get("move", Vector2.ZERO)
	var speed: float = RUN_SPEED if c.get("run", false) else WALK_SPEED
	var target := Vector3(wish.x, 0, wish.y) * speed
	var v := player.velocity
	# accelerate horizontal velocity toward target
	v.x = move_toward(v.x, target.x, GROUND_ACCEL * delta)
	v.z = move_toward(v.z, target.z, GROUND_ACCEL * delta)
	# gravity
	if not player.is_on_floor():
		v.y -= GRAVITY * delta
	else:
		v.y = maxf(v.y, -0.1)
	player.velocity = v
	player.move_and_slide()
	# face travel direction
	if Vector2(v.x, v.z).length() > 0.5:
		var want := atan2(v.x, v.z)
		player_yaw = _lerp_angle(player_yaw, want, TURN_SPEED * delta)
		player.rotation.y = player_yaw

func _update_telemetry(delta: float) -> void:
	var p := player.global_position
	if not _finite(p):
		nan_seen = true
		return
	distance += Vector2(p.x - prev_pos.x, p.z - prev_pos.z).length()
	top_speed = maxf(top_speed, _planar_speed())
	min_y = minf(min_y, p.y)
	max_y = maxf(max_y, p.y)
	prev_pos = p

func _reset_player() -> void:
	player.velocity = Vector3.ZERO
	player.global_position = Vector3(0, 1.0, 0)

# ---------------------------------------------------------------- per-frame
func _process(_d: float) -> void:
	_update_camera()
	_update_hud()
	if mode == "selfcheck" and sim_time >= next_capture:
		next_capture += capture_interval
		_capture_frame()

func _update_camera() -> void:
	if cam == null or player == null:
		return
	var p := player.global_position
	var back := Vector3(-sin(player_yaw), 0, -cos(player_yaw))
	var target := p + back * 9.0 + Vector3.UP * 6.0
	cam.global_position = cam.global_position.lerp(target, 0.12)
	cam.look_at(p + Vector3.UP * 1.0, Vector3.UP)

func _update_hud() -> void:
	if hud == null:
		return
	var stars := ""
	for i in range(5):
		stars += "*" if i < int(round(heat)) else "."
	hud.text = "NEON DELTA — on foot\nmode:%s  speed:%.1f m/s  waypoints:%d/%d  targets:%d/%d\nHEAT [%s]  pursuers:%d" % [
		mode, _planar_speed(), waypoints_reached, waypoints.size(),
		targets_destroyed, target_pos.size(), stars, pursuers.size(),
	]

func _capture_frame() -> void:
	if DisplayServer.get_name() == "headless" or capture_index >= capture_max:
		capture_index += 1
		return
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(frames_dir)
	img.save_png("%s/foot_%04d.png" % [frames_dir, capture_index])
	capture_index += 1

# ----------------------------------------------------------------- selfcheck
func _finish_selfcheck() -> void:
	set_physics_process(false)
	set_process(false)
	print("[sandbox] finishing at sim_time=%.1f reached=%d/%d frames=%d" % [
		sim_time, waypoints_reached, waypoints.size(), capture_index,
	])
	var grounded := (min_y > -2.0) and (max_y < 5.0)
	var checks := []
	checks.append(_check("physics stable (no NaN)", not nan_seen and _finite(player.global_position)))
	checks.append(_check("player actually moved (>40 m)", distance > 40.0))
	checks.append(_check("reached a sane walk speed (>3 m/s)", top_speed > 3.0))
	checks.append(_check("reached all waypoints", waypoints_reached >= waypoints.size()))
	checks.append(_check("stayed grounded (no fall-through / launch)", grounded))
	checks.append(_check("fired the gun", shots_fired > 0))
	checks.append(_check("destroyed every target", targets_destroyed >= target_pos.size()))
	checks.append(_check("decent aim (>=45% of shots hit)", shots_fired > 0 and float(shots_hit) / float(shots_fired) >= 0.45))
	checks.append(_check("crimes raised Heat (peak >= 1 star)", heat_peak >= 1.0))
	checks.append(_check("Heat spawned a pursuer", pursuers_spawned > 0))
	checks.append(_check("pursuer closed in (min dist < 32 m)", pursuer_min_dist < 32.0))
	checks.append(_check("Heat decays when clean (final < peak)", heat < heat_peak - 0.1))
	checks.append(_check("captured frames for visual review", capture_index >= 3))

	var passed := true
	for c in checks:
		if not c["ok"]:
			passed = false

	var report := {
		"mode": mode,
		"sim_seconds": sim_time,
		"distance_m": distance,
		"top_speed_ms": top_speed,
		"waypoints_reached": waypoints_reached,
		"waypoints_total": waypoints.size(),
		"min_y": min_y,
		"max_y": max_y,
		"shots_fired": shots_fired,
		"shots_hit": shots_hit,
		"targets_destroyed": targets_destroyed,
		"targets_total": target_pos.size(),
		"heat_peak": heat_peak,
		"heat_final": heat,
		"pursuers_spawned": pursuers_spawned,
		"pursuer_min_dist": pursuer_min_dist,
		"frames_captured": capture_index,
		"checks": checks,
		"passed": passed,
	}
	var f := FileAccess.open("user://sandbox_selfcheck.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()

	var pf := FileAccess.open("user://foot_path.csv", FileAccess.WRITE)
	pf.store_line("t,x,z,y,speed")
	for s in samples:
		pf.store_line("%f,%f,%f,%f,%f" % [s["t"], s["x"], s["z"], s["y"], s["speed"]])
	pf.close()

	print("[sandbox] verdict: ", "PASS" if passed else "FAIL")
	for c in checks:
		print("  ", "[ok] " if c["ok"] else "[XX] ", c["name"])
	print("  report: ", ProjectSettings.globalize_path("user://sandbox_selfcheck.json"))
	get_tree().quit(0 if passed else 1)

# ---------------------------------------------------------------------- utils
func _check(name: String, ok: bool) -> Dictionary:
	return {"name": name, "ok": ok}

func _planar_speed() -> float:
	var v := player.velocity
	return Vector2(v.x, v.z).length()

func _finite(p: Vector3) -> bool:
	return is_finite(p.x) and is_finite(p.y) and is_finite(p.z)

func _lerp_angle(from: float, to: float, weight: float) -> float:
	return from + _wrap_pi(to - from) * clampf(weight, 0.0, 1.0)

func _wrap_pi(a: float) -> float:
	while a > PI:
		a -= TAU
	while a < -PI:
		a += TAU
	return a
