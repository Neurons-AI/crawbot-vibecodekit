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

### Desktop install guide (non-tech)

Always include in `docs/install-desktop.md` and shorter version in in-app help:

- Download link/file location per OS (Win/macOS/Linux).
- Exact installer filename.
- Open/install steps including OS security warnings (SmartScreen, Gatekeeper).
- How to launch after install.
- How to update.
- How to uninstall.
- Where local data is stored for backup.

Never tell a non-tech user to clone a repo or run `npm`.

### Mobile install + share guide (non-tech)

Always include in `docs/install-mobile.md` and shorter version in in-app help. Split into two clearly labeled blocks:

```md
## Người làm app chạy
- npx expo start
- Lấy QR code / link
- (Optional) eas update để có link bền

## Người dùng làm
1. Cài Expo Go từ App Store / Google Play.
2. Mở Expo Go.
3. Quét QR code hoặc paste link.
4. Đợi app load lần đầu rồi dùng.
```

Also explain:

- Cách chia sẻ app: gửi QR/link, publish `eas update`, hoặc build standalone qua `eas build` cho TestFlight/APK.
- Cách cập nhật.
- Lỗi thường gặp (Wi-Fi, tunnel mode, QR không quét được trên iPhone).

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
5. Nếu app bị lỗi, bấm nút **Báo lỗi** ở góc dưới — bé sẽ copy log vào clipboard, paste lại cho bé Amagi để fix.

Dữ liệu được lưu trong máy của bạn bằng SQLite, không gửi lên cloud.
```

## Bug reporter examples (web)

Web app pattern (Next.js page or modal):

```tsx
// app/report-bug/page.tsx
"use client";
import { useState } from "react";

export default function ReportBugPage() {
  const [note, setNote] = useState("");
  const [done, setDone] = useState(false);

  async function send() {
    const report = {
      version: process.env.NEXT_PUBLIC_APP_VERSION ?? "unknown",
      ua: navigator.userAgent,
      route: location.pathname,
      time: new Date().toISOString(),
      note,
      // last console errors captured by a small window.onerror buffer
      errors: (window as any).__bugBuffer ?? [],
    };
    const text = JSON.stringify(report, null, 2);
    await navigator.clipboard.writeText(text);
    await fetch("/api/bug-report", { method: "POST", body: text });
    setDone(true);
  }

  return (
    <div className="p-6">
      <h1 className="text-xl font-bold">Báo lỗi</h1>
      <p>Bé sẽ copy báo cáo vào clipboard. Sau đó paste vào chat với agent.</p>
      <textarea
        className="w-full border rounded p-2 mt-3"
        rows={4}
        placeholder="Anh đang làm gì lúc bị lỗi?"
        value={note}
        onChange={(e) => setNote(e.target.value)}
      />
      <button className="mt-3 px-4 py-2 bg-black text-white rounded" onClick={send}>
        Gửi báo cáo
      </button>
      {done && <p className="mt-3 text-green-600">Đã copy. Paste vào chat với bé Amagi nha.</p>}
    </div>
  );
}
```

Server side stores it under `bug-reports/<timestamp>.json` so agent can read on next session.

## Bug reporter examples (mobile / Expo)

```tsx
import * as Clipboard from "expo-clipboard";
import * as FileSystem from "expo-file-system";
import { Alert, Button, TextInput, View } from "react-native";
import { useState } from "react";

export function ReportBug() {
  const [note, setNote] = useState("");
  async function send() {
    const report = {
      version: "0.1.0",
      time: new Date().toISOString(),
      note,
    };
    const text = JSON.stringify(report, null, 2);
    await Clipboard.setStringAsync(text);
    const path = FileSystem.documentDirectory + `bug-${Date.now()}.json`;
    await FileSystem.writeAsStringAsync(path, text);
    Alert.alert("Đã copy báo cáo", "Paste vào chat với bé Amagi để bé fix nha.");
  }
  return (
    <View style={{ padding: 16 }}>
      <TextInput
        placeholder="Anh đang làm gì lúc bị lỗi?"
        value={note}
        onChangeText={setNote}
        multiline
        style={{ borderWidth: 1, padding: 8, minHeight: 80 }}
      />
      <Button title="Gửi báo cáo" onPress={send} />
    </View>
  );
}
```

## Smoke test example (`scripts/smoke.mjs`)

```js
#!/usr/bin/env node
// Boots the app for ~10s, checks main route returns 200, then exits.
import { spawn } from "node:child_process";
import http from "node:http";

const proc = spawn("npm", ["start"], { stdio: ["ignore", "pipe", "pipe"] });
let booted = false;
proc.stdout.on("data", (b) => {
  const s = b.toString();
  if (!booted && /ready|listening|started/i.test(s)) {
    booted = true;
    setTimeout(check, 1500);
  }
});

function check() {
  http.get("http://localhost:3000/", (res) => {
    const ok = res.statusCode === 200;
    proc.kill();
    if (!ok) {
      console.error("smoke: main route returned", res.statusCode);
      process.exit(1);
    }
    console.log("smoke: ok");
    process.exit(0);
  }).on("error", (e) => {
    proc.kill();
    console.error("smoke: request failed", e.message);
    process.exit(1);
  });
}

setTimeout(() => {
  if (!booted) {
    proc.kill();
    console.error("smoke: app did not boot in 20s");
    process.exit(1);
  }
}, 20000);
```

Mobile equivalent: use `expo start --no-dev --minify` headless OR a Jest test that imports the root component without throwing.

## Versioning quick rules

- Patch (`0.1.0 → 0.1.1`): bug fix only, no schema change, no user-visible new feature.
- Minor (`0.1.1 → 0.2.0`): new feature, additive schema, backward compatible.
- Major (`0.2.0 → 1.0.0`): breaking change, destructive migration, removed feature.

Always update `docs/vibe-changelog.md` with the version + date when bumping.
