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
const SELFCHECK_SECONDS := 60.0   # room for the full enter-car / drive / exit loop
# Frame capture is handled by the VizCapture autoload (scripts/capture.gd).

var mode := "play"
var selfcheck_seconds := SELFCHECK_SECONDS

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

# ---- play-mode feel (mouse-look + audio); unused by bot/selfcheck ----
const MOUSE_SENS := 0.0026
var cam_yaw := 0.0
var cam_pitch := -0.12
var gun_player: AudioStreamPlayer

# ---- enter/exit car verb ----
const CAR_ENGINE := 3400.0
const CAR_BRAKE := 40.0
const CAR_MAX_STEER := 0.5
const CAR_STEER_SPEED := 5.0
const CAR_MASS := 1300.0
const CAR_WHEEL_FRICTION := 4.0
const CAR_SIZE := Vector3(2.0, 1.0, 4.4)
const ENTER_RADIUS := 3.6
var car: VehicleBody3D
var car_start := Vector3(16, 0.7, 4)
var car_steer := 0.0
var control_mode := "foot"           # "foot" or "drive"
var entered_car := false
var exited_car := false
var car_distance := 0.0
var car_prev_pos := Vector3.ZERO

# telemetry / state
var sim_time := 0.0
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
	_build_environment()
	_build_ground()
	_build_walls()
	_build_skyline()
	_build_obstacles()
	_build_targets()
	_build_car()
	_build_player()
	_build_camera()
	_build_hud()
	_build_audio()
	_setup_input()
	if mode == "play":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# a square patrol the bot walks (also the human-readable "goal" in play mode)
	waypoints = [
		Vector3(30, 0, 0), Vector3(30, 0, 30),
		Vector3(-30, 0, 30), Vector3(-30, 0, -30),
		Vector3(0, 0, 0),
	]
	bot = FootBot.new(waypoints, target_pos, car_start)

	start_pos = player.global_position
	prev_pos = start_pos
	car_prev_pos = car.global_position

# ----------------------------------------------------------------- world build
func _build_environment() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.02, 0.02, 0.05)            # deep night
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.12, 0.14, 0.26)        # cool, dim — let neon pop
	e.ambient_light_energy = 0.5
	# bloom so the emissive neon actually glows (harmless if the GL renderer
	# can't post-process it).
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_strength = 1.1
	e.glow_bloom = 0.3
	e.glow_hdr_threshold = 0.85
	env.environment = e
	add_child(env)
	# a low, cool "moon" so geometry still reads in shadow
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-60, -50, 0)
	moon.light_energy = 0.35
	moon.light_color = Color(0.6, 0.7, 1.0)
	add_child(moon)

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
	mat.albedo_color = Color(0.03, 0.03, 0.05)
	mat.metallic = 0.3
	mat.roughness = 0.4
	plane.material = mat
	mesh.mesh = plane
	body.add_child(mesh)
	add_child(body)
	_build_grid()

func _build_grid() -> void:
	# a glowing neon floor grid — the signature NEON DELTA look.
	var step := 10.0
	var n := int(ARENA / step)
	var line_mat := StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.02, 0.55, 0.65)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.05, 0.85, 0.95)            # cyan
	line_mat.emission_energy_multiplier = 1.6
	for i in range(-n, n + 1):
		var x := i * step
		_grid_line(Vector3(x, 0.03, 0), Vector3(0.12, 0.04, ARENA * 2), line_mat)
		_grid_line(Vector3(0, 0.03, x), Vector3(ARENA * 2, 0.04, 0.12), line_mat)

func _grid_line(pos: Vector3, size: Vector3, mat: StandardMaterial3D) -> void:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.material_override = mat
	m.position = pos
	add_child(m)

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
	mat.albedo_color = Color(0.05, 0.06, 0.10)
	mat.metallic = 0.4
	mat.roughness = 0.5
	mesh.mesh = bm
	mesh.material_override = mat
	body.add_child(mesh)
	# glowing magenta cap so edges read in the dark
	var strip := MeshInstance3D.new()
	var sb := BoxMesh.new()
	sb.size = Vector3(size.x * 1.01, 0.18, size.z * 1.01)
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 0.16, 0.43)
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.16, 0.43)             # magenta
	smat.emission_energy_multiplier = 1.8
	strip.mesh = sb
	strip.material_override = smat
	strip.position.y = size.y * 0.5
	mesh.add_child(strip)
	body.position = pos
	add_child(body)

func _build_skyline() -> void:
	# a ring of dark towers with neon vertical strips, just outside the arena —
	# Port Soleil on the horizon. Pure atmosphere (no collision needed).
	var hues := [Color(0.05, 0.85, 0.95), Color(1.0, 0.16, 0.43), Color(0.7, 0.4, 1.0), Color(0.2, 1.0, 0.5)]
	var count := 22
	for i in range(count):
		var ang := TAU * float(i) / float(count)
		var r := ARENA + 14.0 + randf() * 26.0
		var h := 16.0 + randf() * 60.0
		var pos := Vector3(cos(ang) * r, h * 0.5, sin(ang) * r)
		var tower := MeshInstance3D.new()
		var bm := BoxMesh.new()
		var w := 6.0 + randf() * 6.0
		bm.size = Vector3(w, h, w)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.03, 0.04, 0.08)
		tower.mesh = bm
		tower.material_override = mat
		tower.position = pos
		add_child(tower)
		# a couple of glowing window bands
		var hue: Color = hues[i % hues.size()]
		for b in range(2):
			var band := MeshInstance3D.new()
			var bb := BoxMesh.new()
			bb.size = Vector3(w * 1.02, 1.4 + randf() * 2.0, w * 1.02)
			var bmat := StandardMaterial3D.new()
			bmat.albedo_color = hue
			bmat.emission_enabled = true
			bmat.emission = hue
			bmat.emission_energy_multiplier = 2.2
			band.mesh = bb
			band.material_override = bmat
			band.position = Vector3(pos.x, h * (0.4 + 0.3 * b), pos.z)
			add_child(band)

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

func _build_car() -> void:
	car = VehicleBody3D.new()
	car.mass = CAR_MASS
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = CAR_SIZE
	col.shape = box
	col.position.y = CAR_SIZE.y * 0.5
	car.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CAR_SIZE.x, CAR_SIZE.y - 0.1, CAR_SIZE.z)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.16, 0.43)            # player magenta (vs cyan cops)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.16, 0.43)
	mat.emission_energy_multiplier = 0.8
	mesh.material_override = mat
	mesh.position.y = CAR_SIZE.y * 0.5
	car.add_child(mesh)
	# headlight nose so heading reads
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(1.4, 0.25, 0.2)
	var nm := StandardMaterial3D.new()
	nm.albedo_color = Color(1, 1, 0.8)
	nm.emission_enabled = true
	nm.emission = Color(1, 1, 0.7)
	nm.emission_energy_multiplier = 2.0
	nose.material_override = nm
	nose.mesh = nb
	nose.position = Vector3(0, CAR_SIZE.y * 0.5, -(CAR_SIZE.z * 0.5 - 0.1))
	car.add_child(nose)
	var wx := CAR_SIZE.x * 0.5 - 0.15
	var wz := CAR_SIZE.z * 0.5 - 1.0
	_add_wheel(Vector3(-wx, 0.0, -wz), true, true)
	_add_wheel(Vector3(wx, 0.0, -wz), true, true)
	_add_wheel(Vector3(-wx, 0.0, wz), true, false)
	_add_wheel(Vector3(wx, 0.0, wz), true, false)
	car.position = car_start
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
	w.wheel_friction_slip = CAR_WHEEL_FRICTION
	car.add_child(w)

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
	mat.emission_energy_multiplier = 1.7
	mesh.mesh = cm
	mesh.material_override = mat
	mesh.position.y = 0.9
	player.add_child(mesh)
	var glow := OmniLight3D.new()
	glow.light_color = Color(1.0, 0.2, 0.5)
	glow.light_energy = 2.0
	glow.omni_range = 9.0
	glow.position = Vector3(0, 1.2, 0)
	player.add_child(glow)
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
	# centre crosshair
	var cross := Label.new()
	cross.text = "+"
	cross.add_theme_font_size_override("font_size", 30)
	cross.add_theme_color_override("font_color", Color(0.05, 0.85, 0.95))
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	layer.add_child(cross)

func _build_audio() -> void:
	gun_player = AudioStreamPlayer.new()
	gun_player.stream = _make_gunshot()
	gun_player.volume_db = -7.0
	add_child(gun_player)

func _make_gunshot() -> AudioStreamWAV:
	# a short noise burst with a fast decay — generated in code (no asset files).
	var sr := 22050
	var n := int(sr * 0.14)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t := float(i) / float(n)
		var env := pow(1.0 - t, 2.2)
		var s := (randf() * 2.0 - 1.0) * env * 0.7
		var v := int(clampf(s, -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xff
		data[i * 2 + 1] = (v >> 8) & 0xff
	var st := AudioStreamWAV.new()
	st.format = AudioStreamWAV.FORMAT_16_BITS
	st.mix_rate = sr
	st.stereo = false
	st.data = data
	return st

func _setup_input() -> void:
	for action in ["mv_fwd", "mv_back", "mv_left", "mv_right", "run", "reset", "fire", "enter"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_bind("mv_fwd", [KEY_W, KEY_UP])
	_bind("mv_back", [KEY_S, KEY_DOWN])
	_bind("mv_left", [KEY_A, KEY_LEFT])
	_bind("mv_right", [KEY_D, KEY_RIGHT])
	_bind("run", [KEY_SHIFT])
	_bind("reset", [KEY_R])
	_bind("enter", [KEY_F])
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
		c = _player_controls() if control_mode == "foot" else _car_controls_play()
		if Input.is_action_just_pressed("enter"):
			c["request"] = "exit" if control_mode == "drive" else "enter"
	else:
		c = bot.control(player.global_position, delta)
		if c.get("reached", false):
			waypoints_reached += 1
		if c.get("done", false):
			bot_done = true

	# enter / exit the car
	var req: String = c.get("request", "")
	if req == "enter" and control_mode == "foot" and _near_car():
		_enter_car()
	elif req == "exit" and control_mode == "drive":
		_exit_car()

	if control_mode == "foot":
		_apply_movement(c, delta)
		# aim: bot supplies an explicit aim vector; the player aims along look/facing.
		if c.has("aim"):
			aim_dir = c["aim"]
		elif mode == "play":
			aim_dir = _cam_aim()
		else:
			aim_dir = Vector3(sin(player_yaw), 0, cos(player_yaw))
		if c.get("fire", false):
			_shoot()
	else:
		_drive_car(c, delta)

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

func _unhandled_input(event: InputEvent) -> void:
	if mode != "play":
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam_yaw -= event.relative.x * MOUSE_SENS
		cam_pitch = clampf(cam_pitch - event.relative.y * MOUSE_SENS, -1.2, 0.5)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _player_controls() -> Dictionary:
	# camera-relative movement so WASD follows where you're looking
	var f := Input.get_action_strength("mv_fwd") - Input.get_action_strength("mv_back")
	var s := Input.get_action_strength("mv_right") - Input.get_action_strength("mv_left")
	var forward := Vector2(sin(cam_yaw), cos(cam_yaw))
	var right := Vector2(cos(cam_yaw), -sin(cam_yaw))
	var wish := forward * f + right * s
	if wish.length() > 1.0:
		wish = wish.normalized()
	return {"move": wish, "run": Input.is_action_pressed("run"),
			"fire": Input.is_action_just_pressed("fire")}

func _cam_aim() -> Vector3:
	return Vector3(sin(cam_yaw) * cos(cam_pitch), sin(cam_pitch), cos(cam_yaw) * cos(cam_pitch)).normalized()

func _car_controls_play() -> Dictionary:
	var throttle := Input.get_action_strength("mv_fwd")
	var brake := Input.get_action_strength("mv_back")
	var steer := Input.get_action_strength("mv_left") - Input.get_action_strength("mv_right")
	return {"throttle": throttle, "brake": brake, "steer": steer}

func _near_car() -> bool:
	return car != null and player.global_position.distance_to(car.global_position) < ENTER_RADIUS

func _enter_car() -> void:
	control_mode = "drive"
	entered_car = true
	player.visible = false
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)
	player.velocity = Vector3.ZERO
	car_prev_pos = car.global_position

func _exit_car() -> void:
	control_mode = "foot"
	exited_car = true
	car.engine_force = 0.0
	car.brake = CAR_BRAKE
	var side := car.global_transform.basis.x.normalized()
	player.global_position = car.global_position + side * 2.4 + Vector3.UP * 0.2
	player.visible = true
	player.set_collision_layer_value(1, true)
	player.set_collision_mask_value(1, true)
	player.velocity = Vector3.ZERO
	player_yaw = car.rotation.y

func _drive_car(c: Dictionary, delta: float) -> void:
	var throttle: float = c.get("throttle", 0.0)
	var brake: float = c.get("brake", 0.0)
	var steer: float = c.get("steer", 0.0)
	var target_steer := steer * CAR_MAX_STEER
	car_steer = move_toward(car_steer, target_steer, CAR_STEER_SPEED * CAR_MAX_STEER * delta)
	car.steering = car_steer
	car.engine_force = throttle * CAR_ENGINE
	car.brake = brake * CAR_BRAKE
	var cp := car.global_position
	car_distance += Vector2(cp.x - car_prev_pos.x, cp.z - car_prev_pos.z).length()
	car_prev_pos = cp
	# the hidden player rides along so telemetry + exit placement track the car
	player.global_position = cp

func _shoot() -> void:
	shots_fired += 1
	if gun_player != null:
		gun_player.play()
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
	var light := OmniLight3D.new()
	light.light_color = Color(0.1, 0.9, 1.0)
	light.light_energy = 2.4
	light.omni_range = 11.0
	light.position = Vector3(0, 1.4, 0)
	cop.add_child(light)
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

func _update_camera() -> void:
	if cam == null or player == null:
		return
	if control_mode == "drive" and car != null:
		var b := car.global_transform.basis
		var target := car.global_position + b.z * 9.0 + Vector3.UP * 4.5
		cam.global_position = cam.global_position.lerp(target, 0.12)
		cam.look_at(car.global_position + Vector3.UP * 1.0 - b.z * 4.0, Vector3.UP)
		return
	var p := player.global_position
	if mode == "play":
		# mouse-look orbit: third-person behind the look direction
		var back := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
		var height: float = 3.2 - cam_pitch * 4.5
		var target := p + back * 6.5 + Vector3.UP * height
		cam.global_position = cam.global_position.lerp(target, 0.3)
		cam.look_at(p + Vector3.UP * 1.4 + _cam_aim() * 5.0, Vector3.UP)
		player.rotation.y = cam_yaw
		player_yaw = cam_yaw
		return
	var back := Vector3(-sin(player_yaw), 0, -cos(player_yaw))
	var target := p + back * 8.0 + Vector3.UP * 4.6
	cam.global_position = cam.global_position.lerp(target, 0.14)
	cam.look_at(p + Vector3.UP * 1.3, Vector3.UP)

func _update_hud() -> void:
	if hud == null:
		return
	var stars := ""
	for i in range(5):
		stars += "*" if i < int(round(heat)) else "."
	var title := "NEON DELTA — DRIVING" if control_mode == "drive" else "NEON DELTA — on foot"
	var hint := ""
	if control_mode == "drive":
		hint = "   [F] get out"
	elif _near_car():
		hint = "   [F] get in car"
	var spd: float = car.linear_velocity.length() if (control_mode == "drive" and car != null) else _planar_speed()
	hud.text = "%s%s\nmode:%s  speed:%.1f m/s  waypoints:%d/%d  targets:%d/%d\nHEAT [%s]  pursuers:%d" % [
		title, hint, mode, spd, waypoints_reached, waypoints.size(),
		targets_destroyed, target_pos.size(), stars, pursuers.size(),
	]

# ----------------------------------------------------------------- selfcheck
func _finish_selfcheck() -> void:
	set_physics_process(false)
	set_process(false)
	print("[sandbox] finishing at sim_time=%.1f reached=%d/%d frames=%d" % [
		sim_time, waypoints_reached, waypoints.size(), VizCapture.idx,
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
	checks.append(_check("got in a car", entered_car))
	checks.append(_check("drove the car (>15 m)", car_distance > 15.0))
	checks.append(_check("got back out on foot", exited_car and control_mode == "foot"))
	checks.append(_check("captured frames for visual review", VizCapture.idx >= 3))

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
		"entered_car": entered_car,
		"exited_car": exited_car,
		"car_distance_m": car_distance,
		"frames_captured": VizCapture.idx,
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
