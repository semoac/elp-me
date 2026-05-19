# Phase 0 Audit: <milestone-name>

## Milestone
[Milestone or feature being evaluated]

## 1. Empirical Inventory
[Searches, counts, and scans over the current codebase.]
- Files involved: <count>
- Lines of code affected: <estimated range>
- Dependencies touched: [list]
- Surface area: [modules, components, or zones affected]

## 2. Surface Quantification
- References per file: [count of call sites, imports, etc.]
- Types of change required: [e.g., signature changes, new modules, refactors]
- Test coverage of affected areas: [percentage or qualitative assessment]

## 3. Survey of Options

### Option A: [Name]
- Cost: [low/medium/high with justification]
- Risk: [low/medium/high with justification]
- Resulting state: [what the codebase looks like after]
- Tradeoffs: [pros and cons]

### Option B: [Name]
- Cost: [low/medium/high with justification]
- Risk: [low/medium/high with justification]
- Resulting state: [what the codebase looks like after]
- Tradeoffs: [pros and cons]

### Option C: [Name]
- Cost: [low/medium/high with justification]
- Risk: [low/medium/high with justification]
- Resulting state: [what the codebase looks like after]
- Tradeoffs: [pros and cons]

### Option D: [Name] (if applicable)
- Cost, risk, resulting state, tradeoffs...

## 4. Quality-Gate Strategy
[How the build stays green at every PR during implementation.]
- Incremental approach: [description]
- Test coverage plan: [description]
- Rollback strategy: [description]

## 5. Risk Inventory
- [Risk 1]: [likelihood and impact]
- [Risk 2]: [likelihood and impact]
- [Risk 3]: [likelihood and impact]

## 6. Verdict and Recommended Phase Order
- Verdict: [GO / NO-GO / CONDITIONAL]
- Reasoning: [summary of empirical findings]
- Recommended phase order: [if GO, what sequence of lanes is recommended]
- Prerequisites: [what must be in place before starting]

## 7. If NO-GO
[What would need to change for this milestone to be viable.]
- Alternative milestones: [suggested alternatives]
- Further research needed: [open questions]
