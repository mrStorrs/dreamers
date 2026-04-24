# Delegation Protocol

Each Agent tool invocation must include in the prompt:
- **Context** — what this agent is being asked to do and why
- **Prior work** — what was done previously (by whom, and absolute paths to any output files to read)
- **What is needed** — specific deliverable expected from this agent
- **Constraints** — hard rules the agent must not violate
- **Definition of Done** — how to know the work is complete
- **Plan file paths** — absolute paths to relevant plan file(s)

## Agent selection

Use the right agent for the job:
- **Forge** (Sonnet) — implementation, code changes
- **Sentinel** (Sonnet) — code review
- **Probe** (Sonnet) — test writing and strategy
- **Echo** (Haiku) — documentation
- **Nova** (Opus) — replanning between sub-plans only
- **Bolt** (Haiku) — mechanical execution: run tests, git push, PR creation, issue closing, build commands, type-checks. Use Bolt for anything that requires zero reasoning.

**Rule of thumb:** If the task requires judgment, use the appropriate specialist. If it's just executing a command and reporting output, use Bolt.

## Conflict resolution

If agents produce conflicting outputs, summarize the tradeoffs, recommend a decision, and record it in `decisions.md`.
