#!/usr/bin/env bash
# SessionStart hook — runs when a Claude Code session opens (including web/cloud).
# It prints a short readiness report to stdout, which the harness feeds to the
# agent as context, so every agent immediately knows: what this repo is, where the
# rules live, and which rigs it can actually run in this environment.
#
# Keep it FAST and non-fatal: always exit 0 so a session never fails to start.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0

echo "── NEON DELTA (Ge-te-Ay) — AI-built open-world crime game ──"
echo "Read first: CLAUDE.md (rules + commands) · CONTRIBUTING.md (workflow) · docs/00-index.md"
echo "The gate before every commit: make check"
echo

have() { command -v "$1" >/dev/null 2>&1 && echo "  yes" || echo "  NO"; }
ENGINE="prototype/neon-delta-slice/engine/Godot_v4.3-stable_linux.x86_64"

printf "Environment:\n"
printf "  python3 (web server + checks): %s\n" "$(command -v python3 >/dev/null 2>&1 && python3 --version 2>&1 || echo missing)"
printf "  xvfb-run (headless render):   %s\n" "$(command -v xvfb-run >/dev/null 2>&1 && echo present || echo missing)"
if [ -x "$ENGINE" ]; then
	printf "  Godot 4.3 engine:             present — engine self-checks available\n"
else
	printf "  Godot 4.3 engine:             not fetched — run 'make engine' for engine self-checks\n"
fi
echo
echo "Reminder: you own correctness + playability; a HUMAN owns delight (the taste wall, docs/24)."
exit 0
