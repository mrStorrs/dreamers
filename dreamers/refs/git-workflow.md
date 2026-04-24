# Git Workflow (mandatory)

Every milestone uses a feature branch + PR — never work directly on main.

## Startup verification (do this FIRST)
1. `git fetch origin && git log origin/main --oneline -5` — anchor to remote truth before reading any `.dreamers/` files. Workspace files are local-only and may be stale. `origin/main` is the authoritative record of what is actually shipped.

## Branch setup (before invoking Forge)
1. `git checkout main && git pull origin main` — never build off a stale local main.
2. Cut `feat/d<N>-<name>` from main.
3. Review all persistent workspace files across agents (`assumptions.md`, `decisions.md`, `questions.md`, `links.md`) — prune stale/resolved entries.
4. Wipe all live files across **all** agents — every file in this list must be reset to "No active work / No pending items":
   - `forge/status.md`, and any `forge/implementation*.md`
   - `probe/status.md`, `probe/bugs.md`, `probe/test-plan.md`, `probe/runbook.md`, and any `probe/*-test-plan.md`
   - `sentinel/status.md`, `sentinel/findings.md`, `sentinel/review.md`
   If any file still contains prior-milestone content after this step, it is a protocol failure.
   **Wipe mechanism:** Use Bash `printf 'content' > path` for each file — do NOT use the Write tool for wipes.
5. **Clean up prior feature's plan files** — check if the previous feature's PR is merged (`gh pr list --state merged` or `gh pr view <number>`):
   - **Merged:** delete all plan files for that feature from `.dreamers/plans/`. The PR description is the lasting record.
   - **Not merged:** leave plan files in place.
6. No init commit — Forge's first commit is the first thing in the PR diff.

## Commit discipline (non-negotiable)
1. **Commit at end of each sub-plan** — after Probe passes (and user sign-off if required).
2. **Commit before PR creation** — a final commit capturing any last changes before opening the PR.
3. **No auto-commit after PR is created** — if changes are made after `gh pr create`, do NOT commit automatically. Ask the user first.

## Push discipline (non-negotiable)
`git push` happens EXACTLY ONCE — immediately before `gh pr create` at final close-out. Never push after intermediate commits, between sub-plans, or at any other point in the pipeline.

## Post-PR push discipline
If the user approves a post-PR commit, push with `git push` (no force). The PR will update automatically.

## Commit structure (separate commits, not squashed)
- `feat(D<N>): initial implementation` — Forge first pass
- `fix(D<N>): sentinel blockers round N` — one commit per fix round (Probe edge tests land here too)

Separate commits make fix history a quality signal — track how many rounds each milestone needs.

## What gets committed
Nothing in `.dreamers/` is committed — all workspace files are gitignored and stay local. Ensure `.dreamers/` is in the project's `.gitignore`.

## No worktrees
Forge works directly on the feature branch. Worktrees caused Sentinel/Probe to read stale main-branch code.

## Git history is the archive
No separate archive directories. `git log` and PR diffs are the record.
