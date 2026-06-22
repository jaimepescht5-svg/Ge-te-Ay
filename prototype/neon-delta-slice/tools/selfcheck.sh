#!/usr/bin/env bash
# Run the autonomous self-observation pass: the bot drives the slice, the engine
# captures frames + telemetry, invariants are asserted, and the process exits
# non-zero if any check fails (so this works as a CI gate).
#
# Headless-with-rendering is achieved via Xvfb + Mesa software GL, so it runs on
# a machine with no GPU/display. Pass --headless to skip rendering entirely
# (faster; logic/telemetry only, no screenshots).
#
# Usage:
#   tools/selfcheck.sh                 # rendered, captures frames
#   tools/selfcheck.sh --headless      # logic only, no frames
#   SC_SECONDS=45 tools/selfcheck.sh   # bound the run length
set -euo pipefail
cd "$(dirname "$0")/.."

ENGINE="engine/Godot_v4.3-stable_linux.x86_64"
if [ ! -x "$ENGINE" ]; then
	echo "Engine not found. Run tools/fetch_godot.sh first." >&2
	exit 2
fi

export GAME_MODE=selfcheck
export SC_SECONDS="${SC_SECONDS:-140}"

if [ "${1:-}" = "--headless" ]; then
	"$ENGINE" --headless --path .
else
	LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a "$ENGINE" --path . \
		--rendering-driver opengl3 --resolution 800x450
fi
status=$?

USERDATA="$HOME/.local/share/godot/app_userdata/NEON DELTA — Gray Box Slice"
echo
echo "Artifacts:"
echo "  report:  $USERDATA/selfcheck.json"
echo "  frames:  $USERDATA/frames/"
echo "  path:    $USERDATA/path.csv"
echo "Top-down plot (needs Pillow):"
echo "  python3 tools/plot_run.py \"$USERDATA\""
exit $status
