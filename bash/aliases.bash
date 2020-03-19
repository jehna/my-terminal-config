# to_gif
#
# Converts a movie into GIF with the default ffmpeg shipped with MacOS homebrew
#
# Usage:
# to_gif input.mov output.gif
#
to_gif() {
    INPUT=$1
    OUTPUT=${2:-${INPUT%.*}.gif}

    CONVERSION_FILTERS="paletteuse=bayer_scale=2:dither=none:diff_mode=rectangle"

    ffmpeg -i "$INPUT" -vf palettegen=stats_mode=diff pipe:.png |
      ffmpeg -i "$INPUT" -i pipe: -lavfi $CONVERSION_FILTERS -r 18 -gifflags +transdiff "$OUTPUT"
}

