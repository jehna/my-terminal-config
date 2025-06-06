#!/bin/bash
set -euo pipefail

# cowsay with filget text
#
TEXT="$@"
COWS=$(cowsay -l | tail -n+2 | awk -F ' ' '{for (i=1; i<=NF; i++) print $i}')
FIGS=$(ls $(figlet -I2))
figlet -f "$(echo "$FIGS" | shuf -n 1)" "$TEXT" | cowsay -nf "$(echo "$COWS" | shuf -n 1)"