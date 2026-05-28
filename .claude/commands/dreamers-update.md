Project-only meta-edit skill for the Dreamers Claude system. Sets directory scope, claude-not-copilot framing, style standards, and sync rules for editing the Dreamers source repo at `C:/projects/dreamers/`.

Follow the Dreamers Kernel and output discipline from `CLAUDE.md`.

$ARGUMENTS

If no task description was provided, halt + ask via `AskUserQuestion`.

## Scope (hard rules)

1. **This project directory only.** Stay inside `C:/projects/dreamers/`. Do not hand-edit `~/.claude/` — `Install-Dreamers.ps1` propagates changes from this repo. Do not reach into other projects unless the user names a path.
2. **Claude Code, not Copilot CLI.** Runtime tools: `Agent`, `AskUserQuestion`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Bash`, `TaskCreate`, `TaskUpdate`. Do not import Copilot CLI conventions (`task()`, `request_information`, `view`, `manage_todo_list`).
3. **Subagent allowlist (HARD RULE).** Delegate Dreamers work only to: forge / sentinel / probe / hone / echo / sage / bolt / nova. NEVER general-purpose / claude.
4. **Halt on ambiguity.** One `AskUserQuestion` round, not a chain of guesses.

## Style (apply to every edit)

- Minimal. To the point. No fluff.
- Structured but not over-structured. Headings where they aid scanning, not for ceremony.
- Written for AI consumers, not human reading. Optimize for clarity-per-token. No restating the obvious, no "Note that...", no marketing tone.
- Prefer editing existing files. Match the tone of sibling commands (terse, declarative, bullet-heavy, body-only — no frontmatter).
- The harness does the work. These files are guides + standards, not procedures the LLM follows blindly.

## Sync rules (after any edit)

1. **Refs are source-of-truth and referenced by absolute path.** Commands and agents read `~/.claude/dreamers/refs/<name>.md` at runtime — NOT inlined. Edit refs in `.claude/dreamers/refs/` directly; consumers pick up changes via path reference. No drift mechanism, no sync script.
2. **Agent definitions in `.claude/agents/`.** If you rename an agent, change its tool list, or change its responsibilities, audit every command in `.claude/commands/` for references and update them.
3. **Route consistency across commands.** `dreamers-full` and `dreamers-atlas-choice` both declare pipeline routes (Forge → Sentinel → Probe → ...). Change one route → audit the others.
4. **README sync.** Update `README.md` when adding/removing/renaming a command or agent, when a route changes, or when repo structure changes.

## Git / PR

- Branch: `feat/<slug>` or `fix/<slug>` cut from fresh `origin/main`.
- Stage files by name. No `git add -A`.
- Commit trailer matches existing repo style (verify with `git log -3` if unsure):
  ```
  Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
  ```
- One PR per logical change. Combine related fixes.
- No `--no-verify`, no force-push, no destructive ops without explicit user request.

## Exit

Report in chat: files changed, sync checks performed (refs / agents / route consistency / README), halts or questions raised.
