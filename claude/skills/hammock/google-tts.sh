#!/usr/bin/env bash
# Google Cloud Text-to-Speech (Chirp 3: HD) — synthesise one text file to audio.
#
# Usage: google-tts.sh VOICE TEXT_FILE OUT_FILE
#
# VOICE is either a short tag (fi, en) or a full Chirp 3 voice name such as
# fi-FI-Chirp3-HD-Charon.
#
# The encoding comes from OUT_FILE's extension. Prefer .wav: the API gives MP3
# only at 32 kbps, which audibly mangles these voices. Chirp 3 renders at
# 24 kHz, so .wav is that rate, uncompressed, with no artefacts.
#
# Auth is your gcloud login — no API key is stored anywhere:
#   gcloud auth login
#   gcloud config set project YOUR_PROJECT
#   gcloud services enable texttospeech.googleapis.com
#
# Overrides:
#   GOOGLE_TTS_PROJECT       billing/quota project (default: gcloud's)
#   GOOGLE_TTS_ACCESS_TOKEN  pre-fetched OAuth token (default: gcloud's)
#   HAMMOCK_VOICE_FI / _EN   voice names for the short tags
#   HAMMOCK_RATE_GOOGLE      speaking rate, 0.25–2.0 (default 1.6)
set -uo pipefail

ENDPOINT="https://texttospeech.googleapis.com/v1/text:synthesize"
VOICE_FI="${HAMMOCK_VOICE_FI:-fi-FI-Chirp3-HD-Leda}"
VOICE_EN="${HAMMOCK_VOICE_EN:-en-US-Chirp3-HD-Leda}"
RATE="${HAMMOCK_RATE_GOOGLE:-1.6}" # Chirp 3 caps at 2.0

[ $# -eq 3 ] || {
	echo "usage: $(basename "$0") VOICE TEXT_FILE OUT_FILE" >&2
	exit 2
}
voice="$1" text_file="$2" out_file="$3"

case "$voice" in
fi | fi-FI) voice="$VOICE_FI" ;;
en | en-US) voice="$VOICE_EN" ;;
*Chirp3*) ;;                    # already a full Chirp 3 voice name
fi-*) voice="$VOICE_FI" ;;      # legacy edge-tts name, e.g. fi-FI-HarriNeural
en-*) voice="$VOICE_EN" ;;
esac
language_code="${voice%%-Chirp3*}"

case "$out_file" in
*.wav) encoding=LINEAR16 sample_rate=24000 ;; # Chirp 3's native rate
*.ogg) encoding=OGG_OPUS sample_rate=48000 ;;
*.mp3) encoding=MP3 sample_rate=24000 ;;
*)
	echo "google-tts: unknown output extension in '$out_file'" >&2
	exit 2
	;;
esac

token="${GOOGLE_TTS_ACCESS_TOKEN:-$(gcloud auth print-access-token 2>/dev/null)}"
[ -n "$token" ] || {
	echo "google-tts: no gcloud access token — run 'gcloud auth login'" >&2
	exit 3
}
project="${GOOGLE_TTS_PROJECT:-$(gcloud config get-value project 2>/dev/null)}"
[ "$project" = "(unset)" ] && project=""

body=$(jq -n \
	--rawfile text "$text_file" \
	--arg voice "$voice" \
	--arg lang "$language_code" \
	--argjson rate "$RATE" \
	--arg encoding "$encoding" \
	--argjson sample_rate "$sample_rate" \
	'{input: {text: $text},
	  voice: {languageCode: $lang, name: $voice},
	  audioConfig: {audioEncoding: $encoding,
	                sampleRateHertz: $sample_rate,
	                speakingRate: $rate}}') || exit 4

declare -a headers=(-H "Authorization: Bearer $token" -H "Content-Type: application/json")
[ -n "$project" ] && headers+=(-H "x-goog-user-project: $project")

response=$(curl -sS --max-time 60 -X POST "${headers[@]}" -d "$body" "$ENDPOINT") || exit 5

audio=$(printf '%s' "$response" | jq -r '.audioContent // empty')
[ -n "$audio" ] || {
	echo "google-tts: $(printf '%s' "$response" | jq -r '.error.message // .' | head -3)" >&2
	exit 6
}

printf '%s' "$audio" | base64 -d >"$out_file" || exit 7
[ -s "$out_file" ] || exit 8
