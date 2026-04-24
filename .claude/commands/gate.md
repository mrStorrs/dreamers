Set the ai-gate mode. Usage: `/gate <mode>` — modes: `yolo` (approve all), `ask` (ask-list only), `on` (full pipeline)

$ARGUMENTS

---

## Modes
- **yolo** — approve everything unconditionally (no ask list, no AI check)
- **ask** — approve everything except ask-list items (skip Haiku AI check)
- **on** — full pipeline: ask list → allow list → Haiku AI check (default)

## Instructions

1. Parse the argument. Valid values: `yolo`, `ask`, `on`. If no argument or invalid, show the current mode and list the three options.
2. Write the mode value to `C:/Users/cjsto/.claude/hooks/ai-gate/.mode` (just the mode string, no newline padding).
3. Confirm the change. Be brief — one line.
