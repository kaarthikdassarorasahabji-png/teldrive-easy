# TelDrive Easy — Mobile (Android, iOS coming soon)

> Flutter client for [TelDrive Easy](https://github.com/kaarthikdassarorasahabji-png/teldrive-easy).
> Talks to your own TelDrive server (the Windows `.exe`) over HTTP.

---

## What you need

1. The TelDrive Easy `.exe` already running on your Windows PC (24/7 service).
2. The PC and the phone on the **same Wi-Fi**, OR the PC exposed via a tunnel (Cloudflare Tunnel, Tailscale).
3. Android Studio with Flutter installed (`flutter doctor` should be green).

## First run

```powershell
cd mobile
flutter pub get
flutter run
```

On the device:
1. Enter your PC's address: `http://192.168.x.y:8080` (find via `ipconfig` on Windows → look for IPv4 Address).
2. The app opens TelDrive's login page in a WebView. Log in with your Telegram phone number.
3. After login, the app captures the JWT cookie and drops you on the file browser.

---

## Phase A scope (this commit)

- ✅ Server URL screen (validation, secure storage)
- ✅ Telegram login WebView with cookie capture
- ✅ File/folder browser with breadcrumbs (read-only)
- ✅ Image preview with pinch-zoom
- ✅ Settings screen (logout, change server)

## Phase B (next)

- ⏳ Video player (`media_kit` or `video_player`)
- ⏳ PDF preview (`pdfx`)
- ⏳ File upload (`file_picker` + Dio progress)
- ⏳ Background uploads (`workmanager`)
- ⏳ Offline cache for thumbnails

## Phase C

- iOS support (no code changes — just `flutter build ipa` once Apple Dev account is in place)

---

## Folder layout

```
lib/
  main.dart                    Entry point
  app.dart                     Root widget + router
  core/
    auth_storage.dart          flutter_secure_storage wrapper
    dio_client.dart            Dio + JWT interceptor
  data/
    td_models.dart             TdFile, TdSession (hand-written, no codegen)
    td_api.dart                REST methods
  features/
    auth/
      server_url_screen.dart   First-run server picker
      telegram_login_screen.dart   WebView login
    browser/
      browser_screen.dart      Folder list
      file_tile.dart           List item
    viewer/
      image_viewer.dart        Pinch-zoom image
    settings/
      settings_screen.dart     Logout, change server, about
test/
  widget_test.dart             Server URL screen tests
```

No code generation. No `freezed`/`json_serializable`. ~600 lines total — read it all in one sitting.

---

Made by **Kaarthik Dass Arora**.
