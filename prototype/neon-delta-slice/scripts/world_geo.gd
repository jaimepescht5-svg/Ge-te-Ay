extends Node

# World geometry builder: districts, roads, buildings, causeways, sea, atmosphere.
# Owned-node sub-script: references main-owned state/helpers via `m.`.

var m  # reference to the main scene (set in setup)

const ROAD_WIDTH := 12.0
const ROAD_SPACING := 80.0

func setup(main) -> void:
	m = main

# ----------------------------------------------------------------- sea
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
	m.add_child(mesh)
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
	m.add_child(bed)

# ----------------------------------------------------------------- districts
func _build_districts() -> void:
	for dd in m.DISTRICTS:
		_build_district(dd)

func _build_district(d: Dictionary) -> void:
	var cx: float = d["cx"]
	var cz: float = d["cz"]
	var w: float = d["w"]
	var dep: float = d["d"]
	var ground_col: Color = m._hex(d["ground"])
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
	m.add_child(body)

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
	m.add_child(fmesh)
	m.flood_entries.append({"mesh": fmesh, "flood": d["flood"]})

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
		var lx: float = m.rng.randf_range(-hw + 8.0, hw - 8.0)
		var lz: float = m.rng.randf_range(-hd + 8.0, hd - 8.0)
		# clear a cross through the centre so the road grid stays drivable
		if absf(lx) < road_clear or absf(lz) < road_clear:
			continue
		var bw: float = m.rng.randf_range(5.0, 12.0)
		var bd: float = m.rng.randf_range(5.0, 12.0)
		# keep the whole waypoint tour drivable: never block a road corridor
		if _near_route(Vector2(cx + lx, cz + lz), maxf(bw, bd) * 0.5 + m.ROAD_HALF_WIDTH):
			continue
		placed += 1
		var bh := _building_height(style)
		var ccol: Color = m._hex(palette[m.rng.randi_range(0, palette.size() - 1)])
		_place_building(Vector3(cx + lx, 0, cz + lz), Vector3(bw, bh, bd), ground_col, ccol)

func _building_height(style: String) -> float:
	match style:
		"towers":     return m.rng.randf_range(15.0, 70.0)
		"mansion":    return m.rng.randf_range(8.0, 22.0)
		"industrial": return m.rng.randf_range(5.0, 30.0)
		"beach":      return m.rng.randf_range(2.0, 10.0)
		"swamp":      return m.rng.randf_range(2.0, 12.0)
		"suburb":     return m.rng.randf_range(4.0, 14.0)
		"rowhouse":   return m.rng.randf_range(5.0, 16.0)
		_:            return m.rng.randf_range(5.0, 15.0)

# True if point p (xz) is within `margin` metres of any leg of the waypoint
# tour — used to keep the road corridors clear of buildings.
func _near_route(p: Vector2, margin: float) -> bool:
	for i in range(m.WP.size() - 1):
		if m._dist_to_segment(p, m.WP[i], m.WP[i + 1]) < margin:
			return true
	return false

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
	m.add_child(body)

# Lay a simple 2-lane asphalt grid over a district with white dashed centre lines
# and raised concrete sidewalks along the road edges. All visual (no collision):
# the district ground slab underneath stays the drivable surface.
func _build_district_roads(cx: float, cz: float, w: float, dep: float) -> void:
	if m.headless:
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
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = m._mat(0x1a1a1a)
	mi.position = pos
	m.add_child(mi)

# Dashed white centre line. `along_x` true: dashes run along x; else along z.
func _dashed_line(pos: Vector3, length: float, along_x: bool) -> void:
	var step := 8.0
	var dash_len := 3.0
	var n := int(length / step)
	var start := -length * 0.5 + step * 0.5
	for k in range(n):
		var off := start + k * step
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		if along_x:
			bm.size = Vector3(dash_len, 0.02, 0.5)
			mi.position = pos + Vector3(off, 0, 0)
		else:
			bm.size = Vector3(0.5, 0.02, dash_len)
			mi.position = pos + Vector3(0, 0, off)
		mi.mesh = bm
		mi.material_override = m._mat(0xf0f0f0, true, 0.4)
		m.add_child(mi)

# Raised concrete sidewalks flanking a road. `vertical` true: road runs along z.
func _sidewalk_pair(rx: float, rz: float, length: float, vertical: bool) -> void:
	var edge := ROAD_WIDTH * 0.5 + 1.0
	for s in [-1.0, 1.0]:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		if vertical:
			bm.size = Vector3(2.0, 0.1, length)
			mi.position = Vector3(rx + s * edge, 0.05, rz)
		else:
			bm.size = Vector3(length, 0.1, 2.0)
			mi.position = Vector3(rx, 0.05, rz + s * edge)
		mi.mesh = bm
		mi.material_override = m._mat(0xb0a090)
		m.add_child(mi)

# ----------------------------------------------------------------- causeways
func _build_causeways() -> void:
	for c in m.CAUSEWAYS:
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
	m.add_child(body)

	# two glowing cyan rail strips along the edges (visual only)
	_causeway_rail(mid, yaw, span, hw)
	_causeway_rail(mid, yaw, span, -hw)

	# dashed yellow centre line + cyan guardrail posts (decorative)
	if not m.headless:
		_causeway_centre_line(a, b, span)
		_causeway_guardrails(a, b, span, hw)

func _causeway_centre_line(a: Vector2, b: Vector2, span: float) -> void:
	var dir := (b - a).normalized()
	var step := 8.0
	var n := int(span / step)
	for k in range(n):
		var t := (k * step + step * 0.5) / span
		var p := a.lerp(b, t)
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.4, 0.02, 3.0)
		mi.mesh = bm
		mi.material_override = m._mat(0xf9f871, true, 0.6)
		mi.position = Vector3(p.x, 0.04, p.y)
		mi.rotation.y = atan2(dir.x, dir.y)
		m.add_child(mi)

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
			post.material_override = m._mat(0x05d9e8, true, 1.4)
			var q: Vector2 = p + perp * (hw * s)
			post.position = Vector3(q.x, 0.6, q.y)
			m.add_child(post)

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
	m.add_child(rail)

# ----------------------------------------------------------------- atmosphere
# Neon signs over downtown, a lighthouse beacon in Cayo Brava, cypress silhouettes
# in Bayou Verde. Pure decoration — render-only, skipped in headless CI.
func _build_atmosphere() -> void:
	if m.headless:
		return
	# downtown neon signs: glowing emissive panels + a matching point light
	var neon_cols := [0xff2a6d, 0x05d9e8, 0xb967ff, 0xf9f871, 0xff7b00]
	for i in range(8):
		var x: float = m.rng.randf_range(-90.0, 90.0)
		var z: float = -40.0 + m.rng.randf_range(-90.0, 90.0)
		var c: int = neon_cols[i % neon_cols.size()]
		var sign := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(m.rng.randf_range(3.0, 7.0), m.rng.randf_range(2.0, 5.0), 0.3)
		sign.mesh = bm
		var mat := StandardMaterial3D.new()
		mat.albedo_color = m._hex(c)
		mat.emission_enabled = true
		mat.emission = m._hex(c)
		mat.emission_energy_multiplier = 3.0
		sign.material_override = mat
		sign.position = Vector3(x, m.rng.randf_range(12.0, 28.0), z)
		sign.rotation.y = m.rng.randf_range(0.0, TAU)
		m.add_child(sign)
		var glow := OmniLight3D.new()
		glow.light_color = m._hex(c)
		glow.light_energy = 2.5
		glow.omni_range = 16.0
		glow.position = sign.position
		m.add_child(glow)

	# lighthouse beacon in Cayo Brava
	var beacon := OmniLight3D.new()
	beacon.light_color = m._hex(0xf9f871)
	beacon.light_energy = 6.0
	beacon.omni_range = 60.0
	beacon.position = Vector3(30, 30, -370)
	m.add_child(beacon)
	var tower := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 1.5
	tm.bottom_radius = 2.5
	tm.height = 30.0
	tower.mesh = tm
	var twmat := StandardMaterial3D.new()
	twmat.albedo_color = Color(0.9, 0.9, 0.92)
	tower.material_override = twmat
	tower.position = Vector3(30, 15, -370)
	m.add_child(tower)

	# bayou cypress silhouettes (green cones)
	for i in range(20):
		var cone := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = m.rng.randf_range(1.5, 3.0)
		cm.height = m.rng.randf_range(8.0, 16.0)
		cone.mesh = cm
		var cmat := StandardMaterial3D.new()
		cmat.albedo_color = m._hex(0x183a1a)
		cone.material_override = cmat
		var cx: float = -250.0 + m.rng.randf_range(-120.0, 120.0)
		var cz: float = 360.0 + m.rng.randf_range(-110.0, 110.0)
		cone.position = Vector3(cx, cm.height * 0.5, cz)
		m.add_child(cone)
