---
name: elp-phase2-brief
description: Use when preparing to launch a new ELP lane and need to generate a structured brief from a GitHub issue, ensuring all pinned decisions, scope, and instrumentation are specified before autonomous execution.
disable-model-invocation: true
argument-hint: [issue-number]
allowed-tools: Read Write Bash(gh issue view *) Bash(gh issue list *)
---

# ELP Phase 2: Brief Generation

## Overview
Transform a GitHub issue into a complete, detailed lane brief. The brief is the contract between the architect (human) and the lane agent. Its quality is the ceiling on the lane's quality.

**Goal:** Produce `/tmp/wt-claude-prompt-<issue>-<descr>.txt` ready for `elp-launch.sh`.

## When to Use
- A GitHub issue has been triaged and is ready to become a lane
- Before running `elp-launch.sh`
- Parallel lanes are being planned and need coordinated briefs

## When NOT to Use
- No GitHub issue exists yet (create the issue first)
- The issue lacks sufficient functional specification
- No `docs/principles.md` or `docs/design.md` exists (use elp-phase1-setup first)

## Prerequisites
Before generating a brief, verify:
- [ ] GitHub issue exists and has clear functional specification
- [ ] `docs/elp-config.json` is present and valid
- [ ] `docs/principles.md` has relevant pinned decisions
- [ ] `docs/design.md` describes the affected components
- [ ] `docs/vision.md` clarifies priority if tradeoffs arise
- [ ] Related retros from prior lanes have been read (if applicable)

## Process

### Step 1: Read Context
Read the following in order:
1. `docs/elp-config.json` — for project settings, conventions, and labels
2. `docs/principles.md` — for invariants this lane must respect
3. `docs/design.md` — for architectural context
4. `docs/vision.md` — for priority when tradeoffs arise
5. The GitHub issue: `gh issue view <number>`
6. Related retros: `docs/lane-experiences/lane-experience-<previous>.md` (if any)
7. Phase 0 audit: `docs/phase0-audits/<milestone>-phase0-audit.md` (if this lane follows an audit)

### Step 2: Interview the Architect
The human decides scope, not the agent. Ask the architect:

1. **Scope confirmation**
   - Does this issue represent one lane or should it be split?
   - What is the smallest delta that fulfills the issue?

2. **Files to touch**
   - Which files will be modified? (The agent must read these first.)
   - Any files that are explicitly off-limits?

3. **Pinned decisions for THIS lane**
   - Are there decisions already made that the lane must not re-discuss?
   - Should the lane fix adjacent bugs or STOP-and-report?
   - Any dependencies on parallel lanes?

4. **Parallel lane awareness**
   - What other lanes are in flight?
   - Could this lane conflict with them?

5. **Verification criteria**
   - What tests must pass before push?
   - What does "done" look like?

### Step 3: Generate the Brief

Use `${CLAUDE_SKILL_DIR}/templates/brief-template.md` as the structure. Fill in every section:

#### Goal
1-3 sentences. Cite the issue. Explain why this matters now.

#### Context
- Repo name, branch name (auto-generated: `issue-NNN-descr`)
- Verification command (e.g., `git log --oneline -5 origin/main`)
- Pinned rules file (`CLAUDE.md`, `docs/principles.md`)
- Relevant principles from `docs/principles.md`
- Parallel lanes in flight

#### Read First
List every file the agent must read before writing code:
- The issue itself
- Related audit or design doc
- Prior retros that share context
- Specific source files this lane will modify

#### Pinned Decisions
Explicit decisions the agent MUST NOT re-discuss:
- "Do not fix issue #219 in this lane."
- "Do not touch CHANGELOG.md or VERSION."
- "Smallest-delta wins."
- "Diagnose before implementing."

#### Lane Scope (In and Out)

**DO:**
- Specific, bounded actions

**DO NOT:**
- Explicit prohibitions

**STOP-and-report if:**
- Conditions where the agent must halt and report

#### Required Outputs
- Modified files list
- Commit message in Conventional Commits format
- PR body contents
- Closing commands (`gh pr create`, `gh pr merge --auto`)

#### Discipline
- Test tiers before push
- Clean working tree requirement
- Auto-integration rules

#### Instrumentation (Mandatory)
- TSV path: `/tmp/lane-issue-NNN-descr-builds.tsv`
- Retro path: `docs/lane-experiences/lane-experience-issue-NNN-descr.md`

### Step 4: Review with Architect
Present the generated brief to the human. Incorporate feedback. The brief is not final until the architect approves it.

### Step 5: Write Brief to Disk

```bash
BRIEF_PATH="/tmp/wt-claude-prompt-${ISSUE}-${SAFE_DESC}.txt"
# Write the final brief to this path
cat > "${BRIEF_PATH}" << 'EOF'
[brief content]
EOF
```

## Quality Checklist

- [ ] Goal cites the issue and explains priority
- [ ] Context includes branch, verification, principles, and parallel lanes
- [ ] Read First lists all files the agent must read
- [ ] Pinned Decisions has at least 3 explicit constraints
- [ ] DO list is bounded and actionable
- [ ] DO NOT list prevents scope creep
- [ ] STOP-and-report conditions are specific
- [ ] Required outputs specify commit format and PR commands
- [ ] Discipline includes test tiers and clean working tree
- [ ] Instrumentation has TSV path and retro path
- [ ] Brief is approved by the architect

## Supporting Files

Bundled at `${CLAUDE_SKILL_DIR}/templates/`:
- `brief-template.md` — canonical brief structure with all required sections

## Anti-Patterns
- **Thin brief:** "Implement X" without context, scope, or decisions. Produces a lost agent.
- **Vague STOP-and-report:** "If something goes wrong, stop." Be specific about conditions.
- **Missing DO NOT:** The model is trained to be helpful. If not told to stop, it keeps going.
- **No parallel lane awareness:** Briefs that ignore other lanes create merge conflicts.
- **Skipping architect review:** Never launch a lane with an unreviewed brief.

## Example Pinned Decisions
- "Do not touch `CHANGELOG.md` or `VERSION`. The release bump regenerates them."
- "Do not refactor unrelated code. Smallest-delta wins."
- "If you discover a bug in module Y, STOP-and-report. Do not fix it here."
- "Use existing error handling patterns. Do not introduce new exception types."
- "Keep backwards compatibility. Do not break existing API consumers."
