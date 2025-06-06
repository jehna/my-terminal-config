#!/bin/bash
set -euo pipefail

# In case of a new Mac
# Makes sure that you keep connecting to correct beacon with multi beacon systems
# See: https://www.reddit.com/r/eero/comments/aom1ut/5x_speed_increase_on_macbook_pro_with_a_terminal/
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport prefs joinMode=Strongest joinModeFallback=KeepLooking