# CrawBot Integration — Project Lifecycle

CrawBot manages every app built by this skill. The contract lives in `vibe-app.json` at the project root. CrawBot scans `<workspace>/projects/*/vibe-app.json` and shows each app in its UI with **Start / Stop / Open / Logs / Backup / Rollback** actions.

## Project layout

```
<workspace>/
  projects/
    quan-ly-chi-tieu/
      vibe-app.json           ← CrawBot manifest
      package.json
      docs/
        vibe-brief.md
        vibe-changelog.md
        install-desktop.md | install-mobile.md
      scripts/
        doctor.mjs
        smoke.mjs
      data/
        app.db
        backups/
      bug-reports/
      migrations/
      src/ | app/ | ...
```

Never scaffold an app outside `<workspace>/projects/`. CrawBot will not see it.

## `vibe-app.json` schema (v1)

```jsonc
{
  "$schema": "vibe-app/v1",

  // identity
  "slug": "quan-ly-chi-tieu",         // kebab-case, unique per workspace
  "name": "App quản lý chi tiêu",     // user-facing
  "description": "App ghi chép thu chi cá nhân, lưu trong máy.",
  "version": "0.1.0",                 // matches package.json
  "icon": "icon.png",                 // optional, relative to project root
  "createdAt": "2026-05-15T04:40:00+07:00",
  "updatedAt": "2026-05-15T05:00:00+07:00",

  // platform & stack
  "platform": "web",                  // "web" | "desktop" | "mobile"
  "stack": ["next.js", "tailwind", "sqlite"],
  "runtime": {
    "node": ">=20",
    "packageManager": "npm"           // "npm" | "pnpm" | "yarn" | "bun"
  },

  // lifecycle scripts (shell commands CrawBot will spawn)
  "scripts": {
    "install": "npm install",
    "dev":     "npm run dev",
    "start":   "npm start",
    "stop":    null,                  // null = SIGTERM is enough
    "build":   "npm run build",
    "doctor":  "node scripts/doctor.mjs",
    "smoke":   "node scripts/smoke.mjs"
  },

  // runtime metadata
  "url": "http://localhost:3000",     // null for desktop/mobile
  "ports": [3000],
  "openOnStart": true,
  "readySignal": "ready",             // substring CrawBot watches for in stdout

  // user features
  "helpRoute": "/huong-dan",          // route or screen name
  "bugReportRoute": "/report-bug",

  // data management
  "dataPaths": ["data/app.db", "data/backups/"],
  "backupCommand": null,              // optional custom backup cmd

  // safety
  "rollbackHint": "Nhắn bé Amagi 'hoàn tác thay đổi cuối'."
}
```

## Lifecycle contract (must hold for every app)

1. **Idempotent install** — re-running `scripts.install` never breaks state.
2. **Ready signal** — `scripts.dev` / `scripts.start` print the configured `readySignal` (default: `ready`, `listening`, or `started`) within 30s. CrawBot uses this to mark "running".
3. **Clean shutdown** — process exits cleanly on SIGTERM within 10s. Otherwise CrawBot SIGKILLs.
4. **Sandboxed writes** — app writes only inside its own folder.
5. **Configurable port** — `process.env.PORT` overrides the default in `ports[0]`. Same for any other port (`API_PORT`, etc.).
6. **Stdout logs** — no proprietary log file required. CrawBot captures stdout/stderr.

## Platform-specific recipes

### Web (Next.js)

```json
{
  "platform": "web",
  "scripts": {
    "install": "npm install",
    "dev":     "next dev -p ${PORT:-3000}",
    "start":   "next start -p ${PORT:-3000}",
    "build":   "next build",
    "doctor":  "node scripts/doctor.mjs",
    "smoke":   "node scripts/smoke.mjs"
  },
  "url": "http://localhost:3000",
  "ports": [3000],
  "openOnStart": true,
  "readySignal": "ready - started server"
}
```

### Desktop (Electron)

```json
{
  "platform": "desktop",
  "scripts": {
    "install": "npm install",
    "dev":     "npm run electron:dev",
    "start":   "npm run electron:start",
    "build":   "npm run electron:build"
  },
  "url": null,
  "ports": [],
  "openOnStart": false,
  "readySignal": "electron ready"
}
```

CrawBot just runs the process and shows logs. The app opens its own window.

### Mobile (Expo)

```json
{
  "platform": "mobile",
  "scripts": {
    "install": "npm install",
    "dev":     "expo start --tunnel",
    "start":   "expo start --tunnel",
    "build":   "expo export"
  },
  "url": null,
  "ports": [8081, 19000, 19001, 19002],
  "openOnStart": false,
  "readySignal": "Metro waiting"
}
```

CrawBot surfaces the Expo QR code + tunnel URL from stdout so user can scan with Expo Go.

## Slug rules

- Lowercase, kebab-case, ASCII only.
- Derived from `name` by stripping diacritics + spaces → dashes.
- Must be unique inside `<workspace>/projects/`. If collision, append `-2`, `-3`, etc.
- Used as folder name and CrawBot internal id. Never rename after creation (breaks CrawBot history).

## When user asks "start/stop my app"

Don't run shell commands directly when CrawBot is available — instead:

1. Confirm which app (by slug or name).
2. Tell the user CrawBot will manage it: “Em đã chuẩn bị app ở `projects/<slug>`. Anh bấm nút **Start** trong CrawBot là chạy, hoặc bảo em ‘chạy app <name>’ em sẽ kích hoạt giúp.”
3. If user prefers chat, agent may invoke CrawBot's start/stop via the standard CrawBot tool surface (when exposed). Otherwise fall back to spawning `scripts.start` directly and stream logs.

## When updating an existing app

After any feature/bug-fix work, also:

1. Bump `version` in both `package.json` and `vibe-app.json`.
2. Update `updatedAt`.
3. Update `ports` / `url` / `dataPaths` / routes if they changed.
4. Update `stack` if a major library was added/removed.
5. Commit the manifest change in the same commit as the feature.

CrawBot watches `vibe-app.json` mtime; updating it is what makes the UI refresh.

## Validation

`scripts/doctor.mjs` of each app should check `vibe-app.json` is present and valid JSON. Minimal check:

```js
import fs from "node:fs";
const m = JSON.parse(fs.readFileSync("vibe-app.json", "utf8"));
for (const k of ["slug", "name", "version", "platform", "scripts"]) {
  if (!m[k]) { console.error("vibe-app.json missing:", k); process.exit(1); }
}
```

## Anti-patterns (don't)

- Don't hardcode absolute paths in `scripts.*`.
- Don't fork background services from inside `scripts.start` — CrawBot must be the parent so SIGTERM works.
- Don't write data outside the project folder (no `~/Documents/...`).
- Don't require sudo/admin for normal start/stop.
- Don't bind to a hardcoded port without honoring `$PORT`.
- Don't omit `vibe-app.json` "because it's just a small app" — CrawBot needs it.
