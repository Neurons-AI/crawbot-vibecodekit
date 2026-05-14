---
name: vibe-builder
description: Build small personal apps and prototypes with a hybrid vibe-coding workflow. Use when the user asks to make, scaffold, vibe code, prototype, or iterate a small personal app/tool/dashboard/mobile app, and needs a decision on whether the main assistant should code directly or delegate execution to Codex/Claude/acpx. Guides the assistant to keep product taste/context while using coding harnesses only when task size, complexity, or debugging needs justify it.
---

# Vibe Builder

Use this skill to turn a casual app idea into a working personal prototype without over-delegating or over-engineering.

## Core stance

Default to **main assistant as product lead + taste keeper**.

Choose execution mode per task:

- **Direct mode**: main assistant codes directly for small, clear, low-risk changes.
- **Delegate mode**: use acpx/Codex/Claude for heavy multi-file implementation, long debug loops, or large refactors.
- **Hybrid mode**: main assistant designs/scaffolds/reviews; harness implements bounded tasks.

Do not throw the whole product at a harness and hope. Keep intent, scope, and acceptance criteria in the main conversation.

## Mode selection rule

Use **direct mode** when most are true:

- Expected work <2 hours.
- App is small: 1–5 screens or a narrow tool.
- Repo is new or easy to inspect.
- Few dependencies and no native build weirdness.
- Product taste matters more than brute-force code volume.
- User wants fast interactive iteration.

Use **delegate mode** when any are true:

- Expected work >2 hours.
- Many files/modules or broad refactor.
- Build/test/lint/debug loop may take many rounds.
- Native mobile, Expo dependency, auth, storage, charts, payments, sync, or platform-specific bugs are involved.
- Need parallel feature work.
- Need fresh-agent review or install simulation.

Use **hybrid mode** by default for real apps:

1. Main assistant clarifies goal and defines MVP.
2. Main assistant writes/updates product brief and acceptance criteria.
3. Main assistant directly creates scaffold or minimal vertical slice when small.
4. Delegate bounded implementation tasks to acpx/Codex/Claude when work gets heavy.
5. Main assistant reviews diff, runs verification, fixes taste issues, and reports.

## App planning template

Before coding, produce this compact brief unless the user explicitly asks to skip planning:

```md
## Goal
<one sentence>

## MVP
- <screen/feature>
- <screen/feature>

## Not in v1
- <defer>

## Tech choice
<framework + why>

## Execution mode
Direct | Hybrid | Delegate — <reason>

## Acceptance checks
- <manual or automated check>
- <manual or automated check>
```

Keep this brief in the chat or write it to `docs/vibe-brief.md` for projects that will continue across sessions.

## Recommended stacks

Prefer boring, easy-to-run stacks:

- **Static/simple web app**: Vite + React + TypeScript.
- **Personal dashboard/tool**: Next.js only if server/API routes are actually useful; otherwise Vite.
- **Mobile prototype for iPhone testing**: React Native + Expo + Expo Go.
- **Local scripts/automation**: Node.js script with clear CLI args.
- **Data-heavy prototype**: local JSON/SQLite first; avoid cloud until needed.

## Delegation prompt pattern

When delegating to acpx/Codex/Claude, make the task bounded:

```md
You are implementing one bounded part of this app.

Context:
- Goal: ...
- Current stack: ...
- User taste: pragmatic, minimal, works end-to-end.

Task:
- Implement ...

Constraints:
- Do not change unrelated files.
- Keep commands reproducible.
- Add/update minimal tests or doctor checks if practical.
- Do not introduce paid/cloud services unless explicitly requested.

Acceptance:
- ...

When done:
- Summarize changed files.
- Include commands run and any failing checks.
```

For ACP harness requests, use OpenClaw ACP runtime/acpx flow per environment policy. Do not use raw PTY scraping when ACP is available.

## Verification discipline

Always verify with at least one of:

- `npm run build`
- `npm run lint`
- `npm test`
- `node scripts/doctor.mjs`
- framework-specific smoke test
- manual browser/app launch check when UI matters

If verification is impossible, say why and provide exact next command for the user/agent.

## Output style to user

Be concise and practical:

- What mode you chose and why.
- What you changed or delegated.
- How to run it.
- What passed/failed.
- Next suggested step.

## Reference

For more detailed heuristics and examples, read `references/mode-heuristics.md` only when deciding a borderline task or teaching the workflow.
