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

# heat / pursuers
var heat := 0.0
var heat_peak := 0.0
var heat_clean_timer := 0.0
var pursuers: Array = []
var pursuers_spawned := 0
var rng := RandomNumberGenerator.new()

# shooting
var shots_fired := 0

# lead character (cosmetic only)
var leads := ["RAE", "THEO", "FRANKIE"]
var lead_idx := 0

# HUD
var hud_left: Label
var hud_right: Label
var hud_bottom: Label

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
		Engine.time_scale = float(ts)
	rng.seed = 12345
	headless = DisplayServer.get_name() == "headless"

	_setup_input()
	_build_environment()
	_build_sea()
	_build_districts()
	_build_causeways()
	_build_car()
	_build_player()
	_build_camera()
	_build_hud()

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

# ----------------------------------------------------------------- world build
func _build_environment() -> void:
	var headless := DisplayServer.get_name() == "headless"
	var we := WorldEnvironment.new()
	var e := Environment.new()
	env = e

	# --- procedural sky (synthwave golden-hour-into-violet) ---
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = _hex(0x1a1140)
	sky_mat.sky_horizon_color = _hex(0xff7b00)
	sky_mat.ground_horizon_color = _hex(0xb967ff)
	sky_mat.ground_bottom_color = _hex(0x0d0d14)
	sky_mat.sky_energy_multiplier = 1.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	e.background_mode = Environment.BG_SKY
	e.sky = sky

	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_color = Color(0.30, 0.34, 0.46)
	e.ambient_light_energy = 0.65
	e.ambient_light_sky_contribution = 0.4

	e.fog_enabled = true
	e.fog_light_color = Color(0.20, 0.14, 0.28)
	e.fog_density = 0.0016

	# tone mapping
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	e.tonemap_exposure = 1.0

	# glow / bloom
	e.glow_enabled = true
	e.glow_intensity = 0.4
	e.glow_bloom = 0.1
	e.glow_strength = 1.0

	# SSAO (cheap-ish, render-only)
	if not headless:
		e.ssao_enabled = true
		e.ssao_radius = 2.0
		e.ssao_intensity = 1.5
		# SDFGI crashes headless; render-only and only on a compatible renderer
		e.sdfgi_enabled = true
		e.sdfgi_cascades = 4

	we.environment = e
	add_child(we)

	# --- sun ---
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -42, 0)
	sun.light_energy = 1.2
	sun.light_color = Color(1.0, 0.88, 0.70)
	if not headless:
		sun.shadow_enabled = true
	add_child(sun)

	# --- moon (dimmer, bluish, roughly opposite) ---
	moon = DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-122, -42, 0)
	moon.light_energy = 0.0
	moon.light_color = Color(0.55, 0.66, 1.0)
	add_child(moon)

	_build_streetlights()
	_update_day_night(0.0)

# Warm orange OmniLights at district corners and along causeways. They glow at
# night and switch off in daylight (driven by _update_day_night).
func _build_streetlights() -> void:
	if headless:
		return   # OmniLights + poles are render-only decoration
	# district corners
	for d in DISTRICTS:
		var hw: float = d["w"] * 0.5 - 12.0
		var hd: float = d["d"] * 0.5 - 12.0
		var cx: float = d["cx"]
		var cz: float = d["cz"]
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				_add_streetlight(Vector3(cx + sx * hw, 7.0, cz + sz * hd))
	# causeway edges (a couple per causeway)
	for c in CAUSEWAYS:
		var a := Vector2(c["ax"], c["az"])
		var b := Vector2(c["bx"], c["bz"])
		var hwc: float = c["hw"]
		var dir := (b - a).normalized()
		var perp := Vector2(-dir.y, dir.x)
		for t in [0.25, 0.75]:
			var m := a.lerp(b, t)
			_add_streetlight(Vector3(m.x + perp.x * hwc, 7.0, m.y + perp.y * hwc))
			_add_streetlight(Vector3(m.x - perp.x * hwc, 7.0, m.y - perp.y * hwc))

func _add_streetlight(pos: Vector3) -> void:
	# pole
	var pole := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.12
	pm.bottom_radius = 0.18
	pm.height = 7.0
	pole.mesh = pm
	pole.material_override = _mat(0x2a2a30)
	pole.position = pos - Vector3(0, 3.5, 0)
	add_child(pole)
	# lamp
	var light := OmniLight3D.new()
	light.light_color = _hex(0xf97316)
	light.light_energy = 4.0
	light.omni_range = 22.0
	light.position = pos
	light.visible = false
	add_child(light)
	streetlights.append(light)

# Advance the day/night cycle. In selfcheck we freeze at golden hour for a nice
# clip; otherwise the sun & moon sweep across DAY_SECONDS.
func _update_day_night(delta: float) -> void:
	if mode == "selfcheck":
		day_time = DAY_SECONDS * 0.12   # frozen golden hour (low warm sun)
	else:
		day_time = fmod(day_time + delta, DAY_SECONDS)
	var phase := day_time / DAY_SECONDS         # 0..1
	# sun elevation: sin curve, +1 noon, -1 midnight, phase 0 = dawn
	sun_elev = sin((phase - 0.25) * TAU)
	# rotate the sun: -90deg at dawn rising to overhead at noon
	var sun_pitch := -sun_elev * 80.0
	sun.rotation_degrees = Vector3(sun_pitch, -42.0, 0.0)
	moon.rotation_degrees = Vector3(sun_pitch + 180.0, -42.0, 0.0)

	var day := clampf(sun_elev, 0.0, 1.0)        # 0 night, 1 full day
	var night := 1.0 - day
	sun.light_energy = lerpf(0.0, 1.3, day)
	moon.light_energy = lerpf(0.0, 0.35, night)

	# warmer at low sun (golden hour), whiter at noon
	var golden := clampf(1.0 - absf(sun_elev - 0.2) * 2.5, 0.0, 1.0)
	sun.light_color = Color(1.0, 0.93, 0.78).lerp(Color(1.0, 0.62, 0.35), golden)

	# ambient + fog tie to elevation
	if env != null:
		env.ambient_light_energy = lerpf(0.18, 0.85, day)
		env.fog_density = lerpf(0.0042, 0.0012, day)
		env.fog_light_color = _hex(0x231030).lerp(_hex(0x4a3a30), day)
		if sky_mat != null:
			sky_mat.sky_energy_multiplier = lerpf(0.25, 1.1, day)
			sky_mat.sky_horizon_color = _hex(0xff2a6d).lerp(_hex(0xff9b3a), day)
			sky_mat.sky_top_color = _hex(0x0a0820).lerp(_hex(0x2a3aa0), day)

	# streetlights on at night
	var lights_on := sun_elev < 0.15
	for l in streetlights:
		l.visible = lights_on

func _build_sea() -> void:
	# a big dark plane under everything — the delta water the city floods into.
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(3000, 3000)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.06, 0.12)
	mat.metallic = 0.3
	mat.roughness = 0.4
	plane.material = mat
	mesh.mesh = plane
	mesh.position = Vector3(0, -1.5, 0)
	add_child(mesh)
	# A collidable seabed flush with the island tops (y = 0) so the whole delta is
	# one continuous drivable surface: districts are the dry land, the gaps between
	# them are shallow flooded flats you can still drive across (and the causeways
	# are the proper raised roads). This keeps the world traversable end-to-end and
	# stops a stray car from falling into a bottomless void.
	var bed := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3000, 2.0, 3000)
	col.shape = box
	col.position = Vector3(0, -1.0, 0)   # top at y = 0, flush with island ground
	bed.add_child(col)
	add_child(bed)

func _build_districts() -> void:
	for dd in DISTRICTS:
		_build_district(dd)

func _build_district(d: Dictionary) -> void:
	var cx: float = d["cx"]
	var cz: float = d["cz"]
	var w: float = d["w"]
	var dep: float = d["d"]
	var ground_col := _hex(d["ground"])
	var palette: Array = d["palette"]
	var style: String = d["style"]
	var density: float = d["density"]

	# --- ground slab (collidable, flat) ---
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(w, 2.0, dep)
	col.shape = box
	col.position = Vector3(0, -1.0, 0)
	body.add_child(col)
	var gmesh := MeshInstance3D.new()
	var gplane := PlaneMesh.new()
	gplane.size = Vector2(w, dep)
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = ground_col
	gplane.material = gmat
	gmesh.mesh = gplane
	body.add_child(gmesh)
	body.position = Vector3(cx, 0, cz)
	add_child(body)

	# --- road grid, centre lines, sidewalks ---
	_build_district_roads(cx, cz, w, dep)

	# --- flood overlay (translucent water plane, animated by the tide) ---
	var fmesh := MeshInstance3D.new()
	var fplane := PlaneMesh.new()
	fplane.size = Vector2(w, dep)
	var fmat := StandardMaterial3D.new()
	var fcol := Color(0.02, 0.15, 0.35)
	fcol.a = 0.6
	fmat.albedo_color = fcol
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.metallic = 0.2
	fmat.roughness = 0.3
	fplane.material = fmat
	fmesh.mesh = fplane
	fmesh.position = Vector3(cx, -2.0, cz)
	add_child(fmesh)
	flood_entries.append({"mesh": fmesh, "flood": d["flood"]})

	# --- buildings (deterministic via the seeded rng) ---
	var hw := w * 0.5
	var hd := dep * 0.5
	var area := w * dep
	var count := int(area / 2600.0 * density)
	var road_clear := 28.0   # cross of clear road through the district centre
	var placed := 0
	var attempts := 0
	while placed < count and attempts < count * 6 + 10:
		attempts += 1
		var lx := rng.randf_range(-hw + 8.0, hw - 8.0)
		var lz := rng.randf_range(-hd + 8.0, hd - 8.0)
		# clear a cross through the centre so the road grid stays drivable
		if absf(lx) < road_clear or absf(lz) < road_clear:
			continue
		var bw := rng.randf_range(5.0, 12.0)
		var bd := rng.randf_range(5.0, 12.0)
		# keep the whole waypoint tour drivable: never block a road corridor
		if _near_route(Vector2(cx + lx, cz + lz), maxf(bw, bd) * 0.5 + ROAD_HALF_WIDTH):
			continue
		placed += 1
		var bh := _building_height(style)
		var ccol := _hex(palette[rng.randi_range(0, palette.size() - 1)])
		_place_building(Vector3(cx + lx, 0, cz + lz), Vector3(bw, bh, bd), ground_col, ccol)

func _building_height(style: String) -> float:
	match style:
		"towers":     return rng.randf_range(15.0, 70.0)
		"mansion":    return rng.randf_range(8.0, 22.0)
		"industrial": return rng.randf_range(5.0, 30.0)
		"beach":      return rng.randf_range(2.0, 10.0)
		"swamp":      return rng.randf_range(2.0, 12.0)
		"suburb":     return rng.randf_range(4.0, 14.0)
		"rowhouse":   return rng.randf_range(5.0, 16.0)
		_:            return rng.randf_range(5.0, 15.0)

# True if point p (xz) is within `margin` metres of any leg of the waypoint
# tour — used to keep the road corridors clear of buildings.
func _near_route(p: Vector2, margin: float) -> bool:
	for i in range(WP.size() - 1):
		if _dist_to_segment(p, WP[i], WP[i + 1]) < margin:
			return true
	return false

func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var len2 := ab.length_squared()
	if len2 < 0.0001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / len2, 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _place_building(pos: Vector3, size: Vector3, base_col: Color, neon: Color) -> void:
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	col.position = Vector3(0, size.y * 0.5, 0)
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = base_col.lerp(Color(0.5, 0.55, 0.62), 0.35)
	mat.emission_enabled = true
	mat.emission = neon
	mat.emission_energy_multiplier = 0.18
	mesh.mesh = bm
	mesh.material_override = mat
	mesh.position = Vector3(0, size.y * 0.5, 0)
	body.add_child(mesh)
	body.position = pos
	add_child(body)

# Lay a simple 2-lane asphalt grid over a district with white dashed centre lines
# and raised concrete sidewalks along the road edges. All visual (no collision):
# the district ground slab underneath stays the drivable surface.
const ROAD_WIDTH := 12.0
const ROAD_SPACING := 80.0

func _build_district_roads(cx: float, cz: float, w: float, dep: float) -> void:
	if headless:
		return   # decorative-only; no collision, skip in headless CI
	var hw := w * 0.5
	var hd := dep * 0.5
	# vertical roads (run along z) at regular x intervals, including centre
	var nx := int(w / ROAD_SPACING)
	for i in range(-nx, nx + 1):
		var x := i * ROAD_SPACING
		if absf(x) > hw - ROAD_WIDTH:
			continue
		_road_strip(Vector3(cx + x, 0.01, cz), Vector3(ROAD_WIDTH, 0.02, dep))
		_dashed_line(Vector3(cx + x, 0.03, cz), dep, false)
		_sidewalk_pair(cx + x, cz, dep, true)
	# horizontal roads (run along x) at regular z intervals
	var nz := int(dep / ROAD_SPACING)
	for j in range(-nz, nz + 1):
		var z := j * ROAD_SPACING
		if absf(z) > hd - ROAD_WIDTH:
			continue
		_road_strip(Vector3(cx, 0.01, cz + z), Vector3(w, 0.02, ROAD_WIDTH))
		_dashed_line(Vector3(cx, 0.03, cz + z), w, true)
		_sidewalk_pair(cx, cz + z, w, false)

func _road_strip(pos: Vector3, size: Vector3) -> void:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.material_override = _mat(0x1a1a1a)
	m.position = pos
	add_child(m)

# Dashed white centre line. `along_x` true: dashes run along x; else along z.
func _dashed_line(pos: Vector3, length: float, along_x: bool) -> void:
	var step := 8.0
	var dash_len := 3.0
	var n := int(length / step)
	var start := -length * 0.5 + step * 0.5
	for k in range(n):
		var off := start + k * step
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		if along_x:
			bm.size = Vector3(dash_len, 0.02, 0.5)
			m.position = pos + Vector3(off, 0, 0)
		else:
			bm.size = Vector3(0.5, 0.02, dash_len)
			m.position = pos + Vector3(0, 0, off)
		m.mesh = bm
		m.material_override = _mat(0xf0f0f0, true, 0.4)
		add_child(m)

# Raised concrete sidewalks flanking a road. `vertical` true: road runs along z.
func _sidewalk_pair(rx: float, rz: float, length: float, vertical: bool) -> void:
	var edge := ROAD_WIDTH * 0.5 + 1.0
	for s in [-1.0, 1.0]:
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		if vertical:
			bm.size = Vector3(2.0, 0.1, length)
			m.position = Vector3(rx + s * edge, 0.05, rz)
		else:
			bm.size = Vector3(length, 0.1, 2.0)
			m.position = Vector3(rx, 0.05, rz + s * edge)
		m.mesh = bm
		m.material_override = _mat(0xb0a090)
		add_child(m)

func _build_causeways() -> void:
	for c in CAUSEWAYS:
		_build_causeway(c)

func _build_causeway(c: Dictionary) -> void:
	var a := Vector2(c["ax"], c["az"])
	var b := Vector2(c["bx"], c["bz"])
	var hw: float = c["hw"]
	var mid := (a + b) * 0.5
	var span := a.distance_to(b)
	var dir := (b - a).normalized()
	var yaw := atan2(dir.x, dir.y)

	# flat collidable deck — 2 m thick, top surface flush with district ground (y=0)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(hw * 2.0, 2.0, span)
	col.shape = box
	col.position = Vector3(0.0, -1.0, 0.0)  # top surface at y=0, matching districts
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = box.size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.15, 0.18)
	mesh.mesh = bm
	mesh.material_override = mat
	mesh.position = Vector3(0.0, -1.0, 0.0)  # mesh matches collision
	body.add_child(mesh)
	body.position = Vector3(mid.x, 0.0, mid.y)
	body.rotation.y = yaw
	add_child(body)

	# two glowing cyan rail strips along the edges (visual only)
	_causeway_rail(mid, yaw, span, hw)
	_causeway_rail(mid, yaw, span, -hw)

	# dashed yellow centre line + cyan guardrail posts (decorative)
	if not headless:
		_causeway_centre_line(a, b, span)
		_causeway_guardrails(a, b, span, hw)

func _causeway_centre_line(a: Vector2, b: Vector2, span: float) -> void:
	var dir := (b - a).normalized()
	var step := 8.0
	var n := int(span / step)
	for k in range(n):
		var t := (k * step + step * 0.5) / span
		var p := a.lerp(b, t)
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.4, 0.02, 3.0)
		m.mesh = bm
		m.material_override = _mat(0xf9f871, true, 0.6)
		m.position = Vector3(p.x, 0.04, p.y)
		m.rotation.y = atan2(dir.x, dir.y)
		add_child(m)

func _causeway_guardrails(a: Vector2, b: Vector2, span: float, hw: float) -> void:
	var dir := (b - a).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var step := 15.0
	var n := int(span / step)
	for k in range(n + 1):
		var t := clampf((k * step) / span, 0.0, 1.0)
		var p := a.lerp(b, t)
		for s in [-1.0, 1.0]:
			var post := MeshInstance3D.new()
			var cm := CapsuleMesh.new()
			cm.radius = 0.12
			cm.height = 1.2
			post.mesh = cm
			post.material_override = _mat(0x05d9e8, true, 1.4)
			var q: Vector2 = p + perp * (hw * s)
			post.position = Vector3(q.x, 0.6, q.y)
			add_child(post)

func _causeway_rail(mid: Vector2, yaw: float, span: float, offset: float) -> void:
	var rail := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.4, 0.8, span)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.85, 0.91)
	mat.emission_enabled = true
	mat.emission = Color(0.02, 0.85, 0.91)
	mat.emission_energy_multiplier = 1.6
	rail.mesh = bm
	rail.material_override = mat
	# offset perpendicular to the causeway direction
	var perp := Vector2(cos(yaw), -sin(yaw))
	rail.position = Vector3(mid.x + perp.x * offset, 0.5, mid.y + perp.y * offset)
	rail.rotation.y = yaw
	add_child(rail)

func _build_car() -> void:
	car = VehicleBody3D.new()
	car.mass = CAR_MASS
	# pin the centre of mass low so the heavy cruiser doesn't roll onto its side
	# under a hard low-speed steer (it sits well below the body, near the axles).
	car.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	car.center_of_mass = Vector3(0, -0.6, 0)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CAR_W, CAR_H, CAR_LEN)
	col.shape = box
	col.position.y = CAR_H * 0.5
	car.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CAR_W, CAR_H - 0.1, CAR_LEN)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.85, 0.95)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.4, 0.5)
	mat.emission_energy_multiplier = 0.4
	mesh.material_override = mat
	mesh.position.y = CAR_H * 0.5
	car.add_child(mesh)
	# nose marker so heading reads in screenshots
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.6, 0.4, 0.8)
	var nm := StandardMaterial3D.new()
	nm.albedo_color = Color(1, 1, 0.3)
	nose.material_override = nm
	nose.mesh = nb
	nose.position = Vector3(0, CAR_H * 0.5 + 0.5, -(CAR_LEN * 0.5 - 0.4))
	car.add_child(nose)
	var wx := CAR_W * 0.5 - 0.15
	var wz := CAR_LEN * 0.5 - 1.0
	_add_wheel(car, Vector3(-wx, 0.0, -wz), true, true)
	_add_wheel(car, Vector3(wx, 0.0, -wz), true, true)
	_add_wheel(car, Vector3(-wx, 0.0, wz), true, false)
	_add_wheel(car, Vector3(wx, 0.0, wz), true, false)
	car.position = spawn_pos
	car.rotation.y = spawn_yaw
	add_child(car)

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

func _build_player() -> void:
	player_body = CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	player_body.add_child(col)
	var mesh := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.4
	cm.height = 1.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.16, 0.43)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.16, 0.43)
	mat.emission_energy_multiplier = 0.5
	mesh.mesh = cm
	mesh.material_override = mat
	mesh.position.y = 0.9
	player_body.add_child(mesh)
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.2, 0.2, 0.5)
	nose.mesh = nb
	nose.position = Vector3(0, 1.2, 0.45)
	player_body.add_child(nose)
	player_body.position = spawn_pos
	player_body.visible = false
	player_body.set_physics_process(false)
	add_child(player_body)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.fov = 65
	cam.position = spawn_pos + Vector3(0, 8, 14)
	add_child(cam)  # child of root, NOT the car
	cam.look_at(spawn_pos, Vector3.UP)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud_left = Label.new()
	hud_left.position = Vector2(20, 16)
	hud_left.add_theme_font_size_override("font_size", 26)
	layer.add_child(hud_left)
	hud_right = Label.new()
	hud_right.position = Vector2(540, 16)
	hud_right.add_theme_font_size_override("font_size", 22)
	hud_right.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
	layer.add_child(hud_right)
	hud_bottom = Label.new()
	hud_bottom.position = Vector2(20, 410)
	hud_bottom.add_theme_font_size_override("font_size", 22)
	hud_bottom.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	layer.add_child(hud_bottom)

# ----------------------------------------------------------------- input
func _setup_input() -> void:
	_action("accel", [KEY_W, KEY_UP])
	_action("brake", [KEY_S, KEY_DOWN])
	_action("steer_left", [KEY_A, KEY_LEFT])
	_action("steer_right", [KEY_D, KEY_RIGHT])
	_action("run", [KEY_SHIFT])
	_action("reset", [KEY_R])
	_action("enter_exit", [KEY_E])
	_action("shoot", [KEY_F])
	_action("switch_lead", [KEY_TAB])

func _action(name: String, keys: Array) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(name, ev)

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
	_update_tide(delta)
	_update_day_night(delta)
	if in_car:
		_car_physics(delta)
	else:
		_foot_physics(delta)
	_handle_enter_exit()
	_update_heat(delta)
	_update_pursuers(delta)
	_update_telemetry(delta)
	if mode == "selfcheck":
		_selfcheck_tick(delta)
	if mode == "play" and Input.is_action_just_pressed("reset"):
		_respawn_in_car()
	if mode == "play" and Input.is_action_just_pressed("switch_lead"):
		lead_idx = (lead_idx + 1) % leads.size()

# ----------------------------------------------------------------- tide
func _update_tide(delta: float) -> void:
	tide_time += delta
	tide_level = 0.5 - 0.5 * cos(TAU * tide_time / TIDE_PERIOD)
	for entry in flood_entries:
		var fl: String = entry["flood"]
		var mesh: MeshInstance3D = entry["mesh"]
		var y := -2.0
		if fl == "first":
			y = lerpf(-2.0, 1.5, tide_level)
		elif fl == "mid":
			y = lerpf(-2.0, 1.5, maxf(0.0, (tide_level - 0.4) / 0.6))
		# 'dry' stays at -2 (submerged out of sight)
		var pos := mesh.position
		pos.y = y
		mesh.position = pos

func _tide_phase() -> String:
	var rising := sin(TAU * tide_time / TIDE_PERIOD) > 0.0
	if tide_level < 0.15:
		return "LOW"
	if tide_level > 0.85:
		return "HIGH"
	return "RISING" if rising else "FALLING"

# ----------------------------------------------------------------- car physics
func _car_physics(delta: float) -> void:
	var c: Dictionary
	if mode == "play":
		c = _player_drive_controls()
	else:
		c = bot.control(_car_xz(), _car_forward_xz(), _car_speed())
		bot.advance_if_close(_car_xz())
	var target_steer: float = -c["steer"] * MAX_STEER   # Godot positive steering = right; bot positive = left
	steer_current = move_toward(steer_current, target_steer, STEER_SPEED * MAX_STEER * delta)
	car.steering = steer_current
	car.engine_force = c["throttle"] * ENGINE_POWER
	car.brake = c["brake"] * BRAKE_POWER

func _player_drive_controls() -> Dictionary:
	var throttle := Input.get_action_strength("accel")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	return {"throttle": throttle, "brake": brake, "steer": steer}

# ----------------------------------------------------------------- foot physics
func _foot_physics(delta: float) -> void:
	var c := _player_foot_controls()
	var wish: Vector2 = c["move"]
	# move camera-relative: project onto the camera's flattened forward/right
	var fwd := -Vector3(cam.global_transform.basis.z.x, 0, cam.global_transform.basis.z.z)
	if fwd.length() > 0.001:
		fwd = fwd.normalized()
	else:
		fwd = Vector3(0, 0, -1)
	var right := Vector3(fwd.z, 0, -fwd.x)
	var move_dir := right * wish.x + fwd * (-wish.y)
	var speed: float = RUN_SPEED if c["run"] else WALK_SPEED
	var target := move_dir * speed
	var v := player_body.velocity
	v.x = move_toward(v.x, target.x, GROUND_ACCEL * delta)
	v.z = move_toward(v.z, target.z, GROUND_ACCEL * delta)
	if not player_body.is_on_floor():
		v.y -= GRAVITY * delta
	else:
		v.y = maxf(v.y, -0.1)
	player_body.velocity = v
	player_body.move_and_slide()
	if Vector2(v.x, v.z).length() > 0.5:
		var want := atan2(v.x, v.z)
		player_yaw = _lerp_angle(player_yaw, want, TURN_SPEED * delta)
		player_body.rotation.y = player_yaw
	if c["fire"]:
		_shoot()

func _player_foot_controls() -> Dictionary:
	if mode != "play":
		# the bot never goes on foot; stay idle
		return {"move": Vector2.ZERO, "run": false, "fire": false}
	var mv := Vector2.ZERO
	mv.y -= Input.get_action_strength("accel")
	mv.y += Input.get_action_strength("brake")
	mv.x -= Input.get_action_strength("steer_left")
	mv.x += Input.get_action_strength("steer_right")
	if mv.length() > 1.0:
		mv = mv.normalized()
	return {"move": mv, "run": Input.is_action_pressed("run"),
			"fire": Input.is_action_just_pressed("shoot")}

# ----------------------------------------------------------------- enter / exit
func _handle_enter_exit() -> void:
	if mode != "play":
		return
	if not Input.is_action_just_pressed("enter_exit"):
		return
	if in_car:
		# step out next to the car
		var side := car.global_transform.basis.x.normalized()
		var out := car.global_position + side * 2.5
		out.y = 1.0
		player_body.global_position = out
		player_body.velocity = Vector3.ZERO
		player_body.visible = true
		player_body.set_physics_process(true)
		player_yaw = car.rotation.y
		player_body.rotation.y = player_yaw
		in_car = false
	else:
		# enter if close enough
		if _player_xz().distance_to(_car_xz()) < 8.0:
			player_body.visible = false
			player_body.set_physics_process(false)
			in_car = true

func _respawn_in_car() -> void:
	in_car = true
	player_body.visible = false
	player_body.set_physics_process(false)
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.position = spawn_pos
	car.rotation = Vector3(0, spawn_yaw, 0)
	steer_current = 0.0

# ----------------------------------------------------------------- shooting
func _shoot() -> void:
	shots_fired += 1
	var origin := cam.global_position
	var aim := -cam.global_transform.basis.z
	var from := origin + aim * 1.0
	var to := from + aim * GUN_RANGE
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.exclude = [player_body.get_rid()]
	var hit := space.intersect_ray(q)
	var hit_point: Vector3 = to
	if hit.has("position"):
		hit_point = hit["position"]
	heat = minf(HEAT_MAX, heat + HEAT_PER_SHOT)
	heat_peak = maxf(heat_peak, heat)
	heat_clean_timer = 0.0
	_spawn_tracer(from, hit_point)

func _spawn_tracer(from: Vector3, to: Vector3) -> void:
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

# ----------------------------------------------------------------- heat
func _update_heat(delta: float) -> void:
	heat_clean_timer += delta
	if heat_clean_timer > HEAT_CLEAN_DELAY and heat > 0.0:
		heat = maxf(0.0, heat - HEAT_DECAY * delta)
	var want: int = mini(PURSUER_CAP, int(floor(heat)))
	while pursuers.size() < want:
		_spawn_pursuer()
	# despawn all pursuers once we're clean
	if heat <= 0.0 and not pursuers.is_empty():
		for cop in pursuers:
			cop.queue_free()
		pursuers.clear()

func _spawn_pursuer() -> void:
	var cop := VehicleBody3D.new()
	cop.mass = 1400.0
	cop.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	cop.center_of_mass = Vector3(0, -0.6, 0)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CAR_W, CAR_H, CAR_LEN)
	col.shape = box
	col.position.y = CAR_H * 0.5
	cop.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CAR_W, CAR_H - 0.1, CAR_LEN)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.85, 0.91)   # cyan = the law
	mat.emission_enabled = true
	mat.emission = Color(0.05, 0.85, 0.91)
	mat.emission_energy_multiplier = 0.6
	mesh.material_override = mat
	mesh.position.y = CAR_H * 0.5
	cop.add_child(mesh)
	var wx := CAR_W * 0.5 - 0.15
	var wz := CAR_LEN * 0.5 - 1.0
	_add_wheel(cop, Vector3(-wx, 0.0, -wz), true, true)
	_add_wheel(cop, Vector3(wx, 0.0, -wz), true, true)
	_add_wheel(cop, Vector3(-wx, 0.0, wz), true, false)
	_add_wheel(cop, Vector3(wx, 0.0, wz), true, false)
	# spawn at a random district edge
	var d: Dictionary = DISTRICTS[rng.randi_range(0, DISTRICTS.size() - 1)]
	cop.position = Vector3(d["cx"] + d["w"] * 0.5, 1.5, d["cz"])
	add_child(cop)
	pursuers.append(cop)
	pursuers_spawned += 1

func _update_pursuers(_delta: float) -> void:
	var tgt := _active_pos()
	for cop: VehicleBody3D in pursuers:
		var to := Vector2(tgt.x - cop.global_position.x, tgt.z - cop.global_position.z)
		var dist := to.length()
		var fwd := -cop.global_transform.basis.z   # VehicleBody3D drives in local -Z
		var fwd2 := Vector2(fwd.x, fwd.z).normalized()
		var steer := 0.0
		if dist > 0.001 and fwd2.length() > 0.001:
			var d := to.normalized()
			var cross := fwd2.x * d.y - fwd2.y * d.x
			var dot := fwd2.dot(d)
			steer = clampf(atan2(cross, dot) * 2.0, -1.0, 1.0)
		cop.steering = -steer * MAX_STEER   # Godot positive = right; bot positive = left
		var spd := cop.linear_velocity.length()
		if dist > 6.0 and spd < PURSUER_SPEED:
			cop.engine_force = ENGINE_POWER
			cop.brake = 0.0
		else:
			cop.engine_force = 0.0
			cop.brake = BRAKE_POWER * 0.5

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
	_update_camera()
	_update_hud()

func _update_camera() -> void:
	if cam == null or not cam.is_inside_tree():
		return
	if in_car:
		var back := -car.global_transform.basis.z
		var target := car.global_position + back * 12.0 + Vector3.UP * 6.0
		cam.global_position = cam.global_position.lerp(target, 0.10)
		cam.look_at(car.global_position + Vector3.UP * 1.0, Vector3.UP)
	else:
		var p := player_body.global_position
		var back := Vector3(-sin(player_yaw), 0, -cos(player_yaw))
		var target := p + back * 8.0 + Vector3.UP * 5.0
		cam.global_position = cam.global_position.lerp(target, 0.12)
		cam.look_at(p + Vector3.UP * 1.0, Vector3.UP)

func _update_hud() -> void:
	if hud_left == null:
		return
	var spd := _car_speed() if in_car else _planar_speed_body()
	var kmh := int(round(spd * 3.6))
	var mode_str := "DRIVING" if in_car else "ON FOOT"
	var pos := _car_xz() if in_car else _player_xz()
	hud_left.text = "%d km/h\n%s\n%s" % [kmh, mode_str, _district_at(pos)]
	var stars := ""
	for i in range(5):
		stars += "*" if i < int(round(heat)) else "."
	hud_right.text = "HEAT [%s]\nTIDE: %s" % [stars, _tide_phase()]
	hud_bottom.text = "LEAD: %s   (Tab to cycle)" % leads[lead_idx]

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
