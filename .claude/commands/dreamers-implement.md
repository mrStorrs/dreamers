Read these refs before starting:
- `~/.claude/dreamers/refs/git-workflow.md`
- `~/.claude/dreamers/refs/quality-gates.md`
- `~/.claude/dreamers/refs/delegation.md`
- `~/.claude/dreamers/refs/close-out.md`
- `~/.claude/dreamers/refs/agent-recovery.md`

If the plan has sub-plans, also read:
- `~/.claude/dreamers/refs/sub-plan-loop.md`

Follow the Dreamers Kernel and output discipline from `CLAUDE.md`.

A plan already exists. Go straight to implementation for the following task:

$ARGUMENTS

The prompt must include a path to the existing plan file. If no plan file path is provided, stop and ask for it before proceeding — do not invent or skip the plan.

**User Input Audit (before Gate 2):** Review the entire conversation thread. For every suggestion, correction, preference, or constraint the user expressed, confirm it is explicitly addressed in the plan file. If anything is missing, update the plan to incorporate it before proceeding. Do not skip this step.

**Single plan route:** Forge → Sentinel → Probe → Simplify → Echo → Close-out (Bolt handles push + PR)
**Sub-plan route:** Loop per sub-plan (see sub-plan-loop.md), then Simplify → Echo → Close-out (Bolt handles push + PR)

Run Gate 2 (plan quality check) first. Run quality gates at every handoff boundary. Follow delegation.md for all agent invocations (use Bolt for mechanical tasks like test runs, git push, PR creation, issue closing). Follow git-workflow.md for branching, commits, and push discipline. Follow close-out.md for retro and PR creation.

**Before PR creation:** Run `/dreamers-simplify` to review changed code for reuse opportunities, quality issues, and efficiency improvements. Fix any issues found. Then invoke Echo to update project docs before proceeding to close-out.

If the prompt references a GitHub issue number or URL, pass it to Bolt at close-out to close: `gh issue close <number> --comment "Resolved in <PR URL>"`.
