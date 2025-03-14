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
    PALETTE="/tmp/palette.png"

    CONVERSION_FILTERS="paletteuse=bayer_scale=2:dither=none:diff_mode=rectangle"

    # Generate palette first
    ffmpeg -i "$INPUT" -vf palettegen=stats_mode=diff "$PALETTE" && \
    # Then use the palette to convert to gif
    ffmpeg -i "$INPUT" -i "$PALETTE" -lavfi $CONVERSION_FILTERS -r 30 -gifflags +transdiff "$OUTPUT"

    # Clean up
    rm "$PALETTE"
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
  softwareupdate -ia            # Mac's own software update
  mas upgrade                   # Programmatic App Store update

  # Back up recently installed apps and plugins
  cursor --list-extensions > ~/.config/cursor/extensions.list                                # Cursor plugins
  brew bundle dump -f --file=~/.config/brew/Brewfile --brews --casks --taps --mas --describe # Brewfile (no cursor plugins)

  # Upgrading gpg needs a restart, so let's do one just in case
  gpgconf --kill all

  # Remove old versions from the cellar
  brew cleanup

  # Clean docker
  DOCKER_RUNNING=$(docker info 2>/dev/null | grep -c running)
  if [ "$DOCKER_RUNNING" -gt 0 ]; then
    yes | docker image prune
    yes | docker container prune
    yes | docker volume prune
    yes | docker system prune
  fi
}

# espresso
#
# Keep mac alive for the execution of a task

alias espresso="caffeinate -sm"

# In case of a new Mac
function configure_new_mac() {
  # Makes sure that you keep connecting to correct beacon with multi beacon systems
  # See: https://www.reddit.com/r/eero/comments/aom1ut/5x_speed_increase_on_macbook_pro_with_a_terminal/
  sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport prefs joinMode=Strongest joinModeFallback=KeepLooking
}

# pingsay
#
# Privides an audible cue about the system being online or not
#
function pingsay() {
  ping 8.8.8.8 2>/dev/null | sed -l 's/.*bytes.*/yay/; s/.*timeout.*/nah/' | xargs -I {} say {}
}

# figsay
# cowsay with filget text
#
function figsay() {
  TEXT="$@"
  COWS=$(cowsay -l | tail -n+2 | awk -F ' ' '{for (i=1; i<=NF; i++) print $i}')
  FIGS=$(ls $(figlet -I2))
  figlet -f "$(echo "$FIGS" | shuf -n 1)" "$TEXT" | cowsay -nf "$(echo "$COWS" | shuf -n 1)"
}

# A fuzzy finder for a subdirectory
#
# Uses git to limit the amount of directories to search, otherwise good luck on
# searching through a node_modules folder.
#
# Usage: cdf
#
function cdf() {
  IS_GIT_INITIALIZED=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$IS_GIT_INITIALIZED" != "true" ]; then
    echo "Not a git repository"
    return
  fi
  GIT_ROOT=$(git rev-parse --show-toplevel)
  GIT_ROOT_RELATIVE="$(grealpath --relative-to="$PWD" "$GIT_ROOT")/"
  SUBDIRS=$(git ls-tree --name-only -d -r HEAD "$GIT_ROOT")
  SUBDIRS_INCLUDING_ROOT=$(echo -e "$GIT_ROOT_RELATIVE\n$SUBDIRS" | grep -v '^./$')
  cd "$(echo "$SUBDIRS_INCLUDING_ROOT" | fzf)" || return
}