# Agent Setup Runbook — acpx + OpenClaw + Codex

Goal: get the delegation harness fully working on a non-technical user's machine, with the **narrowest sandbox/approval permissions that still let vibe-coding flow without nagging the user**.

Run this once per machine, and re-run if any harness call later fails with `command not found`, `not logged in`, `permission denied`, or similar.

Always speak to the user in plain VN. Never paste raw stack traces at them; translate the meaning.

## 0. Detect current state first

Don't reinstall blindly. Probe what's already there:

```bash
which acpx     && acpx --version
which openclaw && openclaw --version
which codex    && codex --version
```

If a binary is on PATH and prints a version → installed. Then check login:

```bash
openclaw whoami 2>/dev/null   # or: openclaw status
codex whoami 2>/dev/null      # or: codex status
```

Memorize results in `<workspace>/MEMORY.md` so future sessions skip the probe.

## 1. acpx

### Install

- npm (cross-platform): `npm i -g @openclaw/acpx`
- pnpm: `pnpm add -g @openclaw/acpx`
- Verify: `acpx --version`

If `command not found` after install:

- macOS/Linux: ensure `$(npm prefix -g)/bin` is on `$PATH` (add to `~/.zshrc` / `~/.bashrc`).
- Windows (PowerShell): `npm config get prefix` → add `<prefix>` to PATH via System Settings → Environment Variables.
- WSL: same as Linux. If installed in Windows-npm but running in WSL → reinstall in WSL.

### Permissions

acpx itself doesn't need credentials. It spawns the configured harness (openclaw or codex). The permission knobs live on the harness side.

Always pin acpx `--cwd` to the specific app folder (`projects/<slug>`), not the whole workspace. Smaller blast radius if a delegate misbehaves.

## 2. OpenClaw (Claude harness)

### Install

- npm: `npm i -g @anthropic-ai/openclaw`
- If CrawBot ships a bundled OpenClaw → skip; use bundled binary.
- Verify: `openclaw --version`

### Login

- Run: `openclaw login`
- Browser opens → sign in with Anthropic / Claude account.
- After redirect, terminal shows "Logged in as …".
- Verify: `openclaw whoami` (or `openclaw status`).

If browser doesn't open (headless / SSH / WSL without browser bridge):

- Copy the auth URL the CLI prints, open it on the user's main machine.
- Paste the resulting auth code back into the terminal.

### Subscription / quota

- Pro / Team plan recommended; free tier may hit limits during long delegate loops.
- If user is unsure → check `openclaw status` for current plan.

### Permissions

For delegate calls from this skill, always use:

```bash
openclaw --print --permission-mode bypassPermissions --cwd projects/<slug> "<task>"
```

Rationale: vibe-coding is local-only, scoped to the app folder. `bypassPermissions` avoids interactive approval prompts the non-tech user can't answer mid-loop.

Do NOT enable bypass globally in `~/.openclaw/config`. Pass per-call.

## 3. Codex (OpenAI harness)

### Install

- npm: `npm i -g @openai/codex`
- Verify: `codex --version`

### Login

- Run: `codex login`
- Browser opens → sign in with ChatGPT account.
- After redirect, terminal shows confirmation.
- Verify: `codex --print "say hi"` (small ping).

### Subscription / quota

- Plus / Pro / Team plan recommended.
- Free tier or pay-per-use will get rate-limited fast on bigger delegate tasks.

### Permissions

Default Codex sandbox blocks file writes outside its own working dir and asks for approval often — bad for non-tech vibe loop. Use:

```bash
codex \
  --sandbox workspace-write \
  --ask-for-approval never \
  --cwd projects/<slug> \
  "<task>"
```

Flags explained (in plain VN for user):

- `workspace-write`: chỉ cho ghi file trong thư mục app, không động máy.
- `never`: không hỏi approve giữa chừng, chạy thẳng.
- `--cwd`: pin vào đúng thư mục app này.

For risky tasks (deleting files, system changes) bump to `--sandbox danger-full-access` **only with explicit user consent**, then go back to `workspace-write`.

PTY note: per the `coding-agent` skill, Codex/Pi/OpenCode require `pty:true` when spawned via exec.

## 4. OS-level permissions

### macOS

- First run of `openclaw` / `codex`: Gatekeeper may block ("cannot be opened because developer cannot be verified").
  - User fix: right-click the binary in Finder → Open → Open anyway. Or: System Settings → Privacy & Security → "Allow anyway".
- Full Disk Access not required for `projects/<slug>` scope.
- If the agent needs to read user docs/photos → guide user to grant Full Disk Access to the terminal app being used.

### Windows

- First run may trigger Windows Defender SmartScreen → "More info → Run anyway".
- If `command not found` after install: `npm prefix -g` to find global bin path, add to PATH.
- Prefer WSL Ubuntu for the harness (per workspace TOOLS.md). PowerShell only for Windows-native tasks.

### WSL

- Make sure npm global prefix is set inside WSL, not Windows:
  ```bash
  npm config get prefix
  # should look like /home/<user>/.npm-global or /usr/local
  ```
- If it points to `/mnt/c/...` → reset:
  ```bash
  mkdir -p ~/.npm-global
  npm config set prefix '~/.npm-global'
  echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc
  ```
- Reinstall acpx/openclaw/codex after fixing prefix.

### Linux

- If installed via system npm and PATH is fine → done.
- For systemd-managed user services (rare for this skill) the harness binaries must be on the service's PATH, not just the login shell's.

## 5. Smoke-test the full chain

After install + login + permissions, run this end-to-end check before promising the user the workflow works:

```bash
mkdir -p projects/_smoke
acpx run \
  --agent codex \
  --cwd projects/_smoke \
  --task "Create a file named hello.txt with the single line 'ok'. Then stop."
ls projects/_smoke/hello.txt && cat projects/_smoke/hello.txt
```

Expected: `hello.txt` exists with `ok`. Then clean up `projects/_smoke`.

Repeat with `--agent openclaw` to verify the Claude harness path.

If either fails → don't proceed to user work. Diagnose using the troubleshooting table below.

## 6. Troubleshooting matrix

| Symptom                                | Likely cause                                      | Plain-VN fix to user                                              |
|----------------------------------------|---------------------------------------------------|-------------------------------------------------------------------|
| `command not found: acpx`              | npm global bin not on PATH                        | Em sẽ thêm npm bin vào PATH cho anh.                              |
| `EACCES` during `npm i -g`             | Global install needs sudo / npm prefix is system  | Em sẽ chuyển npm prefix về `~/.npm-global` rồi cài lại.            |
| `openclaw login` không mở browser      | Headless terminal                                 | Em sẽ đưa link, anh mở trên máy chính rồi paste code lại nha.     |
| Codex luôn hỏi approve                 | Sandbox + approval policy mặc định                | Em chạy với `--ask-for-approval never --sandbox workspace-write`. |
| Gatekeeper chặn binary trên macOS      | App chưa được notarize                            | Anh vào Privacy & Security → "Allow anyway" giúp em.              |
| `not logged in` mid-delegate           | Token hết hạn                                     | Em chạy `openclaw login` / `codex login` lại nha.                 |
| Rate-limit / 429                       | Free tier hoặc dùng nhiều                         | Đợi vài phút hoặc nâng plan; em sẽ giảm số attempt loop xuống.    |
| Delegate ghi file ngoài project        | Sandbox quá rộng / cwd sai                        | Em sẽ pin lại `--cwd projects/<slug>` và hạ sandbox xuống.        |

## 7. Persist setup state

After successful smoke-test, write to `<workspace>/MEMORY.md`:

```md
## Vibe Builder — Agent Harness
- acpx: <version>, PATH ok
- openclaw: <version>, login=<account>, default flags: `--permission-mode bypassPermissions`
- codex: <version>, login=<account>, default flags: `--sandbox workspace-write --ask-for-approval never`
- OS notes: <macOS/Windows/WSL/Linux + any one-time perms granted>
- Last verified: <YYYY-MM-DD>
```

Re-verify when:

- A harness call fails with auth/permission/not-found error.
- User changes machine or reinstalls OS.
- > 30 days since last verification.
- User reports CrawBot can't start a delegated build.

## 8. Safety reminders

- Never store the user's harness tokens in plaintext outside the harness's own config dir.
- Never enable `danger-full-access` globally — only per-call and only with explicit user consent.
- If the user asks "why does it want to access my files?" — explain: chỉ ghi trong thư mục app, không động máy.
- If the harness asks for cloud/credential access unrelated to the current app → refuse and tell the user.
