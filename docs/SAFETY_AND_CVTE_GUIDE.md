# Safety Guide and Hardware Guardrails

This document details the safety rules implemented in **CleanYourOldTV** to avoid device bricking, bootloops, and broken tuner controls observed with generic debloat scripts on budget hardware.

---

## Core Safety Rules

### Guardrail 1: NEVER Remount `/system` Read-Write
* **The Danger**: Budget smart TVs (especially MediaTek MT5863 / MT5867 / MT5862) enforce **dm-verity** kernel integrity checks on boot. If any script remounts `/system` as read-write (`mount -o remount,rw /system`) and modifies, deletes, or replaces system files, dm-verity trips upon reboot. The TV will permanently bootloop at the bootloader stage, requiring factory JTAG/eMMC flashing tools.
* **Our Protection**: CleanYourOldTV works **strictly in user-space (`/data`)**. No `/system` partitions are ever remounted or modified.

---

### Guardrail 2: NEVER Disable Google Play Services (`com.google.android.gms`)
* **The Danger**: Many generic debloat scripts recommend disabling `com.google.android.gms` to save RAM. On Android 7.0 (Nougat) and Android 8.0 CVTE AOSP firmware, the Android ActivityManagerService (AMS) and system lockscreen frameworks have a hard dependency on GMS initialization during cold boot. If GMS is disabled, the boot sequence hangs indefinitely at the looping "android" boot animation.
* **Our Protection**: CleanYourOldTV explicitly preserves Google Play Services and system initializers.

---

### Guardrail 3: NEVER Disable the Stock Launcher on Budget / CVTE Motherboards
* **The Danger**: On millions of budget TVs (Lloyd, Thomson, Kodak, Vu, etc.), the TV uses a universal smart TV motherboard manufactured by **CVTE** (running custom software such as `cn.zeasn.launcher.vstoresubclient.cvte` or `com.cvte.tv.launcher.space`). 
  The TV's physical remote has a "Home" or "Source" button wired directly to toggle between Smart TV mode and the Cable/Antenna/HDMI tuner hardware. Disabling the stock launcher or setting a third-party launcher as default breaks physical input switching and confuses family members.
* **Our Protection**: We keep the stock launcher intact and instead set all animation scales to `0.0x`. This makes the stock interface open instantly with zero lag while preserving full compatibility with the physical remote and cable tuner.

---

### Guardrail 4: Safe Package Management (`pm disable-user --user 0`)
* **The Danger**: Commands like `pm uninstall -k --user 0` remove the application package for the user, making recovery difficult if the user does not have a copy of the original APK.
* **Our Protection**: We only use `pm disable-user --user 0`. The APK is frozen in place without deleting a single file. Running `RESTORE_FACTORY.bat` re-enables every package in 5 seconds without needing an internet connection.

---

## The Standalone On-TV Remote Architecture (Zero-RAM Overhead)

Most remote apps require running a Python server on a desktop computer. CleanYourOldTV runs the web remote **directly inside the TV**:

```text
[ Physical TV Boot ]
       │
       ▼
 [ TVRemoteBoot.apk ]  <-- BroadcastReceiver catches BOOT_COMPLETED
       │                   Spawns daemon as root via localhost socket
       ▼
[ BusyBox httpd ]     <-- Micro web server (Listening on :8080)
       │                   Uses only ~24 KB of physical RAM
       ▼
  [ key.cgi ]         <-- Injects events straight to /dev/input/event2 (<5ms)
       │
[ Mobile Web UI ]     <-- Served directly to any smartphone browser on Wi-Fi
```

* **Zero Persistent App Footprint**: `TVRemoteBoot.apk` exits immediately after triggering the daemon.
* **Native Memory Footprint**: The micro-httpd daemon consumes only **24 KB** (0.024 MB), leaving 100% of RAM available for streaming.
