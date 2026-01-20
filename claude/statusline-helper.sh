#!/bin/bash
# Cached usage data fetcher for statusline
# Caches API response for 60 seconds

CACHE_FILE="/tmp/claude-statusline-cache"
CACHE_TTL=60

# Check if cache is fresh
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$cache_age" -lt "$CACHE_TTL" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get OAuth token from keychain
creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
if [ -z "$creds" ]; then
    exit 0
fi

token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)

if [ -z "$token" ]; then
    exit 0
fi

# Fetch usage from API
usage=$(curl -s -m 2 -X GET "https://api.anthropic.com/api/oauth/usage" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

# Check if we got a valid response
if [ -z "$usage" ]; then
    exit 0
fi

# Check for errors
if echo "$usage" | jq -e '.error' >/dev/null 2>&1; then
    exit 0
fi

# Parse 5-hour block
five_hour_util=$(echo "$usage" | jq -r '.five_hour.utilization // 0')
if [ "$five_hour_util" = "null" ] || [ -z "$five_hour_util" ]; then
    five_hour_util="0"
fi
five_hour_pct=$(echo "$five_hour_util" | cut -d. -f1)
five_hour_reset=$(echo "$usage" | jq -r '.five_hour.resets_at // empty')

# Calculate time until 5-hour reset
if [ -n "$five_hour_reset" ]; then
    # Parse ISO timestamp - handle both Z and +00:00 formats
    # Example: 2026-01-14T18:04:15.123Z or 2026-01-14T18:04:15+00:00
    iso_time="$five_hour_reset"

    # Remove milliseconds if present: .123Z -> Z or .123+00:00 -> +00:00
    iso_time=$(echo "$iso_time" | sed -E 's/\.[0-9]+(Z|[-+][0-9:]+)$/\1/')

    # Remove colon from timezone (+00:00 -> +0000) for macOS date compatibility
    iso_time=$(echo "$iso_time" | sed -E 's/([-+][0-9]{2}):([0-9]{2})$/\1\2/')

    # Convert Z to +0000 for consistency
    iso_time=$(echo "$iso_time" | sed 's/Z$/+0000/')

    # Parse the timestamp (macOS date command)
    reset_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$iso_time" +%s 2>/dev/null)

    if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt 0 ]; then
        now_epoch=$(date +%s)
        remaining_sec=$((reset_epoch - now_epoch))
        if [ "$remaining_sec" -lt 0 ]; then remaining_sec=0; fi
        hours=$((remaining_sec / 3600))
        mins=$(((remaining_sec % 3600) / 60))
        if [ "$hours" -gt 0 ]; then
            time_str="${hours}h${mins}m"
        else
            time_str="${mins}m"
        fi
    else
        time_str=""
    fi
else
    time_str=""
fi

# Parse 7-day (overall and sonnet-only)
seven_day_util=$(echo "$usage" | jq -r '.seven_day.utilization // 0')
if [ "$seven_day_util" = "null" ] || [ -z "$seven_day_util" ]; then
    seven_day_util="0"
fi
seven_day_pct=$(echo "$seven_day_util" | cut -d. -f1)
seven_day_reset=$(echo "$usage" | jq -r '.seven_day.resets_at // empty')

sonnet_util=$(echo "$usage" | jq -r '.seven_day_sonnet.utilization // empty')
if [ "$sonnet_util" != "null" ] && [ -n "$sonnet_util" ]; then
    sonnet_pct=$(echo "$sonnet_util" | cut -d. -f1)
else
    sonnet_pct=""
fi

# Calculate time until weekly reset
wk_time_str=""
if [ -n "$seven_day_reset" ]; then
    # Parse ISO timestamp - handle both Z and +00:00 formats
    wk_iso_time="$seven_day_reset"

    # Remove milliseconds if present
    wk_iso_time=$(echo "$wk_iso_time" | sed -E 's/\.[0-9]+(Z|[-+][0-9:]+)$/\1/')

    # Remove colon from timezone (+00:00 -> +0000) for macOS date compatibility
    wk_iso_time=$(echo "$wk_iso_time" | sed -E 's/([-+][0-9]{2}):([0-9]{2})$/\1\2/')

    # Convert Z to +0000 for consistency
    wk_iso_time=$(echo "$wk_iso_time" | sed 's/Z$/+0000/')

    # Parse the timestamp (macOS date command)
    wk_reset_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$wk_iso_time" +%s 2>/dev/null)

    if [ -n "$wk_reset_epoch" ] && [ "$wk_reset_epoch" -gt 0 ]; then
        wk_now_epoch=$(date +%s)
        wk_remaining_sec=$((wk_reset_epoch - wk_now_epoch))
        if [ "$wk_remaining_sec" -gt 0 ]; then
            wk_days=$((wk_remaining_sec / 86400))
            wk_hours=$(((wk_remaining_sec % 86400) / 3600))
            if [ "$wk_days" -gt 0 ]; then
                wk_time_str="${wk_days}d${wk_hours}h"
            else
                wk_time_str="${wk_hours}h"
            fi
        fi
    fi
fi

# Colors (using $'...' for escape sequences)
dim=$'\033[2m'       # dim for labels
gray=$'\033[90m'     # gray for values
reset=$'\033[0m'

# Build result: "5h 14% ↻2h 12m ∙ 7d 28%/1% ↻3d 5h"
# Ensure we have valid percentages
if [ -z "$five_hour_pct" ]; then five_hour_pct="0"; fi
if [ -z "$seven_day_pct" ]; then seven_day_pct="0"; fi

if [ -n "$time_str" ]; then
    blk_part="${dim}5h${reset} ${gray}${five_hour_pct}%${reset} ${gray}↻${time_str}${reset}"
else
    blk_part="${dim}5h${reset} ${gray}${five_hour_pct}%${reset}"
fi

# Weekly with optional sonnet and reset time
if [ -n "$sonnet_pct" ]; then
    wk_part="${dim}7d${reset} ${gray}${seven_day_pct}%/${sonnet_pct}%${reset}"
else
    wk_part="${dim}7d${reset} ${gray}${seven_day_pct}%${reset}"
fi
if [ -n "$wk_time_str" ]; then
    wk_part="${wk_part} ${gray}↻${wk_time_str}${reset}"
fi

result="${blk_part} ${dim}∙${reset} ${wk_part}"

# Cache result
echo "$result" > "$CACHE_FILE"
echo "$result"
