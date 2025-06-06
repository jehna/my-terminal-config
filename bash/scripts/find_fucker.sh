#!/bin/bash
set -euo pipefail

# Finds the fucker that's keeping your port as a hostage
#
# Usage:
# find_fucker 5000
#
lsof -nP "-iTCP:$1" | grep LISTEN