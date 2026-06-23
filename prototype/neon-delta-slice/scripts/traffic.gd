extends Node
# Civilian traffic and pedestrian NPCs. Play-mode only — skipped in selfcheck
# to keep headless physics realtime. Reads/writes main state via `m`.

var m  # main scene node

func setup(main) -> void:
	m = main

func is_ped(node) -> bool:
	for ped in m.peds:
		if ped["body"] == node:
			return true
	return false

func build_traffic() -> void:
	if m.mode != "play":
		return
	var per_district := 2
	var idx := 0
	for d in m.DISTRICTS:
		if d["id"] == "bayou" or d["id"] == "cayo":
			continue
		for n in range(per_district):
			_spawn_civilian(d, idx)
			idx += 1

func _spawn_civilian(d: Dictionary, idx: int) -> void:
	var car_c := VehicleBody3D.new()
	car_c.mass = 1200.0
	car_c.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	car_c.center_of_mass = Vector3(0, -0.55, 0)
	var sw: float = m.CAR_W * 0.92
	var sl: float = m.CAR_LEN * 0.9
	var sh: float = m.CAR_H * 0.92
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(sw, sh, sl)
	col.shape = box
	col.position.y = sh * 0.5
	car_c.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(sw, sh - 0.1, sl)
	var color: int = m.civ_palette[idx % m.civ_palette.size()]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = m._hex(color)
	mat.metallic = 0.4
	mat.roughness = 0.45
	mesh.material_override = mat
	mesh.position.y = sh * 0.5
	car_c.add_child(mesh)
	var wx: float = sw * 0.5 - 0.15
	var wz: float = sl * 0.5 - 1.0
	m._add_wheel(car_c, Vector3(-wx, 0.0, -wz), true, true)
	m._add_wheel(car_c, Vector3(wx, 0.0, -wz), true, true)
	m._add_wheel(car_c, Vector3(-wx, 0.0, wz), true, false)
	m._add_wheel(car_c, Vector3(wx, 0.0, wz), true, false)
	var loop := _civ_loop(d)
	car_c.position = Vector3(loop[0].x, 1.5, loop[0].y)
	car_c.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	m.add_child(car_c)
	var b = m.WaypointBot.new(loop)
	m.civilians.append({"car": car_c, "bot": b})

func _civ_loop(d: Dictionary) -> PackedVector2Array:
	var cx: float = d["cx"]
	var cz: float = d["cz"]
	var hw: float = d["w"] * 0.5 - 18.0
	var hd: float = d["d"] * 0.5 - 18.0
	return PackedVector2Array([
		Vector2(cx - hw * 0.5, cz - hd * 0.5),
		Vector2(cx + hw * 0.5, cz - hd * 0.5),
		Vector2(cx + hw * 0.5, cz + hd * 0.5),
		Vector2(cx - hw * 0.5, cz + hd * 0.5),
		Vector2(cx - hw * 0.5, cz - hd * 0.5),
	])

func update_traffic(_delta: float) -> void:
	var pp: Vector3 = m._active_pos()
	for entry in m.civilians:
		var c: VehicleBody3D = entry["car"]
		if not is_instance_valid(c):
			continue
		var far := Vector2(c.global_position.x - pp.x, c.global_position.z - pp.z).length() > 130.0
		if far:
			if not c.freeze:
				c.freeze = true
			continue
		if c.freeze:
			c.freeze = false
		var b = entry["bot"]
		var pos := Vector2(c.global_position.x, c.global_position.z)
		var fwd := -c.global_transform.basis.z
		var fwd2 := Vector2(fwd.x, fwd.z).normalized()
		var ctrl: Dictionary = b.control(pos, fwd2, c.linear_velocity.length())
		b.advance_if_close(pos)
		if b.wp_idx >= b.waypoints.size() - 1:
			b.wp_idx = 0
		c.steering = -ctrl["steer"] * m.MAX_STEER
		c.engine_force = ctrl["throttle"] * 1400.0
		c.brake = ctrl["brake"] * 30.0

func build_peds() -> void:
	if m.mode != "play":
		return
	var per_district := 8
	for d in m.DISTRICTS:
		if d["id"] == "bayou" or d["id"] == "cayo":
			continue
		for n in range(per_district):
			_spawn_ped(d)

func _spawn_ped(d: Dictionary) -> void:
	var body := CharacterBody3D.new()
	body.collision_layer = 4
	body.collision_mask = 1 | 4
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	body.add_child(col)
	var mesh := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.3
	cm.height = 1.8
	mesh.mesh = cm
	var shirt: int = d["palette"][m.rng.randi_range(0, d["palette"].size() - 1)]
	var sm := StandardMaterial3D.new()
	sm.albedo_color = m._hex(shirt)
	mesh.material_override = sm
	mesh.position.y = 0.9
	body.add_child(mesh)
	var head := MeshInstance3D.new()
	var hb := BoxMesh.new()
	hb.size = Vector3(0.4, 0.4, 0.4)
	head.mesh = hb
	var skin: int = m.skin_tones[m.rng.randi_range(0, m.skin_tones.size() - 1)]
	var hm := StandardMaterial3D.new()
	hm.albedo_color = m._hex(skin)
	head.material_override = hm
	head.position.y = 1.9
	body.add_child(head)
	var hw: float = d["w"] * 0.5 - 10.0
	var hd: float = d["d"] * 0.5 - 10.0
	var sx: float = d["cx"] + m.rng.randf_range(-hw, hw)
	var sz: float = d["cz"] + m.rng.randf_range(-hd, hd)
	body.position = Vector3(sx, 1.0, sz)
	m.add_child(body)
	m.peds.append({
		"body": body,
		"target": _ped_pick(d),
		"speed": m.rng.randf_range(1.2, 2.0),
		"scatter": 0.0,
		"scatter_dir": Vector2.ZERO,
		"d": d,
	})

func _ped_pick(d: Dictionary) -> Vector2:
	var hw: float = d["w"] * 0.5 - 10.0
	var hd: float = d["d"] * 0.5 - 10.0
	return Vector2(d["cx"] + m.rng.randf_range(-hw, hw), d["cz"] + m.rng.randf_range(-hd, hd))

func update_peds(delta: float) -> void:
	var pp: Vector3 = m._active_pos()
	for ped in m.peds:
		var body: CharacterBody3D = ped["body"]
		if not is_instance_valid(body):
			continue
		var pos := Vector2(body.global_position.x, body.global_position.z)
		var far := pos.distance_to(Vector2(pp.x, pp.z)) > 150.0
		if far:
			if body.is_physics_processing():
				body.set_physics_process(false)
			continue
		var v := body.velocity
		var move: Vector2
		if ped["scatter"] > 0.0:
			ped["scatter"] -= delta
			move = ped["scatter_dir"] * 4.0
		else:
			var to_t: Vector2 = ped["target"] - pos
			if to_t.length() < 2.0:
				ped["target"] = _ped_pick(ped["d"])
				to_t = ped["target"] - pos
			move = to_t.normalized() * ped["speed"]
		v.x = move.x
		v.z = move.y
		if not body.is_on_floor():
			v.y -= m.GRAVITY * delta
		else:
			v.y = maxf(v.y, -0.1)
		body.velocity = v
		body.move_and_slide()
		if move.length() > 0.1:
			body.rotation.y = atan2(move.x, move.y)

func scatter_peds(impact: Vector3) -> void:
	for ped in m.peds:
		var body: CharacterBody3D = ped["body"]
		if not is_instance_valid(body):
			continue
		var pos := Vector2(body.global_position.x, body.global_position.z)
		var ip := Vector2(impact.x, impact.z)
		if pos.distance_to(ip) < 15.0:
			ped["scatter"] = 5.0
			var away := (pos - ip)
			ped["scatter_dir"] = away.normalized() if away.length() > 0.01 else Vector2(1, 0)
