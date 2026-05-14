# Feature Addition — Existing App

Use this when the user wants to add/change something in an app that already exists.

## Preconditions

- Project has `docs/vibe-brief.md`. If missing → recreate from inspection before continuing.
- Project is a git repo (or `git init` + initial commit first).
- `npm install` (or equivalent) succeeds on current main.
- `node scripts/smoke.mjs` passes on current main. If not, fix that first — never stack a feature on a broken base.

## Change brief template (write before coding)

Save inline in your reply and also keep it in commit message body.

```md
## Tính năng mới
<one sentence in user language>

## Vì sao
<plain VN: user need / problem>

## Màn hình / tính năng ảnh hưởng
- <screen or feature>
- <screen or feature>

## Dữ liệu có đổi không?
None | Add column <X> on <table> | New table <Y> | Rename …

## Migration cần làm?
None | Script migrations/<NNN>-<name>.sql | Backup DB trước khi chạy

## Rủi ro & cách rollback
- Rủi ro: <plain VN>
- Rollback: `git reset --hard <checkpoint-sha>` hoặc restore backup DB

## Kiểm tra xong khi
- Smoke test pass
- Màn hình mới mở được, thao tác chính chạy đúng
- Hướng dẫn trong app đã cập nhật
- Bug reporter vẫn hoạt động
```

## Checklist

1. `git status` — ensure clean. If dirty → commit `wip: pre-feature snapshot` after confirming with user.
2. `git rev-parse HEAD` → record checkpoint SHA in the Change brief.
3. Write Change brief.
4. If schema changes → backup DB to `data/backups/app-<timestamp>.db` and write migration.
5. Implement (direct/hybrid/delegate per mode rule). Prefer additive code paths over rewrites.
6. Update in-app **Hướng dẫn sử dụng** if user-visible behavior changed.
7. Confirm bug reporter still works.
8. Run verification pipeline (lint → build → doctor → smoke → runtime check → UI sanity → help+reporter grep).
9. If any step fails → auto bug-fix loop (max 4 attempts) per main skill.
10. Update `docs/vibe-brief.md` (current scope/stack).
11. Append to `docs/vibe-changelog.md`:
    ```md
    ## YYYY-MM-DD — v<x.y.z>
    - <plain VN summary of feature>
    - Schema: <none | change>
    - Rollback: <git sha or restore note>
    ```
12. Bump version in `package.json` per Versioning rule (patch/minor/major).
13. `git commit -m "feat: <plain VN summary>"`.
14. Report to user: what changed, how to use, how to rollback.

## Non-tech rollback phrase

Document in `docs/vibe-brief.md`:

> Nếu thấy app bị lỗi sau khi thêm tính năng mới, nhắn bé Amagi: **“hoàn tác thay đổi cuối”**. Bé sẽ chạy `git reset --hard <checkpoint>` và restore backup DB nếu cần.

## When to refuse / push back

- User wants a feature that needs cloud/paid service but said the app must be local-only → explain tradeoff, ask.
- User wants a feature that breaks a currently working screen → propose additive alternative first.
- User wants a destructive schema change without backup → require backup + migration script, no exceptions.
- User wants to skip verification → explain that non-tech apps without smoke test usually break silently; recommend keeping it.
