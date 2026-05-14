# CrawBot VibeCode Kit

A small, agent-readable starter kit for setting up a CrawBot/OpenClaw vibe-coding workspace.

The repo is intentionally structured so a coding agent can be given only this URL and still know how to install it:

```text
https://github.com/Neurons-AI/crawbot-vibecodekit
```

## Quick install

### macOS / Linux / WSL

```bash
git clone https://github.com/Neurons-AI/crawbot-vibecodekit.git
cd crawbot-vibecodekit
bash scripts/install.sh
node scripts/doctor.mjs
```

### Windows PowerShell

```powershell
git clone https://github.com/Neurons-AI/crawbot-vibecodekit.git
cd crawbot-vibecodekit
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
node scripts/doctor.mjs
```

## For agents

If you are an AI coding agent asked to install this kit:

1. Read [`AGENTS.md`](./AGENTS.md) first.
2. Read [`agent-install.json`](./agent-install.json) for machine-readable install metadata.
3. Run the install command for the detected OS.
4. Run `node scripts/doctor.mjs` and report the result.
5. Do not overwrite existing user files without making a backup.

## What this kit provides

```text
.
├── AGENTS.md                 # Human/agent operating instructions
├── agent-install.json        # Machine-readable install manifest
├── skills/
│   └── vibe-builder/         # Hybrid direct/delegated app-building skill
├── templates/                # Files copied into a workspace
│   ├── AGENTS.md
│   ├── HEARTBEAT.md
│   ├── vibe-workflow.md
│   └── skills/vibe-builder/
└── scripts/
    ├── install.sh            # macOS/Linux/WSL installer
    ├── install.ps1           # Windows installer
    └── doctor.mjs            # Post-install health check
```

## Default install location

The installer copies templates into the current directory by default. Override with:

```bash
CRAWBOT_KIT_TARGET=/path/to/workspace bash scripts/install.sh
```

or PowerShell:

```powershell
.\scripts\install.ps1 -Target "C:\path\to\workspace"
```

## Design goals

- Agent-first: clear instructions, predictable scripts, minimal guessing.
- Idempotent: safe to run repeatedly.
- Cross-platform: macOS, Linux/WSL, Windows PowerShell.
- Non-destructive: existing files are backed up before replacement.
