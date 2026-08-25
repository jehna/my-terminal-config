#!/usr/bin/env bash
# Speak for hammock mode: synthesise first, stop the hold music, then play.
#
# Usage: speak.sh VOICE TEXT [VOICE TEXT ...]
#
# VOICE is a short language tag — fi or en. Full backend voice names work too.
# TEXT may be literal text, or @/path/to/file to read the text from a file
# (use that for anything with apostrophes, quotes or backticks).
#
# Every segment is synthesised to a local file before anything is played, so
# the hold music keeps running through the whole synthesis round trip and stops
# only when the audio is ready. Segments play in the order given.
#
# Backends, tried in order: Google Cloud TTS (Chirp 3: HD, via your gcloud
# login), edge-tts, macOS `say`. HAMMOCK_TTS=google|edge|say pins one.
set -uo pipefail

RATE="${HAMMOCK_RATE:-+150%}"
BACKEND="${HAMMOCK_TTS:-auto}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hammock-speak.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

[ $# -ge 2 ] && [ $(($# % 2)) -eq 0 ] || {
	echo "usage: $(basename "$0") VOICE TEXT [VOICE TEXT ...]" >&2
	exit 1
}

read_text() {
	case "$1" in
	@*) cat "${1#@}" ;;
	*) printf '%s' "$1" ;;
	esac
}

play_file() {
	# afplay first: it is the native macOS player and has no terminal handling
	# to go wrong. mpv needs --no-terminal and a closed stdin, or it treats the
	# immediate EOF as a quit key and cuts the clip off after a fraction of a
	# second.
	if command -v afplay >/dev/null; then
		afplay "$1" </dev/null
	elif command -v mpv >/dev/null; then
		mpv --no-video --no-terminal "$1" </dev/null
	else
		mpg123 -q "$1" </dev/null
	fi
}

stop_music() {
	bash "$SKILL_DIR/hold-music.sh" stop 2>/dev/null
	return 0
}

edge_voice() {
	case "$1" in
	fi | fi-*) echo "${HAMMOCK_EDGE_VOICE_FI:-fi-FI-HarriNeural}" ;;
	*) echo "${HAMMOCK_EDGE_VOICE_EN:-en-US-AndrewNeural}" ;;
	esac
}

# Synthesises to a backend-appropriate format and echoes the file it produced.
# Google gets .wav — its MP3 is a 32 kbps mess on these voices.
synthesise() { # voice text_file out_base -> path on stdout, 0 on success
	local voice="$1" text_file="$2" base="$3"

	if [ "$BACKEND" = google ] || [ "$BACKEND" = auto ]; then
		if bash "$SKILL_DIR/google-tts.sh" "$voice" "$text_file" "$base.wav" 2>"$WORK_DIR/google.err"; then
			echo "$base.wav"
			return 0
		fi
		[ "$BACKEND" = google ] && {
			cat "$WORK_DIR/google.err" >&2
			return 1
		}
	fi

	if [ "$BACKEND" = edge ] || [ "$BACKEND" = auto ]; then
		if uvx --from edge-tts@latest edge-tts \
			--voice "$(edge_voice "$voice")" --rate="$RATE" \
			--file "$text_file" --write-media "$base.mp3" >/dev/null 2>&1 &&
			[ -s "$base.mp3" ]; then
			echo "$base.mp3"
			return 0
		fi
	fi

	return 1 # nothing worked — the `say` fallback happens at playback time
}

# Phase 1 — synthesise everything while the hold music is still playing.
declare -a media=() voices=() texts=()
i=0
while [ $# -gt 0 ]; do
	voice="$1"
	text_file="$WORK_DIR/segment-$i.txt"
	read_text "$2" >"$text_file"
	shift 2

	if out=$(synthesise "$voice" "$text_file" "$WORK_DIR/segment-$i"); then
		media+=("$out")
	else
		media+=("")
	fi
	voices+=("$voice")
	texts+=("$text_file")
	i=$((i + 1))
done

# Phase 2 — audio is ready, so the music can go.
stop_music

# Phase 3 — play in order.
status=0
for n in "${!media[@]}"; do
	if [ -n "${media[$n]}" ]; then
		play_file "${media[$n]}"
	elif command -v say >/dev/null; then
		case "${voices[$n]}" in
		fi-*) say -v Satu -f "${texts[$n]}" ;;
		*) say -f "${texts[$n]}" ;;
		esac
	else
		status=1
	fi
done

exit $status
