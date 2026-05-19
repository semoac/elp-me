#!/bin/bash
set -euo pipefail

# ELP Lane Launch Script
# Launches a lane in an isolated git worktree with tmux session.
# Run from the project root (or set ELP_PROJECT_DIR).
# Usage: bash elp-launch.sh <issue-number> <description> [brief-file]

PROJECT_DIR="${ELP_PROJECT_DIR:-${PWD}}"
CONFIG_FILE="${PROJECT_DIR}/docs/elp-config.json"

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <issue-number> <description> [brief-file]"
    echo "Example: $0 42 auth-jwt-middleware"
    echo "         $0 42 auth-jwt-middleware /path/to/custom-brief.txt"
    exit 1
fi

ISSUE="$1"
DESCRIPTION="$2"
BRIEF_FILE="${3:-}"

# Normalize description for branch/session names
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
BRIEF_DIR="/tmp"
LAUNCH_DIR="/tmp"

mkdir -p "${WORKTREE_BASE}"

# Guard: session must not exist
if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "Error: tmux session '${SESSION_NAME}' already exists."
    echo "Use elp-monitor.sh to check its status, or elp-cleanup.sh after integration."
    exit 1
fi

# Guard: worktree must not exist
if [ -d "${WORKTREE_DIR}" ]; then
    echo "Error: worktree '${WORKTREE_DIR}' already exists."
    exit 1
fi

# Guard: branch must not exist
if git -C "${PROJECT_DIR}" branch --list "${BRANCH}" | grep -q "${BRANCH}"; then
    echo "Error: branch '${BRANCH}' already exists."
    exit 1
fi

# Determine brief file path
if [ -z "${BRIEF_FILE}" ]; then
    BRIEF_PATH="${BRIEF_DIR}/wt-claude-prompt-${ISSUE}-${SAFE_DESC}.txt"
else
    BRIEF_PATH="${BRIEF_FILE}"
fi

if [ ! -f "${BRIEF_PATH}" ]; then
    echo "Error: Brief not found at ${BRIEF_PATH}"
    echo "Generate a brief first using the elp-phase2-brief skill."
    exit 1
fi

echo "=== Launching ELP Lane ==="
echo "Issue:        ${ISSUE}"
echo "Description:  ${DESCRIPTION}"
echo "Branch:       ${BRANCH}"
echo "Worktree:     ${WORKTREE_DIR}"
echo "Session:      ${SESSION_NAME}"
echo "Brief:        ${BRIEF_PATH}"

# Create worktree + branch
echo "Creating git worktree..."
git -C "${PROJECT_DIR}" worktree add -b "${BRANCH}" "${WORKTREE_DIR}"

# Write launch script
LAUNCH_SCRIPT="${LAUNCH_DIR}/launch-${ISSUE}.sh"
cat > "${LAUNCH_SCRIPT}" << LAUNCHEOF
#!/bin/bash
set -euo pipefail
cd "${WORKTREE_DIR}"
export LANE="${BRANCH}"
export LANE_ISSUE="${ISSUE}"
export LANE_DESCRIPTION="${DESCRIPTION}"
export LANE_WORKTREE="${WORKTREE_DIR}"
export LANE_START_TIME=\$(date -Iseconds)

# Initialize TSV logging
echo -e "timestamp\tcmd\toutcome\telapsed_s" > /tmp/lane-\${LANE}-builds.tsv
date -Iseconds > /tmp/lane-\${LANE}-start.txt

exec claude "\$(cat "${BRIEF_PATH}")"
LAUNCHEOF
chmod +x "${LAUNCH_SCRIPT}"

# Launch tmux session
echo "Creating tmux session..."
tmux new-session -d -s "${SESSION_NAME}" "bash '${LAUNCH_SCRIPT}'"

echo ""
echo "=== Lane Launched ==="
echo "Monitor: bash elp-monitor.sh ${SESSION_NAME}"
echo "Attach:  tmux attach -t ${SESSION_NAME}"
echo ""
echo "WARNING: Do NOT cleanup until PR is integrated."
