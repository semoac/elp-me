# ELP (Empirical Lane Parallelism) — Implementation Kit

This directory contains the skills, scripts, templates, and configuration needed to implement the [ELP method](https://raw.githubusercontent.com/lnds/elp/refs/heads/main/elp-method-en.md) for software engineering with multiple AI agents working in parallel.

## Quick Start

### 1. Install Skills

**Recommended — using the [skills CLI](https://github.com/vercel-labs/skills)** (works with Claude Code, OpenCode, Cursor, and 55+ agents):

```bash
npx skills add semoac/elp-me
```

The CLI will let you choose which agent(s) to install to and whether to symlink or copy the files.

**Manual install for Claude Code:**

```bash
mkdir -p ~/.claude/skills
cp -r skills/elp-phase1-setup ~/.claude/skills/
cp -r skills/elp-phase2-brief ~/.claude/skills/
cp -r skills/elp-phase3-lane ~/.claude/skills/
```

Each skill is self-contained with bundled templates and scripts:
- `elp-phase1-setup/` — Phase 1 skill + doc templates
- `elp-phase2-brief/` — Phase 2 skill + brief template
- `elp-phase3-lane/` — Phase 3 skill + retro/audit templates + operational scripts

### 2. Run Setup

From your project root:

```bash
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-setup.sh
```

This checks dependencies and creates the directory structure.

### 3. Phase 1 — Project Setup

Activate the `elp-phase1-setup` skill. It will interview you to generate:
- `docs/vision.md`
- `docs/design.md`
- `docs/principles.md`
- `docs/glossary.md`
- `docs/elp-config.json`

**You must complete Phase 1 before starting any lanes.**

### 4. Phase 2 — Generate Brief

For each GitHub issue you want to implement:

1. Ensure the issue has a clear functional specification
2. Activate the `elp-phase2-brief` skill
3. Provide the issue number
4. The skill will interview you and generate a detailed brief at `/tmp/wt-claude-prompt-<issue>-<descr>.txt`

### 5. Phase 3 — Launch Lane

From your project root:

```bash
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-launch.sh <issue-number> <description> [brief-file]
```

Example:
```bash
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-launch.sh 42 auth-jwt-middleware
```

This creates:
- A git worktree at `~/work/<project>.issue-42-auth-jwt-middleware/`
- A git branch `issue-42-auth-jwt-middleware`
- A tmux session `issue-42-auth-jwt-middleware`
- A launch script `/tmp/launch-42.sh`

The lane agent runs autonomously and produces a PR.

### 6. Monitor

```bash
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-monitor.sh
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-monitor.sh issue-42-auth-jwt-middleware
```

### 7. Cleanup (After PR Merge)

```bash
bash ~/.claude/skills/elp-phase3-lane/scripts/elp-cleanup.sh 42 auth-jwt-middleware
```

**WARNING:** Only run after the PR is merged. This is irreversible.

## Directory Structure

```
.
└── skills/
    ├── elp-phase1-setup/
    │   ├── SKILL.md                 # Phase 1: project setup instructions
    │   └── templates/               # vision, design, principles, glossary, elp-config
    ├── elp-phase2-brief/
    │   ├── SKILL.md                 # Phase 2: brief generation instructions
    │   └── templates/               # brief-template.md
    └── elp-phase3-lane/
        ├── SKILL.md                 # Phase 3: lane execution instructions
        ├── templates/               # retro, phase0-audit, honesty-targets templates
        └── scripts/                 # elp-setup, elp-launch, elp-monitor, elp-cleanup
```

Once installed, Phase 1 generates the following in your project:

```
your-project/
└── docs/
    ├── elp-config.json
    ├── vision.md
    ├── design.md
    ├── principles.md
    ├── glossary.md
    ├── lane-experiences/
    ├── phase0-audits/
    └── honesty-targets/
```

## Configuration

After running Phase 1, edit `docs/elp-config.json` in your project to customize:
- Git repository URL
- Worktree base directory
- GitHub labels
- Subagent model
- tmux session prefix
- Conventional commits setting
- Auto-merge behavior

## Key Principles

- **No brief without architect approval.**
- **No retro, no PR.**
- **Do not touch `CHANGELOG.md` or `VERSION`.**
- **No direct push to `main`.**
- **Cleanup only after explicit authorization.**

## Skills Reference

| Skill | Purpose | When to Use |
|---|---|---|
| `elp-phase1-setup` | Generate initial documentation | Starting a new ELP project |
| `elp-phase2-brief` | Generate detailed lane briefs | Before launching each lane |
| `elp-phase3-lane` | Execute lane autonomously | Inside the lane agent session |

## Requirements

- `node` / `npx` — for `npx skills add` installation
- `git` (with worktree support)
- `tmux`
- `gh` (GitHub CLI, for PR automation)
- `jq` (optional, for config parsing)
- `claude` (Claude Code CLI) or your agent's CLI

## Compatibility

### skills CLI (recommended)

This repo follows the [Agent Skills open standard](https://agentskills.io) and is discoverable by the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI. Running `npx skills add semoac/elp-me` handles path resolution for any supported agent automatically.

### Agent feature matrix

These skills use several **Claude Code-specific extensions** that are silently ignored by other agents:

| Feature | Claude Code | OpenCode | Cursor / others |
|---|---|---|---|
| `SKILL.md` format and frontmatter basics | ✅ | ✅ | ✅ |
| `${CLAUDE_SKILL_DIR}` (template/script paths) | ✅ | ❌ unresolved | ❌ unresolved |
| `disable-model-invocation` | ✅ | ❌ ignored | ❌ ignored |
| `allowed-tools` | ✅ | ❌ ignored | ❌ ignored |
| `argument-hint` | ✅ | ❌ ignored | ❌ ignored |
| `exec claude` in launch script | ✅ | ❌ needs `exec opencode` | ❌ needs agent CLI |

**Using with OpenCode or other agents:**
1. Install via `npx skills add semoac/elp-me` and select your agent — paths are resolved automatically
2. Replace `${CLAUDE_SKILL_DIR}/templates/...` references in SKILL.md files with the resolved install path
3. Change `exec claude` to your agent's CLI command in `elp-phase3-lane/scripts/elp-launch.sh`
4. Accept that `disable-model-invocation`, `allowed-tools`, and `argument-hint` are no-ops

The skill instructions, interview logic, templates, and checklists are plain markdown and work identically in all agents.

## More Information

- [ELP Method Document](https://raw.githubusercontent.com/lnds/elp/refs/heads/main/elp-method-en.md)
