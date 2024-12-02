# Get the directory of the current script
DIR="$(dirname "${BASH_SOURCE[0]}")"

# Loop through all .bash files in the directory
for file in "$DIR"/*.bash; do
    # Exclude the main.bash file
    if [[ "$file" != "$DIR/main.bash" ]]; then
        # shellcheck disable=SC1090
        source "$file"
    fi
done