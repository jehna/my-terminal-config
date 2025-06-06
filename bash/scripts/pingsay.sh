#!/bin/bash
set -euo pipefail

# Privides an audible cue about the system being online or not
#
ping 8.8.8.8 2>/dev/null | sed -l 's/.*bytes.*/yay/; s/.*timeout.*/nah/' | xargs -I {} say {}