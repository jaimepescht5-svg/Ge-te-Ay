#!/usr/bin/env bash
# Fetch the pinned Godot engine binary into ./engine/ (gitignored).
# Godot is a real, external dependency — we do not vendor a 100 MB binary in the
# design repo. This pins the exact version the slice was built and tuned against.
set -euo pipefail

GODOT_VERSION="4.3-stable"
GODOT_FILE="Godot_v4.3-stable_linux.x86_64"
URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_FILE}.zip"

cd "$(dirname "$0")/.."
mkdir -p engine
if [ -x "engine/${GODOT_FILE}" ]; then
	echo "Godot already present: engine/${GODOT_FILE}"
	exit 0
fi
echo "Downloading Godot ${GODOT_VERSION}..."
curl -sL -o engine/godot.zip "$URL"
( cd engine && unzip -o -q godot.zip && rm -f godot.zip )
chmod +x "engine/${GODOT_FILE}"
echo "Installed engine/${GODOT_FILE}"
