# Dreamers

An agent orchestration system for Claude Code. Dreamers coordinates specialized AI agents through structured pipelines — planning, implementation, review, testing, and documentation — to deliver production-grade code changes.

## Structure

```
agents/           # Agent definitions (Forge, Sentinel, Probe, Echo, Nova, Bolt, Sage, Hone)
commands/         # Skill entry points for each pipeline (dreamers-full, dreamers-fix, etc.)
dreamers/
├── refs/         # Shared reference docs (delegation protocol, git workflow, quality gates, etc.)
└── templates/    # Plan templates, PR descriptions, logging standards
```

## Agents

| Agent | Role | Model |
|-------|------|-------|
| **Forge** | Coder — implements changes against a plan | Sonnet |
| **Sentinel** | Reviewer — correctness, security, maintainability | Sonnet |
| **Probe** | Tester — derives tests from acceptance criteria | Sonnet |
| **Echo** | Documentarian — READMEs, changelogs, ADRs | Haiku |
| **Nova** | Replanner — re-verifies remaining plans between sub-plan cycles | Opus |
| **Bolt** | Runner — git ops, test execution, PR creation | Haiku |
| **Sage** | Researcher — deep multi-perspective research | Sonnet |
| **Hone** | Simplifier — readability, maintainability, redundancy reduction | Sonnet |

## Skills (Pipelines)

| Skill | Purpose |
|-------|---------|
| `dreamers-full` | Full pipeline: plan, implement, review, test, document, PR |
| `dreamers-plan` | Planning only — produce a plan without implementing |
| `dreamers-implement` | Implement an existing approved plan |
| `dreamers-fix` | Bug triage and fix |
| `dreamers-research` | Deep research with phased workflow |
| `dreamers-simplify` | Code simplification pass (Hone + Sentinel + Probe) |
| `dreamers-pr-resolve` | Resolve PR review comments |
| `dreamers-issue` | Create structured GitHub issues |
| `dreamers-new-project` | Bootstrap a new project |
| `dreamers-cleanup-comments` | Code comment cleanup pass |
| `dreamers-clean-work` | Between-milestone maintenance |
| `dreamers-add-logging` | Add production-grade logging |
| `dreamers-atlas-choice` | Route to the correct pipeline |

## Install

Install agents, commands, and refs into your global `~/.claude/` directory:

```powershell
.\Install-Dreamers.ps1
```

Options:
- `-Force` — overwrite existing files without prompting
- `-ClaudeHome "D:\custom\.claude"` — install to a custom location

The installer manages your `CLAUDE.md` safely:
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

The uninstaller strips only the marked Dreamers section from `CLAUDE.md` — your personal instructions remain intact.

## Project setup

When bootstrapping a new project to use Dreamers:

1. Ensure `.dreamers/` is in the project's `.gitignore`
2. Create the project-level `CLAUDE.md` with tech stack, conventions, and distribution info
3. Create `.dreamers/plans/` directory for plan files

## Core principles

- **Markdown-first** — substantive work goes to files, not chat
- **Plan before you build** — non-trivial work requires a plan file
- **Critical thinking mandate** — agents evaluate before executing, push back on flawed ideas
- **Keep context thin** — git history is the archive; prune live files regularly
