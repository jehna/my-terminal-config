#!/usr/bin/env bash
# Hold music for hammock mode: quiet ambient radio while a long task runs.
# Usage: hold-music.sh start | stop
set -uo pipefail

PLAYLIST_URL="https://somafm.com/groovesalad.pls"
PROCESS_PATTERN="mpg123.*somafm"
BACKGROUND_VOLUME=4000 # out of 32768 — quiet enough that `say` is heard over it

stop_music() {
	pkill -f "$PROCESS_PATTERN" 2>/dev/null
	return 0
}

resolve_stream() {
	curl -sL --max-time 10 -A "Mozilla/5.0" "$PLAYLIST_URL" |
		grep -m1 '^File1=' | cut -d= -f2-
}

start_music() {
	command -v mpg123 >/dev/null || return 0

	local stream
	stream=$(resolve_stream)
	[ -n "$stream" ] || return 0

	stop_music
	mpg123 -q -f "$BACKGROUND_VOLUME" "$stream" >/dev/null 2>&1 &
}

case "${1:-}" in
start) start_music ;;
stop) stop_music ;;
*)
	echo "usage: $(basename "$0") start|stop" >&2
	exit 1
	;;
esac
