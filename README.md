# TelDrive Easy

> A friend-friendly Windows installer for TelDrive — your personal Telegram cloud drive. One double-click and you have unlimited storage backed by your Telegram account.

**Made by [Kaarthik Dass Arora](https://github.com/kaarthikdassarorasahabji-png)** — based on [tgdrive/teldrive](https://github.com/tgdrive/teldrive).

---

## Why this exists

Plain TelDrive is powerful but takes ~30 minutes to set up: PostgreSQL, `config.toml`, JWT secrets, Telegram API, scheduled tasks. Most people give up.

**TelDrive Easy** wraps all of that into a single `.exe`. You double-click, follow a 3-screen wizard, and you're done. TelDrive runs 24/7 in the background. Your files live in your own Telegram channel.

---

## What you get

- ✅ **Single double-click installer** — no command line, no config files
- ✅ **24/7 background service** — auto-starts on boot, restarts on crash
- ✅ **Your storage stays yours** — files go into *your* Telegram channel, not anyone else's
- ✅ **Web UI at** `http://localhost:8080`
- 📱 **Android & iOS apps — coming soon. Stay tuned.**

---

## Get the installer

The `.exe` is **not** in this repo (it would contain testing-phase secrets).

During the friend-testing phase, get it directly from Kaarthik (Telegram / Drive link). After public launch it'll appear under [Releases](https://github.com/kaarthikdassarorasahabji-png/teldrive-easy/releases).

---

## Install — 3 steps

1. Download `TelDriveSetup-x.y.z.exe`.
2. Right-click → **Run as administrator** → click through the wizard.
3. The wizard will:
   - Open `https://my.telegram.org` in your browser → you create a free Telegram developer app and paste back two values
   - Help you create a private Telegram channel
   - Auto-configure the rest — JWT, encryption keys, 24/7 service, browser launch

When done, your TelDrive opens at `http://localhost:8080`. Log in with your Telegram phone number. **Done.**

---

## What's in this repo?

```
.
├── installer/
│   ├── setup-wizard.ps1        # The PowerShell wizard run on first install
│   ├── teldrive-setup.iss      # Inno Setup script (compiles to .exe)
│   ├── build-installer.ps1     # Local-only build script (asks for your DB URL)
│   ├── Open-TelDrive.bat       # Start menu shortcut helper
│   ├── Stop-TelDrive.bat
│   └── Uninstall-Service.bat
├── UPSTREAM_README.md          # Original TelDrive README (full credit upstream)
└── ... (TelDrive Go source from upstream fork)
```

The Go source is the original [tgdrive/teldrive](https://github.com/tgdrive/teldrive) — we add only the `installer/` folder on top.

---

## Build the installer yourself

Requires:
- Windows 10/11
- [Inno Setup 6](https://jrsoftware.org/isdl.php)
- PowerShell 5+
- A Postgres connection string (free [Supabase](https://supabase.com) tier works)

Then:

```powershell
cd installer
powershell -ExecutionPolicy Bypass -File .\build-installer.ps1
```

You'll be prompted for the Supabase URL once. The output `.exe` lands in `dist/`. **Never commit `dist/` to a public repo** — the `.exe` contains your DB password.

---

## Roadmap

- [x] Windows `.exe` installer (this repo)
- [ ] **Android app** (Flutter, native MTProto, no shared backend) — *next*
- [ ] **iOS app** — after Android
- [ ] Multi-tenant TelDrive 2.0 (each user fully isolated, no whitelist) — long-term

---

## License

MIT (matches upstream).

---

## Credits

- Upstream: [tgdrive/teldrive](https://github.com/tgdrive/teldrive) — the Go server doing all the heavy lifting
- Installer + branding: **Kaarthik Dass Arora**
