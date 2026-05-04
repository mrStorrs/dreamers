# Requirements Clarification Protocol (MANDATORY)

Never write a plan file until the user has explicitly approved the goal and acceptance criteria. Three phases — in order, no skipping.

## Phase 1 — Hash it out

On receiving a new task:
1. Write a concise **understanding summary** — one paragraph stating what you believe the goal, scope, and done-state to be.
2. Identify all ambiguities, gaps, and open decisions.
3. Ask every clarifying question in a **single numbered list** — one round only. Do not trickle questions across multiple messages.
4. Wait for the user's response before proceeding.

If the task is fully unambiguous and there are no questions, skip directly to Phase 2 with a brief "I understand the goal as: …" confirmation.

## Phase 2 — Explicit approval

After Phase 1 (or immediately if no questions), present this proposal block and wait — no plan file is written until the user explicitly approves:

---
**Goal:** [one sentence]
**Scope:** [what is in]
**Non-goals:** [only if scope is genuinely ambiguous or there's real risk of over-building — omit by default]
**Acceptance criteria:**
1. [AC 1]
2. [AC 2]
…

*Reply "approved", ask a question, or provide corrections.*

---

### Classify every user reply before acting

The user's reply falls into exactly one of three buckets. Misclassifying is the most common failure mode — re-read the reply and pick deliberately.

1. **Approval** — explicit go-ahead ("approved", "ship it", "looks good, proceed", "yes do it"). → Move to Phase 3.
2. **Correction / change request** — an instruction to modify the proposal ("make scope smaller", "drop AC 2", "add support for X", "use library Y instead"). → Revise the proposal block and re-present it.
3. **Question / discussion / pushback** — anything that asks for information, challenges a choice, or explores an alternative ("why did you pick X?", "what about Y?", "is Z safe?", "have you considered…", "I'm not sure about AC 3"). → **Answer the question in chat. Do NOT re-print the proposal block. Do NOT silently edit the proposal.** Continue the conversation until the user signals they're ready to re-evaluate, then re-present the proposal only if something actually changed.

If a reply mixes types (e.g. a question *and* a correction), answer the question first, then ask whether the correction should be applied — do not assume.

When in doubt between bucket 2 and bucket 3, treat it as bucket 3. A question answered is cheap; a silent edit that ignores the user is expensive.

Repeat Phase 2 until the user explicitly approves. There is no cap on rounds — brainstorming until the proposal is right is the point of this phase.

## Phase 3 — Decompose

Only after explicit user approval: write the plan file(s) per the naming rules in `refs/plan-rules.md`, content rules in `refs/plan-content.md`, and decomposition rules in `refs/feature-decomposition.md`.

Use the template at `~/.claude/dreamers/templates/plan-sub.md` as the starting structure for every sub-plan and standalone plan.

**Component usage check (mandatory):** When a plan modifies a shared component, run `grep -r "ComponentName" app/` before finalizing the scope file list — include all callers in scope to avoid build failures from missing prop updates.

## Output discipline during planning

**During Phase 1:** Understanding summary (one paragraph) + numbered clarifying questions (one round only).
**During Phase 2 (initial proposal or after a correction):** The proposal block only.
**During Phase 2 (answering a question / discussion):** Direct, substantive answer in chat. No proposal block. No silent edits. The proposal is only re-presented when the user is ready to evaluate it again.
**After Phase 3:** Brief summary + plan file path(s) created/updated + any open items flagged.

Never output plan content in chat — write it to the plan file only. (This applies to plan *details*; the Phase 2 proposal block is a goal/scope/AC summary and is allowed in chat.)
