# Vibe Builder Mode Heuristics

## User language

Prefer simple words:

- Say “mở bằng trình duyệt” instead of “web frontend”.
- Say “lưu trong máy” instead of “local persistence”.
- Say “app tự chạy khi mở máy” instead of “autostart service”.
- Say “cơ sở dữ liệu nhỏ gọn trong máy” before mentioning SQLite.

Ask fewer questions. If a reasonable default exists, choose it and explain.

## Platform examples

### Web app

Good for:

- Personal dashboards.
- Small admin tools.
- Finance/CRM/course trackers.
- Apps used mostly on laptop but okay in browser.

Default stack: Node.js + Next.js + Tailwind CSS + SQLite + local files/config. Add Docker when it makes install/run easier or when the app has background services.

### Desktop/laptop app

Good for:

- User explicitly wants a separate computer app.
- App must feel separate from browser.
- App mostly stores local data/files.

Default stack: React Native desktop-oriented app + SQLite + local files/config. If this is too heavy, recommend a local web app with auto-start as v1.

### Mobile/tablet app

Good for:

- iPhone/iPad/Android daily use.
- Camera/photo/input while away from laptop.
- Simple prototype students/users can test for free.

Default stack: React Native + Expo Go + embedded SQLite.

## Direct mode examples

- Single-page landing page.
- Simple CRUD app with local storage/SQLite.
- Personal calculator/tracker.
- Script to transform CSV/JSON.
- Small Expo prototype with 1–3 screens and no native modules.

Main assistant should code directly, because context and taste matter more than agent throughput.

## Hybrid mode examples

- Personal finance app with dashboard, transaction entry, categories, charts.
- Course companion app with lessons, exercises, progress, and local persistence.
- Admin dashboard with several pages and reusable components.
- Local web app that needs Docker and auto-start docs.

Main assistant should own product brief, scaffold, review, help section, and integration. Delegate bounded chunks such as charts, persistence layer, Docker/autostart, or component library.

## Delegate mode examples

- Existing repo with many files and unknown architecture.
- Multi-screen Expo app with auth/storage/charts/sync.
- Build failures involving native dependencies.
- Large refactor or test suite generation.
- Cross-platform auto-start implementation that needs Windows/macOS/Linux scripts.

Use acpx/Codex/Claude and keep the task bounded with acceptance criteria.

## Escalation triggers

Start direct, then escalate to delegate if:

- The same bug survives two fix attempts.
- Build/test output is long and requires iterative debugging.
- The change touches more than ~8 files.
- Docker, native mobile, or OS-specific auto-start gets involved.
- The user asks to continue while main assistant should stay responsive.

## De-escalation triggers

Take work back from harness if:

- It changes unrelated files.
- It ignores product taste or acceptance criteria.
- It adds unnecessary infra/cloud dependencies.
- It forgets the built-in “Hướng dẫn sử dụng” section.
- It cannot explain failures clearly.

## Built-in help examples

Each app should include user-facing help like:

```md
# Hướng dẫn sử dụng

App này giúp bạn quản lý chi tiêu cá nhân.

1. Bấm “Thêm giao dịch” để nhập khoản thu/chi.
2. Chọn danh mục để dashboard thống kê đúng.
3. Mở “Báo cáo” để xem tổng theo tháng.
4. Bấm “Xuất dữ liệu” để backup file.

Dữ liệu được lưu trong máy của bạn bằng SQLite, không gửi lên cloud.
```
