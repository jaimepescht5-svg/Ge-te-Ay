#!/usr/bin/env bash
# Run the autonomous self-check for the on-foot verbs sandbox (Sandbox.tscn)
# and produce a clip. Counterpart to tools/selfcheck.sh for the driving slice.
#
# Usage:
#   tools/selfcheck_foot.sh                # rendered, captures frames, produces MP4
#   tools/selfcheck_foot.sh --headless     # logic/telemetry only, faster
#   SC_SECONDS=40 tools/selfcheck_foot.sh  # bound the run length
set -euo pipefail
cd "$(dirname "$0")/.."

ENGINE="engine/Godot_v4.3-stable_linux.x86_64"
if [ ! -x "$ENGINE" ]; then
	echo "Engine not found. Run tools/fetch_godot.sh first." >&2
	exit 2
fi

VIZ_PY="$(dirname "$0")/../../../tools/viz/viz.py"
FRAMES_DIR="${FRAMES_DIR:-/tmp/neon_delta_foot_frames_$$}"
SCENE="res://Sandbox.tscn"

export GAME_MODE=selfcheck
export SC_SECONDS="${SC_SECONDS:-45}"

if [ "${1:-}" = "--headless" ]; then
	status=0
	"$ENGINE" --headless --path . "$SCENE" || status=$?
else
	export VIZ_CAPTURE=1
	export VIZ_OUT="$FRAMES_DIR"
	export VIZ_INTERVAL="${VIZ_INTERVAL:-0.16}"
	export VIZ_MAX="${VIZ_MAX:-180}"
	status=0
	LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$ENGINE" --path . "$SCENE" \
		--rendering-driver opengl3 --resolution 800x450 || status=$?

	echo
	echo "--- building clip ---"
	python3 "$VIZ_PY" clip "$FRAMES_DIR" --width 640 --fps 24
	echo "--- contact sheet ---"
	python3 "$VIZ_PY" contact "$FRAMES_DIR" --max 12
fi

USERDATA="$HOME/.local/share/godot/app_userdata/NEON DELTA — Gray Box Slice"
echo
echo "Artifacts:"
echo "  report:  $USERDATA/sandbox_selfcheck.json"
echo "  frames:  $FRAMES_DIR"
echo "  clip:    $FRAMES_DIR/clip.mp4"
echo "  contact: $FRAMES_DIR/contact.png"
echo "  path:    $USERDATA/foot_path.csv"
exit $status
