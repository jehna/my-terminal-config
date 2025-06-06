#!/bin/bash
set -euo pipefail

# Converts a movie into GIF with the default ffmpeg shipped with MacOS homebrew
#
# Usage:
# to_gif input.mov output.gif
#
INPUT=$1
OUTPUT=${2:-${INPUT%.*}.gif}
PALETTE="/tmp/palette.png"

CONVERSION_FILTERS="paletteuse=bayer_scale=2:dither=none:diff_mode=rectangle"

# Generate palette first
ffmpeg -i "$INPUT" -vf palettegen=stats_mode=diff "$PALETTE" && \
# Then use the palette to convert to gif
ffmpeg -i "$INPUT" -i "$PALETTE" -lavfi $CONVERSION_FILTERS -r 30 -gifflags +transdiff "$OUTPUT"

# Clean up
rm "$PALETTE"