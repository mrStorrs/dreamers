# Dreamers

An agent orchestration system for Claude Code. Dreamers runs the planning → tests-first → implementation → parallel-review → docs → PR flow.

## Structure

Everything lives under `.claude/`:

```
.claude/
├── agents/             # Agent definitions (Sentinel, Probe, Hone, Echo, Sage, Bolt)
├── commands/           # Command entry points (/dreamers-*, /gate)
├── dreamers/
│   ├── refs/           # Shared reference docs (inlined into consumers at install time)
│   └── templates/      # Plan-writing guide, PR description shape, etc.
└── CLAUDE.dreamers.md  # Managed section appended to ~/.claude/CLAUDE.md by the installer
```

## Agents

| Agent | Type | Role | Model |
|---|---|---|---|
| **Forge** | Persona | Implementation orchestrator. User-invoked session pre-loaded with the Dreamers pipeline. Routes user intent to the right command. | Sonnet |
| **Nova** | Persona | Planning specialist. Mirrors the `/dreamers-plan` 3-phase flow; hard-stops at the approval gate. | Sonnet |
| **Sentinel** | Subagent | Reviewer — correctness, security, maintainability. Read-only / report-only. | Sonnet |
| **Probe** | Subagent | Reviewer — test coverage (AC matrix, layer audit, edge cases, regression risk). Read-only / report-only. | Sonnet |
| **Hone** | Subagent | Reviewer — simplicity, over-engineering, redundancy, architectural quality. Read-only / report-only; surfaces full-refactor recommendations without softening. | Sonnet |
| **Echo** | Subagent | Documentarian — project docs, README, CHANGELOG, Echo-owned sections of CLAUDE.md. | Haiku |
| **Sage** | Subagent | Researcher — deep multi-perspective research with citation verification. | Opus |
| **Bolt** | Subagent | Runner — mechanical tasks: test runs, git push, `gh pr create`, status checks. Fire-and-forget. | Haiku |

Forge and Nova are personas the user enters when they want a multi-turn session focused on that role. They are NOT spawned by commands. Sentinel + Probe + Hone spawn in parallel per cycle via `/dreamers-review`. Echo spawns per milestone via `/dreamers-docs`. Sage is invoked by `/dreamers-research`. Bolt is invoked from the pipeline commands for mechanical work.

## Commands

### Pipeline

| Command | Purpose |
|---|---|
| `/dreamers-full` | End-to-end pipeline. Invokes `/dreamers-plan`, implements each plan inline (tests-first, Bolt for test runs), invokes `/dreamers-review`, applies findings with major-refactor gate, user-testing gate per plan, then close-out (inline + `/dreamers-docs` + `/dreamers-pr`). |
| `/dreamers-plan` | 3-phase planning (Hash-out → Write → Review). Produces plan file(s) + optional manifest. Hard-stops at the review gate. |
| `/dreamers-implement` | One-shot implementation: write failing tests, implement, run tests via Bolt. Exits at green tests. |
| `/dreamers-review` | Spawns Sentinel + Probe + Hone in parallel; reports structured findings. Read-only. `--lens <name>` for a single-lens audit. |
| `/dreamers-docs` | Spawns Echo to update project docs based on the diff. Stages edits; user commits. |
| `/dreamers-pr` | Pushes the branch (Bolt) and opens the PR using the `pr-description.md` template. |
| `/dreamers-fix` | Self-contained bug-fix pipeline: branch + regression test + implement + run tests via Bolt. Escalates to `/dreamers-full` on scope blowup. |

### Single-lens reviewer wrappers

`/dreamers-review --lens sentinel` (or `probe`/`hone`) covers the same ground. The standalone commands `dreamers-test` (Probe) and `dreamers-simplify` (Hone) remain as convenient aliases.

### Utility + orthogonal

| Command | Purpose |
|---|---|
| `/dreamers-pr-resolve` | Resolve PR review comments inline; parallel review of accepted changes. |
| `/dreamers-add-logging` | Phased pass to add/improve logging per `logging-standards.md`. |
| `/dreamers-cleanup-comments` | Project-wide comment cleanup per `comment-rules.md`. |
| `/dreamers-cleanup-comments-branch` | Same cleanup, scoped to current feature-branch diff. |
| `/dreamers-research` | Deep research via Sage. |
| `/dreamers-issue` | Create structured GitHub issues with acceptance criteria. |
| `/dreamers-new-project` | Bootstrap a brand new project (discovery → stack → brief → shell plans). |
| `/dreamers-plan-verify` | Inline drift check on a plan vs current code. |
| `/dreamers-clean-work` | Between-milestone maintenance (improvements audit, archive, drift scan). |
| `/dreamers-update` | Project-only meta-edit skill for editing the Dreamers Claude system itself. |
| `/gate` | Set the ai-gate mode (`yolo`/`ask`/`on`). Claude-specific. |

## Pipeline shape

```
/dreamers-full <task | plan paths | manifest.md>
  ├─ Phase 1   → /dreamers-plan   (Mode 1 only: 3-phase planning conversation)
  ├─ Phase 1.5 → Ship-strategy gate (multi-plan only: INCREMENTAL vs ATOMIC)
  ├─ Phase 2   → per plan, inline:
  │               1. Write failing tests
  │               2. Implement
  │               3. Type-check + run tests (via Bolt)
  │               4. Invoke /dreamers-review (triad → findings, read-only)
  │               5. Apply findings + major-refactor gate
  │               6. User-testing gate (every plan)
  │               ↳ between cycles: drift check + INCREMENTAL light close-out / ATOMIC continuation
  └─ Phase 3   → close-out (inline + /dreamers-docs + /dreamers-pr)
                   improvements append → Echo docs → retro → final commit
                   → user approval gate → push (Bolt) + PR (Bolt) → plan archive → post-PR scan
```

Each command is independent — no command invokes another mid-flow except `/dreamers-full`, which orchestrates the sequence. Refs in `.claude/dreamers/refs/` are inlined into consumers at install time via `scripts/sync-refs.ps1`. CI's `verify-refs` workflow fails any PR whose inlined content drifts from source.

## Install

Install agents, commands, refs, and templates into your global `~/.claude/` directory:

```powershell
.\Install-Dreamers.ps1
```

Options:
- `-Force` — overwrite existing files without prompting
- `-ClaudeHome "D:\custom\.claude"` — install to a custom location

The installer manages your `~/.claude/CLAUDE.md` safely:
- **New install:** creates the file with the Dreamers section
- **Existing file:** appends a marked Dreamers section (your personal instructions are never touched)
- **Re-install/update:** replaces only the marked section between `DREAMERS-START` / `DREAMERS-END` markers

## Uninstall

Remove only Dreamers-managed files from `~/.claude/`:

```powershell
.\Remove-Dreamers.ps1
```

Options:
- `-DryRun` — preview what would be removed without deleting
- `-ClaudeHome "D:\custom\.claude"` — target a custom location

The uninstaller strips only the marked Dreamers section from `~/.claude/CLAUDE.md` — your personal instructions remain intact.

## Project setup

For a new project that wants to use Dreamers, see [project-bootstrap.md](.claude/dreamers/refs/project-bootstrap.md):

1. Ensure `.dreamers/` is in the project's `.gitignore`.
2. Create the project-level `CLAUDE.md` (auto-loaded by Claude Code).
3. Create `.dreamers/plans/` directory.
