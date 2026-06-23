extends Node
# Shooting, weapons cycling, ammo crates, tracers. Reads/writes main state via m.

var m

func setup(main) -> void:
	m = main

func shoot() -> void:
	if m.fire_cooldown > 0.0:
		return
	var w: Dictionary = m._cur_weapon()
	if w["ammo"] <= 0:
		return
	w["ammo"] -= 1
	m.shots_fired += 1
	m.fire_cooldown = w["rof"]
	m.heat = minf(m.HEAT_MAX, m.heat + w["heat"])
	m.heat_peak = maxf(m.heat_peak, m.heat)
	m.heat_clean_timer = 0.0
	var origin: Vector3 = m.cam.global_position
	var base_aim: Vector3 = -m.cam.global_transform.basis.z
	var from: Vector3 = origin + base_aim * 1.0
	var pellets: int = w["pellets"]
	var spread: float = w["spread"]
	var rng_w: float = w["range"]
	for p in range(pellets):
		var aim: Vector3 = base_aim
		if spread > 0.0:
			aim = (base_aim
				+ m.cam.global_transform.basis.x * m.rng.randf_range(-spread, spread)
				+ m.cam.global_transform.basis.y * m.rng.randf_range(-spread, spread)).normalized()
		var to: Vector3 = from + aim * rng_w
		var space: PhysicsDirectSpaceState3D = m.get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(from, to)
		q.exclude = [m.player_body.get_rid()]
		var hit: Dictionary = space.intersect_ray(q)
		var hit_point: Vector3 = to
		var hit_collider = null
		if hit.has("position"):
			hit_point = hit["position"]
			hit_collider = hit.get("collider")
		if hit_collider != null:
			if m.traffic_sys.is_ped(hit_collider):
				m.heat = minf(m.HEAT_MAX, m.heat + 1.5)
				m.traffic_sys.scatter_peds(hit_point)
			elif m.heat_sys.is_pursuer(hit_collider):
				m.heat_sys.hit_pursuer(hit_collider)
			else:
				m.heat_sys.spawn_impact_spark(hit_point)
		m.traffic_sys.scatter_peds(hit_point)
		_spawn_tracer(from, hit_point)
	_spawn_muzzle_flash(from)

func cycle_weapon(dir: int) -> void:
	m.weapon_idx = (m.weapon_idx + dir + m.weapons.size()) % m.weapons.size()

func reload() -> void:
	var w: Dictionary = m._cur_weapon()
	var need: int = w["mag"] - w["ammo"]
	if need <= 0 or w["reserve"] <= 0:
		return
	var take: int = mini(need, w["reserve"])
	w["ammo"] += take
	w["reserve"] -= take

func build_ammo_crates() -> void:
	if m.mode != "play":
		return
	for i in range(20):
		var d: Dictionary = m.DISTRICTS[i % m.DISTRICTS.size()]
		var hw: float = d["w"] * 0.5 - 15.0
		var hd: float = d["d"] * 0.5 - 15.0
		var x: float = d["cx"] + m.rng.randf_range(-hw, hw)
		var z: float = d["cz"] + m.rng.randf_range(-hd, hd)
		_spawn_ammo_crate(Vector3(x, 0.5, z))

func _spawn_ammo_crate(pos: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.6, 0.6, 0.6)
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = m._hex(0xf9f871)
	mat.emission_enabled = true
	mat.emission = m._hex(0xf9f871)
	mat.emission_energy_multiplier = 0.6
	mi.material_override = mat
	mi.position = pos
	m.add_child(mi)
	m.ammo_crates.append({"node": mi, "timer": 0.0, "active": true, "pos": pos})

func update_ammo_crates(delta: float) -> void:
	if m.ammo_crates.is_empty():
		return
	var pp: Vector3 = m._active_pos()
	for crate in m.ammo_crates:
		var node: MeshInstance3D = crate["node"]
		if not is_instance_valid(node):
			continue
		if crate["active"]:
			node.rotation.y += delta * 1.2
			if not m.in_car:
				var pos: Vector3 = crate["pos"]
				if Vector2(pp.x - pos.x, pp.z - pos.z).length() < 1.5:
					var w: Dictionary = m._cur_weapon()
					w["ammo"] = w["mag"]
					w["reserve"] += w["mag"]
					crate["active"] = false
					crate["timer"] = 0.0
					node.visible = false
		else:
			crate["timer"] += delta
			if crate["timer"] >= 60.0:
				crate["active"] = true
				node.visible = true

func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mid := (from + to) * 0.5
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.06, 0.06, from.distance_to(to))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.98, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(0.98, 0.98, 0.5)
	mat.emission_energy_multiplier = 3.0
	mi.mesh = bm
	mi.material_override = mat
	mi.position = mid
	mi.look_at_from_position(mid, to, Vector3.UP)
	m.add_child(mi)
	m.get_tree().create_timer(0.06).timeout.connect(mi.queue_free)

func _spawn_muzzle_flash(pos: Vector3) -> void:
	if m.headless:
		return
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.1)
	light.light_energy = 8.0
	light.omni_range = 6.0
	light.position = pos
	m.add_child(light)
	m.get_tree().create_timer(0.05).timeout.connect(light.queue_free)
