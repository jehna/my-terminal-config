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

# find_fucker
#
# Finds the fucker that's keeping your port as a hostage
#
# Usage:
# find_fucker 5000
#
function find_fucker() {
  lsof -nP "-iTCP:$1" | grep LISTEN
}

# monday
#
# Manually run repetitive tasks (like installing updates). Should be ran on
# every Monday.

function monday() {
  # Upgrade everything
  brew upgrade                  # Upgraade most Homebrew packages
  brew upgrade --cask --greedy  # Upgrade apps that have auto-update feature
  brew services restart redis   # Redis needs a manual restart after `brew upgrade`
  softwareupdate -ia            # Mac's own software update
  mas upgrade                   # Programmatic App Store update

  # Back up recently installed apps and plugins
  code --list-extensions > ~/.config/vscode/extensions.list # VSConde plugins
  brew bundle dump -f --file=~/.config/brew/Brewfile        # Brewfile

  # Upgrading gpg needs a restart, so let's do one just in case
  gpgconf --kill all
}

# espresso
#
# Keep mac alive for the execution of a task

alias espresso="caffeinate -sm"