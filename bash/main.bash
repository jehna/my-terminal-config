# Bash configs
source "$(dirname $BASH_SOURCE)/bash.bash"

# Enable git autocompletion
source "$(dirname $BASH_SOURCE)/git-completion.bash"

# Android development specific configs
source "$(dirname $BASH_SOURCE)/android.bash"

# Fastlane specific configs
source "$(dirname $BASH_SOURCE)/fastlane.bash"

# NVM specific configs
source "$(dirname $BASH_SOURCE)/nvm.bash"

# Java specific configs
source "$(dirname $BASH_SOURCE)/java.bash"

# Ruby specific configs
source "$(dirname $BASH_SOURCE)/ruby.bash"

# Aliases
source "$(dirname $BASH_SOURCE)/aliases.bash"

# Homebrew
source "$(dirname $BASH_SOURCE)/homebrew.bash"

# Enable gnupg
source "$(dirname $BASH_SOURCE)/gnupg.bash"

# Flutter configs
source "$(dirname $BASH_SOURCE)/flutter.bash"
