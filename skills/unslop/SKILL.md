---
name: unslop
description: Remove AI-sounding phrasing from a draft while preserving its meaning, evidence, and intended tone. Use on its own for a quick prose edit or as the final pass of refine-tech-document after structural editing.
---

# Unslop

Make the text sound like its author explaining something concrete to a colleague. Preserve claims, uncertainty, citations, names, commands, and code identifiers. Do not replace a vague claim with an invented fact.

Run this skill on its own for a short draft, or after `refine-tech-document` has settled a document's structure and reasoning. This pass changes expression, not the underlying argument.

1. Read the whole passage and identify its purpose and tone. Keep wording that serves either one, even if it matches a pattern below.
2. Remove filler openings, repeated summaries, decorative headings, forced groups of three, and praise that adds no information.
3. Replace abstract claims, fashionable metaphors, and inflated verbs with the actual action or observable result. If the text does not supply one, flag the gap or delete the empty sentence.
4. Check vague attribution, unsupported certainty, excessive hedging, passive voice that hides the actor, synonym cycling, and contrastive framing such as "not just X, but Y". Keep uncertainty when the evidence warrants it.
5. Read the revision once more for meaning and rhythm. Split sentences that require backtracking, but keep a natural mix of lengths. Do not compress the result into fragments or symbols the reader must decode.

Common tells include 「重要なのは」「要するに」「包括的」「多角的」「シームレスに」 and "delve", "leverage", "crucial", "landscape", "it is important to note". Treat these as clues, not a forbidden-word list. Domain terms and a deliberate voice can stay.

Return the revised text directly. Explain a material change or unresolved claim briefly when it affects the author's meaning.

Adapted from [pstack's unslop skill](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md) (MIT).
