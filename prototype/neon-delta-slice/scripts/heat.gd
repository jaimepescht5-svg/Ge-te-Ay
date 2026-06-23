extends Node
# Heat/wanted system: decay, spawning & destroying police VehicleBody3D pursuers,
# light-bar strobing, explosions. Reads/writes main state via `m`.

var m  # main scene node

func setup(main) -> void:
	m = main

func is_pursuer(node) -> bool:
	return m.pursuers.has(node)

func update_heat(delta: float) -> void:
	m.heat_clean_timer += delta
	if m.heat_clean_timer > m.HEAT_CLEAN_DELAY and m.heat > 0.0:
		m.heat = maxf(0.0, m.heat - m.HEAT_DECAY * delta)
	var want: int = mini(m.PURSUER_CAP, int(floor(m.heat)))
	while m.pursuers.size() < want:
		spawn_pursuer()
	if m.heat <= 0.0 and not m.pursuers.is_empty():
		for cop in m.pursuers:
			cop.queue_free()
		m.pursuers.clear()

func spawn_pursuer() -> void:
	var cop := VehicleBody3D.new()
	cop.mass = 1400.0
	cop.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	cop.center_of_mass = Vector3(0, -0.6, 0)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(m.CAR_W, m.CAR_H, m.CAR_LEN)
	col.shape = box
	col.position.y = m.CAR_H * 0.5
	cop.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(m.CAR_W, m.CAR_H - 0.1, m.CAR_LEN)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.04, 0.04, 0.05)
	mesh.material_override = mat
	mesh.position.y = m.CAR_H * 0.5
	cop.add_child(mesh)
	var bar_l := _make_lightbar(Vector3(-0.5, m.CAR_H + 0.15, 0.0))
	var bar_r := _make_lightbar(Vector3(0.5, m.CAR_H + 0.15, 0.0))
	cop.add_child(bar_l)
	cop.add_child(bar_r)
	cop.set_meta("bar_l", bar_l)
	cop.set_meta("bar_r", bar_r)
	cop.set_meta("hits", 0)
	var wx: float = m.CAR_W * 0.5 - 0.15
	var wz: float = m.CAR_LEN * 0.5 - 1.0
	m._add_wheel(cop, Vector3(-wx, 0.0, -wz), true, true)
	m._add_wheel(cop, Vector3(wx, 0.0, -wz), true, true)
	m._add_wheel(cop, Vector3(-wx, 0.0, wz), true, false)
	m._add_wheel(cop, Vector3(wx, 0.0, wz), true, false)
	var d: Dictionary = m.DISTRICTS[m.rng.randi_range(0, m.DISTRICTS.size() - 1)]
	cop.position = Vector3(d["cx"] + d["w"] * 0.5, 1.5, d["cz"])
	m.add_child(cop)
	m.pursuers.append(cop)
	m.pursuers_spawned += 1

func _make_lightbar(pos: Vector3) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.8, 0.18, 0.5)
	mesh.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.05, 0.85, 0.91)
	mat.emission_enabled = true
	mat.emission = Color(0.05, 0.85, 0.91)
	mat.emission_energy_multiplier = 3.0
	mesh.material_override = mat
	mesh.position = pos
	return mesh

func update_police_lights() -> void:
	if m.headless or m.pursuers.is_empty():
		return
	var t := sin(m.sim_time * 8.0) > 0.0
	var cyan := Color(0.05, 0.85, 0.91)
	var mag := Color(1.0, 0.16, 0.83)
	for cop in m.pursuers:
		if not is_instance_valid(cop):
			continue
		var bl: MeshInstance3D = cop.get_meta("bar_l")
		var br: MeshInstance3D = cop.get_meta("bar_r")
		if bl == null or br == null:
			continue
		var ml: StandardMaterial3D = bl.material_override
		var mr: StandardMaterial3D = br.material_override
		ml.emission = cyan if t else mag
		ml.albedo_color = ml.emission
		mr.emission = mag if t else cyan
		mr.albedo_color = mr.emission

func update_pursuers(_delta: float) -> void:
	var tgt: Vector3 = m._active_pos()
	for cop: VehicleBody3D in m.pursuers:
		var to := Vector2(tgt.x - cop.global_position.x, tgt.z - cop.global_position.z)
		var dist := to.length()
		var fwd := cop.global_transform.basis.z
		var fwd2 := Vector2(fwd.x, fwd.z).normalized()
		var steer := 0.0
		if dist > 0.001 and fwd2.length() > 0.001:
			var d := to.normalized()
			var cross := fwd2.x * d.y - fwd2.y * d.x
			var dot := fwd2.dot(d)
			steer = clampf(atan2(cross, dot) * 2.0, -1.0, 1.0)
		cop.steering = -steer * m.MAX_STEER
		var spd := cop.linear_velocity.length()
		if dist > 6.0 and spd < m.PURSUER_SPEED:
			cop.engine_force = m.ENGINE_POWER
			cop.brake = 0.0
		else:
			cop.engine_force = 0.0
			cop.brake = m.BRAKE_POWER * 0.5

func hit_pursuer(cop) -> void:
	if not is_instance_valid(cop):
		return
	var hits: int = cop.get_meta("hits", 0) + 1
	cop.set_meta("hits", hits)
	spawn_impact_spark(cop.global_position + Vector3(0, 1.0, 0))
	if hits >= 3:
		explode_pursuer(cop)

func explode_pursuer(cop) -> void:
	if not is_instance_valid(cop):
		return
	var pos: Vector3 = cop.global_position
	m.pursuers.erase(cop)
	cop.queue_free()
	m.heat = minf(m.HEAT_MAX, m.heat + 0.5)
	m.heat_peak = maxf(m.heat_peak, m.heat)
	spawn_explosion(pos)

func spawn_explosion(pos: Vector3) -> void:
	if m.headless:
		return
	var burst := OmniLight3D.new()
	burst.light_color = Color(1.0, 0.5, 0.1)
	burst.light_energy = 12.0
	burst.omni_range = 18.0
	burst.position = pos + Vector3(0, 1.5, 0)
	m.add_child(burst)
	m.get_tree().create_timer(0.5).timeout.connect(burst.queue_free)
	for i in range(8):
		var shard := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.5
		sm.height = 1.0
		shard.mesh = sm
		var mat := StandardMaterial3D.new()
		var c: Color = Color(1.0, 0.5, 0.1) if (i % 2 == 0) else Color(1.0, 0.2, 0.05)
		mat.albedo_color = c
		mat.emission_enabled = true
		mat.emission = c
		mat.emission_energy_multiplier = 4.0
		shard.material_override = mat
		shard.position = pos + Vector3(0, 1.5, 0)
		m.add_child(shard)
		var dir := Vector3(m.rng.randf_range(-1, 1), m.rng.randf_range(0.2, 1.0), m.rng.randf_range(-1, 1)).normalized()
		var tw := m.create_tween() as Tween
		tw.set_parallel(true)
		tw.tween_property(shard, "position", shard.position + dir * 8.0, 1.0)
		tw.tween_property(shard, "scale", Vector3.ZERO, 1.0)
		tw.chain().tween_callback(shard.queue_free)

func spawn_impact_spark(pos: Vector3) -> void:
	if m.headless:
		return
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 1.0, 1.0)
	light.light_energy = 6.0
	light.omni_range = 3.0
	light.position = pos
	m.add_child(light)
	m.get_tree().create_timer(0.05).timeout.connect(light.queue_free)
