extends Node

# Environment / lighting / tide builder + updater.
# Owned-node sub-script: references main-owned state/helpers via `m.`.

var m  # reference to the main scene (set in setup)

func setup(main) -> void:
	m = main

# ----------------------------------------------------------------- world build
func _build_environment() -> void:
	var headless := DisplayServer.get_name() == "headless"
	var we := WorldEnvironment.new()
	var e := Environment.new()
	m.env = e

	# --- procedural sky (realistic golden-hour blue sky; CLAUDE.md: not synthwave) ---
	m.sky_mat = ProceduralSkyMaterial.new()
	m.sky_mat.sky_top_color = m._hex(0x3a6ea5)        # daytime blue
	m.sky_mat.sky_horizon_color = m._hex(0xe8b074)    # warm golden horizon
	m.sky_mat.ground_horizon_color = m._hex(0xc99a6a)
	m.sky_mat.ground_bottom_color = m._hex(0x2a2620)
	m.sky_mat.sky_energy_multiplier = 1.0
	var sky := Sky.new()
	sky.sky_material = m.sky_mat
	e.background_mode = Environment.BG_SKY
	e.sky = sky

	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_color = Color(0.40, 0.42, 0.48)
	e.ambient_light_energy = 0.65
	e.ambient_light_sky_contribution = 0.5

	e.fog_enabled = true
	e.fog_light_color = Color(0.18, 0.16, 0.13)   # warm dark fog, not violet
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
	m.add_child(we)

	# --- sun ---
	m.sun = DirectionalLight3D.new()
	m.sun.rotation_degrees = Vector3(-58, -42, 0)
	m.sun.light_energy = 1.2
	m.sun.light_color = Color(1.0, 0.88, 0.70)
	if not headless:
		m.sun.shadow_enabled = true
	m.add_child(m.sun)

	# --- moon (dimmer, bluish, roughly opposite) ---
	m.moon = DirectionalLight3D.new()
	m.moon.rotation_degrees = Vector3(-122, -42, 0)
	m.moon.light_energy = 0.0
	m.moon.light_color = Color(0.55, 0.66, 1.0)
	m.add_child(m.moon)

	_build_streetlights()
	_update_day_night(0.0)

# Warm orange OmniLights at district corners and along causeways. They glow at
# night and switch off in daylight (driven by _update_day_night).
func _build_streetlights() -> void:
	if m.headless:
		return   # OmniLights + poles are render-only decoration
	# district corners
	for d in m.DISTRICTS:
		var hw: float = d["w"] * 0.5 - 12.0
		var hd: float = d["d"] * 0.5 - 12.0
		var cx: float = d["cx"]
		var cz: float = d["cz"]
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				_add_streetlight(Vector3(cx + sx * hw, 7.0, cz + sz * hd))
	# causeway edges (a couple per causeway)
	for c in m.CAUSEWAYS:
		var a := Vector2(c["ax"], c["az"])
		var b := Vector2(c["bx"], c["bz"])
		var hwc: float = c["hw"]
		var dir := (b - a).normalized()
		var perp := Vector2(-dir.y, dir.x)
		for t in [0.25, 0.75]:
			var mp := a.lerp(b, t)
			_add_streetlight(Vector3(mp.x + perp.x * hwc, 7.0, mp.y + perp.y * hwc))
			_add_streetlight(Vector3(mp.x - perp.x * hwc, 7.0, mp.y - perp.y * hwc))

func _add_streetlight(pos: Vector3) -> void:
	# pole
	var pole := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.12
	pm.bottom_radius = 0.18
	pm.height = 7.0
	pole.mesh = pm
	pole.material_override = m._mat(0x2a2a30)
	pole.position = pos - Vector3(0, 3.5, 0)
	m.add_child(pole)
	# lamp
	var light := OmniLight3D.new()
	light.light_color = m._hex(0xf97316)
	light.light_energy = 4.0
	light.omni_range = 22.0
	light.position = pos
	light.visible = false
	m.add_child(light)
	m.streetlights.append(light)

# Advance the day/night cycle. In selfcheck we freeze at golden hour for a nice
# clip; otherwise the sun & moon sweep across DAY_SECONDS.
func _update_day_night(delta: float) -> void:
	if m.mode == "selfcheck":
		m.day_time = m.DAY_SECONDS * 0.29   # frozen golden hour (low warm sun, elev ~+0.25)
	else:
		if m.day_time == 0.0:
			m.day_time = m.DAY_SECONDS * 0.70   # start at warm late-afternoon (CLAUDE.md tod 0.70)
		m.day_time = fmod(m.day_time + delta, m.DAY_SECONDS)
	var phase: float = m.day_time / m.DAY_SECONDS         # 0..1
	# sun elevation: sin curve, +1 noon, -1 midnight, phase 0 = dawn
	m.sun_elev = sin((phase - 0.25) * TAU)
	# rotate the sun: -90deg at dawn rising to overhead at noon
	var sun_pitch: float = -m.sun_elev * 80.0
	m.sun.rotation_degrees = Vector3(sun_pitch, -42.0, 0.0)
	m.moon.rotation_degrees = Vector3(sun_pitch + 180.0, -42.0, 0.0)

	var day := clampf(m.sun_elev, 0.0, 1.0)        # 0 night, 1 full day
	var night := 1.0 - day
	m.sun.light_energy = lerpf(0.0, 1.3, day)
	m.moon.light_energy = lerpf(0.0, 0.35, night)

	# warmer at low sun (golden hour), whiter at noon
	var golden := clampf(1.0 - absf(m.sun_elev - 0.2) * 2.5, 0.0, 1.0)
	m.sun.light_color = Color(1.0, 0.93, 0.78).lerp(Color(1.0, 0.62, 0.35), golden)

	# ambient + fog tie to elevation (realistic warm dark night -> bright day)
	if m.env != null:
		m.env.ambient_light_energy = lerpf(0.18, 0.85, day)
		m.env.fog_density = lerpf(0.0042, 0.0012, day)
		m.env.fog_light_color = m._hex(0x12100c).lerp(m._hex(0x6a5c48), day)   # warm dark
		if m.sky_mat != null:
			m.sky_mat.sky_energy_multiplier = lerpf(0.20, 1.1, day)
			m.sky_mat.sky_horizon_color = m._hex(0x4a3a40).lerp(m._hex(0xe8b074), day)  # night gray -> golden
			m.sky_mat.sky_top_color = m._hex(0x0a0e18).lerp(m._hex(0x3a6ea5), day)      # deep night -> blue

	# streetlights on at night
	var lights_on: bool = m.sun_elev < 0.15
	for l in m.streetlights:
		l.visible = lights_on

# ----------------------------------------------------------------- tide
func _update_tide(delta: float) -> void:
	m.tide_time += delta
	m.tide_level = 0.5 - 0.5 * cos(TAU * m.tide_time / m.TIDE_PERIOD)
	for entry in m.flood_entries:
		var fl: String = entry["flood"]
		var mesh: MeshInstance3D = entry["mesh"]
		var y := -2.0
		if fl == "first":
			y = lerpf(-2.0, 1.5, m.tide_level)
		elif fl == "mid":
			y = lerpf(-2.0, 1.5, maxf(0.0, (m.tide_level - 0.4) / 0.6))
		# 'dry' stays at -2 (submerged out of sight)
		var pos := mesh.position
		pos.y = y
		mesh.position = pos

func _tide_phase() -> String:
	var rising := sin(TAU * m.tide_time / m.TIDE_PERIOD) > 0.0
	if m.tide_level < 0.15:
		return "LOW"
	if m.tide_level > 0.85:
		return "HIGH"
	return "RISING" if rising else "FALLING"
