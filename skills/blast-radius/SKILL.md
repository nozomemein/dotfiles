---
name: blast-radius
description: Review the downstream impact of a proposed code or configuration change when asked what it could break, especially when a small diff crosses library, protocol, runtime, or deployment boundaries.
---

# Blast radius

Assess a specific diff or PR against the code that will actually run. Keep the audit read-only unless the user asks for a fix. Treat the PR description and passing CI as evidence to check, not conclusions.

1. Fix the exact base and head revisions. State the behavior that changes. Trace the relevant callers and downstream boundaries, but do not make a caller list the result.
2. Identify the one or two conditions on which safety depends. Follow each through the real path, including pinned dependency source, configuration branches, wire formats, other workspaces, and runtime timing where relevant.
3. Test the condition at the highest practical level: source inspection, step-by-step failure analysis, executable probe using the real code, or running service. Prefer a small probe that crosses the boundary the diff changes. If an existing test appears to cover the condition, temporarily break that condition in an isolated checkout and see whether the test fails; restore the checkout afterward. Do not turn a hypothetical risk into a finding.
4. Report confirmed risks separately from risks cleared. For each, cite the exact code location and observed result. State what remains unverified, including platform or production behavior that a local test cannot prove. Recommend the cheapest additional check that would close an important gap.

Use concise sections: changed behavior, safety condition and proof level, confirmed risks, cleared risks, and remaining check. Do not publish review comments or change a PR unless the user's task authorizes that action.

Adapted from [pstack's blast-radius skill](https://github.com/cursor/plugins/blob/main/pstack/skills/blast-radius/SKILL.md) (MIT). This skill keeps the executable-proof method and omits Cursor-specific agent and model routing.
