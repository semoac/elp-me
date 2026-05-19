# Lane Brief: issue-NNN-<description>

## Goal
[1-3 sentences. What is delivered and why it matters now. Cite the issue number.]

## Context
- Repository: <repo-name>, branch: issue-NNN-<description>
- Verification: `git log --oneline -5 origin/main`
- Project pinned rules: `CLAUDE.md`, `docs/principles.md`
- Applicable principles: [list relevant principles from docs/principles.md]
- Parallel lanes in flight: [list any parallel lanes and their scope to anticipate conflicts]

## Read First
- Issue: `gh issue view NNN`
- Audit: `docs/phase0-audits/<milestone>-phase0-audit.md` (if applicable)
- Related retros: `docs/lane-experiences/lane-experience-<previous>.md`
- Files to inspect: [list specific source files the lane will touch]

## Pinned Decisions
Decisions already made that the agent MUST NOT re-discuss:
- [Decision 1: e.g., "Do not fix issue #219 in this lane."]
- [Decision 2: e.g., "Do not touch CHANGELOG.md or VERSION."]
- [Decision 3: e.g., "Smallest-delta wins. Change the minimum needed."]
- [Decision 4: e.g., "Diagnose before implementing."]

## Lane Scope (In and Out)

### DO:
- [Action 1]
- [Action 2]
- [Action 3]

### DO NOT:
- [Prohibition 1: e.g., "Do not touch other modules."]
- [Prohibition 2: e.g., "Do not touch versioning files."]
- [Prohibition 3: e.g., "Do not open new issues for adjacent gaps."]

### STOP-and-report if:
- [Condition 1: e.g., "You find a bug adjacent to scope."]
- [Condition 2: e.g., "A design decision not covered by the brief is needed."]
- [Condition 3: e.g., "You need to touch more zones than anticipated."]

## Required Outputs
- Expected modified files: [list paths]
- Commit message format: `<type>(<scope>): <subject>` (Conventional Commits)
- PR body should include: [what to document in the PR]
- Closing commands: `gh pr create` + `gh pr merge --auto` (if CI green)

## Discipline
- Required test tiers before push: [e.g., "tier 0 and tier 1 tests locally"]
- Clean working tree at every commit
- Automatic integration enabled when applicable

## Instrumentation (Mandatory)
- Build logging to TSV at `/tmp/lane-issue-NNN-<description>-builds.tsv`
- Retro document at `docs/lane-experiences/lane-experience-issue-NNN-<description>.md` with all mandatory sections
- Start timestamp: record at beginning of lane
