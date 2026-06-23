extends Node3D

# NEON DELTA — PORT SOLEIL open-world slice.
#
# This is the merge of the three branch prototypes into one Godot scene:
#   * world map      — the seven districts + causeways of Port Soleil
#   * driving        — the heavy VehicleBody3D cruiser
#   * on-foot sandbox — walk/run CharacterBody3D, raycast gun, 0-5 Heat system
#
# All geometry is built in GDScript (no binary .tscn content) so diffs in the
# design repo stay meaningful. No `class_name` anywhere — headless CI parses on a
# clean clone without the `.godot/` global class cache.
#
# Mode is chosen by GAME_MODE:
#   play       (default) — drive with WASD/arrows; E to enter/exit the car; on
#                          foot Shift runs and F fires; R respawns in the car.
#   bot        — the waypoint bot drives the world tour; you watch.
#   selfcheck  — the bot drives headless-under-Xvfb; we capture frames, log
#                telemetry, assert invariants, and quit with a status code.

const WaypointBot := preload("res://scripts/bot.gd")

# ----------------------------------------------------------------- world model
# Districts of Port Soleil (verbatim from game/index.html). ground/palette are
# hex ints converted to Color via _hex().
const DISTRICTS := [
	{"id": "downtown", "name": "DOWNTOWN CORE",  "cx": 0.0,    "cz": -40.0,  "w": 210.0, "d": 210.0, "ground": 0x121826, "palette": [0xff2a6d, 0x05d9e8, 0xb967ff], "flood": "mid",   "style": "towers",     "density": 0.78},
	{"id": "cut",      "name": "THE CUT",        "cx": -10.0,  "cz": 150.0,  "w": 230.0, "d": 150.0, "ground": 0x1d1726, "palette": [0xff7b00, 0xf9f871, 0xff2a6d], "flood": "first", "style": "rowhouse",   "density": 0.80},
	{"id": "heights",  "name": "MARISOL HEIGHTS","cx": 300.0,  "cz": -20.0,  "w": 180.0, "d": 220.0, "ground": 0x10241a, "palette": [0xf9f871, 0xffffff, 0xffd9a0], "flood": "dry",   "style": "mansion",    "density": 0.30},
	{"id": "reach",    "name": "THE REACH",      "cx": -300.0, "cz": 20.0,   "w": 190.0, "d": 250.0, "ground": 0x14130f, "palette": [0xff7b00, 0xf9f871, 0x05d9e8], "flood": "first", "style": "industrial", "density": 0.45},
	{"id": "cayo",     "name": "CAYO BRAVA",     "cx": 30.0,   "cz": -370.0, "w": 330.0, "d": 130.0, "ground": 0x1a2333, "palette": [0x05d9e8, 0xf9f871, 0xff7b00], "flood": "first", "style": "beach",      "density": 0.32},
	{"id": "bayou",    "name": "BAYOU VERDE",    "cx": -250.0, "cz": 360.0,  "w": 270.0, "d": 250.0, "ground": 0x0d1a12, "palette": [0x39ff14, 0xf9f871, 0x05d9e8], "flood": "first", "style": "swamp",      "density": 0.22},
	{"id": "sabal",    "name": "SABAL SPRINGS",  "cx": 250.0,  "cz": 360.0,  "w": 270.0, "d": 230.0, "ground": 0x1a1410, "palette": [0xff7b00, 0xf9f871, 0xff2a6d], "flood": "dry",   "style": "suburb",     "density": 0.34},
]

# Causeways linking the districts: ax,az -> bx,bz with a half-width.
const CAUSEWAYS := [
	{"ax": 20.0,  "az": -145.0, "bx": 30.0,   "bz": -300.0, "hw": 13.0},  # Downtown -> Cayo
	{"ax": 95.0,  "az": -30.0,  "bx": 215.0,  "bz": -25.0,  "hw": 11.0},  # Downtown -> Marisol Heights
	{"ax": -95.0, "az": 10.0,   "bx": -210.0, "bz": 15.0,   "hw": 11.0},  # Downtown -> The Reach
	{"ax": -15.0, "az": 80.0,   "bx": -120.0, "bz": 260.0,  "hw": 11.0},  # The Cut -> Bayou Verde
	{"ax": 70.0,  "az": 170.0,  "bx": 130.0,  "bz": 270.0,  "hw": 11.0},  # The Cut -> Sabal Springs
]

const TIDE_PERIOD := 120.0   # seconds for a full low->high->low tide cycle
const DAY_SECONDS := 240.0   # seconds for a full sun->moon->sun day/night cycle

# Half-width of the building-free road corridor carved along the waypoint tour,
# so the whole world stays drivable however the districts pack in. Generous so a
# heavy car drifting mid-corner still has clear tarmac instead of a wall.
const ROAD_HALF_WIDTH := 20.0

# ----------------------------------------------------------------- self-check tour
# A closed loop that visits all seven districts via the causeways. Used by the
# bot in selfcheck/bot mode. xz world coordinates.
var WP := PackedVector2Array([
	Vector2(-10, 150),                                   # start: The Cut
	Vector2(70, 170), Vector2(130, 270),                # Cut/Sabal causeway
	Vector2(250, 360),                                  # Sabal Springs
	Vector2(130, 270), Vector2(70, 170),               # back across
	Vector2(-15, 80), Vector2(-80, 170), Vector2(-120, 260),  # Cut/Bayou causeway
	Vector2(-250, 360),                                 # Bayou Verde
	Vector2(-120, 260), Vector2(-15, 80),              # back
	Vector2(-10, 150),                                  # through The Cut
	Vector2(0, -40),                                    # Downtown core
	Vector2(95, -30), Vector2(215, -25),               # Downtown/Heights causeway
	Vector2(300, -20),                                 # Marisol Heights
	Vector2(215, -25), Vector2(95, -30),              # back
	Vector2(0, -40),                                   # Downtown
	Vector2(20, -145), Vector2(30, -230),             # Downtown/Cayo causeway
	Vector2(30, -370),                                # Cayo Brava
	Vector2(30, -230), Vector2(20, -145),             # back
	Vector2(0, -40),                                  # Downtown
	Vector2(-95, 10), Vector2(-210, 15),             # Downtown/Reach causeway
	Vector2(-300, 20),                               # The Reach
	Vector2(-210, 15), Vector2(-95, 10),            # back
	Vector2(0, -40),                                 # Downtown
	Vector2(-10, 150),                              # home to The Cut
])

# ----------------------------------------------------------------- car tunables
const ENGINE_POWER := 2800.0
const BRAKE_POWER := 38.0
const MAX_STEER := 0.40
const STEER_SPEED := 4.0
const CAR_MASS := 1800.0
const WHEEL_FRICTION := 2.6
const CAR_LEN := 6.0
const CAR_W := 2.4
const CAR_H := 1.7

# ----------------------------------------------------------------- foot tunables
const WALK_SPEED := 5.5
const RUN_SPEED := 9.5
const GROUND_ACCEL := 45.0
const GRAVITY := 24.0
const TURN_SPEED := 10.0
const GUN_RANGE := 80.0

# ----------------------------------------------------------------- heat tunables
const HEAT_MAX := 5.0
const HEAT_DECAY := 0.25
const HEAT_CLEAN_DELAY := 6.0
const PURSUER_SPEED := 11.0
const PURSUER_CAP := 3
const HEAT_PER_SHOT := 0.5

# ----------------------------------------------------------------- runtime state
var mode := "play"
var selfcheck_seconds := 300.0
var headless := false   # true under --headless: skip render-only decoration

var car: VehicleBody3D
var player_body: CharacterBody3D
var cam: Camera3D
var bot

var in_car := true
var sim_time := 0.0
var steer_current := 0.0
var player_yaw := 0.0

# spawn reference (The Cut, facing default)
var spawn_pos := Vector3(-10, 1, 150)
var spawn_yaw := -PI / 2   # face world +X toward the Cut→Sabal causeway

# tide
var tide_time := 0.0
var tide_level := 0.0
var flood_entries: Array = []   # {mesh: MeshInstance3D, flood: String}

# sky / day-night
var env: Environment
var sun: DirectionalLight3D
var moon: DirectionalLight3D
var sky_mat: ProceduralSkyMaterial
var day_time := 0.0          # phase within DAY_SECONDS
var sun_elev := 1.0          # -1..1, 1 = noon
var streetlights: Array = [] # OmniLight3D nodes that auto-toggle at night
var mat_cache: Dictionary = {}   # color-int -> StandardMaterial3D (shared mats)

# owned-node sub-systems (builders/updaters that read/write main state via m.)
var geo_sys
var env_sys
var heat_sys
var traffic_sys
var player_sys
var weapons_sys
var hud_sys
var missions_sys

# heat / pursuers
var heat := 0.0
var heat_peak := 0.0
var heat_clean_timer := 0.0
var pursuers: Array = []
var pursuers_spawned := 0
var rng := RandomNumberGenerator.new()

# shooting
var shots_fired := 0

# weapons (dicts can't be const — use var)
var weapons := [
	{"name": "PISTOL",  "damage": 25, "range": 80.0,  "rof": 0.4,  "ammo": 12, "mag": 12, "reserve": 48, "heat": 0.5, "spread": 0.02, "pellets": 1, "auto": false},
	{"name": "SHOTGUN", "damage": 80, "range": 25.0,  "rof": 0.9,  "ammo": 6,  "mag": 6,  "reserve": 24, "heat": 0.8, "spread": 0.15, "pellets": 6, "auto": false},
	{"name": "SMG",     "damage": 15, "range": 60.0,  "rof": 0.08, "ammo": 30, "mag": 30, "reserve": 120,"heat": 0.3, "spread": 0.06, "pellets": 1, "auto": true},
	{"name": "RIFLE",   "damage": 60, "range": 200.0, "rof": 0.6,  "ammo": 8,  "mag": 8,  "reserve": 32, "heat": 0.6, "spread": 0.005,"pellets": 1, "auto": false},
]
var weapon_idx := 0
var fire_cooldown := 0.0
var ammo_crates: Array = []   # {node, timer:float, active:bool}

# traffic (civilian NPC cars)
var civilians: Array = []   # {car: VehicleBody3D, bot: WaypointBot}
var civ_palette := [0xff2a6d, 0xffffff, 0xf9f871, 0x05d9e8, 0xc0c0c0, 0x1a2a6b]

# pedestrian NPCs
var peds: Array = []   # {body, target:Vector2, speed:float, scatter:float, d:Dictionary}
var skin_tones := [0xf1c27d, 0xe0ac69, 0xc68642, 0x8d5524, 0xffdbac]

# missions (dicts/Vectors can't be const). target is world XZ (x, z).
var MISSIONS := [
	{"id": 0, "name": "FIRST CONTACT",   "zone": "downtown", "target": Vector2(20, -145),  "desc": "Drive to Cayo Brava. Fast.",            "reward": 500,  "type": "drive_to"},
	{"id": 1, "name": "CLEAN SWEEP",     "zone": "reach",    "target": Vector2(-300, 20),  "desc": "Eliminate the gang at The Reach.",      "reward": 800,  "type": "eliminate", "count": 3},
	{"id": 2, "name": "HOT WHEELS",      "zone": "cut",      "target": Vector2(-10, 150),  "desc": "Steal the car. Get it to Sabal Springs.","reward": 1200, "type": "deliver"},
	{"id": 3, "name": "HIGHLAND ESCAPE", "zone": "heights",  "target": Vector2(300, -20),  "desc": "Lose your Heat in Marisol Heights.",    "reward": 600,  "type": "lose_heat"},
	{"id": 4, "name": "BAYOU RUNNER",    "zone": "bayou",    "target": Vector2(-250, 360), "desc": "Reach Bayou Verde with Heat >= 3.",     "reward": 1500, "type": "drive_heat"},
]
var current_mission := -1
var money := 0
var mission_completed: Array = []

# player health / damage
var health := 100.0
var health_max := 100.0
var wasted := false
var wasted_timer := 0.0
var car_impacts := 0
var car_smoke_light: OmniLight3D
var prev_player_y := 0.0
var prev_cop_dists: Dictionary = {}   # cop -> last speed delta sample (impact detect)
var mission_target_sphere: MeshInstance3D
var mission_banner := ""
var mission_banner_timer := 0.0

# lead character (cosmetic only)
var leads := ["RAE", "THEO", "FRANKIE"]
var lead_idx := 0

# HUD
var hud_left: Label
var hud_right: Label
var hud_bottom: Label
# GTA-style HUD widgets
var hud_money: Label
var hud_char: Label
var hud_district: Label
var hud_mission: Label
var hud_weapon: Label
var hud_speed: Label
var hud_heat: Label
var hud_tide: Label
var hud_center: Label
var hud_health_bg: ColorRect
var hud_health_fill: ColorRect

# minimap
var minimap_vp: SubViewport
var minimap_cam: Camera3D
var minimap_dots: Dictionary = {}   # role -> Array[MeshInstance3D]
var mission_blips: Array = []        # {pos: Vector2, mesh: MeshInstance3D}

# telemetry / selfcheck
var distance := 0.0
var prev_pos := Vector2.ZERO
var top_speed := 0.0
var min_y := INF
var wps_hit := 0
var nan_seen := false
var _finishing := false

# ----------------------------------------------------------------- lifecycle
func _ready() -> void:
	mode = OS.get_environment("GAME_MODE")
	if mode == "":
		mode = "play"
	var sc := OS.get_environment("SC_SECONDS")
	if sc != "":
		selfcheck_seconds = float(sc)
	var ts := OS.get_environment("TIME_SCALE")
	if ts != "":
		var ts_val := float(ts)
		Engine.time_scale = ts_val
		# Scale physics ticks proportionally: keeps each simulated step at 1/60 s
		# so VehicleBody3D stays stable at any time_scale. 15× → 900 ticks/s.
		Engine.physics_ticks_per_second = int(60.0 * ts_val)
	rng.seed = 12345
	headless = DisplayServer.get_name() == "headless"

	geo_sys = preload("res://scripts/world_geo.gd").new(); add_child(geo_sys); geo_sys.setup(self)
	env_sys = preload("res://scripts/world_env.gd").new(); add_child(env_sys); env_sys.setup(self)
	heat_sys = preload("res://scripts/heat.gd").new(); add_child(heat_sys); heat_sys.setup(self)
	traffic_sys = preload("res://scripts/traffic.gd").new(); add_child(traffic_sys); traffic_sys.setup(self)
	player_sys = preload("res://scripts/player.gd").new(); add_child(player_sys); player_sys.setup(self)
	weapons_sys = preload("res://scripts/weapons.gd").new(); add_child(weapons_sys); weapons_sys.setup(self)
	hud_sys = preload("res://scripts/hud.gd").new(); add_child(hud_sys); hud_sys.setup(self)
	missions_sys = preload("res://scripts/missions.gd").new(); add_child(missions_sys); missions_sys.setup(self)

	player_sys.setup_input()
	env_sys._build_environment()
	geo_sys._build_sea()
	geo_sys._build_districts()
	geo_sys._build_causeways()
	player_sys.build_car()
	player_sys.build_player()
	player_sys.build_camera()
	hud_sys.build_hud()
	traffic_sys.build_traffic()
	traffic_sys.build_peds()
	hud_sys.build_minimap()
	weapons_sys.build_ammo_crates()
	geo_sys._build_atmosphere()
	geo_sys._build_parked_cars()

	bot = WaypointBot.new(WP)
	in_car = true
	prev_pos = _car_xz()

# ----------------------------------------------------------------- color helper
func _hex(h: int) -> Color:
	return Color(((h >> 16) & 0xff) / 255.0, ((h >> 8) & 0xff) / 255.0, (h & 0xff) / 255.0)

# Shared emissive/plain material cache keyed by color int + emission flag, to keep
# the material count down across the many procedural meshes we spawn.
func _mat(h: int, emit: bool = false, emit_energy: float = 1.0) -> StandardMaterial3D:
	var key := h * 10 + (1 if emit else 0)
	if mat_cache.has(key):
		return mat_cache[key]
	var m := StandardMaterial3D.new()
	var c := _hex(h)
	m.albedo_color = c
	if emit:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit_energy
	mat_cache[key] = m
	return m
func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var len2 := ab.length_squared()
	if len2 < 0.0001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / len2, 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _add_wheel(target: VehicleBody3D, pos: Vector3, traction: bool, steering: bool) -> void:
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
	target.add_child(w)

# minimap panel/overlay constants — accessible as m.MM_SIZE etc. by modules
const MM_SIZE := 200
const MM_ORTHO := 320.0
const MM_LAYER := 2

# ----------------------------------------------------------------- helpers
func _car_xz() -> Vector2:
	return Vector2(car.global_position.x, car.global_position.z)

func _car_forward_xz() -> Vector2:
	var f := -car.global_transform.basis.z   # VehicleBody3D drives in local -Z
	return Vector2(f.x, f.z).normalized()

func _car_speed() -> float:
	return car.linear_velocity.length()

func _player_xz() -> Vector2:
	return Vector2(player_body.global_position.x, player_body.global_position.z)

func _planar_speed_body() -> float:
	var v := player_body.velocity
	return Vector2(v.x, v.z).length()

func _active_pos() -> Vector3:
	return car.global_position if in_car else player_body.global_position

func _district_at(p: Vector2) -> String:
	for d in DISTRICTS:
		var hw: float = d["w"] * 0.5
		var hd: float = d["d"] * 0.5
		if absf(p.x - d["cx"]) <= hw and absf(p.y - d["cz"]) <= hd:
			return d["name"]
	return "THE CAUSEWAYS"

# ----------------------------------------------------------------- sim loop
func _physics_process(delta: float) -> void:
	sim_time += delta
	env_sys._update_tide(delta)
	env_sys._update_day_night(delta)
	if in_car:
		player_sys.car_physics(delta)
	else:
		player_sys.foot_physics(delta)
	player_sys.handle_enter_exit()
	heat_sys.update_heat(delta)
	heat_sys.update_pursuers(delta)
	traffic_sys.update_traffic(delta)
	traffic_sys.update_peds(delta)
	_update_telemetry(delta)
	if fire_cooldown > 0.0:
		fire_cooldown -= delta
	weapons_sys.update_ammo_crates(delta)
	missions_sys.update_missions(delta)
	player_sys.update_health(delta)
	if mode == "selfcheck":
		_selfcheck_tick(delta)
	if mode == "play":
		_handle_play_keys()

func _handle_play_keys() -> void:
	if Input.is_action_just_pressed("reset"):
		if in_car:
			player_sys.respawn_in_car()
		else:
			weapons_sys.reload()
	if Input.is_action_just_pressed("switch_lead"):
		lead_idx = (lead_idx + 1) % leads.size()
	if Input.is_action_just_pressed("weapon_prev"):
		weapons_sys.cycle_weapon(-1)
	if Input.is_action_just_pressed("weapon_next"):
		weapons_sys.cycle_weapon(1)
	if Input.is_action_just_pressed("mission"):
		missions_sys.accept_next_mission()
# ----------------------------------------------------------------- shooting helper (kept in main for cross-module access)
func _cur_weapon() -> Dictionary:
	return weapons[weapon_idx]

# ----------------------------------------------------------------- telemetry
func _update_telemetry(_delta: float) -> void:
	var p3 := _active_pos()
	if not (is_finite(p3.x) and is_finite(p3.y) and is_finite(p3.z)):
		nan_seen = true
		return
	var p := Vector2(p3.x, p3.z)
	distance += p.distance_to(prev_pos)
	prev_pos = p
	var spd := _car_speed() if in_car else _planar_speed_body()
	top_speed = maxf(top_speed, spd)
	min_y = minf(min_y, p3.y)

# ----------------------------------------------------------------- per-frame
func _process(_d: float) -> void:
	player_sys.update_camera()
	hud_sys.update_hud()
	heat_sys.update_police_lights()
	hud_sys.update_minimap()
	if car_smoke_light != null and is_instance_valid(car_smoke_light):
		car_smoke_light.light_energy = 2.0 + sin(sim_time * 20.0) * 1.5

# ----------------------------------------------------------------- selfcheck
func _selfcheck_tick(_delta: float) -> void:
	# wp_idx is the count of distinct waypoints already advanced past
	if bot != null:
		wps_hit = bot.wp_idx
	if sim_time >= selfcheck_seconds or wps_hit >= WP.size() - 1:
		_finish_selfcheck()

func _finish_selfcheck() -> void:
	if _finishing:
		return
	_finishing = true
	set_process(false)
	set_physics_process(false)

	var checks := []
	var p3 := car.global_position
	checks.append(_check("physics stable (no NaN)",
		not nan_seen and is_finite(p3.x) and is_finite(p3.y) and is_finite(p3.z)))
	checks.append(_check("car moved (>1000 m)", distance > 1000.0))
	checks.append(_check("reached a sane top speed (>60 km/h)", top_speed * 3.6 > 60.0))
	checks.append(_check("visited >=10 waypoints", wps_hit >= 10))
	checks.append(_check("never fell off the world (min_y > -5)", min_y > -5.0))

	var passed := true
	for c in checks:
		if not c["ok"]:
			passed = false

	var report := {
		"mode": "selfcheck",
		"sim_seconds": sim_time,
		"distance_m": distance,
		"top_speed_kmh": top_speed * 3.6,
		"waypoints_hit": wps_hit,
		"waypoints_total": WP.size(),
		"min_y": min_y,
		"heat_peak": heat_peak,
		"pursuers_spawned": pursuers_spawned,
		"frames_captured": VizCapture.idx,
		"checks": checks,
		"passed": passed,
	}
	var f := FileAccess.open("user://selfcheck.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()

	print("==== NEON DELTA — PORT SOLEIL SELFCHECK ====")
	for c in checks:
		print(("  PASS  " if c["ok"] else "  FAIL  "), c["name"])
	print("  sim=%.1fs  dist=%.0fm  top=%.0f km/h  wps=%d/%d  min_y=%.2f  frames=%d (report only)" % [
		sim_time, distance, top_speed * 3.6, wps_hit, WP.size(), min_y, VizCapture.idx])
	print("  report: ", ProjectSettings.globalize_path("user://selfcheck.json"))
	print("==== ", ("PASS" if passed else "FAIL"), " ====")
	get_tree().quit(0 if passed else 1)

func _check(name: String, ok: bool) -> Dictionary:
	return {"name": name, "ok": ok}

# ----------------------------------------------------------------- utils
func _lerp_angle(from: float, to: float, weight: float) -> float:
	return from + _wrap_pi(to - from) * clampf(weight, 0.0, 1.0)

func _wrap_pi(a: float) -> float:
	while a > PI:
		a -= TAU
	while a < -PI:
		a += TAU
	return a
