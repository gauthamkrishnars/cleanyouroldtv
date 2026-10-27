# CleanYourOldTV ⚡📺

> **Resurrect any sluggish budget Android TV (1GB RAM or less) over Wi-Fi in 60 seconds.**  
> Instant UI · Safe OEM Debloat · Standalone 24/7 Phone Remote & Trackpad · Zero-Stutter Streaming · 1-Click Restore.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Android TV](https://img.shields.io/badge/Platform-Android%20TV%20%7C%20Google%20TV%20%7C%20Fire%20OS-brightgreen.svg)](#supported-tvs)
[![Safe: No Root / No Brick](https://img.shields.io/badge/Safety-100%25%20Verified%20Safe-success.svg)](docs/SAFETY_AND_CVTE_GUIDE.md)

---

## The Problem With Budget Android TVs

Millions of budget smart TVs (Lloyd, Xiaomi/Mi, TCL, Realme, OnePlus, Thomson, Vu, Kodak, Blaupunkt) ship with **1 GB or less of RAM**. 

After a couple of years, they become nearly unusable:
* 🐢 **Agonizing UI Lag**: Navigating home menus takes seconds per click because heavy fade animations exhaust the CPU.
* ⌨️ **Remote Typing Torture**: Typing searches and passwords with a plastic infrared remote takes forever.
* 💥 **Decoder Crashes**: Budget chips (like MediaTek MT5863) lack 4K decoders. Playing high-res streams freezes the TV with a black screen.
* ⚠️ **Generic Guides Break Cable TV**: Tools like *CleanYourTV* replace the launcher—which breaks the physical remote's Cable TV / Tuner input on millions of CVTE motherboards and can cause infinite bootloops on Android 7/8.

**CleanYourOldTV** fixes all of this with **zero cables, zero risk of bricking, and a 1-click restore**.

---

## What CleanYourOldTV Does

| Feature | Before | After CleanYourOldTV |
| :--- | :--- | :--- |
| **Menu & Navigation Speed** | Sluggish 1.0x fade delays | **Instant snappy UI (`0.0x` scaling)** |
| **Background Memory Load** | OEM test shims & crash telemetry running | **Safely frozen in user-space (`pm disable-user`)** |
| **Phone Remote Control** | Need an external app or PC running 24/7 | **Built-in 24/7 Web Remote hosted directly on TV (24 KB RAM)** |
| **Mouse & Touchpad** | None | **Smooth precision trackpad with micro-nudge arrows** |
| **Typing Input** | Clicking one letter at a time on D-pad | **Type directly from your phone's keyboard** |
| **Cable TV / Tuner Toggle** | Broken by third-party launchers | **100% preserved (Stock launcher kept safe)** |
| **Video Playback** | Stutters or crashes on high bitrate | **Hardware-buffered VLC profile with zero lag** |
| **Safety Net** | Risk of bootlooping | **1-Click Factory Restore (`RESTORE_FACTORY.bat`)** |

---

## Screenshots

<p align="center">
  <img src="assets/home_clean.png" width="48%" alt="Clean TV Home Screen" />
  <img src="assets/stremio_live.png" width="48%" alt="Streaming Optimization" />
</p>

---

## 🚀 Quickstart: 3 Simple Steps

### Step 1: Turn on Developer Options on Your TV
1. On your TV, go to **Settings** $\rightarrow$ **About** (or *System $\rightarrow$ About*).
2. Find **Build Number** (or *Software Version*) and click the **OK button 7 times**.
3. A message will say *"You are now a developer!"*
4. Go back $\rightarrow$ open **Developer Options** $\rightarrow$ turn **ON**:
   * **USB Debugging**
   * **Network Debugging** (if present)
5. Check your TV's IP address in **Settings $\rightarrow$ Network** (e.g., `192.168.1.4`).

*(For brand-specific guides like Sony, Fire TV, or non-Android LG/Samsung TVs, see our [Universal Brands & Platforms Guide](docs/BRANDS_AND_PLATFORMS.md)).*

---

### Step 2: Run the 1-Click Optimizer

Make sure your PC or phone is connected to the **same Wi-Fi or Ethernet** as your TV.

#### 🪟 Windows (Easiest)
1. Download this repository as a `.zip` and extract it.
2. Double-click **`RUN_OPTIMIZER.bat`**.
3. Type your TV's IP address when prompted (or let it auto-detect).
4. Hands off! In 45 seconds, the script backs up your packages, applies the speed boost, debloats background junk, and launches the phone remote.

#### 🍏 macOS / 🐧 Linux / 📱 Android Termux
Open terminal inside the extracted folder and run:
```bash
chmod +x run_optimizer.sh
./run_optimizer.sh
```

---

### Step 3: Open Your New Phone Remote!

Once the script finishes, open your mobile browser on your phone (connected to your home Wi-Fi) and go to:

```text
http://<YOUR-TV-IP>:8080
```
*(Example: `http://192.168.1.4:8080`)*

> 💡 **Pro Tip**: In your phone browser, tap **Share / Settings $\rightarrow$ Add to Home Screen**. It will install as an app with an icon, giving you instant 1-tap remote access 24/7!

---

## The Standalone On-TV Web Remote

Unlike other remote apps that require a computer running in the background, this remote **lives 100% inside your TV**:

```text
[ Physical TV Boot ]
       │
       ▼
 [ TVRemoteBoot.apk ]  <-- 8 KB receiver catches BOOT_COMPLETED
       │                   Spawns daemon via root localhost socket
       ▼
[ BusyBox httpd ]     <-- Native micro-webserver on port 8080
       │                   Uses only ~24 KB of physical RAM
       ▼
  [ key.cgi ]         <-- Injects events into Linux kernel (/dev/input)
       │
[ Mobile Web UI ]     <-- Clean HTML5 D-Pad, Trackpad & Keyboard
```

### Remote Capabilities:
* **Dual Mode**: Switch between traditional **D-Pad Remote** and **Laptop Trackpad**.
* **Precision Ballistics**: Fine micro-movements for accurate button clicking without overshoot.
* **Micro-Nudge Arrows**: Precision directional arrows (`▲`, `◀`, `▶`, `▼`) for navigating difficult menus.
* **Instant Phone Typing**: Type URLs, passwords, and movie titles using your phone's native keyboard.
* **🧹 Close All Apps**: 1-tap button to kill all background apps and purge cached memory (`drop_caches`), freeing up RAM instantly before gaming or streaming.

---

## 📺 Zero-Stutter Streaming Setup (Stremio + VLC)

Low-RAM TVs often choke when streaming high-bitrate media. Here is the configuration we recommend:

1. **Stremio Android TV**:
   * Sideload the official Stremio Android TV app (`com.stremio.one`).
   * In **Settings $\rightarrow$ Streaming**, exclude `4k` streams (budget MediaTek chips cannot decode 4K and will black-screen).
   * Set **Default Player** to **External Player**.
2. **VLC for Android**:
   * Install VLC for Android (`org.videolan.vlc`).
   * In **Settings $\rightarrow$ Advanced**, set **Network Caching** to `3,000 ms`.
   * Result: Smooth, stutter-free streaming with instant seek and pause.

---

## 🛡️ 100% Safety Guarantee & Rollback

We believe in strict safety guardrails:
* **Zero System Files Deleted**: We only use `pm disable-user --user 0`.
* **Critical Frameworks Preserved**: We **never** disable `com.google.android.gms` (which causes bootloops on Nougat) or the stock launcher (which breaks Cable TV tuner toggles).
* **Automatic Backup**: A full package inventory is automatically saved before touching a single setting.

### How to Undo Everything (1-Click Restore)
If you ever want to revert 100% of the changes back to factory default:
* On Windows: Double-click **`RESTORE_FACTORY.bat`**.
* On Linux/Mac: Run `./restore_factory.sh`.

---

## 📖 Documentation
* [Universal Brands & Platforms Guide (LG webOS, Samsung Tizen, Fire TV, Sony, etc.)](docs/BRANDS_AND_PLATFORMS.md)
* [Safety Guide & Architectural Guardrails](docs/SAFETY_AND_CVTE_GUIDE.md)

---

## ⚖️ License
This project is open-source and released under the [MIT License](LICENSE).
