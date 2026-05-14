---
name: vibe-builder
description: Build, grow, and let CrawBot manage small personal apps for non-technical users with a friendly question-first vibe-coding workflow. Use when the user asks to make, scaffold, vibe code, prototype, iterate, fix, add features to, start/stop, or manage a personal web/desktop/mobile app. Covers simple product questions, platform choice (web/desktop/mobile), automatic tech-stack selection, local data storage, built-in user instructions, automatic bug-fix loops, safe feature-addition workflow, schema migrations, in-app error reporting, and CrawBot project lifecycle (vibe-app.json manifest, projects/ workspace, start/stop scripts).
---

# Vibe Builder

Turn a casual personal app idea into a working prototype for a non-technical user — and keep growing it safely over time.

## Core stance

Default to **main assistant as product lead + taste keeper + safety net**.

The user should not need to understand frameworks, databases, Docker, or build tooling. Ask simple product questions, translate answers into technical choices, then build or delegate. Always assume the user cannot read stack traces and cannot recover a broken app on their own.

Execution modes:

- **Direct mode**: small, clear, low-risk apps.
- **Delegate mode**: heavy multi-file implementation, long debug loops, large refactors.
- **Hybrid mode** (default for real apps): main assistant designs/scaffolds/reviews; harness implements bounded tasks.

Never throw the whole product at a harness. Keep user intent, scope, acceptance criteria, and bug-fix decisions in the main conversation.

## Two entry workflows

This skill handles two situations. Detect which one first.

### A) New app

User wants something that does not exist yet. Use the **First questions** section below.

### B) Existing app — add feature / fix bug / change behavior

User already has a project from this skill (or similar). Before anything:

1. Read `docs/vibe-brief.md` if present — that is the source of truth for goal/scope/stack.
2. Read `docs/vibe-changelog.md` if present — see what shipped already.
3. Glance at `package.json`, top-level folder structure, and the main screen file(s).
4. Ask at most **1–2 plain questions** to clarify the request. Examples:
   - “Anh muốn thêm trang quản lý khách hàng vào app chi tiêu, hay là app riêng?”
   - “Tính năng mới này có cần lưu thêm dữ liệu gì không?”
5. Produce a **Change brief** (template in `references/feature-add.md`) before coding.
6. Commit current state to git first (safety net). Then implement. Then verify. Then update brief + changelog + help section.

Never start editing an existing app without (a) committing current state and (b) writing the change brief.

## First questions for new apps

Ask only the minimum. Plain language.

1. **App này dùng để làm gì?**
2. **Anh/chị muốn dùng app ở đâu?** Web / Desktop / Mobile.
3. **Dữ liệu cần lưu gì?**
4. **Ai dùng app này?** Cá nhân / gia đình / team / nhiều người.
5. **Màn hình quan trọng nhất là gì?** Đề xuất 2–4 nếu user chưa biết.

If user already answered some, do not re-ask. Make a reasonable choice and say it plainly.

## Non-technical planning template

Before coding, produce this compact brief unless user says skip. Write to `docs/vibe-brief.md` for any project that may continue.

```md
## App mình sẽ làm
<one sentence in user language>

## Dùng ở đâu
Web | Desktop/laptop | Mobile/tablet — <plain-language reason>

## Bản đầu tiên có gì
- <screen/feature>

## Tạm chưa làm
- <defer>

## Cách lưu dữ liệu
<plain VN: lưu trong máy / file local / SQLite / schema sơ bộ>

## Hướng dẫn trong app
App có mục “Hướng dẫn sử dụng” và nút “Báo lỗi”.

## Cách bé làm
Direct | Hybrid | Delegate — <reason>

## Kiểm tra xong khi
- <smoke test passes>
- <manual or automated check>
- <built-in help present>
```

## Project location & CrawBot integration

Every app built by this skill **must** live inside the agent workspace so CrawBot can manage it:

```
<workspace>/projects/<app-slug>/
```

- `<app-slug>` is kebab-case, derived from the user-facing name (e.g. "App quản lý chi tiêu" → `quan-ly-chi-tieu`).
- Never scaffold outside `<workspace>/projects/`. If user asks for another path, explain CrawBot won't see/manage it and recommend the default.
- One app per folder. No monorepos here.

### `vibe-app.json` manifest (mandatory)

At project root. CrawBot reads this to show the app in its UI with start/stop buttons. Schema:

```json
{
  "$schema": "vibe-app/v1",
  "slug": "quan-ly-chi-tieu",
  "name": "App quản lý chi tiêu",
  "description": "App ghi chép thu chi cá nhân, lưu trong máy.",
  "version": "0.1.0",
  "platform": "web",
  "icon": "icon.png",
  "createdAt": "2026-05-15T04:40:00+07:00",
  "stack": ["next.js", "tailwind", "sqlite"],
  "runtime": {
    "node": ">=20",
    "packageManager": "npm"
  },
  "scripts": {
    "install": "npm install",
    "dev": "npm run dev",
    "start": "npm start",
    "stop": null,
    "build": "npm run build",
    "doctor": "node scripts/doctor.mjs",
    "smoke": "node scripts/smoke.mjs"
  },
  "url": "http://localhost:3000",
  "ports": [3000],
  "openOnStart": true,
  "dataPaths": ["data/app.db", "data/backups/"],
  "helpRoute": "/huong-dan",
  "bugReportRoute": "/report-bug",
  "rollbackHint": "Nhắn bé Amagi 'hoàn tác thay đổi cuối'."
}
```

Field rules:

- `platform`: `web` | `desktop` | `mobile`.
- `scripts.dev`/`scripts.start`/`scripts.stop`: shell commands CrawBot will spawn. Set `stop: null` if a SIGTERM on the started process is enough (most cases).
- `url`: web URL to open when app is started (`http://localhost:<port>`). For mobile, set to the Expo URL pattern or `null`.
- `ports`: ports the app will bind; CrawBot uses this to detect collisions.
- `openOnStart`: CrawBot opens `url` in the user's browser/Expo Go after start succeeds.
- `dataPaths`: relative paths CrawBot exposes in a "Backup data" action.
- `helpRoute` / `bugReportRoute`: routes where in-app help and bug reporter live (web). For mobile/desktop use screen names instead.

Update the manifest on every change: version bump, new ports, new data paths, route changes.

### Lifecycle contract for CrawBot

Each app must guarantee:

1. `scripts.install` is idempotent — re-running does not break state.
2. `scripts.dev` (or `start`) prints something like `ready`/`listening`/`started` to stdout within 30 seconds. CrawBot uses this to mark the app as "running".
3. Process responds to SIGTERM by shutting down cleanly within 10 seconds. If not, CrawBot will SIGKILL.
4. App writes data only inside its own folder (`data/`, `bug-reports/`, etc.). No writes outside the project dir.
5. Port from `ports[0]` is configurable via `PORT` env var so CrawBot can avoid collisions:
   ```js
   const port = Number(process.env.PORT ?? 3000);
   ```
6. Logs go to stdout/stderr (no custom log files needed — CrawBot captures the stream).

### Platform-specific lifecycle notes

**Web (Next.js):**
- `dev`: `next dev -p $PORT`
- `start`: `next start -p $PORT` (after `next build`)
- CrawBot opens `http://localhost:$PORT` automatically.

**Desktop (Electron/RN-desktop):**
- `dev`: launch in dev mode.
- `start`: launch packaged binary if available, else dev mode.
- No URL; CrawBot just runs the process and shows logs.

**Mobile (Expo):**
- `dev`: `expo start --tunnel` so QR works regardless of network.
- `start`: same as dev (no separate prod local run).
- `url`: leave `null`; CrawBot surfaces the Expo QR/link from stdout instead.

## Project state files (must keep updated)

Every project from this skill has these files. Agent updates them automatically after any change.

- `vibe-app.json` — CrawBot manifest (see above). Must exist and stay in sync.
- `docs/vibe-brief.md` — current goal, stack, scope. Source of truth.
- `docs/vibe-changelog.md` — plain-VN list of shipped changes, newest first. One bullet per change.
- `docs/install-desktop.md` or `docs/install-mobile.md` — non-tech install/share guide (see Platform mapping).
- `scripts/doctor.mjs` — env/setup health check.
- `scripts/smoke.mjs` — runtime smoke test (boot app, hit main route/screen, check DB if any). Agent runs this before declaring done.

If any of these are missing in an existing project the user brought back, recreate them on first interaction.

## Platform-to-stack mapping

### Web app

Default stack:

- Node.js + Next.js + Tailwind CSS.
- SQLite for local data.
- Local files/config for uploads/exports/settings.
- Docker only if user wants the app to run as a background service.
- Auto-start support (LaunchAgent / Startup folder / systemd user) only if requested.

Rules:

- Local-first by default. No cloud accounts unless asked.
- Always ship `scripts/doctor.mjs` + `scripts/smoke.mjs`.
- `npm start` must work from a clean clone after `npm install`.

### Desktop/laptop app

Default stack:

- React Native desktop or Electron (whichever fits the environment).
- SQLite for local data.

Rules:

- Prefer simple packaging first.
- If desktop-native is too heavy, recommend web app + auto-start as a simpler v1 and say so plainly.

**Required `docs/install-desktop.md` (non-tech)**, also surfaced in the app's “Hướng dẫn sử dụng”:

- Download link + exact installer filename per OS (`MyApp-1.0.0-Setup.exe`, `.dmg`, `.AppImage`).
- Open/install steps with OS security warnings (SmartScreen “More info → Run anyway”, macOS right-click → Open, `chmod +x` AppImage).
- How to launch after install.
- How to update.
- How to uninstall.
- Where local data is stored for backup.

Never tell non-tech to clone a repo or run `npm` manually.

### Mobile/tablet app

Default stack:

- React Native + Expo + Expo Go for testing.
- Embedded SQLite for local data.
- Expo-compatible libs only. Avoid native modules unless required.

**Required `docs/install-mobile.md` (non-tech)** with two clearly labeled blocks:

```md
## Người làm app chạy
- npx expo start
- Lấy QR code / link
- (Optional) eas update để có link bền

## Người dùng làm
1. Cài Expo Go từ App Store / Google Play.
2. Mở Expo Go.
3. Quét QR hoặc paste link.
4. Đợi app load lần đầu.
```

Also cover: cách chia sẻ (QR / `eas update` / `eas build` cho TestFlight/APK), cách cập nhật, lỗi thường gặp (Wi-Fi, tunnel mode, QR iPhone).

**Cost & store reality check (must say up-front if relevant):**

- Expo Go: miễn phí, chỉ dev/test, không publish App Store được.
- `eas build` standalone iOS → App Store: cần Apple Developer Program **$99/năm**.
- Android APK: miễn phí, gửi file trực tiếp được.
- Nếu user non-tech và chỉ muốn cá nhân dùng → khuyên Expo Go + `eas update` link, đừng vẽ ra App Store.

## Built-in help + error reporter requirement

Every app must include:

1. **Hướng dẫn sử dụng** — visible page/modal/menu. Explains:
   - App này dùng để làm gì.
   - 3–5 bước sử dụng cơ bản.
   - Dữ liệu lưu ở đâu.
   - Cách backup/export nếu có.
   - Cách báo lỗi (link tới nút Báo lỗi).

2. **Nút “Báo lỗi” (bug reporter for non-tech)** — visible somewhere in the app (footer / settings / help page). When clicked it:
   - Collects: app version, OS info, last N console logs/errors, current route/screen, optional user note.
   - Saves to a local file (`bug-reports/<timestamp>.txt`) and copies to clipboard.
   - Shows the user a friendly screen: “Đã copy báo cáo lỗi. Paste vào chat với bé Amagi (hoặc agent) để bé fix.”
   - On web: include a small textarea for the user to type what they were doing.

Skill must scaffold this reporter as part of the first build, not as an afterthought.

Do not ship without help section + bug reporter unless user explicitly removes them.

## Mode selection rule

**Direct** when most are true: <2h work, 1–5 screens, narrow tool, easy repo, few deps, no native build weirdness, taste-heavy, fast iteration.

**Delegate** when any: >2h work, many files/modules, broad refactor, long build/test/debug loop, native mobile/Expo/auth/storage/charts/payments/sync/Docker/auto-start, parallel feature work, fresh-agent review.

**Hybrid** (default for real apps):

1. Main assistant asks product/platform questions.
2. Main assistant writes/updates brief + acceptance checks.
3. Main assistant scaffolds or does minimal vertical slice when small.
4. Delegate bounded tasks to acpx/Codex/Claude when heavy.
5. Main assistant reviews diff, runs verification (incl. smoke + auto bug-fix loop), checks help + reporter, fixes taste, reports.

## Git safety net (mandatory)

Before any destructive or feature-adding work on an existing project:

1. `git status` — show user what's dirty in plain VN if anything.
2. If dirty, ask: “Anh muốn em lưu lại tình trạng app hiện tại trước không?” → commit with message `wip: pre-feature snapshot`.
3. Always create a checkpoint commit before starting: `chore: checkpoint before <feature>`.
4. After feature done + verified, commit: `feat: <plain-VN summary>`.
5. Expose a simple rollback path. Document in `docs/vibe-brief.md`:
   - “Để hoàn tác thay đổi cuối: chạy `git reset --hard HEAD~1` trong thư mục app, hoặc nhờ bé Amagi 'hoàn tác thay đổi cuối'.”

If project is not a git repo yet → `git init` + initial commit on first scaffold. Never skip this.

## Data migration discipline

When a feature changes SQLite schema (new column, new table, renamed field):

1. Backup current DB file before migration: `data/app.db` → `data/backups/app-<timestamp>.db`.
2. Write idempotent migration script in `migrations/<NNN>-<name>.sql` (or JS).
3. Bump app data version in a `meta` table or config.
4. App must auto-run pending migrations on boot.
5. Restore plan documented in `docs/vibe-brief.md`: where backups live + how to swap one in.
6. If migration is risky, smoke-test with backup → restore → re-migrate before declaring done.

Never `DROP COLUMN` or rename destructively without backup. Prefer additive changes.

## Dependency conservatism

- Don't add a new library if the existing stack / Expo SDK / Next.js / Node builtin can do it acceptably.
- New dependency must be: actively maintained (commit in last 12 months), Expo-compatible if mobile, no native build step unless required.
- Lock versions (`^` ok, no `*`).
- After adding any dep: run install + smoke + build to confirm nothing broke. If anything breaks → revert the dep.

## Verification discipline (must run, in order)

For every change (new app or feature add):

1. **Lint/typecheck** if available: `npm run lint`, `tsc --noEmit`.
2. **Build**: `npm run build` (web/desktop) or `expo prebuild --no-install` style check (mobile).
3. **Doctor**: `node scripts/doctor.mjs`.
4. **Smoke test**: `node scripts/smoke.mjs` — boots the app headlessly when possible, hits main route/screen, checks DB readable.
5. **Runtime check** (not just build): actually start the app (`npm start` in background, or `expo start --no-dev --minify` style) and confirm it doesn't crash within ~10s. Kill it after.
6. **UI sanity** when feasible: screenshot via browser tool (web) or Expo screenshot (mobile) and visually confirm the main screen rendered.
7. **Help + reporter present**: grep for the help section + bug-report entry point.

Report each step pass/fail in the final message to the user, in plain VN.

## Auto bug-fix loop (key for non-tech success)

When any verification step above fails, do not bounce the error back to the user. Run this loop:

```
for attempt in 1..N (default N=4):
  1. Capture failure: command, stderr/stdout, stack trace, last logs.
  2. Classify: build error, runtime crash, lint, smoke-test fail, dep conflict.
  3. Propose minimal fix (smallest diff that addresses root cause, not symptom).
  4. Apply fix.
  5. Re-run the failing step.
  6. If pass → continue verification pipeline.
  7. If same error twice in a row → switch strategy (different lib, simpler approach, ask delegate).
  8. If 4 attempts fail → stop, summarize attempts in plain VN, ask user for guidance with one concrete recommendation.
```

Rules:

- Never disable a test/check just to make it pass.
- Never `--force` install to silence peer-dep warnings without understanding.
- Never silence TypeScript errors with `as any` / `// @ts-ignore` unless documented why and approved.
- Prefer reverting the last edit + retrying with a different approach over piling fixes.

Surface the loop to the user only when it finishes (success or 4-fail give-up), not every attempt. Non-tech user does not need to see each retry.

## Feature-addition workflow (existing app)

Detailed steps, see `references/feature-add.md`. Summary:

1. Read brief + changelog. Confirm app still builds/smoke-passes on current main.
2. Git checkpoint commit.
3. Write Change brief (plain VN): goal, affected screens, data schema impact, risk, rollback plan.
4. Migration if schema changes.
5. Implement (direct or delegate per mode rule).
6. Verify full pipeline + auto bug-fix loop.
7. Update `docs/vibe-brief.md` (current state) and append to `docs/vibe-changelog.md`.
8. Update in-app “Hướng dẫn sử dụng” if user-visible behavior changed.
9. Commit `feat: <summary>`.
10. Report to user in plain VN: what changed, how to use it, how to rollback.

## Delegation prompt pattern

```md
You are implementing one bounded part of this personal app.

User-facing goal:
- ...

Platform & stack:
- Web | Desktop | Mobile — <stack>

Task:
- Implement ...

Non-negotiables:
- Keep understandable for non-technical users.
- Keep/update visible “Hướng dẫn sử dụng” and bug-reporter.
- Local data only unless told otherwise.
- No new heavy dependency without justification.
- Don't change unrelated files.
- Run lint + build + smoke before declaring done.
- If a verification step fails, run the auto bug-fix loop (max 4 attempts) before reporting.

Acceptance:
- ...

When done:
- Summarize changed files.
- Run pipeline. Report pass/fail per step.
- Update docs/vibe-brief.md + docs/vibe-changelog.md.
```

For ACP harness, use OpenClaw ACP runtime / acpx per environment policy. No raw PTY scraping when ACP available.

## Output style to user

Concise, practical, plain VN:

- Confirm platform and goal.
- Say mode chosen + why.
- Say what changed (or delegated).
- Simple run/use instructions.
- Pipeline result (pass/fail per step).
- Next small step suggestion.
- Rollback hint if it was a risky change.

## Versioning

Simple semver bumped by agent automatically in `package.json`:

- Patch: bug fix only.
- Minor: new feature, backward compatible, no data migration.
- Major: breaking change or data migration.

Append the version + date to `docs/vibe-changelog.md` for each release.

## Reference

- `references/mode-heuristics.md` — borderline mode decisions, examples.
- `references/feature-add.md` — full Change-brief template + feature-addition checklist.
- `references/bug-fix-loop.md` — failure classification cheatsheet for the auto bug-fix loop.
- `references/crawbot-integration.md` — full `vibe-app.json` schema, lifecycle contract, examples per platform.
