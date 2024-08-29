#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide a commit hash with 'git squash <commit-hash>'"
  exit 1
fi;

COMMIT_HASH="$(git rev-parse "$1")"
REST_OF_ARGS=("${@:2}")

GIT_EDITOR=: git commit  --no-edit --squash "$COMMIT_HASH" "${REST_OF_ARGS[@]}"
GIT_EDITOR=: git rebase --autosquash --autostash -i "$COMMIT_HASH^"