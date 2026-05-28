---
description: 'Resolve unresolved PR review comments inline. Orchestrator decides accept/reject per thread, applies fixes, spawns Sentinel + Probe + Hone in parallel for review of accepted changes, then resolves accepted threads via `gh api`. Triggers: /dreamers-pr-resolve, resolve PR comments, address review comments, fix PR feedback.'
---

Resolve unresolved PR review comments. All work inline except a parallel review pass (Sentinel + Probe + Hone) over the accepted changes, with Bolt for mechanical test runs + push.

Follow the Dreamers Kernel and output discipline from `~/.claude/CLAUDE.md`.

<dreamers-kernel>
# Dreamers Kernel

## Subagent allowlist (HARD RULE)

Do not use any non-Dreamers agent unless explicitly authorized by user. Allowed Dreamers subagents: `sentinel`, `probe`, `hone`, `echo`, `sage`, `bolt`. NEVER `general-purpose`, NEVER `claude`, NEVER any other host-runtime agent.

## Subagent prompt — required content

Every `Agent` invocation MUST include in the prompt:
- **Context** — what this agent is being asked to do and why
- **Prior work** — what was done previously, with absolute paths to any output files
- **What is needed** — specific deliverable
- **Constraints** — hard rules the agent must not violate
- **Definition of Done** — how to know the work is complete
- **Plan file path** — absolute path to the relevant plan file (if applicable)
- **Mandatory line:** `Do NOT call TaskCreate / TaskUpdate / TaskList. The command that invoked you owns its todo.`

All `Agent` calls run synchronously (default) — the call blocks until the agent returns.

## Continuation principle

At every natural pause between phases — where the command has produced a meaningful result and the user could redirect — call `AskUserQuestion` with three choices: `Continue` / `Halt for now` / `Other` (freeform). Never silently advance; never silently stop. On `Halt`, emit a one-line resume command and stop.

## Implementation discipline

- **Plan adherence:** edit only files in the plan's scope. No while-I'm-here cleanup, no unrelated refactors mixed with feature work.
- **No spec-arguing comments:** never add a code comment that argues the spec permits a pattern.
- **Branch identity check:** before the first edit, `git log --oneline -3`. Confirm the branch and recent commits match the expected feature. If not, halt and surface.
- **No dependency installs without permission.** Don't run `npm install`, `pip install`, etc. without explicit user approval.
- **Type-check before declaring implementation done.** Run the project's type-check command from `CLAUDE.md` and fix errors before moving on.

## Commit trailer

Every commit body includes:

```
Co-authored-by: The Dreamers System
```
</dreamers-kernel>

$ARGUMENTS

---

## Todo list

At skill entry, declare via `TaskCreate`:
- [ ] Read review comments (discover PR + pull unresolved threads via GraphQL)
- [ ] Categorize threads (accept/reject decision per thread)
- [ ] Apply accepted fixes inline + run tests
- [ ] Spawn parallel review of accepted changes (Sentinel + Probe + Hone)
- [ ] Resolve accepted threads + commit + report

Mark each item `in_progress` when starting, `completed` when done. Never batch completions at the end.

---

## Step 1 — Discover open PRs

Run `gh pr list --state open` to find all live PRs. If a specific PR is provided in `$ARGUMENTS`, use that one. If multiple are open and none is specified, call `AskUserQuestion` with each open PR as a choice (format: `#NUM — <title>`) plus `"Other"` for freeform input. If exactly one is open, use it without prompting.

## Step 2 — Pull unresolved review threads (GraphQL only)

For the target PR, use GraphQL to get only the unresolved threads (the REST API `resolved` field is unreliable — always use GraphQL):

```bash
gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { pullRequest(number: N) { reviewThreads(first: 50) { nodes { isResolved id comments(first: 1) { nodes { path body } } } } } } }'
```

Extract only threads where `isResolved: false`. Capture each thread's `id`, `path`, and `body`. If there are none, report that back to the user and stop.

## Step 3 — Decide accept / reject per thread (inline)

**HARD STOP — fix application is inline.** The orchestrator (this skill) edits files directly using Edit / Write / Bash tools to apply accepted PR-feedback fixes. **Do NOT spawn any subagent to write the fix code.** Specifically:
- `subagent_type: "general-purpose"` → FORBIDDEN. There is no general-purpose fallback for implementation.
- `subagent_type: "claude"` or any other host-runtime agent → FORBIDDEN.
- The only `subagent_type` values you may spawn from this skill are `sentinel`, `probe`, `hone` in Step 5 (parallel review of the applied fixes) and `bolt` in Steps 4 and 6 (mechanical test runs + push). Nothing else.

For each unresolved thread, judge whether to accept or reject the comment. You are the implementation expert and have full authority. **Do not feel obligated to accept every comment** — if a suggestion conflicts with the plan, the architecture, or is simply wrong, reject it and say why.

For each thread, record:
- Thread ID
- Path + comment body (one-line summary)
- Decision: **accept** or **reject**
- Rationale: one sentence

If **accept** → apply the fix inline (Edit the file). Stage with `git add`. Follow the comment + implementation discipline from `dreamers-kernel.md` and `comment-rules.md`.

If **reject** → no edit. Note in chat for the final report.

## Step 4 — Run tests after accepted changes (delegated to Bolt)

If any threads were accepted:
- Spawn Bolt (`subagent_type: "bolt"`) to run the project's type-check command (from `CLAUDE.md`). Fix any errors before proceeding.
- Spawn Bolt to run the project's test command. Fix any regressions inline. Up to 3 attempts.

If no threads were accepted, skip to Step 6.

## Step 5 — Parallel review of accepted changes (Sentinel + Probe + Hone)

Spawn **three reviewers in parallel** in a single message with three `Agent` invocations. All three are read-only / report-only; each returns structured findings in the format from `reviewer-findings-format.md`. Scope is restricted to ONLY the files touched by accepted threads.

Common prompt context for all three (subagent prompt rule — include verbatim):
- **Todo discipline:** "Do NOT call `TaskCreate` / `TaskUpdate` / `TaskList`. The orchestrator owns the todo." (per `dreamers-kernel.md` § "Subagent prompt — required content")
- Plan file: none (ad-hoc PR-feedback work, no plan binding) — mark plan-alignment summary as N/A
- Scope: list of files changed by accepted threads from `git status`
- Branch + default branch names
- What the orchestrator has done: addressed N accepted PR review comments via inline edits; type-checked + tests green.

Per-reviewer prompt addition:

**Sentinel** (`subagent_type: "sentinel"`) — correctness, security, maintainability lenses.

**Probe** (`subagent_type: "probe"`) — test coverage lens (did the PR-feedback fixes break or weaken test coverage?).

**Hone** (`subagent_type: "hone"`) — simplicity lens (did the fixes introduce over-engineering or redundancy?).
- **Mandate reinforcement (include in Hone's prompt verbatim):** "Aggressively flag bad architecture, over-engineering, redundancy, and simpler alternatives. Refactor cost is NOT a moderating factor — do not soften, hedge, or omit findings because the fix is big. When the suggested fix has architectural scope (touches files outside the PR-feedback surface, requires a new module, requires schema or symbol changes, or amounts to a full refactor of a subsystem), state the scope explicitly in the suggested-fix text. The orchestrator's major-refactor finding gate (per `dreamers-review.md`) routes those findings through the user for apply-now vs defer decisions. Your job is to surface; the gate handles disposition."

Apply findings inline per `dreamers-review.md` § "Phase 2 — Apply findings":

1. Sort findings by severity.
2. Resolve conflicts per the rule (correctness > simplicity).
3. **Evaluate each finding against the Major-refactor finding gate** per `dreamers-review.md` § "Major-refactor finding gate." If ANY criterion fires for a finding (new module / schema change / cross-cutting refactor / new exported symbols / files outside the PR-feedback surface / Hone-style "tear out X" scope language), call `AskUserQuestion` with the 3-choice template (`Apply now — refactor in this cycle` / `Defer — create follow-up plan` / `Other`) and route per the user's answer. On `Defer`, create the stub plan file per the canonical template; do NOT apply the deferred fix.
4. Apply each (non-deferred) fix inline; stage with `git add`.
5. Re-run type-check + tests (via Bolt); fix regressions inline (up to 3 attempts).

Handle non-finding outputs:
- Any reviewer returns `Blocked` → halt; surface; resolve; re-spawn that reviewer.
- Open questions → present to user before proceeding.
- All three `Approved — no findings` → proceed to Step 6 directly.

## Step 6 — Commit accepted fixes (if any)

If any fixes landed (Step 3 accepted + Step 5 reviewer findings applied):

```bash
git status                # confirm staged content
git commit -m "fix: address PR feedback"
```

Use a single commit covering all the PR-feedback fixes. Commit message per `git-workflow.md`.

**Do not push yet.** Call `AskUserQuestion` with `["Push to PR", "Hold — don't push yet", "Other"]` and a summary of the staged commit (hash, files touched, accepted thread count). Post-PR changes always require explicit user approval before pushing.

Only push after explicit `Push to PR` approval: spawn Bolt to run `git push`. On `Hold` → stop with status; the commit stays on the branch for the user to push manually.

## Step 7 — Resolve accepted threads via gh api

For each thread marked **accept** in Step 3, resolve it:

```bash
gh api graphql -f query='mutation { resolveReviewThread(input: { threadId: "THREAD_ID" }) { thread { isResolved } } }'
```

Leave rejected threads open — they represent active disagreements the reviewer should see.

## Step 8 — Report

Report to the user:
- N comments accepted (with one-line path + decision rationale per accept)
- M comments rejected (with one-line path + rejection rationale per reject)
- Threads remaining open (the M rejected ones)
- Commit hash + push status
- Reviewer results (Sentinel + Probe + Hone)

This skill does NOT update the PR description, does NOT re-request review, does NOT close the PR. Those are user actions.
