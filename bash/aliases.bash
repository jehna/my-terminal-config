# Dynamic alias loader
# Automatically creates aliases for all .sh files in the scripts/ directory
# The alias name is the filename without the .sh extension

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

if [ -d "$SCRIPTS_DIR" ]; then
    for script in "$SCRIPTS_DIR"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script" .sh)
            alias "$script_name"="$script"
        fi
    done
fi

unset SCRIPTS_DIR