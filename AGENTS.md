# AGENTS.md — CrawBot VibeCode Kit

This repository is designed to be installed by humans **or** coding agents.

## Install protocol for agents

When a user gives you this repo URL and asks you to install/setup the kit:

1. Clone the repo.
2. Read `agent-install.json`.
3. Detect the operating system.
4. Run the matching install command:
   - macOS/Linux/WSL: `bash scripts/install.sh`
   - Windows PowerShell: `powershell -ExecutionPolicy Bypass -File scripts/install.ps1`
5. Run `node scripts/doctor.mjs`.
6. Summarize exactly what changed and any remaining manual steps.

## Safety rules

- Do not delete user files.
- If a target file already exists, back it up with a timestamped `.bak-YYYYMMDD-HHMMSS` suffix before replacing it.
- Prefer deterministic scripts over manual edits.
- Keep changes small and explainable.

## Expected result

After installation, the target workspace should contain:

- `AGENTS.md` — workspace guidance for coding agents.
- `HEARTBEAT.md` — lightweight proactive maintenance prompt.
- `docs/vibe-workflow.md` — CrawBot vibe-coding workflow notes.

## Development notes

- Keep install scripts idempotent.
- Keep `agent-install.json` in sync with README commands.
- Run `node scripts/doctor.mjs` before committing.
