# Khamasiyat Customer App — Simple Setup Guide

Welcome. This guide is for people who are **not** software developers.

It explains, step by step, how to:

1. Download this project safely from GitHub  
2. Install the free tools you need  
3. Run the Khamasiyat mobile app on a Windows computer (Android)

Please follow the steps **in order**. Do not skip steps.

---

## What is this project?

**Khamasiyat** is a mobile app for customers to browse stadiums, choose a pitch time, book a slot, and pay.

This folder is the **source code** of the customer app (built with Flutter).

That means:

- You are **not** installing a finished app from the Play Store.
- You are downloading the project and running it in **developer / test mode** on your computer.

---

## Before you start — what you need

| Item | Notes |
|------|--------|
| A Windows computer | Windows 10 or 11 is best |
| Internet connection | Needed for downloads and first setup |
| About **15–30 GB** free disk space | Android tools are large |
| Time | First setup can take **1–2 hours** |
| Patience | The first install is the hard part; later runs are faster |

### Important honesty check

This app talks to a **backend server** (API).

- If the server is **not running**, the app may open but login / stadiums / booking will fail.
- If you only received this mobile project, ask the person who shared it for:
  - the server address, **or**
  - help starting the backend

You can still complete install and launch steps below.

---

## Safety rules (please read)

Follow these to stay safe:

1. **Download only from the official GitHub link** below.  
2. **Do not** download Flutter, Android Studio, or Git from random websites or ads.  
3. **Do not** enter real bank passwords into unknown copies of this project.  
4. Use this for **testing** unless your team tells you otherwise.  
5. If Windows asks “Allow this app to make changes?”, only click **Yes** for software you intentionally installed (Android Studio, Flutter).  
6. Never share your GitHub password in chat, screenshots, or email.

**Official project page:**

https://github.com/ZicoLap/khamasiyat-mobile-app

If the page does not look like GitHub, or the address is different, stop and ask for help.

---

## Step 1 — Download the project from GitHub (easiest way)

You do **not** need to know Git for this method.

1. Open this link in your browser:  
   https://github.com/ZicoLap/khamasiyat-mobile-app
2. Click the green **Code** button.
3. Click **Download ZIP**.
4. Wait until the ZIP file finishes downloading.
5. Open your **Downloads** folder.
6. Right-click the ZIP file → **Extract All…** → choose a simple place, for example:

   `C:\Users\YOUR_NAME\Desktop\Khamasiyat`

7. Open the extracted folder until you see files like:
   - `README.md` (this file)
   - `pubspec.yaml`
   - folders named `lib`, `android`, `config`

**Tip:** Avoid putting the project in folders with Arabic characters or spaces if you can.  
A path like `C:\Khamasiyat\khamasiyat-mobile-app` is safer.

---

## Step 2 — Install Git (recommended)

Git is a free tool. Some Flutter tools work better when Git is installed.

1. Open: https://git-scm.com/download/win  
2. Download the Windows installer.  
3. Run it.  
4. Keep clicking **Next** (default options are fine).  
5. Finish the install.  
6. Restart your computer if asked.

---

## Step 3 — Install Android Studio

Android Studio is free. It includes the Android tools and an optional phone simulator.

1. Open: https://developer.android.com/studio  
2. Download **Android Studio**.  
3. Install it (default options are fine).  
4. Open Android Studio for the first time.  
5. Complete the setup wizard and let it download components.  
6. When finished, leave Android Studio installed (you will use it again).

### Create a virtual phone (emulator)

1. In Android Studio, open **Device Manager** (phone icon / More Actions).  
2. Click **Create device** (or Create Virtual Device).  
3. Choose a modern phone, for example **Pixel 6**.  
4. Download a system image if asked (choose a recent one).  
5. Finish and click **Finish**.

You now have a virtual Android phone on your computer.

---

## Step 4 — Install Flutter

Flutter is the free toolkit this app is built with.

1. Open: https://docs.flutter.dev/get-started/install/windows  
2. Follow the official Windows install page carefully.  
3. Download the Flutter SDK ZIP.  
4. Extract it to a simple folder, for example:

   `C:\flutter`

5. Add Flutter to your PATH (the Flutter install page explains this).  
6. Close **all** open terminals / Command Prompt windows.  
7. Open a **new** Command Prompt or PowerShell.  
8. Type this command and press Enter:

```text
flutter doctor
```

9. Read the report.
10. Fix anything marked with an **X** (Flutter doctor often tells you what to install next).
11. Run again until Android tooling looks mostly OK:

```text
flutter doctor
```

Common required items:

- Flutter SDK  
- Android toolchain  
- Android Studio  
- Windows version of Chrome (optional for web; not required for this Android guide)

---

## Step 5 — Accept Android licenses (one-time)

In Command Prompt / PowerShell, run:

```text
flutter doctor --android-licenses
```

When asked, type `y` and press Enter for each license until finished.

---

## Step 6 — Prepare the project on your computer

1. Open Command Prompt or PowerShell.  
2. Go into the project folder. Example:

```text
cd C:\Users\YOUR_NAME\Desktop\Khamasiyat\khamasiyat-mobile-app-main
```

(Use your real extracted folder name. Sometimes GitHub adds `-main` at the end.)

3. Download project packages:

```text
flutter pub get
```

Wait until it finishes without red error text.

---

## Step 7 — Start the virtual phone

1. Open Android Studio.  
2. Open **Device Manager**.  
3. Click the **Play** button next to your virtual phone.  
4. Wait until the virtual phone home screen appears.

**Keep the virtual phone running** while you start the app.

---

## Step 8 — Run the Khamasiyat app

In the same project folder in Command Prompt / PowerShell, run:

```text
flutter devices
```

You should see your emulator listed.

Then run:

```text
flutter run --dart-define-from-file=config/development.json
```

What happens next:

1. Flutter builds the app (first time can take **many minutes**).  
2. The app installs on the virtual phone.  
3. The Khamasiyat login / splash screen should appear.

### How to stop the app later

In the terminal where the app is running:

- Press `q` to quit  
  or  
- Close the terminal window

---

## Step 9 — Using a real Android phone (optional)

If you prefer a real phone instead of the emulator:

1. On your phone, enable **Developer options** and **USB debugging**  
   (search Google for “enable USB debugging” + your phone brand).  
2. Connect the phone with a USB cable.  
3. Allow the computer when the phone asks.  
4. Run:

```text
flutter devices
flutter run --dart-define-from-file=config/local.json
```

For a real phone, `config/local.json` must point to a server address your phone can reach on Wi‑Fi.

Ask a technical teammate for the correct `API_BASE_URL` before doing this.

---

## About the server (why login might fail)

This mobile app needs a working backend.

Default development setting (Android emulator):

- Server address: `http://10.0.2.2:3000`

That special address means: “the computer running the emulator.”

So for full testing you usually need:

1. The **Khamasiyat server** running on your computer, **and**  
2. This mobile app running on the emulator

If you do not have the server:

- The app may still open.  
- Features that need internet data (login, stadiums, booking, payment) may show errors.

That is expected. Ask your team for the backend setup instructions.

---

## Common problems and easy fixes

### “flutter is not recognized”

- Flutter is not in PATH, or you did not open a **new** terminal after installing.  
- Close the terminal, open a new one, try again.  
- Re-check the Flutter Windows install guide.

### “No devices found”

- Start the Android emulator first.  
- Wait until the virtual phone fully boots.  
- Run `flutter devices` again.

### Build takes forever / computer is slow

- First build is normal to be slow.  
- Close other heavy apps.  
- Leave the computer alone until it finishes.

### App opens but cannot log in / no stadiums

- Backend server is probably not running, or the API address is wrong.  
- Ask a teammate to confirm the server is up.

### Antivirus / Windows Defender warnings

- Prefer official downloads only.  
- If a warning appears for Android Studio or Flutter from official sites, it is usually a normal installer prompt.  
- If unsure, pause and ask a technical person.

### “Permission denied” or strange path errors

- Move the project to a simple English path like `C:\Khamasiyat\app`.  
- Avoid OneDrive-synced folders if they cause file lock issues.

### ZIP folder name ends with `-main`

That is normal. Use that folder as your project folder.

---

## What success looks like

You are done with the basic setup when:

1. `flutter doctor` looks mostly healthy  
2. An Android emulator (or phone) is visible in `flutter devices`  
3. `flutter run --dart-define-from-file=config/development.json` launches the app  
4. You can see the Khamasiyat screens on the phone/emulator  

If login and stadium lists also work, the backend is connected successfully.

---

## Safe daily habit after setup

Next time you want to run the app:

1. Start the Android emulator  
2. Open terminal in the project folder  
3. Run:

```text
flutter pub get
flutter run --dart-define-from-file=config/development.json
```

You usually do **not** need to reinstall Flutter or Android Studio every time.

---

## Need help?

When asking for help, send:

1. A screenshot of the error  
2. The exact command you typed  
3. The output of:

```text
flutter doctor -v
```

Do **not** send passwords, payment receipts, or private API keys.

---

## For developers (short reference)

If you are a developer, this project is a Flutter customer app.

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=config/development.json
```

Config files live in `config/`.  
Architecture notes: `docs/ARCHITECTURE.md`.

Default Android emulator API origin: `http://10.0.2.2:3000` → `/api/v1`.
