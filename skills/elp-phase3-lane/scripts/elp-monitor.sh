#!/bin/bash
set -euo pipefail

# ELP Lane Monitor Script
# Run from anywhere. Usage: bash elp-monitor.sh [session-name]

if [ $# -eq 0 ]; then
    echo "=== Active ELP Lanes ==="
    tmux list-sessions 2>/dev/null | grep -E "^issue-" || echo "No active lanes found."
    echo ""
    echo "Usage: $0 <session-name>"
    echo "       $0 issue-42-auth-jwt"
    exit 0
fi

SESSION_NAME="$1"

echo "=== Lane Status: ${SESSION_NAME} ==="

if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "Error: Session '${SESSION_NAME}' not found."
    exit 1
fi

echo "Session: ACTIVE"
echo ""
echo "Recent output (last 30 lines):"
echo "---"
tmux capture-pane -t "${SESSION_NAME}" -p | tail -30
echo "---"
echo ""
echo "Commands:"
echo "  Attach:       tmux attach -t ${SESSION_NAME}"
echo "  Send keys:    tmux send-keys -t ${SESSION_NAME} 'your-message' Enter"
echo "  Full capture: tmux capture-pane -t ${SESSION_NAME} -p > output.txt"
