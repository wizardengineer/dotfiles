#!/bin/bash
# Read JSON from stdin
json=$(cat)
# Extract values using jq or fallback to sed
if command -v jq &> /dev/null; then
    cost=$(echo "$json" | jq -r '.cost.total_cost_usd // 0' | xargs printf "%.3f")
    lines_added=$(echo "$json" | jq -r '.cost.total_lines_added // 0')
    lines_removed=$(echo "$json" | jq -r '.cost.total_lines_removed // 0')
    model_name=$(echo "$json" | jq -r '.model.display_name // "Unknown Model"')
    current_dir=$(echo "$json" | jq -r '.workspace.current_dir // "unknown"')
    
    # Optional: Apply smart truncation if path is too long
    # Uncomment the following lines to enable smart truncation:
    # if [ ${#current_dir} -gt 50 ]; then
    #     current_dir="$(echo "$current_dir" | cut -c1-20)...$(echo "$current_dir" | awk -F/ '{print "/"$(NF-1)"/"$NF}')"
    # fi
else
    # Fallback to sed/grep if jq not available
    cost=$(echo "$json" | grep -o '"total_cost_usd":[0-9.]*' | cut -d: -f2 | xargs printf "%.3f" 2>/dev/null || echo "0")
    lines_added=$(echo "$json" | grep -o '"total_lines_added":[0-9]*' | cut -d: -f2 || echo "0")
    lines_removed=$(echo "$json" | grep -o '"total_lines_removed":[0-9]*' | cut -d: -f2 || echo "0")
    model_name=$(echo "$json" | grep -o '"display_name":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "Unknown Model")
    current_dir=$(echo "$json" | grep -o '"current_dir":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
fi
# Get git info
git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
repo_name=""
repo_path_display=""
if [ -n "$git_root" ]; then
    # Get repository name from git root directory
    repo_name=$(basename "$git_root")
    
    # Get relative path from git root to current directory
    if [ "$current_dir" = "$git_root" ]; then
        # At repo root
        repo_path_display="[$repo_name]"
    else
        # In a subdirectory - get relative path
        relative_path=$(echo "$current_dir" | sed "s|^$git_root/||")
        repo_path_display="[$repo_name]/$relative_path"
    fi
else
    # Not in a git repo - fallback to directory name
    repo_path_display="$(basename "$current_dir")"
fi
# Color definitions
GREY="\033[2;37m"    # Dim grey
GREEN="\033[32m"     # Green for added lines
RED="\033[31m"       # Red for removed lines
RESET="\033[0m"      # Reset colors
# Format the status line: [Model $cost] [repo-name]/path (branch) +added/-removed
printf "${GREY}[${model_name} \$${cost}] ${repo_path_display} (${git_branch}) ${GREEN}+${lines_added}${GREY}/${RED}-${lines_removed}${RESET}"
