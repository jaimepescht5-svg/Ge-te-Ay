extends Node
# Player car, on-foot body, camera, input, physics, health. Reads/writes main via m.

var m

func setup(main) -> void:
	m = main

func build_car() -> void:
	m.car = VehicleBody3D.new()
	m.car.mass = m.CAR_MASS
	m.car.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	m.car.center_of_mass = Vector3(0, -0.6, 0)
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(m.CAR_W, m.CAR_H, m.CAR_LEN)
	col.shape = box
	col.position.y = m.CAR_H * 0.5
	m.car.add_child(col)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(m.CAR_W, m.CAR_H - 0.1, m.CAR_LEN)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.85, 0.95)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.4, 0.5)
	mat.emission_energy_multiplier = 0.4
	mesh.material_override = mat
	mesh.position.y = m.CAR_H * 0.5
	m.car.add_child(mesh)
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.6, 0.4, 0.8)
	var nm := StandardMaterial3D.new()
	nm.albedo_color = Color(1, 1, 0.3)
	nose.material_override = nm
	nose.mesh = nb
	nose.position = Vector3(0, m.CAR_H * 0.5 + 0.5, -(m.CAR_LEN * 0.5 - 0.4))
	m.car.add_child(nose)
	var wx: float = m.CAR_W * 0.5 - 0.15
	var wz: float = m.CAR_LEN * 0.5 - 1.0
	m._add_wheel(m.car, Vector3(-wx, 0.0, -wz), true, true)
	m._add_wheel(m.car, Vector3(wx, 0.0, -wz), true, true)
	m._add_wheel(m.car, Vector3(-wx, 0.0, wz), true, false)
	m._add_wheel(m.car, Vector3(wx, 0.0, wz), true, false)
	m.car.position = m.spawn_pos
	m.car.rotation.y = m.spawn_yaw
	m.add_child(m.car)

func build_player() -> void:
	m.player_body = CharacterBody3D.new()
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	m.player_body.add_child(col)
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
	m.player_body.add_child(mesh)
	var nose := MeshInstance3D.new()
	var nb := BoxMesh.new()
	nb.size = Vector3(0.2, 0.2, 0.5)
	nose.mesh = nb
	nose.position = Vector3(0, 1.2, 0.45)
	m.player_body.add_child(nose)
	m.player_body.position = m.spawn_pos
	m.player_body.visible = false
	m.player_body.set_physics_process(false)
	m.add_child(m.player_body)

func build_camera() -> void:
	m.cam = Camera3D.new()
	m.cam.fov = 65
	m.cam.position = m.spawn_pos + Vector3(0, 8, 14)
	m.cam.cull_mask = 0xFFFFF & ~(1 << (m.MM_LAYER - 1))
	m.add_child(m.cam)
	m.cam.look_at(m.spawn_pos, Vector3.UP)

func setup_input() -> void:
	_action("accel", [KEY_W, KEY_UP])
	_action("brake", [KEY_S, KEY_DOWN])
	_action("steer_left", [KEY_A, KEY_LEFT])
	_action("steer_right", [KEY_D, KEY_RIGHT])
	_action("run", [KEY_SHIFT])
	_action("reset", [KEY_R])
	_action("enter_exit", [KEY_E])
	_action("shoot", [KEY_F])
	_action("switch_lead", [KEY_TAB])
	_action("weapon_prev", [KEY_Z])
	_action("weapon_next", [KEY_X])
	_action("mission", [KEY_M])

func _action(name: String, keys: Array) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(name, ev)

func update_camera() -> void:
	if m.cam == null or not m.cam.is_inside_tree():
		return
	if m.in_car:
		var back: Vector3 = -m.car.global_transform.basis.z
		var target: Vector3 = m.car.global_position + back * 12.0 + Vector3.UP * 6.0
		m.cam.global_position = m.cam.global_position.lerp(target, 0.10)
		m.cam.look_at(m.car.global_position + Vector3.UP * 1.0, Vector3.UP)
	else:
		var p: Vector3 = m.player_body.global_position
		var back: Vector3 = Vector3(-sin(m.player_yaw), 0, -cos(m.player_yaw))
		var target: Vector3 = p + back * 8.0 + Vector3.UP * 5.0
		m.cam.global_position = m.cam.global_position.lerp(target, 0.12)
		m.cam.look_at(p + Vector3.UP * 1.0, Vector3.UP)

func car_physics(delta: float) -> void:
	var c: Dictionary
	if m.mode == "play":
		c = _player_drive_controls()
	else:
		c = m.bot.control(m._car_xz(), m._car_forward_xz(), m._car_speed())
		m.bot.advance_if_close(m._car_xz())
	var target_steer: float = -c["steer"] * m.MAX_STEER
	m.steer_current = move_toward(m.steer_current, target_steer, m.STEER_SPEED * m.MAX_STEER * delta)
	m.car.steering = m.steer_current
	m.car.engine_force = c["throttle"] * m.ENGINE_POWER
	m.car.brake = c["brake"] * m.BRAKE_POWER

func _player_drive_controls() -> Dictionary:
	var throttle := Input.get_action_strength("accel")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	return {"throttle": throttle, "brake": brake, "steer": steer}

func foot_physics(delta: float) -> void:
	var c := _player_foot_controls()
	var wish: Vector2 = c["move"]
	var fwd := -Vector3(m.cam.global_transform.basis.z.x, 0, m.cam.global_transform.basis.z.z)
	if fwd.length() > 0.001:
		fwd = fwd.normalized()
	else:
		fwd = Vector3(0, 0, -1)
	var right := Vector3(fwd.z, 0, -fwd.x)
	var move_dir := right * wish.x + fwd * (-wish.y)
	var speed: float = m.RUN_SPEED if c["run"] else m.WALK_SPEED
	var target := move_dir * speed
	var v: Vector3 = m.player_body.velocity
	v.x = move_toward(v.x, target.x, m.GROUND_ACCEL * delta)
	v.z = move_toward(v.z, target.z, m.GROUND_ACCEL * delta)
	if not m.player_body.is_on_floor():
		v.y -= m.GRAVITY * delta
	else:
		v.y = maxf(v.y, -0.1)
	m.player_body.velocity = v
	m.player_body.move_and_slide()
	if Vector2(v.x, v.z).length() > 0.5:
		var want := atan2(v.x, v.z)
		m.player_yaw = m._lerp_angle(m.player_yaw, want, m.TURN_SPEED * delta)
		m.player_body.rotation.y = m.player_yaw
	if m._cur_weapon()["auto"]:
		if c["fire_held"]:
			m.weapons_sys.shoot()
	elif c["fire"]:
		m.weapons_sys.shoot()

func _player_foot_controls() -> Dictionary:
	if m.mode != "play":
		return {"move": Vector2.ZERO, "run": false, "fire": false, "fire_held": false}
	var mv := Vector2.ZERO
	mv.y -= Input.get_action_strength("accel")
	mv.y += Input.get_action_strength("brake")
	mv.x -= Input.get_action_strength("steer_left")
	mv.x += Input.get_action_strength("steer_right")
	if mv.length() > 1.0:
		mv = mv.normalized()
	return {"move": mv, "run": Input.is_action_pressed("run"),
			"fire": Input.is_action_just_pressed("shoot"),
			"fire_held": Input.is_action_pressed("shoot")}

func handle_enter_exit() -> void:
	if m.mode != "play":
		return
	if not Input.is_action_just_pressed("enter_exit"):
		return
	if m.in_car:
		var side: Vector3 = m.car.global_transform.basis.x.normalized()
		var out: Vector3 = m.car.global_position + side * 2.5
		out.y = 1.0
		m.player_body.global_position = out
		m.player_body.velocity = Vector3.ZERO
		m.player_body.visible = true
		m.player_body.set_physics_process(true)
		m.player_yaw = m.car.rotation.y
		m.player_body.rotation.y = m.player_yaw
		m.in_car = false
	else:
		if m._player_xz().distance_to(m._car_xz()) < 8.0:
			m.player_body.visible = false
			m.player_body.set_physics_process(false)
			m.in_car = true

func respawn_in_car() -> void:
	m.in_car = true
	m.player_body.visible = false
	m.player_body.set_physics_process(false)
	m.car.linear_velocity = Vector3.ZERO
	m.car.angular_velocity = Vector3.ZERO
	m.car.position = m.spawn_pos
	m.car.rotation = Vector3(0, m.spawn_yaw, 0)
	m.steer_current = 0.0

func respawn_car_only() -> void:
	m.car.linear_velocity = Vector3.ZERO
	m.car.angular_velocity = Vector3.ZERO
	m.car.position = m.spawn_pos
	m.car.rotation = Vector3(0, m.spawn_yaw, 0)
	m.steer_current = 0.0

func update_health(delta: float) -> void:
	if m.mode != "play":
		return
	if m.wasted:
		m.wasted_timer -= delta
		if m.wasted_timer <= 0.0:
			_revive()
		return
	if m.heat <= 0.0 and m.health < m.health_max:
		m.health = minf(m.health_max, m.health + 5.0 * delta)
	if not m.in_car:
		var y: float = m.player_body.global_position.y
		if m.player_body.is_on_floor():
			var fall: float = m.prev_player_y - y
			if fall > 10.0:
				_damage_player(fall * 1.5)
			m.prev_player_y = y
		else:
			m.prev_player_y = maxf(m.prev_player_y, y)
	else:
		m.prev_player_y = m.car.global_position.y
	_check_cop_collisions()
	if m.health <= 0.0 and not m.wasted:
		_wasted()

func _check_cop_collisions() -> void:
	var ap: Vector3 = m._active_pos()
	for cop: VehicleBody3D in m.pursuers:
		if not is_instance_valid(cop):
			continue
		var d := cop.global_position.distance_to(ap)
		if d < 5.0:
			var my_vel: Vector3 = m.car.linear_velocity if m.in_car else m.player_body.velocity
			var rel := (cop.linear_velocity - my_vel).length()
			if rel > 8.0:
				if m.in_car:
					_car_impact()
				else:
					_damage_player(15.0)

func _damage_player(amount: float) -> void:
	if m.wasted:
		return
	m.health = maxf(0.0, m.health - amount)

func _car_impact() -> void:
	m.car_impacts += 1
	if m.car_impacts == 5 and m.car_smoke_light == null and not m.headless:
		m.car_smoke_light = OmniLight3D.new()
		m.car_smoke_light.light_color = Color(1.0, 0.4, 0.1)
		m.car_smoke_light.omni_range = 8.0
		m.car.add_child(m.car_smoke_light)
		m.car_smoke_light.position = Vector3(0, 2.0, 0)
	if m.car_impacts >= 8:
		_destroy_car()

func _destroy_car() -> void:
	m.heat_sys.spawn_explosion(m.car.global_position)
	m.car_impacts = 0
	if m.car_smoke_light != null and is_instance_valid(m.car_smoke_light):
		m.car_smoke_light.queue_free()
		m.car_smoke_light = null
	if m.in_car:
		var side: Vector3 = m.car.global_transform.basis.x.normalized()
		var out: Vector3 = m.car.global_position + side * 3.0
		out.y = 1.0
		m.player_body.global_position = out
		m.player_body.velocity = Vector3.ZERO
		m.player_body.visible = true
		m.player_body.set_physics_process(true)
		m.player_yaw = m.car.rotation.y
		m.in_car = false
	respawn_car_only()

func _wasted() -> void:
	m.wasted = true
	m.wasted_timer = 2.0
	m.mission_banner = "WASTED"
	m.mission_banner_timer = 2.0

func _revive() -> void:
	m.wasted = false
	m.health = m.health_max
	m.heat = 0.0
	m.car_impacts = 0
	if m.car_smoke_light != null and is_instance_valid(m.car_smoke_light):
		m.car_smoke_light.queue_free()
		m.car_smoke_light = null
	respawn_in_car()
