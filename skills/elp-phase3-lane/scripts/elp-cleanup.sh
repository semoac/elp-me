#!/bin/bash
set -euo pipefail

# ELP Lane Cleanup Script
# Destroys the worktree, branch, and tmux session for a completed lane.
# REQUIRES EXPLICIT AUTHORIZATION — only run AFTER the PR has been integrated.
# Run from the project root (or set ELP_PROJECT_DIR).
# Usage: bash elp-cleanup.sh <issue-number> <description>

PROJECT_DIR="${ELP_PROJECT_DIR:-${PWD}}"
CONFIG_FILE="${PROJECT_DIR}/docs/elp-config.json"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <issue-number> <description>"
    echo "Example: $0 42 auth-jwt-middleware"
    echo ""
    echo "WARNING: Only run AFTER the PR has been integrated. This is irreversible."
    exit 1
fi

ISSUE="$1"
DESCRIPTION="$2"
SAFE_DESC=$(echo "${DESCRIPTION}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9_-')
BRANCH="issue-${ISSUE}-${SAFE_DESC}"
SESSION_NAME="${BRANCH}"

# Read config
WORKTREE_BASE="$HOME/work"
if [ -f "${CONFIG_FILE}" ] && command -v jq >/dev/null 2>&1; then
    WORKTREE_BASE=$(jq -r '.git.worktree_base_dir // "~/work"' "${CONFIG_FILE}")
fi
WORKTREE_BASE="${WORKTREE_BASE/#\~/$HOME}"

PROJECT_NAME=$(basename "${PROJECT_DIR}")
WORKTREE_DIR="${WORKTREE_BASE}/${PROJECT_NAME}.${BRANCH}"

echo "=== ELP Lane Cleanup ==="
echo "Branch:   ${BRANCH}"
echo "Session:  ${SESSION_NAME}"
echo "Worktree: ${WORKTREE_DIR}"
echo ""
echo "WARNING: This action is IRREVERSIBLE."
echo ""
echo "Type the branch name '${BRANCH}' to confirm:"
read -r CONFIRMATION

if [ "${CONFIRMATION}" != "${BRANCH}" ]; then
    echo "Aborted: confirmation did not match."
    exit 1
fi

# Verify branch is merged
echo "Checking if branch is merged..."
if git -C "${PROJECT_DIR}" branch --merged main 2>/dev/null | grep -q "${BRANCH}" || \
   git -C "${PROJECT_DIR}" branch --merged master 2>/dev/null | grep -q "${BRANCH}"; then
    echo "Branch appears merged. Proceeding..."
else
    echo "WARNING: Branch '${BRANCH}' does not appear merged into main/master."
    echo "Type 'YES' to force cleanup anyway:"
    read -r FORCE
    [ "${FORCE}" = "YES" ] || { echo "Aborted."; exit 1; }
fi

# Kill tmux session
if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "Killing tmux session..."
    tmux kill-session -t "${SESSION_NAME}"
else
    echo "Tmux session not found (already closed)."
fi

# Remove worktree
if [ -d "${WORKTREE_DIR}" ]; then
    echo "Removing worktree..."
    git -C "${PROJECT_DIR}" worktree remove "${WORKTREE_DIR}" || \
        echo "Warning: worktree remove failed — remove manually if needed."
else
    echo "Worktree directory not found."
fi

# Delete branch
echo "Deleting branch..."
git -C "${PROJECT_DIR}" branch -D "${BRANCH}" 2>/dev/null || echo "Branch not found or already deleted."

# Clean up temp files
echo "Cleaning up temp files..."
rm -f "/tmp/launch-${ISSUE}.sh"
rm -f "/tmp/wt-claude-prompt-${ISSUE}-${SAFE_DESC}.txt"
rm -f "/tmp/lane-${BRANCH}-builds.tsv"
rm -f "/tmp/lane-${BRANCH}-start.txt"

echo ""
echo "=== Cleanup Complete ==="
echo "Lane '${BRANCH}' removed."
