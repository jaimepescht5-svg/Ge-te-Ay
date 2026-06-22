extends Node
# viz capture — drop-in viewport recorder for visual checks.
#
# Wire it into any Godot project as an autoload (Project Settings > Autoload, or
# add to project.godot [autoload]). It does nothing unless VIZ_CAPTURE=1, so it
# is safe to leave installed.
#
# Env:
#   VIZ_CAPTURE=1     enable
#   VIZ_OUT=<dir>     absolute output dir (default: user://viz_frames)
#   VIZ_INTERVAL=0.2  seconds between frames
#   VIZ_MAX=240       stop after this many frames
#   VIZ_SECONDS=0     stop after this many seconds (0 = no limit)

var active := false
var out_dir := ""
var interval := 0.2
var maxn := 240
var secs := 0.0
var t := 0.0
var next_t := 0.0
var idx := 0

func _ready() -> void:
	active = OS.get_environment("VIZ_CAPTURE") == "1"
	if not active:
		return
	out_dir = OS.get_environment("VIZ_OUT")
	if out_dir == "":
		out_dir = ProjectSettings.globalize_path("user://viz_frames")
	DirAccess.make_dir_recursive_absolute(out_dir)
	if OS.get_environment("VIZ_INTERVAL") != "":
		interval = float(OS.get_environment("VIZ_INTERVAL"))
	if OS.get_environment("VIZ_MAX") != "":
		maxn = int(OS.get_environment("VIZ_MAX"))
	if OS.get_environment("VIZ_SECONDS") != "":
		secs = float(OS.get_environment("VIZ_SECONDS"))

func _process(delta: float) -> void:
	if not active:
		return
	t += delta
	if t >= next_t:
		next_t += interval
		_grab()
	if secs > 0.0 and t >= secs:
		get_tree().quit()

func _grab() -> void:
	if DisplayServer.get_name() == "headless":
		return  # no rendering surface to capture
	var tex := get_viewport().get_texture()
	if tex == null:
		return
	tex.get_image().save_png("%s/frame_%04d.png" % [out_dir, idx])
	idx += 1
	if idx >= maxn:
		active = false  # stop capturing but let the game keep running
