#!/usr/bin/env bash
# Umbrella verification for NEON DELTA — the gate that `make check` runs.
#
# It always validates internal doc links (works anywhere, no engine needed), and
# runs the prototype self-checks when the Godot engine has been fetched. Each
# self-check asserts FLOORS only (physics stable, completable, sane loads) — it
# never claims the result is *good*. Delight stays a human's call (see CLAUDE.md).
#
# Exits non-zero if any check fails, so it works as a CI gate.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
section() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()      { printf '  \033[32mPASS\033[0m %s\n' "$1"; }
bad()     { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }
skip()    { printf '  \033[33mSKIP\033[0m %s\n' "$1"; }

# 1) Internal markdown links --------------------------------------------------
section "doc links"
if python3 tools/check_links.py; then
	ok "internal markdown links resolve"
else
	bad "broken internal markdown links (see above)"
fi

# 2) Prototype self-checks (only if the engine is present) --------------------
ENGINE="prototype/neon-delta-slice/engine/Godot_v4.3-stable_linux.x86_64"
section "prototype self-checks"
if [ -x "$ENGINE" ]; then
	if prototype/neon-delta-slice/tools/selfcheck.sh --headless; then
		ok "open-world slice invariants (driving + on-foot + heat)"
	else
		bad "open-world slice self-check"
	fi
else
	skip "Godot engine not fetched — run 'make engine' to enable engine checks"
fi

section "result"
if [ "$fail" -eq 0 ]; then
	printf '\033[32mALL CHECKS PASSED\033[0m\n'
else
	printf '\033[31mCHECKS FAILED\033[0m\n'
fi
exit "$fail"
