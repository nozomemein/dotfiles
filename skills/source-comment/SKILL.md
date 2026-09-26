---
name: source-comment
description: Write or review source code comments that explain non-obvious behavior, invariants, and design intent. Use when adding comments to code or checking a diff for comments that may describe the patch instead of the code.
---

# Source comments

Write comments for someone reading the resulting source without the diff or PR. A comment should explain a constraint, reason, or consequence that the nearby code does not make clear. If the code already says it, omit the comment.

When writing or reviewing comments:

1. Read the surrounding code and identify what a future maintainer needs to know. Check the claim against the actual branches and behavior; do not infer intent from the diff alone.
2. Describe the current rule and why it matters. Use history only when the historical decision itself is necessary to maintain the code, and then name the relevant change or constraint precisely.
3. Look for patch-relative wording such as “existing”, “new”, “now”, “still”, “instead”, “as before”, or “this change”. These are review cues, not banned words: they can describe real runtime transitions or comparisons. Rewrite them when their only reference point is the previous revision.
4. Remove comments that narrate an edit, repeat a nearby condition, promise behavior the code does not guarantee, or leave an implementation note that belongs in the PR. Preserve useful API documentation, safety warnings, and actionable TODOs.
5. Read each added or changed comment in the final diff once more with the diff hidden. If its meaning depends on deleted code or the commit message, make it self-contained or remove it.

For example, `// Keep the existing fallback for unknown values.` describes a patch. `// Unknown values use the default so older clients can read newer responses.` explains a lasting compatibility rule, if the code actually guarantees it.

When asked to review only, report the specific comments that need changes and why; do not edit files unless the user asks for a fix. When editing code, make the comment changes within the requested scope.

As the final pass, load and apply the [`unslop` skill](../unslop/SKILL.md) to comments you wrote, rewrote, or proposed. Remove filler and unnatural phrasing without changing technical claims, identifiers, or intentional domain terms. Check the resulting comments against the code once more.
