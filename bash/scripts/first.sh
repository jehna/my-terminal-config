#!/bin/bash
set -euo pipefail

# Get the first (or nth) element of a whitespace separated list
#
# Usage:
# first "a b c"
#
awk -v nth="1" '{print $nth}'