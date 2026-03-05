#!/usr/bin/env bash
# Run Claude Code inside a Docker container
# Usage: claud [args...]

set -euo pipefail

IMAGE_NAME="claude-code"
DOCKERFILE_DIR="$HOME/.config/claude/docker"
HASH_FILE="$DOCKERFILE_DIR/.last-build-hash"

# Build the image if it doesn't exist or Dockerfile has changed
current_hash=$(md5 -q "$DOCKERFILE_DIR/Dockerfile")
needs_build=false
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
  needs_build=true
elif [[ ! -f "$HASH_FILE" ]] || [[ "$(cat "$HASH_FILE")" != "$current_hash" ]]; then
  needs_build=true
fi

if $needs_build; then
  echo "Building $IMAGE_NAME image..."
  docker build -t "$IMAGE_NAME" "$DOCKERFILE_DIR"
  echo "$current_hash" > "$HASH_FILE"
fi

MOUNT_DIR="$(pwd)"
WORKDIR="/workspace"

# If inside a git repo, mount the git root and cd to the relative path
if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  relative="${PWD#"$git_root"}"
  MOUNT_DIR="$git_root"
  WORKDIR="/workspace${relative}"
fi

# Ensure .claude.json exists as a file so Docker doesn't create it as a directory
touch "$HOME/.config/claude/.claude.json"

docker run --rm -it \
  -v "$HOME/.config/claude:/home/claude/.claude" \
  -v "$HOME/.config/claude/.claude.json:/home/claude/.claude.json" \
  -v "$MOUNT_DIR:/workspace" \
  -w "$WORKDIR" \
  "$IMAGE_NAME" \
  "$@"
