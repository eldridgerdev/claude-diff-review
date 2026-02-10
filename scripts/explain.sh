#!/bin/bash
#
# explain.sh — Generate an AI-powered explanation of a diff
#
# Usage: explain.sh <diff_file> <display_path>
#

set -euo pipefail

DIFF_FILE="${1:?Usage: explain.sh <diff_file> <display_path>}"
DISPLAY_PATH="${2:?Usage: explain.sh <diff_file> <display_path>}"

spin() {
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    tput civis
    while true; do
        printf "\r  %s Generating explanation for %s..." \
            "${frames[$i]}" "$DISPLAY_PATH"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.08
    done
}

spin &
SPIN_PID=$!
trap 'kill $SPIN_PID 2>/dev/null; tput cnorm' EXIT

explanation=$(claude -p \
    "Explain these code changes concisely. What is being changed and why?" \
    < "$DIFF_FILE" 2>/dev/null)

kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
tput cnorm
printf "\r\033[K"

echo ""
echo "$explanation"
echo ""
read -p "  Press Enter to return to review..."
