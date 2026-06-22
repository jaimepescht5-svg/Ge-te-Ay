#!/usr/bin/env bash
# Autonomous self-check for the on-foot "verbs" sandbox (Sandbox.tscn), the
# counterpart to tools/selfcheck.sh for the driving slice. The foot-bot walks a
# waypoint patrol; invariants are asserted; the process exits non-zero on any
# failure (CI-gradeable).
#
#   tools/selfcheck_foot.sh                # rendered (Xvfb + software GL), frames
#   tools/selfcheck_foot.sh --headless     # logic/telemetry only, faster
#   SC_SECONDS=40 tools/selfcheck_foot.sh  # bound the run length
set -euo pipefail
cd "$(dirname "$0")/.."

ENGINE="engine/Godot_v4.3-stable_linux.x86_64"
if [ ! -x "$ENGINE" ]; then
	echo "Engine not found. Run tools/fetch_godot.sh first." >&2
	exit 2
fi

export GAME_MODE=selfcheck
export SC_SECONDS="${SC_SECONDS:-45}"
SCENE="res://Sandbox.tscn"

if [ "${1:-}" = "--headless" ]; then
	"$ENGINE" --headless --path . "$SCENE"
else
	LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$ENGINE" --path . "$SCENE" \
		--rendering-driver opengl3 --resolution 800x450
fi
status=$?

USERDATA="$HOME/.local/share/godot/app_userdata/NEON DELTA — Gray Box Slice"
echo
echo "Artifacts:"
echo "  report:  $USERDATA/sandbox_selfcheck.json"
echo "  frames:  $USERDATA/frames_foot/"
echo "  path:    $USERDATA/foot_path.csv"
exit $status
