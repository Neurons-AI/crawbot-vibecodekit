# Vibe Builder Mode Heuristics

## Direct mode examples

- Single-page landing page.
- Simple CRUD app with local storage.
- Personal calculator/tracker.
- Script to transform CSV/JSON.
- Small Expo prototype with 1–3 screens and no native modules.

Main assistant should code directly, because context and taste matter more than agent throughput.

## Hybrid mode examples

- Personal finance app with dashboard, transaction entry, categories, charts.
- Course companion app with lessons, exercises, progress, and local persistence.
- Admin dashboard with several pages and reusable components.

Main assistant should own product brief, scaffold, review, and integration. Delegate bounded chunks such as charts, persistence layer, or component library.

## Delegate mode examples

- Existing repo with many files and unknown architecture.
- Multi-screen Expo app with auth/storage/charts/sync.
- Build failures involving native dependencies.
- Large refactor or test suite generation.

Use acpx/Codex/Claude and keep the task bounded with acceptance criteria.

## Escalation triggers

Start direct, then escalate to delegate if:

- The same bug survives two fix attempts.
- Build/test output is long and requires iterative debugging.
- The change touches more than ~8 files.
- The user asks to continue while main assistant should stay responsive.

## De-escalation triggers

Take work back from harness if:

- It changes unrelated files.
- It ignores product taste or acceptance criteria.
- It adds unnecessary infra/cloud dependencies.
- It cannot explain failures clearly.
