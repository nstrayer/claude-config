---
name: anticipate-review-concerns
description: Predict the top reviewer objections for the current branch's changes
---

# Anticipate Review Concerns

Adversarial read from the reviewer's perspective. Surface what they'll **argue with**, not what's broken. Output is a ranked list of concerns with reasoning, so the author can prepare defenses or pre-empt objections.

## Workflow

1. Gather: `git log <base>..HEAD --format="%h %s%n%b%n---"`, `git diff <base>...HEAD --stat --name-only`. `$ARGUMENTS` overrides base.
2. Check repo root for `BRANCH-WALKTHROUGH-*.md` or `BRANCH-SUMMARY-*.md` matching the branch - read it if present. It captures the framing the reviewer will push back on.
3. Read every changed file end-to-end (Explore for >10 files / >2k lines).
4. Read adversarially (see *Finding concerns*), asking at each spot: *"what would I push back on cold?"*
5. Rank into tiers: **Major** (4-6 likely to generate real discussion), **Secondary** (3-5 fragile-but-defensible), optional **Minor** (2-3).
6. Write each concern in three parts (see Output).

## Finding concerns

The concerns worth surfacing are almost always **user-visible choices** the reviewer can see working differently than they expect, or **fragility-under-change** patterns that will break the next time the code evolves. Bugs and style nits aren't this skill's job.

Focus on judgment calls: defaults, scope, error-handling in paths that reach users, deviations from widely-used specs or platform conventions (GFM, CommonMark, ARIA, upstream behavior in a fork), removed or consolidated tests, and fragile-but-defensible patterns.

Use judgment about what applies to this diff. A pure refactor rarely has a11y concerns; a new UI feature almost always does.

## Output

Default: inline response. Each concern has three parts:

- **The concern**: one sentence, `file:line` cited
- **Why a reviewer will raise it**: mental-model mismatch, spec gap, incident pattern
- **How to respond**: intentional defense or concession

If the user asks, also append to the walkthrough doc under "Anticipated pushback".

## Rules

- Not a correctness review. If it's a bug, fix it.
- Every concrete concern needs `file:line`. Vague concerns get dismissed.
- "Why reviewer raises it" is the value add. Skip it and this is just another code review.
- Don't pad. Three items is fine if three is accurate.
