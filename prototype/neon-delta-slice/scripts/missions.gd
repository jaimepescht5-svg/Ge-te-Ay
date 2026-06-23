extends Node
# Mission accept/progress/complete cycle. Reads/writes main state via m.

var m
var eliminate_targets: Array = []
var _eliminate_spawned := false

func setup(main) -> void:
	m = main

func accept_next_mission() -> void:
	_clear_eliminate_targets()
	var n: int = m.MISSIONS.size()
	for step in range(1, n + 1):
		var idx: int = (m.current_mission + step) % n
		if not m.mission_completed.has(idx):
			m.current_mission = idx
			var miss: Dictionary = m.MISSIONS[m.current_mission]
			if miss["type"] == "eliminate":
				_spawn_eliminate_targets(miss)
			_show_mission_target()
			return
	m.current_mission = -1
	_clear_mission_target()

func is_eliminate_target(node) -> bool:
	return eliminate_targets.has(node)

func damage_target(node) -> void:
	if not is_instance_valid(node):
		return
	eliminate_targets.erase(node)
	node.queue_free()
	m.heat = minf(m.HEAT_MAX, m.heat + 0.5)
	m.heat_peak = maxf(m.heat_peak, m.heat)
	m.heat_clean_timer = 0.0

func _spawn_eliminate_targets(miss: Dictionary) -> void:
	if m.mode != "play":
		return
	var t: Vector2 = miss["target"]
	var count: int = miss.get("count", 3)
	_eliminate_spawned = true
	for i in range(count):
		var angle: float = TAU * i / count
		var px: float = t.x + cos(angle) * 14.0
		var pz: float = t.y + sin(angle) * 14.0
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var cap := CapsuleShape3D.new()
		cap.radius = 0.4
		cap.height = 1.8
		col.shape = cap
		col.position.y = 0.9
		body.add_child(col)
		var mesh := MeshInstance3D.new()
		var cm := CapsuleMesh.new()
		cm.radius = 0.4
		cm.height = 1.8
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.15, 0.08)
		mat.emission_enabled = true
		mat.emission = Color(0.9, 0.15, 0.08)
		mat.emission_energy_multiplier = 0.5
		mesh.mesh = cm
		mesh.material_override = mat
		mesh.position.y = 0.9
		body.add_child(mesh)
		body.position = Vector3(px, 0.0, pz)
		m.add_child(body)
		eliminate_targets.append(body)

func _clear_eliminate_targets() -> void:
	for t in eliminate_targets:
		if is_instance_valid(t):
			t.queue_free()
	eliminate_targets.clear()
	_eliminate_spawned = false

func _mission_target_pos() -> Vector3:
	var miss: Dictionary = m.MISSIONS[m.current_mission]
	var t: Vector2 = miss["target"]
	return Vector3(t.x, 4.0, t.y)

func _show_mission_target() -> void:
	if m.headless:
		return
	if m.mission_target_sphere == null:
		m.mission_target_sphere = MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 8.0
		sm.height = 16.0
		m.mission_target_sphere.mesh = sm
		var mat := StandardMaterial3D.new()
		var c: Color = m._hex(0xf9f871)
		c.a = 0.35
		mat.albedo_color = c
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = m._hex(0xf9f871)
		mat.emission_energy_multiplier = 0.8
		m.mission_target_sphere.material_override = mat
		m.add_child(m.mission_target_sphere)
	m.mission_target_sphere.visible = true
	m.mission_target_sphere.position = _mission_target_pos()

func _clear_mission_target() -> void:
	if m.mission_target_sphere != null:
		m.mission_target_sphere.visible = false

func update_missions(delta: float) -> void:
	if m.mission_banner_timer > 0.0:
		m.mission_banner_timer -= delta
		if m.mission_banner_timer <= 0.0:
			m.mission_banner = ""
	if m.current_mission < 0 or m.mode != "play":
		return
	var miss: Dictionary = m.MISSIONS[m.current_mission]
	var tpos: Vector2 = miss["target"]
	var pp: Vector3 = m._active_pos()
	var here := Vector2(pp.x, pp.z)
	var dist := here.distance_to(tpos)
	var done := false
	match miss["type"]:
		"drive_to":
			done = m.in_car and dist < 20.0
		"drive_heat":
			done = dist < 20.0 and m.heat >= 3.0
		"lose_heat":
			done = m.heat <= 0.0 and m._district_at(here) == _zone_name(miss["zone"])
		"eliminate":
			done = _eliminate_spawned and eliminate_targets.is_empty()
		"deliver":
			done = m.in_car and dist < 20.0
		_:
			done = false
	if done:
		_complete_mission()

func _zone_name(zone_id: String) -> String:
	for d in m.DISTRICTS:
		if d["id"] == zone_id:
			return d["name"]
	return ""

func _complete_mission() -> void:
	var miss: Dictionary = m.MISSIONS[m.current_mission]
	m.money += miss["reward"]
	m.mission_completed.append(m.current_mission)
	m.mission_banner = "MISSION COMPLETE  +$%d" % miss["reward"]
	m.mission_banner_timer = 4.0
	m.current_mission = -1
	_clear_eliminate_targets()
	_clear_mission_target()
