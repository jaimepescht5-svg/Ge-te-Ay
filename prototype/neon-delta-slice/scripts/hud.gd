extends Node
# HUD labels, minimap, camera-follow update. Reads/writes main state via m.

var m

func setup(main) -> void:
	m = main

func build_hud() -> void:
	if m.headless:
		return
	var layer := CanvasLayer.new()
	m.add_child(layer)

	m.hud_money = _hud_label(layer, Vector2(20, 14), 28, Color(0.2, 1.0, 0.45))
	m.hud_char = _hud_label(layer, Vector2(20, 48), 18, Color(0.8, 0.9, 1.0))

	m.hud_district = _hud_label(layer, Vector2(0, 14), 30, Color(0.05, 0.85, 0.91))
	m.hud_district.anchor_left = 0.5
	m.hud_district.anchor_right = 0.5
	m.hud_district.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	m.hud_district.size = Vector2(400, 40)
	m.hud_district.position = Vector2(-200, 14)

	m.hud_center = _hud_label(layer, Vector2(-250, 0), 48, Color(1.0, 0.16, 0.2))
	m.hud_center.anchor_left = 0.5
	m.hud_center.anchor_right = 0.5
	m.hud_center.anchor_top = 0.5
	m.hud_center.anchor_bottom = 0.5
	m.hud_center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	m.hud_center.size = Vector2(500, 60)
	m.hud_center.position = Vector2(-250, -30)

	m.hud_mission = _hud_label(layer, Vector2(20, -70), 18, Color(0.98, 0.95, 0.4))
	m.hud_mission.anchor_top = 1.0
	m.hud_mission.anchor_bottom = 1.0

	m.hud_weapon = _hud_label(layer, Vector2(-100, -64), 22, Color(0.9, 0.95, 1.0))
	m.hud_weapon.anchor_left = 0.5
	m.hud_weapon.anchor_right = 0.5
	m.hud_weapon.anchor_top = 1.0
	m.hud_weapon.anchor_bottom = 1.0
	m.hud_weapon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	m.hud_weapon.size = Vector2(200, 24)
	m.hud_speed = _hud_label(layer, Vector2(-100, -36), 20, Color(0.7, 0.85, 1.0))
	m.hud_speed.anchor_left = 0.5
	m.hud_speed.anchor_right = 0.5
	m.hud_speed.anchor_top = 1.0
	m.hud_speed.anchor_bottom = 1.0
	m.hud_speed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	m.hud_speed.size = Vector2(200, 22)

	m.hud_heat = _hud_label(layer, Vector2(-180, -64), 22, Color(1.0, 0.4, 0.3))
	m.hud_heat.anchor_left = 1.0
	m.hud_heat.anchor_right = 1.0
	m.hud_heat.anchor_top = 1.0
	m.hud_heat.anchor_bottom = 1.0
	m.hud_tide = _hud_label(layer, Vector2(-180, -36), 16, Color(0.5, 0.8, 0.95))
	m.hud_tide.anchor_left = 1.0
	m.hud_tide.anchor_right = 1.0
	m.hud_tide.anchor_top = 1.0
	m.hud_tide.anchor_bottom = 1.0

	m.hud_health_bg = ColorRect.new()
	m.hud_health_bg.color = Color(0.1, 0.05, 0.05, 0.8)
	m.hud_health_bg.size = Vector2(14, 160)
	m.hud_health_bg.position = Vector2(8, 90)
	layer.add_child(m.hud_health_bg)
	m.hud_health_fill = ColorRect.new()
	m.hud_health_fill.color = Color(0.2, 1.0, 0.45)
	m.hud_health_fill.size = Vector2(14, 160)
	m.hud_health_fill.position = Vector2(8, 90)
	layer.add_child(m.hud_health_fill)

	m.hud_left = m.hud_money
	m.hud_right = m.hud_heat
	m.hud_bottom = m.hud_weapon

func _hud_label(layer: CanvasLayer, pos: Vector2, size: int, color: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	layer.add_child(l)
	return l

func build_minimap() -> void:
	if m.headless:
		return
	var layer := CanvasLayer.new()
	m.add_child(layer)
	var border := ColorRect.new()
	border.color = Color(0.04, 0.05, 0.08, 0.9)
	border.size = Vector2(m.MM_SIZE + 8, m.MM_SIZE + 8)
	border.position = Vector2(-m.MM_SIZE - 16, 12)
	border.anchor_left = 1.0
	border.anchor_right = 1.0
	layer.add_child(border)

	m.minimap_vp = SubViewport.new()
	m.minimap_vp.size = Vector2i(m.MM_SIZE, m.MM_SIZE)
	m.minimap_vp.transparent_bg = false
	m.minimap_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	m.minimap_vp.world_3d = m.get_world_3d()
	m.add_child(m.minimap_vp)

	m.minimap_cam = Camera3D.new()
	m.minimap_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	m.minimap_cam.size = m.MM_ORTHO
	m.minimap_cam.position = Vector3(m.spawn_pos.x, 600, m.spawn_pos.z)
	m.minimap_cam.rotation_degrees = Vector3(-90, 0, 0)
	m.minimap_cam.cull_mask = 0xFFFFF
	m.minimap_vp.add_child(m.minimap_cam)

	var tex := TextureRect.new()
	tex.texture = m.minimap_vp.get_texture()
	tex.size = Vector2(m.MM_SIZE, m.MM_SIZE)
	tex.position = Vector2(-m.MM_SIZE - 12, 16)
	tex.anchor_left = 1.0
	tex.anchor_right = 1.0
	layer.add_child(tex)

	m.minimap_dots["player"] = [_make_dot(Color(0.05, 0.9, 0.95), 7.0)]
	m.minimap_dots["police"] = []
	m.minimap_dots["traffic"] = []

func _make_dot(c: Color, r: float) -> MeshInstance3D:
	var dot := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	dot.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = c
	mat.emission_enabled = true
	mat.emission = c
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dot.material_override = mat
	dot.layers = 1 << (m.MM_LAYER - 1)
	dot.position = Vector3(0, 50, 0)
	m.add_child(dot)
	return dot

func _ensure_dots(role: String, n: int, c: Color, r: float) -> void:
	var arr: Array = m.minimap_dots[role]
	while arr.size() < n:
		arr.append(_make_dot(c, r))
	for i in range(arr.size()):
		arr[i].visible = i < n

func update_minimap() -> void:
	if m.headless or m.minimap_cam == null:
		return
	var p: Vector3 = m._active_pos()
	m.minimap_cam.position = Vector3(p.x, 600, p.z)
	var pd: MeshInstance3D = m.minimap_dots["player"][0]
	pd.position = Vector3(p.x, 55, p.z)
	_ensure_dots("police", m.pursuers.size(), Color(1.0, 0.15, 0.15), 6.0)
	for i in range(m.pursuers.size()):
		var cop = m.pursuers[i]
		if is_instance_valid(cop):
			m.minimap_dots["police"][i].position = Vector3(cop.global_position.x, 52, cop.global_position.z)
	_ensure_dots("traffic", m.civilians.size(), Color(0.95, 0.95, 0.95), 5.0)
	for i in range(m.civilians.size()):
		var cc = m.civilians[i]["car"]
		if is_instance_valid(cc):
			m.minimap_dots["traffic"][i].position = Vector3(cc.global_position.x, 52, cc.global_position.z)
	if not m.minimap_dots.has("mission"):
		m.minimap_dots["mission"] = []
	var blip_n := 1 if m.current_mission >= 0 else 0
	_ensure_dots("mission", blip_n, Color(0.98, 0.95, 0.3), 9.0)
	if blip_n > 0:
		var t: Vector2 = m.MISSIONS[m.current_mission]["target"]
		m.minimap_dots["mission"][0].position = Vector3(t.x, 58, t.y)

func update_hud() -> void:
	if m.hud_money == null:
		return
	var spd: float = m._car_speed() if m.in_car else m._planar_speed_body()
	var kmh := int(round(spd * 3.6))
	var pos: Vector2 = m._car_xz() if m.in_car else m._player_xz()

	m.hud_money.text = "$%s" % _commafy(m.money)
	m.hud_char.text = m.leads[m.lead_idx]

	var dname: String = m._district_at(pos)
	m.hud_district.text = dname
	m.hud_district.add_theme_color_override("font_color", _district_color(dname))

	if m.current_mission >= 0:
		var miss: Dictionary = m.MISSIONS[m.current_mission]
		var prog := ""
		if miss["type"] == "eliminate" or miss["type"] == "deliver":
			prog = "\n(objective: in progress)"
		m.hud_mission.text = "%s\n%s%s" % [miss["name"], miss["desc"], prog]
	else:
		m.hud_mission.text = "[M] accept mission"

	var w: Dictionary = m._cur_weapon()
	m.hud_weapon.text = "%s %d/%d" % [w["name"], w["ammo"], w["reserve"]]
	m.hud_speed.text = ("%d km/h" % kmh) if m.in_car else "ON FOOT"

	var stars := ""
	var h := int(round(m.heat))
	for i in range(5):
		stars += "★" if i < h else "☆"
	m.hud_heat.text = "HEAT %s" % stars
	m.hud_tide.text = "TIDE: %s" % m.env_sys._tide_phase()

	m.hud_center.text = m.mission_banner
	m.hud_center.add_theme_color_override("font_color",
		Color(1.0, 0.16, 0.2) if m.mission_banner == "WASTED" else Color(0.98, 0.95, 0.4))

	if m.hud_health_fill != null:
		var frac := clampf(m.health / m.health_max, 0.0, 1.0)
		var full_h := 160.0
		m.hud_health_fill.size = Vector2(14, full_h * frac)
		m.hud_health_fill.position = Vector2(8, 90 + full_h * (1.0 - frac))
		m.hud_health_fill.color = Color(0.2, 1.0, 0.45).lerp(Color(1.0, 0.2, 0.2), 1.0 - frac)

func _commafy(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if n < 0 else "") + out

func _district_color(dname: String) -> Color:
	for d in m.DISTRICTS:
		if d["name"] == dname:
			return m._hex(d["palette"][0])
	return Color(0.9, 0.9, 0.95)
