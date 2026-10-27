# CleanYourOldTV ⚡📺

> **Resurrect any sluggish budget Smart TV over Wi-Fi in 60 seconds.**  
> Instant Menu Response · Safe Background Debloat · 24/7 Phone Remote with Touchpad · Stutter-Free Streaming · 100% Risk-Free.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Android TV](https://img.shields.io/badge/Supported-Android%20TV%20%7C%20Google%20TV%20%7C%20Fire%20OS-brightgreen.svg)](#supported-tvs)
[![Safety: 100% Verified](https://img.shields.io/badge/Safety-100%25%20Brick--Proof-success.svg)](docs/SAFETY_AND_CVTE_GUIDE.md)

---

## 🛑 The Problem with Budget & Older Smart TVs

Millions of budget smart TVs (such as **Lloyd, Xiaomi/Mi, TCL, Realme, OnePlus, Thomson, Vu, Kodak, Blaupunkt, Daiwa, Hisense, and generic Android TVs**) come with **only 1 GB or less of RAM**.

After a year or two of updates and usage, they slow down to a crawl:
* 🐢 **Agonizing UI Lag**: Pressing buttons on the remote takes seconds to respond because slow fade animations choke the TV processor.
* ⌨️ **Typing Torture**: Searching on YouTube or typing Wi-Fi passwords with a sluggish plastic remote is agonizing.
* 💥 **App Freezes & Decoder Crashes**: When streaming apps attempt high-bitrate video, older TV chips overheat or crash to a black screen.
* ⚠️ **Generic Guides Break Cable TV**: Many online tutorials tell you to replace the launcher or delete system packages—which can break your physical remote's Cable TV tuner or trap your TV in a bootloop!

**CleanYourOldTV** fixes all of this with **no cables, no root, zero risk, and a 1-click restore**.

---

## ✨ What This Toolkit Does For Your TV

| What Annoyed You | What CleanYourOldTV Fixes |
| :--- | :--- |
| **Laggy Home & Settings Menus** | **Instant responsiveness**: Animation delays set to `0.0x` so menus snap open instantly. |
| **Hidden Factory Telemetry & Bloat** | **Freed RAM**: Freezes background crash-tracking and OEM test shims safely in user-space. |
| **Lost or Sluggish Plastic Remote** | **24/7 On-TV Web Remote**: Runs directly on the TV using only 24 KB RAM. Accessible from any phone browser on Wi-Fi. |
| **No Mouse for Sideloaded Apps** | **Laptop-style Trackpad**: Full touch cursor with micro-nudge arrows for precision aiming. |
| **Slow On-Screen Typing** | **Direct Phone Typing**: Type passwords, movie titles, and links straight from your phone's keyboard. |
| **Family Cable TV Compatibility** | **100% Intact**: Keeps your factory TV launcher untouched so Cable TV and physical remote buttons never break. |
| **Video Playback Stuttering** | **Hardware Buffer Optimization**: Pre-configures video caching so movies play smoothly without buffering. |
| **Peace of Mind** | **1-Click Rollback**: Run `RESTORE_FACTORY.bat` at any time to return 100% back to factory default in 5 seconds. |

---

## 📸 Screenshots

<p align="center">
  <img src="assets/home_clean.png" width="48%" alt="Clean TV Home Screen" />
  <img src="assets/stremio_live.png" width="48%" alt="Smooth Streaming Setup" />
</p>

<p align="center">
  <img src="assets/tv_interface.png" width="48%" alt="Fast Navigation Interface" />
  <img src="assets/youtube_tv.png" width="48%" alt="Instant YouTube Playback" />
</p>

---

## 🚀 Quickstart: 3 Simple Steps

### Step 1: Connect to Your TV over Wi-Fi

Your PC (or phone) and your TV simply need to be connected to the **same home Wi-Fi network or Ethernet router**.

#### How to Enable Network Debugging on Your TV:

Try **Method 0** first—on many budget TVs, it is already ready to connect!

* **Method 0: Try Connecting Right Away! (Most Budget TVs)**  
  Many budget TVs (Lloyd, Thomson, Kodak, Vu, Daiwa) ship with Network Debugging **already enabled by default from the factory**. Simply find your TV's IP address (under *Settings $\rightarrow$ Network*) and run the script! If it connects, you are done!

* **Method 1: The Standard "7 Clicks" Method (Google TV, Sony, Mi, TCL, Realme)**  
  1. Open TV **Settings** $\rightarrow$ **About** (or *System $\rightarrow$ About*).  
  2. Find **Build Number** (or *Android TV OS Build*).  
  3. Press the **OK button on your remote 7 times rapidly** until a message pops up: *"You are now a developer!"*  
  4. Press Back $\rightarrow$ Open **Developer Options** $\rightarrow$ Turn **ON** `USB Debugging` and `Network Debugging`.

* **Method 2: Factory Remote Code (If 7 clicks does not do anything on your TV)**  
  Some older budget TV remotes use a direct factory code:  
  * Press **`Menu`** (or `Source`) on your physical remote, then quickly type **`1 1 4 7`** (or **`2 5 8 0`** or **`8 1 5`**).  
  * In the engineering menu, look for *General / Other Settings* and turn **ADB Debugging ON**.

*(Have an **LG** or **Samsung** TV? See our [Non-Android TV Guide](docs/BRANDS_AND_PLATFORMS.md) for webOS and Tizen speedup tips!)*

---

### Step 2: Run the 1-Click Script

#### 🪟 On Windows (Easiest)
1. Download this repository ([Click here to download ZIP](https://github.com/gauthamkrishnars/cleanyouroldtv/archive/refs/heads/main.zip)) and extract it.
2. Double-click **`RUN_OPTIMIZER.bat`**.
3. Enter your TV's IP address (e.g., `192.168.1.50`) when prompted, or let it auto-detect.
4. **Hands off!** The script automatically backs up your packages, sets instant animations, applies safe debloat, and launches your phone remote.

#### 🍏 On macOS / 🐧 Linux
Open terminal in the folder and run:
```bash
chmod +x run_optimizer.sh
./run_optimizer.sh
```

#### 📱 100% Phone-Only (No PC or Laptop Needed!)
If you don't have a computer, you can run this directly from an Android phone:
1. Install the free **Bugjaeger Mobile ADB** app (or **Termux**) from the Google Play Store on your phone.
2. Connect your phone to your home Wi-Fi and connect to your TV's IP address on port `5555`.
3. In Termux, run:
   ```bash
   pkg install android-tools git
   git clone https://github.com/gauthamkrishnars/cleanyouroldtv.git
   cd cleanyouroldtv
   chmod +x run_optimizer.sh
   ./run_optimizer.sh
   ```

---

### Step 3: Open Your 24/7 Phone Remote!

Once the script completes, open your smartphone browser on your home Wi-Fi and go to:

```text
http://<YOUR-TV-IP>:8080
```
*(Example: `http://192.168.1.50:8080` — replace with your TV's actual IP address)*

> 📱 **Add to Phone Home Screen**: In Safari or Chrome on your phone, tap **Share / Settings $\rightarrow$ Add to Home Screen**. It installs as an app with an icon for instant, full-screen remote control anytime!

---

## 🕹️ Standalone 24/7 On-TV Web Remote

Unlike other remote apps that force you to keep a computer running or install ad-heavy apps from the Play Store, this remote **lives 100% inside your TV**:

```text
[ TV Powers On at Wall ]
           │
           ▼
  [ TVRemoteBoot.apk ]   <-- 8 KB receiver catches power-on broadcast
           │                 Starts micro-daemon via root socket, then exits
           ▼
   [ BusyBox httpd ]     <-- Built-in micro web server (Only 24 KB RAM!)
           │
           ▼
      [ key.cgi ]        <-- Injects events straight to hardware input kernel
           │
    [ Phone Web UI ]     <-- Served directly to any smartphone browser
```

### Remote Highlights:
* **D-Pad & Trackpad Modes**: Seamless toggle between traditional TV D-Pad buttons and a smooth laptop-style mouse trackpad.
* **Sensitivity Controls**: Toggle between **Fine**, **Normal**, and **Fast** pointer speeds.
* **Micro-Nudge Precision**: Arrow buttons (`▲`, `◀`, `▶`, `▼`) for pixel-perfect clicking on small buttons.
* **Instant Phone Keyboard**: Type searches, movie names, and long passwords from your phone keyboard instead of clicking one letter at a time on screen.
* **🧹 Close All Apps / Purge RAM**: Single button that terminates background applications and cleans cached memory (`drop_caches`), giving you maximum free RAM before playing games or launching heavy apps.

---

## 🍿 Recommended Streaming Setup (Zero Stutter)

If your TV has limited RAM or an older MediaTek processor, here is the battle-tested streaming combination:

1. **Stremio for Android TV** (`com.stremio.one`):
   * In **Settings $\rightarrow$ Streaming**, exclude `4k` (budget TV decoders lock up on 4K files).
   * Set **Default Player** to **External Player**.
2. **VLC for Android** (`org.videolan.vlc`):
   * In **Settings $\rightarrow$ Advanced**, set **Network Caching** to `3,000 ms`.
   * **Result**: Zero video stutter, instant playback scrubbing, and zero UI lockup.

---

## 🛡️ Strict Safety Guarantee & 1-Click Rollback

* **No Bricking Hazard**: Operates strictly in user-space (`/data`). System partitions are never remounted.
* **Google Play Services Preserved**: We never disable `com.google.android.gms` (which causes cold-boot hangs on older Android builds).
* **Tuner & Remote Safe**: Your stock launcher is kept intact, meaning Cable TV and your physical remote's Source/Home buttons work exactly as they always did.
* **Safe Freezing**: Uses `pm disable-user --user 0`. No system files are permanently deleted.

### How to Undo (1-Click Factory Restore)
Want to return 100% back to factory default?
* On Windows: Double-click **`RESTORE_FACTORY.bat`**.
* On Linux/Mac: Run `./restore_factory.sh`.

---

## 📚 Deep Guides & Documentation
* [Universal Brands & Platforms Guide (Android TV, Fire TV, LG webOS, Samsung Tizen)](docs/BRANDS_AND_PLATFORMS.md)
* [Safety Architecture & Hardware Lessons](docs/SAFETY_AND_CVTE_GUIDE.md)
* [Manual Step-by-Step Commands (For Power Users)](docs/MANUAL_COMMANDS.md)

---

## ⚖️ License
This project is open-source and free under the [MIT License](LICENSE).
