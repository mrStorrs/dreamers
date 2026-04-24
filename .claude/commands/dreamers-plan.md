Read these refs before starting:
- `~/.claude/dreamers/refs/planning-protocol.md`
- `~/.claude/dreamers/refs/plan-rules.md`
- `~/.claude/dreamers/refs/feature-decomposition.md`
- `~/.claude/dreamers/refs/plan-content.md`
- `~/.claude/dreamers/refs/testing-mandate.md`
- `~/.claude/dreamers/refs/citation-accuracy.md`

Follow the Dreamers Kernel and output discipline from `CLAUDE.md`.

Produce a plan only for the following task. Do not proceed to implementation.

$ARGUMENTS

Run the full requirements conversation directly with the user:
- Phase 1: Hash it out — ask clarifying questions (one round)
- Phase 2: Present the approval gate — wait for explicit user approval
- Phase 3: Write the plan file(s)

This is a direct conversation. When the user approves the plan, write the plan files and present the file path(s). Stop after planning — do not invoke Forge or any other agent.
