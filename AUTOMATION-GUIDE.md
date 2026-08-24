# OpenWA WhatsApp Automation — User Guide

This folder (`whatsaap`) is **OpenWA** (v0.23.2), a self-hosted WhatsApp API gateway.
It runs a local HTTP API on **port 2785** that connects to WhatsApp through the
`whatsapp-web.js` engine (a real headless Chromium browser).

> **24 Aug 2026 update:** OpenWA was upgraded from v0.14.4 → v0.23.2 because
> WhatsApp's Web client change (23 Aug) broke the old version's message bridge.
> The session `code-sunny` reconnected with saved credentials — no re-pair needed.

---

## 1. Start / Stop the server

**Start** (double-click or run in a terminal):

```bat
start-server.bat
```

The server takes **~30 seconds** to boot. When ready you will see:

```
OpenWA is running on: http://localhost:2785
```

**Stop**: close the terminal window, or run:

```powershell
Stop-Process -Name node -ErrorAction SilentlyContinue
```

> ⚠️ Only stop the OpenWA server process — leave other apps running.

---

## 2. Connect WhatsApp (QR scan)

After the server is up, the session `code-sunny` must be linked to your phone:

1. Open **`whatsaap-qr-code.png`** (on your Desktop) in any image viewer.
2. On your phone: **WhatsApp → Settings (⚙️) → Linked devices → Link a device**.
3. Point the phone at the QR code shown on the computer screen.

The QR expires after a short while. If it does, ask the agent to refresh it, or
re-scan a fresh one:

```powershell
$key = (Get-Content "C:\Users\ujaga\OneDrive\Desktop\whatsaap\data\.api-key").Trim()
Invoke-RestMethod -Uri "http://localhost:2785/api/sessions/4ff0b408-0807-4f34-98ca-45bbd8b16a32/qr" -Headers @{ "X-API-Key" = $key }
```

Once linked, the session status changes to `connected`.

---

## 3. The automation (auto-reply rules)

Three rules are already active on session `code-sunny`:

| Rule | When it replies | Reply text |
| --- | --- | --- |
| **Away auto-reply** | Every incoming message (once per chat per 2 min) | "Hello! I'm currently away from phone..." |
| **Price enquiry** | Message contains the word *price* | Pricing info reply |
| **Help request** | Message contains the word *help* | Help is on the way reply |

**List the rules:**

```powershell
$key = (Get-Content "C:\Users\ujaga\OneDrive\Desktop\whatsaap\data\.api-key").Trim()
$h = @{ "X-API-Key" = $key }
Invoke-RestMethod -Uri "http://localhost:2785/api/sessions/4ff0b408-0807-4f34-98ca-45bbd8b16a32/automation-rules" -Headers $h
```

**Add your own rule:**

```powershell
$body = @{
  name          = "My rule"
  replyText     = "Your reply text here"
  cooldownSeconds = 60
  enabled       = $true
  conditions    = @{ conditions = @(@{ field = "body"; operator = "contains"; value = "keyword" }) }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Method Post `
  -Uri "http://localhost:2785/api/sessions/4ff0b408-0807-4f34-98ca-45bbd8b16a32/automation-rules" `
  -Headers $h -ContentType "application/json" -Body $body
```

**Disable a rule:** set `enabled = $false` via `PUT .../automation-rules/<ruleId>`, or delete with `DELETE`.

---

## 4. Send a message manually (API)

```powershell
$body = @{ chatId = "918975805789@c.us"; text = "Hello from OpenWA!" } | ConvertTo-Json

Invoke-RestMethod -Method Post `
  -Uri "http://localhost:2785/api/sessions/4ff0b408-0807-4f34-98ca-45bbd8b16a32/messages/send-text" `
  -Headers $h -ContentType "application/json" -Body $body
```

`chatId` = country code + number, followed by `@c.us` (personal) or `@g.us` (group).

---

## 5. Useful URLs

| What | URL |
| --- | --- |
| API base | `http://localhost:2785/api` |
| Swagger (API docs) | `http://localhost:2785/api/docs` |
| Health check | `http://localhost:2785/api/health` |

---

## ⚠️ Safety notes

- OpenWA uses **unofficial** WhatsApp clients. There is a **ban risk** for the
  linked number. Never link your main personal or business number — use a
  dedicated number you can afford to lose.
- Do not cold-blast strangers or send thousands of messages per hour. Keep
  auto-replies to people who already message you.
- The old session profile was rotated to `data/sessions/session-code-sunny.old-20260824`
  because it was stale and prevented WhatsApp Web from loading. Delete it once
  the new link works for a few days.
