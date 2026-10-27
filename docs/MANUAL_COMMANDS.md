# Manual Step-by-Step Command Guide (For Power Users)

If you prefer running commands manually via your terminal instead of the 1-click script, here is the complete step-by-step breakdown:

---

## 1. Prerequisites & Connecting to the TV

Before running any commands:
1. Ensure your PC and TV are on the **exact same Wi-Fi network** (not guest Wi-Fi).
2. Turn **OFF any active VPN** on your computer.
3. Make sure the TV screen is **ON and awake**.

Find your TV's local IP address (e.g., `192.168.1.50`) and connect over the local network:

```bash
adb connect 192.168.1.50:5555
adb devices
```

> ⚠️ **CRITICAL**: If `adb devices` shows `unauthorized`, look at your TV screen! A popup will ask: *"Allow USB debugging?"*. Use your physical TV remote to check **"[X] Always allow from this computer"** and select **OK**.

Verify that `adb devices` now reports `device`:
```text
List of devices attached
192.168.1.50:5555    device
```

---

## 2. Backup Your Installed Packages

Always create a full backup of all packages before touching anything:

```bash
adb shell pm list packages -f > my_tv_backup.txt
```

---

## 3. Instant UI Speedup (Remove Animation Lag)

This cuts transition and window opening delays to zero, making menus snap open immediately without waiting for slow fade animations:

```bash
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0
```

---

## 4. Safe User-Space Debloat

Freeze universal test shims, print spooler recommendation engines, and crash reporting services:

```bash
adb shell pm disable-user --user 0 com.example.user.myapplication
adb shell pm disable-user --user 0 com.android.cts.priv.ctsshim
adb shell pm disable-user --user 0 com.android.cts.ctsshim
adb shell pm disable-user --user 0 com.mediatek.androidbox
adb shell pm disable-user --user 0 com.android.printservice.recommendation
adb shell pm disable-user --user 0 com.google.android.feedback
adb shell pm disable-user --user 0 com.android.providers.blockednumber
adb shell pm disable-user --user 0 com.android.pacprocessor
adb shell pm disable-user --user 0 com.google.android.onetimeinitializer
adb shell pm disable-user --user 0 com.google.android.gsf.notouch
```

> **IMPORTANT**: Never disable `com.google.android.gms` or your TV's stock launcher!

---

## 5. Deploy the Standalone 24/7 Phone Remote

### A. Push Web Remote Files to the TV:
```bash
adb shell mkdir -p /data/local/tmp/remote/cgi-bin
adb push remote/index.html /data/local/tmp/remote/
adb push remote/manifest.json /data/local/tmp/remote/
adb push remote/icon.svg /data/local/tmp/remote/
adb push remote/cgi-bin/key.cgi /data/local/tmp/remote/cgi-bin/
adb shell chmod 755 /data/local/tmp/remote/cgi-bin/key.cgi
```

### B. Push the Standalone BusyBox Binary:
```bash
adb push bin/busybox /data/local/tmp/busybox
adb shell chmod 755 /data/local/tmp/busybox
```

### C. Install the Auto-Boot Helper APK:
```bash
adb install -r bin/TVRemoteBoot.apk
```

### D. Start the Remote Daemon:
```bash
adb shell "/data/local/tmp/busybox httpd -p 8080 -h /data/local/tmp/remote"
```

Open `http://<YOUR-TV-IP>:8080` in your phone browser!

---

## 6. How to Revert Manually

To undo everything:

```bash
# 1. Restore standard animation scales
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0

# 2. Re-enable all packages
adb shell pm enable com.example.user.myapplication
adb shell pm enable com.android.cts.priv.ctsshim
adb shell pm enable com.android.cts.ctsshim
adb shell pm enable com.mediatek.androidbox
adb shell pm enable com.android.printservice.recommendation
adb shell pm enable com.google.android.feedback
adb shell pm enable com.android.providers.blockednumber
adb shell pm enable com.android.pacprocessor
adb shell pm enable com.google.android.onetimeinitializer
adb shell pm enable com.google.android.gsf.notouch

# 3. Stop remote server and clean up
adb shell pkill -f "busybox httpd"
adb shell rm -rf /data/local/tmp/remote /data/local/tmp/busybox
adb uninstall com.lloyd.tvremote.boot
```
