# Auto Bug-Fix Loop — Failure Cheatsheet

Used by the main SKILL.md when any verification step fails. Goal: fix the smallest root cause, not silence the symptom. Max 4 attempts before asking user.

## Failure classes & default first move

### 1. Install / dependency error

Signals: `npm install` fails, peer-dep warning escalated to error, `ERESOLVE`, `EACCES`, missing native build tool.

First moves:

- Read full error, not just last line.
- Check Node version vs `engines` in `package.json`. If mismatch → align.
- Try `npm install` again (transient registry/network issue is common).
- If peer-dep conflict: prefer pinning compatible versions over `--legacy-peer-deps`.
- If native build (node-gyp, sharp, sqlite native) fails on mobile/Expo → swap to Expo-compatible alternative.

Never: `--force` to silence; deleting `package-lock.json` blindly.

### 2. Lint / typecheck error

First moves:

- Fix the actual code, not the rule.
- If error is in unrelated file you didn't touch → revert your changes near that file first; you may have caused a cascade.
- Only adjust lint config if rule is genuinely wrong for this project and document why in the commit.

Never: blanket `// eslint-disable`, `as any`, `// @ts-ignore` without an inline reason.

### 3. Build error

First moves:

- Read first error in the chain, fix that one; later errors are usually cascade.
- Common: missing import, wrong export name, missing `"use client"` in Next.js, missing dependency in `package.json`.
- For Expo: clear cache with `expo start -c` once before assuming code bug.

### 4. Runtime crash on boot

First moves:

- Read the crash log + first stack frame inside your code (skip framework frames).
- Common: undefined env var, missing DB file/dir, port already in use, SQLite migration not run.
- Check `scripts/doctor.mjs` output — usually catches env/setup issues.

### 5. Smoke test fail

First moves:

- Check what the smoke test actually asserts. Often the assertion is right and the code regressed.
- If smoke asserts a route exists and route was renamed → update the rename OR keep an alias (prefer alias for non-tech UX continuity).
- If DB query fails → check migration ran, check connection path.

### 6. UI broken / blank screen

First moves:

- Open browser console / Expo logs.
- Common: hydration mismatch (SSR), missing `key` in list, async race on first paint.
- Take a screenshot to confirm what's actually rendered.

### 7. Migration error

First moves:

- Stop. Restore from backup at `data/backups/app-<timestamp>.db`.
- Re-read migration script; check it's idempotent (`IF NOT EXISTS`, `ALTER TABLE ... ADD COLUMN` not destructive).
- Test migration on a copy of the backup before re-running on real data.

Never: re-run a destructive migration on production data without backup verified.

## Loop discipline

After each attempt, log mentally:

```
attempt N
  symptom: <short>
  diagnosis: <short>
  fix: <short>
  result: pass | same-error | new-error
```

Switch strategy when:

- Same error twice in a row → root cause is different from your hypothesis. Step back, re-read full log, consider reverting.
- Error keeps moving (new error each attempt) → you are creating cascades. Revert all attempts and start with a smaller change.
- Approaching attempt 4 → prepare a clear plain-VN summary for the user with one concrete recommended next step (e.g. "đổi thư viện X sang Y", "tạm rollback và làm cách khác").

## When to escalate to delegate mode mid-loop

If the failing area is:

- Native build / iOS signing / Expo prebuild issues
- Auth/OAuth flows
- Heavy refactor needed to fix
- Multiple files affected

→ stop the loop, delegate to acpx/Codex/Claude with a bounded task that includes the failing logs and the auto bug-fix loop rules. Resume in main session after delegate reports.

## Reporting to user after loop

Two cases.

### Success

> Em đã fix xong. Ban đầu app bị `<plain VN symptom>`, em đã `<plain VN fix>`. App giờ chạy ok, smoke test pass.

### Give-up (4 fails)

> Em đã thử 4 cách nhưng chưa fix được lỗi `<plain VN>`. Em đoán nguyên nhân là `<…>`. Em đề xuất: `<một việc cụ thể>`. Anh muốn em làm theo cách đó, hay rollback về bản trước?
