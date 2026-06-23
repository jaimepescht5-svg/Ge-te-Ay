extends Node
# Mission accept/progress/complete cycle. Reads/writes main state via m.

var m

func setup(main) -> void:
	m = main

func accept_next_mission() -> void:
	var n: int = m.MISSIONS.size()
	for step in range(1, n + 1):
		var idx: int = (m.current_mission + step) % n
		if not m.mission_completed.has(idx):
			m.current_mission = idx
			_show_mission_target()
			return
	m.current_mission = -1
	_clear_mission_target()

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
	_clear_mission_target()
