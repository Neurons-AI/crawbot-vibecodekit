# CrawBot Vibe-Coding Workflow

Use this workspace as an agent-friendly project root.

## Recommended loop

1. **Brief** — clarify the goal in one sentence.
2. **Plan** — list the smallest safe steps.
3. **Patch** — change files deterministically.
4. **Verify** — run tests, lint, or a doctor script.
5. **Report** — summarize outcome and next action.

## Agent handoff prompt

Give another agent the repo URL plus this instruction:

> Clone this repo, read `AGENTS.md` and `agent-install.json`, run the install command for this OS, then run the verify command and report results.
