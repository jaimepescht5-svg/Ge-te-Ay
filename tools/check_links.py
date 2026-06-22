#!/usr/bin/env python3
"""Validate internal markdown links across the repo.

Scans every tracked-ish .md file for inline links `[text](target)` and reference
definitions, and fails if a *local* link target doesn't exist. External links
(http/https/mailto), pure anchors (`#foo`), and image/asset links are checked the
same way for local targets. Anchors after a path (`file.md#section`) are stripped
to the path before checking existence.

Stdlib only. Exits non-zero if any link is broken, so it can gate CI.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
# Directories we don't author and shouldn't crawl.
SKIP_DIRS = {".git", "engine", ".godot", "node_modules"}
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
EXTERNAL_RE = re.compile(r"^(https?:|mailto:|tel:|#)")


def md_files() -> list[Path]:
    out = []
    for p in ROOT.rglob("*.md"):
        if any(part in SKIP_DIRS for part in p.relative_to(ROOT).parts):
            continue
        out.append(p)
    return sorted(out)


def check_file(path: Path) -> list[str]:
    problems = []
    text = path.read_text(encoding="utf-8", errors="replace")
    for m in LINK_RE.finditer(text):
        raw = m.group(1).strip()
        # Links can be `path "title"` — drop the optional title.
        target = raw.split()[0] if raw else raw
        if not target or EXTERNAL_RE.match(target):
            continue
        # Strip any anchor; we only verify the file resolves.
        file_part = unquote(target.split("#", 1)[0])
        if not file_part:  # was a pure anchor like (#foo)
            continue
        resolved = (path.parent / file_part).resolve()
        if not resolved.exists():
            rel = path.relative_to(ROOT)
            problems.append(f"{rel}: broken link -> {target}")
    return problems


def main() -> int:
    files = md_files()
    all_problems: list[str] = []
    for f in files:
        all_problems.extend(check_file(f))

    if all_problems:
        print(f"Checked {len(files)} markdown files — found {len(all_problems)} broken link(s):")
        for p in all_problems:
            print(f"  {p}")
        return 1

    print(f"Checked {len(files)} markdown files — all internal links resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
