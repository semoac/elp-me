#!/bin/bash
set -euo pipefail

# ELP Setup Script
# Run from the project root to configure it for Empirical Lane Parallelism.
# Usage: bash elp-setup.sh [project-root]

PROJECT_DIR="${ELP_PROJECT_DIR:-${1:-${PWD}}}"
CONFIG_FILE="${PROJECT_DIR}/docs/elp-config.json"

echo "=== ELP Project Setup ==="
echo "Project dir: ${PROJECT_DIR}"

# Check dependencies
command -v git  >/dev/null 2>&1 || { echo "Error: git is required";  exit 1; }
command -v tmux >/dev/null 2>&1 || { echo "Error: tmux is required"; exit 1; }
command -v gh   >/dev/null 2>&1 || echo "Warning: gh (GitHub CLI) is recommended."

# Create directory structure
echo "Creating directory structure..."
mkdir -p "${PROJECT_DIR}/docs/lane-experiences"
mkdir -p "${PROJECT_DIR}/docs/phase0-audits"
mkdir -p "${PROJECT_DIR}/docs/honesty-targets"
mkdir -p "${PROJECT_DIR}/scripts"
mkdir -p "${PROJECT_DIR}/templates"

# Create default config if missing
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Creating default config at ${CONFIG_FILE}..."
    cat > "${CONFIG_FILE}" << 'DEFAULTEOF'
{
  "project": {
    "name": "",
    "description": ""
  },
  "git": {
    "repo_url": "",
    "default_branch": "main",
    "worktree_base_dir": "~/work",
    "remote_name": "origin"
  },
  "github": {
    "owner": "",
    "repo": "",
    "labels": {
      "lane": "elp-lane",
      "audit": "elp-audit",
      "retro": "elp-retro",
      "bug": "bug",
      "feature": "feature"
    }
  },
  "agent": {
    "subagent_model": "haiku",
    "autonomous_mode": true,
    "stop_and_report": true
  },
  "elp": {
    "tmux_prefix": "elp",
    "brief_dir": "/tmp",
    "launch_script_dir": "/tmp",
    "tsv_dir": "/tmp",
    "retros_dir": "docs/lane-experiences",
    "audits_dir": "docs/phase0-audits",
    "honesty_targets_dir": "docs/honesty-targets",
    "principles_file": "docs/principles.md",
    "vision_file": "docs/vision.md",
    "design_file": "docs/design.md",
    "glossary_file": "docs/glossary.md",
    "conventional_commits": true,
    "auto_merge_on_green": true,
    "required_local_checks": ["test", "lint"]
  }
}
DEFAULTEOF
fi

# Read worktree base from config or default
WORKTREE_BASE="$HOME/work"
if [ -f "${CONFIG_FILE}" ] && command -v jq >/dev/null 2>&1; then
    WORKTREE_BASE=$(jq -r '.git.worktree_base_dir // "~/work"' "${CONFIG_FILE}")
fi
WORKTREE_BASE="${WORKTREE_BASE/#\~/$HOME}"
mkdir -p "${WORKTREE_BASE}"

# Initialize git repo if absent
if [ ! -d "${PROJECT_DIR}/.git" ]; then
    echo "Initializing git repository..."
    git -C "${PROJECT_DIR}" init
    git -C "${PROJECT_DIR}" checkout -b main 2>/dev/null || git -C "${PROJECT_DIR}" checkout -b master
fi

# Check gh auth
if command -v gh >/dev/null 2>&1; then
    gh auth status >/dev/null 2>&1 || echo "Warning: gh is not authenticated. Run 'gh auth login' to enable PR automation."
fi

# Warn about missing docs
for doc in vision.md design.md principles.md glossary.md; do
    [ -f "${PROJECT_DIR}/docs/${doc}" ] || echo "Warning: docs/${doc} not found. Fill this in before starting lanes."
done

echo ""
echo "=== Setup Complete ==="
echo "Worktree base: ${WORKTREE_BASE}"
echo ""
echo "Next steps:"
echo "1. Edit docs/elp-config.json with your project details"
echo "2. Complete docs/vision.md, design.md, principles.md, glossary.md"
echo "3. Use elp-launch.sh to start lanes"
