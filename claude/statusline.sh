#!/bin/bash
# Main statusline script with color support

# ═══════════════════════════════════════════════════════════════
# Color definitions - edit these to customize colors
# ═══════════════════════════════════════════════════════════════
dim=$'\033[2m'       # dim for labels
gray=$'\033[90m'     # gray for values
reset=$'\033[0m'     # reset all formatting

# ═══════════════════════════════════════════════════════════════
# Helper functions for colored output
# ═══════════════════════════════════════════════════════════════
label() { echo -n "${dim}$1${reset}"; }    # dim label
value() { echo -n "${gray}$1${reset}"; }   # gray value
sep() { echo -n "${dim} ∙ ${reset}"; }     # separator

# Shortcuts
d=$dim
v=$gray
r=$reset

# Read input
input=$(cat)

# Parse model
model_full=$(echo "$input" | jq -r '.model.display_name')
model_short=$(echo "$model_full" | sed -E 's/Claude (Opus|Sonnet|Haiku) ([0-9.]+)/\1 \2/')

# Parse directory
dir=$(echo "$input" | jq -r '.workspace.current_dir')

# Parse context
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ] && [ -n "$usage" ]; then
    current=$(echo "$usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
    size=$(echo "$input" | jq '.context_window.context_window_size // 1')
    if [ "$size" -gt 0 ] 2>/dev/null; then
        ctx_pct=$((current * 100 / size))
    else
        ctx_pct=0
    fi
else
    ctx_pct=0
fi
ctx_info="${d}ctx${r} ${v}${ctx_pct}%${r}"

# Get quota info from helper
blk_info=$(~/.claude/statusline-helper.sh 2>/dev/null)
# Debug: uncomment next line to see if helper is being called
if [ -z "$blk_info" ]; then blk_info="${d}[no quota data]${r}"; fi

# Git info
git_root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
    dir_display=$(basename "$git_root")
    branch=$(git -C "$dir" -c core.useReplaceRefs=false branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        dirty=""
        if ! git -C "$dir" -c core.useReplaceRefs=false diff-index --quiet HEAD -- 2>/dev/null; then
            dirty="*"
        fi
        ahead_behind=""
        upstream=$(git -C "$dir" -c core.useReplaceRefs=false rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$dir" -c core.useReplaceRefs=false rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
            behind=$(git -C "$dir" -c core.useReplaceRefs=false rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
                ahead_behind=" ↑${ahead}↓${behind}"
            fi
        fi
        untracked_count=$(git -C "$dir" -c core.useReplaceRefs=false ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        untracked=""
        if [ "$untracked_count" -gt 0 ]; then
            untracked=" +${untracked_count}"
        fi
        git_info="${d}(${r}${v}${branch}${dirty}${ahead_behind}${untracked}${r}${d})${r}"
    else
        git_info=""
    fi
else
    dir_display=$(echo "$dir" | sed "s|^$HOME|~|")
    git_info=""
fi

# Separators
dot="${d} ∙ ${r}"
bar="${d} | ${r}"

# Use full path with ~ for home
path_display=$(echo "$dir" | sed "s|^$HOME|~|")

# Output (start with reset to normalize color state)
if [ -n "$blk_info" ]; then
    printf "${r}%s%s%s%s%s%s%s%s" "${v}${model_short}${r}" "$dot" "$ctx_info" "$bar" "$blk_info"
else
    printf "${r}%s%s%s%s%s%s" "${v}${model_short}${r}" "$dot" "$ctx_info"
fi
