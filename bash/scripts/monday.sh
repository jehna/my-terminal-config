#!/bin/bash --login

# Manually run repetitive tasks (like installing updates). Should be ran on
# every Monday.

# Upgrade everything
brew upgrade                  # Upgraade most Homebrew packages
brew upgrade --cask --greedy  # Upgrade apps that have auto-update feature
softwareupdate -ia            # Mac's own software update
mas upgrade                   # Programmatic App Store update

set -euo pipefail

# Update node
nvm install --lts
nvm install --latest-npm

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

# Update all global NPM packages
npm update --global

# Back up globally installed NPM packages
npm list --global --depth=0 --json > ~/.config/npm/packages.list