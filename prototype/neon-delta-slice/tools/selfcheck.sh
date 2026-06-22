#!/usr/bin/env bash
# Run the autonomous self-observation pass and produce a clip.
#
# The bot drives the slice under Xvfb; VizCapture (tools/viz/capture.gd) writes
# frames; invariants are asserted; viz.py stitches frames into clip.mp4.
# Exits non-zero if any selfcheck invariant fails (CI-gradeable).
#
# Usage:
#   tools/selfcheck.sh                 # rendered, captures frames, produces MP4
#   tools/selfcheck.sh --headless      # logic/telemetry only, no frames or MP4
#   SC_SECONDS=45 tools/selfcheck.sh   # bound the run length
set -euo pipefail
cd "$(dirname "$0")/.."

ENGINE="engine/Godot_v4.3-stable_linux.x86_64"
if [ ! -x "$ENGINE" ]; then
	echo "Engine not found. Run tools/fetch_godot.sh first." >&2
	exit 2
fi

VIZ_PY="$(dirname "$0")/../../../tools/viz/viz.py"
FRAMES_DIR="${FRAMES_DIR:-/tmp/neon_delta_frames_$$}"

export GAME_MODE=selfcheck
export SC_SECONDS="${SC_SECONDS:-300}"

if [ "${1:-}" = "--headless" ]; then
	status=0
	"$ENGINE" --headless --path . || status=$?
else
	export VIZ_CAPTURE=1
	export VIZ_OUT="$FRAMES_DIR"
	export VIZ_INTERVAL="${VIZ_INTERVAL:-0.16}"
	export VIZ_MAX="${VIZ_MAX:-180}"
	status=0
	LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$ENGINE" --path . \
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
echo "  report:  $USERDATA/selfcheck.json"
echo "  frames:  $FRAMES_DIR"
echo "  clip:    $FRAMES_DIR/clip.mp4"
echo "  contact: $FRAMES_DIR/contact.png"
echo "  path:    $USERDATA/path.csv"
exit $status
