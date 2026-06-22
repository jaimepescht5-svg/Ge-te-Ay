# NEON DELTA — task runner. One word per common job. See `make help`.
# All paths are relative to the repo root. Designed so the doc/link checks run
# anywhere, while engine-dependent targets degrade gracefully when Godot is absent.

SHELL := /bin/bash

SLICE_DIR   := prototype/neon-delta-slice
ENGINE      := $(SLICE_DIR)/engine/Godot_v4.3-stable_linux.x86_64

.DEFAULT_GOAL := help

.PHONY: help check docs engine slice selfcheck viz clean

help: ## List all targets
	@echo "NEON DELTA — make targets:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

check: ## THE GATE — doc-link validation + prototype self-checks (exits non-zero on failure)
	@tools/check.sh

docs: ## Validate internal markdown links only (fast, no engine needed)
	@python3 tools/check_links.py

engine: ## One-time: download the pinned Godot 4.3 engine binary
	@$(SLICE_DIR)/tools/fetch_godot.sh

slice: $(ENGINE) ## Play the Godot driving slice yourself (you are the judge of feel)
	@$(ENGINE) --path $(SLICE_DIR)

selfcheck: $(ENGINE) ## Run the driving + on-foot bot self-checks headless (assert invariants)
	@echo "== driving slice ==";  $(SLICE_DIR)/tools/selfcheck.sh --headless
	@echo "== on-foot sandbox =="; $(SLICE_DIR)/tools/selfcheck_foot.sh --headless

viz: $(ENGINE) ## Render the slice headless -> contact sheet (AI) + clip (human)
	@VIZ_GODOT=$(ENGINE) python3 tools/viz/viz.py check \
		--project $(SLICE_DIR) --env GAME_MODE=selfcheck \
		--frames-out /tmp/nd_frames --frames /tmp/nd_frames --gif --width 640

$(ENGINE):
	@echo "Godot engine not found. Run 'make engine' first to download it." >&2
	@exit 2

clean: ## Remove local run artifacts (frames, tmp). Never touches committed files.
	@rm -rf /tmp/nd_frames $(SLICE_DIR)/out
	@echo "cleaned local artifacts"
