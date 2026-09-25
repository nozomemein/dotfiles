---
name: why
description: Investigate why a code path, design choice, threshold, or safeguard exists. Trace Git history and PR discussion, then relevant documents, tickets, or chat when available. Use for design changes and reviews that need historical intent; explain current runtime behavior separately.
---

# Why

Find the evidence behind an implementation choice. Keep the investigation read-only. Treat current code as evidence of behavior, not proof of the author's intent.

1. Identify the exact question and anchor it to current files, symbols, and lines. If the target is vague, state the interpretation and proceed with the most likely one.
2. Trace the relevant history with `git blame`, `git log --follow -p -- <path>`, and `git show`. Read the introducing change and any later revisions that altered its rationale. Follow PR numbers to descriptions, review discussion, and linked issues when available. Do not assume the newest commit explains the original decision.
3. If Git and PR evidence leave a material gap, search relevant design documents, issue trackers, and team chat through available read-only tools. Search using concrete symbols, PRs, dates, and decision terms. Use only sources that are connected and relevant; name unavailable or unsearched sources as limits.
4. Separate what a source explicitly says from what the evidence suggests. Surface conflicting explanations and decisions whose original constraints may no longer hold. Do not invent a clean rationale from code shape or passing tests.
5. Answer with the reason, direct links or precise file/commit references, remaining uncertainty, and the constraint this history creates for a proposed change. Keep the result short enough to use during design or review.

Adapted from [pstack's why skill](https://github.com/cursor/plugins/blob/main/pstack/skills/why/SKILL.md) (MIT).
