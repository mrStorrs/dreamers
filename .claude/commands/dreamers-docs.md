---
description: 'Docs skill — spawns Echo to update Echo-owned sections of CLAUDE.md plus other project docs (README, CHANGELOG) affected by recent changes. Echo stages edits; does not commit. Triggers: /dreamers-docs, update docs, echo docs update.'
---

$ARGUMENTS

## Todo - Before you begin.
- Declare a todo list marking all steps at entry: Step 1 / Step 2 / Step 3.

## Step 1 — Resolve diff scope
- `--branch` (default): scope = `git diff --name-only origin/$DEFAULT...HEAD`.
- `--staged`: scope = union of `git diff --cached --name-only` and `git diff --name-only`.
- If the changed-files list is empty → output `No changes detected` and exit.

## Step 2 — Spawn Echo
- `Agent` invocation with `subagent_type: "echo"`. Prompt MUST include `Do NOT call TaskCreate / TaskUpdate / TaskList.`
- Pass: context (ad-hoc or milestone close-out — caller-supplied), changed-files list, diff base, plan paths (if applicable), prior review summary (if applicable).
- Constraint to Echo: edits docs only — no production code, no tests. Stage with `git add`; do NOT commit.
- Wait for Echo to return its structured chat output.

## Step 3 — Handle output
- `Docs updated — N files changed` → surface doc-changes log to user.
- `No doc updates needed` → exit.
- Open questions → present each via `AskUserQuestion`; capture answers; re-spawn Echo with clarification if needed.

## Exit
- Files Echo touched. The caller commits (this skill does NOT commit, push, or open a PR).

## Dreamers Kernel
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
