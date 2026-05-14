---
name: vibe-builder
description: Build small personal apps for non-technical users with a friendly question-first vibe-coding workflow. Use when the user asks to make, scaffold, vibe code, prototype, or iterate a personal web/desktop/mobile app, especially when they need simple questions about what app they want, platform choice (web, desktop/laptop, mobile/tablet), automatic tech-stack selection, local data storage, built-in user instructions, and a decision on whether the main assistant should code directly or delegate execution to Codex/Claude/acpx.
---

# Vibe Builder

Use this skill to turn a casual personal app idea into a working prototype for a non-technical user.

## Core stance

Default to **main assistant as product lead + taste keeper**.

The user should not need to understand frameworks, databases, Docker, or build tooling. Ask simple product questions, translate answers into technical choices, then build or delegate.

Choose execution mode per task:

- **Direct mode**: main assistant codes directly for small, clear, low-risk apps.
- **Delegate mode**: use acpx/Codex/Claude for heavy multi-file implementation, long debug loops, or large refactors.
- **Hybrid mode**: main assistant designs/scaffolds/reviews; harness implements bounded tasks.

Do not throw the whole product at a harness and hope. Keep user intent, scope, and acceptance criteria in the main conversation.

## First questions for non-technical users

Ask only the minimum needed. Use plain language. Avoid technical terms unless immediately explained.

Start with these questions:

1. **App này dùng để làm gì?**  
   Example: quản lý chi tiêu, ghi chú khách hàng, theo dõi học viên, nhắc việc, xem dashboard.
2. **Anh/chị muốn dùng app ở đâu?**  
   - **Web app**: mở bằng trình duyệt như Chrome/Safari.
   - **Desktop/laptop app**: chạy trên máy tính Windows/Mac/Linux như app riêng.
   - **Mobile/tablet app**: chạy trên iPhone/iPad/Android, test nhanh bằng Expo Go.
3. **Dữ liệu cần lưu gì?**  
   Example: danh sách giao dịch, khách hàng, bài học, ảnh/file, ghi chú, cấu hình.
4. **Ai dùng app này?**  
   Chỉ cá nhân, gia đình/team nhỏ, hay nhiều người dùng.
5. **Màn hình quan trọng nhất là gì?**  
   Nếu chưa biết, đề xuất 2–4 màn hình đơn giản.

If the user already answered some questions, do not ask again. Make a reasonable choice and say it plainly.

## Non-technical planning template

Before coding, produce this compact brief unless the user explicitly asks to skip planning:

```md
## App mình sẽ làm
<one sentence in user language>

## Dùng ở đâu
Web | Desktop/laptop | Mobile/tablet — <plain-language reason>

## Bản đầu tiên có gì
- <screen/feature>
- <screen/feature>

## Tạm chưa làm
- <defer>

## Cách lưu dữ liệu
<plain-language explanation: lưu trong máy / file local / SQLite>

## Hướng dẫn trong app
App sẽ có mục “Hướng dẫn sử dụng” để người dùng mở ra xem ngay trong app.

## Cách bé làm
Direct | Hybrid | Delegate — <simple reason>

## Kiểm tra xong khi
- <manual or automated check>
- <manual or automated check>
```

For projects that continue across sessions, write this to `docs/vibe-brief.md`.

## Platform-to-stack mapping

Pick the stack automatically after the platform is known. Explain it in simple words.

### Web app

Use for apps the user wants to open in a browser.

Default stack:

- Node.js runtime.
- Next.js for the web app.
- Tailwind CSS for styling.
- SQLite for local/private data.
- Local files/config for uploads, exports, and settings.
- Docker for running the app/database consistently when useful.
- Auto-start support for Windows/macOS/Linux when the user wants the app to start with the computer.

Implementation notes:

- Keep local-first by default; avoid cloud accounts unless requested.
- Provide `scripts/doctor` or equivalent health check.
- If Docker is used, include `docker-compose.yml` and clear start/stop commands.
- If auto-start is requested, provide OS-specific setup:
  - macOS: LaunchAgent.
  - Windows: Startup folder or Task Scheduler.
  - Linux: systemd user service.

### Desktop/laptop app

Use for apps the user wants as a computer app instead of a browser tab.

Default stack:

- React Native desktop-oriented project when appropriate for the local environment.
- SQLite for local data.
- Local files/config for settings and documents.

Implementation notes:

- Prefer simple local storage and simple packaging first.
- If React Native desktop support is too heavy for the current environment, explain the tradeoff and suggest a web app packaged/auto-started as the simpler v1.

### Mobile/tablet app

Use for iPhone/iPad/Android prototypes.

Default stack:

- React Native + Expo.
- Expo Go for easy testing without App Store/Play Store.
- Embedded SQLite for local data.
- Local app storage for settings/files where possible.

Implementation notes:

- Favor Expo-compatible libraries.
- Avoid native modules that require custom builds unless clearly needed.
- Always include simple steps: install Expo Go, scan QR code, test app.

## Built-in help requirement

Every app must include a visible **Hướng dẫn sử dụng** area, page, modal, or menu item.

It should explain in the user's language:

- App này dùng để làm gì.
- 3–5 bước sử dụng cơ bản.
- Dữ liệu được lưu ở đâu.
- Cách backup/export nếu available.
- Ai cần hỏi khi bị lỗi, or where to check logs if local.

Do not ship an app without this help section unless the user explicitly says to remove it.

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
- Native mobile, Expo dependency, auth, storage, charts, payments, sync, Docker/auto-start services, or platform-specific bugs are involved.
- Need parallel feature work.
- Need fresh-agent review or install simulation.

Use **hybrid mode** by default for real apps:

1. Main assistant asks the simple product/platform questions.
2. Main assistant writes/updates the non-technical brief and acceptance checks.
3. Main assistant directly creates scaffold or minimal vertical slice when small.
4. Delegate bounded implementation tasks to acpx/Codex/Claude when work gets heavy.
5. Main assistant reviews diff, runs verification, checks the built-in help section, fixes taste issues, and reports.

## Delegation prompt pattern

When delegating to acpx/Codex/Claude, make the task bounded and preserve non-technical UX:

```md
You are implementing one bounded part of this personal app.

User-facing goal:
- ...

Platform:
- Web | Desktop/laptop | Mobile/tablet

Current stack:
- ...

Task:
- Implement ...

Non-negotiables:
- Keep the app understandable for non-technical users.
- Include/update the visible “Hướng dẫn sử dụng” section.
- Store data locally by default.
- Do not add cloud/paid services unless explicitly requested.
- Do not change unrelated files.
- Keep commands reproducible.

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
- Docker compose up/down smoke test when Docker is used.
- Expo start/smoke check when mobile is used.
- Manual browser/app launch check when UI matters.

Also verify:

- The app has a visible **Hướng dẫn sử dụng** section.
- A non-technical user can find the main action within a few seconds.
- Start/run commands are documented in plain language.

If verification is impossible, say why and provide exact next command for the user/agent.

## Output style to user

Be concise and practical:

- Confirm the platform and app goal in plain language.
- Say what mode you chose and why.
- Say what changed or what was delegated.
- Give simple run/use instructions.
- Say what passed/failed.
- Suggest the next small step.

## Reference

For more detailed heuristics and examples, read `references/mode-heuristics.md` only when deciding a borderline task or teaching the workflow.
