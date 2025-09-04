# A fuzzy finder for a subdirectory
#
# Uses git to limit the amount of directories to search, otherwise good luck on
# searching through a node_modules folder.
#
# Usage: cdf
#
IS_GIT_INITIALIZED=$(git rev-parse --is-inside-work-tree 2>/dev/null)
if [ "$IS_GIT_INITIALIZED" != "true" ]; then
  echo "Not a git repository"
  exit 1
fi
GIT_ROOT=$(git rev-parse --show-toplevel)
GIT_ROOT_RELATIVE="$(grealpath --relative-to="$PWD" "$GIT_ROOT")/"
SUBDIRS=$(git ls-tree --name-only -d -r HEAD "$GIT_ROOT" | grep -v '^./$')
SUBDIRS_INCLUDING_ROOT=$(echo -e "$GIT_ROOT_RELATIVE\n$SUBDIRS")
cd "$(echo "$SUBDIRS_INCLUDING_ROOT" | fzf)" || exit 1