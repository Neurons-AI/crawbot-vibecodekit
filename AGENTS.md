# AGENTS.md — CrawBot Vibe-Coding Workspace

You are working in a CrawBot/OpenClaw vibe-coding workspace.

## Default workflow

1. Inspect the project before changing it.
2. Make small, testable changes.
3. Prefer scripts and reproducible commands over hidden manual steps.
4. Run the relevant checks/tests before reporting done.
5. Summarize files changed, commands run, and remaining risks.

## Coding-agent install convention

If a repo contains `agent-install.json`, read it first and follow its install/verify commands.

## Safety

- Do not overwrite user files without backup.
- Do not commit secrets.
- Use `tmp/` for temporary files.
- Avoid destructive commands unless the user explicitly approves.
