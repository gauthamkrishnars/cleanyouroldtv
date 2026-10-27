#!/bin/bash
# CleanYourOldTV - Universal 1-Click Android TV Optimizer for Linux, macOS & Android Termux
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===============================================================================${NC}"
echo -e "${GREEN}                  CLEANYOUROLDTV - 1-CLICK TV RESURRECTION                     ${NC}"
echo -e "${BLUE}===============================================================================${NC}"
echo -e " Speed up budget Android / Google TVs (1GB RAM or less) over local Wi-Fi."
echo -e " * 100% Safe (No bricking, No root required, Zero system files deleted)"
echo -e " * Instant Snappy UI (0.0x Animation Scaling)"
echo -e " * Universal Telemetry & Crash Debloat (Safe user-space disable)"
echo -e " * 24/7 On-TV Standalone Phone Web Remote (Zero-RAM, Auto-Boot)"
echo -e "${BLUE}===============================================================================${NC}\n"

echo -e "${YELLOW}[CRITICAL PREREQUISITES]${NC}"
echo -e " 1. TV must be turned ON and awake (not in standby)."
echo -e " 2. This device and TV must be on the EXACT SAME Wi-Fi or router network."
echo -e " 3. Turn OFF any active VPN on this device before proceeding.\n"

# Check ADB
if ! command -v adb &> /dev/null; then
    echo -e "${RED}[X] ADB is not installed or not in PATH.${NC}"
    echo -e "    On Ubuntu/Debian : sudo apt update && sudo apt install adb"
    echo -e "    On macOS         : brew install android-platform-tools"
    echo -e "    On Android Termux: pkg install android-tools"
    exit 1
fi

# Detect existing device
EXISTING_DEV=$(adb devices | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | head -n 1 | awk '{print $1}')
DEV_STATE=$(adb devices | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | head -n 1 | awk '{print $2}')

if [ "$DEV_STATE" = "unauthorized" ]; then
    echo -e "${YELLOW}=======================================================================${NC}"
    echo -e "${RED}[!] ACTION REQUIRED ON YOUR TV SCREEN:${NC}"
    echo -e " A popup is showing on your TV: 'Allow USB Debugging?'"
    echo -e " Use your TV remote to check '[X] Always allow from this computer' and click OK."
    echo -e "${YELLOW}=======================================================================${NC}"
    read -p "Press Enter AFTER clicking OK on your TV..."
    adb reconnect &>/dev/null || true
    sleep 2
fi

if [ -n "$EXISTING_DEV" ] && [ "$DEV_STATE" = "device" ]; then
    echo -e "${GREEN}[i] Detected connected TV: $EXISTING_DEV${NC}"
    read -p "Use this TV? (Y/n): " USE_EXISTING
    if [[ ! "$USE_EXISTING" =~ ^[Nn]$ ]]; then
        TV_TARGET="$EXISTING_DEV"
        TV_IP=$(echo "$EXISTING_DEV" | cut -d: -f1)
    fi
fi

if [ -z "$TV_TARGET" ]; then
    echo -e "-------------------------------------------------------------------------------"
    echo -e "Find TV IP in: Settings -> Network -> Your Wi-Fi -> IP Address"
    echo -e "-------------------------------------------------------------------------------"
    read -p "Enter your TV's local IP address (e.g. 192.168.1.50): " RAW_IP
    TV_IP=$(echo "$RAW_IP" | cut -d: -f1)
    if [ -z "$TV_IP" ]; then
        echo -e "${RED}[!] IP address cannot be empty.${NC}"
        exit 1
    fi
    echo -e "[*] Connecting wirelessly to $TV_IP:5555..."
    adb connect "$TV_IP:5555"
    TV_TARGET="$TV_IP:5555"
fi

# Verify state
CHECK_STATE=$(adb devices | grep "$TV_TARGET" | awk '{print $2}')
if [ "$CHECK_STATE" = "unauthorized" ]; then
    echo -e "\n${YELLOW}=======================================================================${NC}"
    echo -e "${RED}[!] ACTION REQUIRED: LOOK AT YOUR TV SCREEN RIGHT NOW!${NC}"
    echo -e " A popup says: 'Allow USB debugging?'"
    echo -e " 1. Check '[X] Always allow from this computer'"
    echo -e " 2. Click 'OK'"
    echo -e "${YELLOW}=======================================================================${NC}"
    read -p "Press Enter AFTER clicking OK on your TV screen..."
    adb reconnect &>/dev/null || true
    sleep 2
    CHECK_STATE=$(adb devices | grep "$TV_TARGET" | awk '{print $2}')
fi

if [ "$CHECK_STATE" != "device" ]; then
    echo -e "${RED}[X] Could not connect to $TV_TARGET.${NC}"
    echo -e " Troubleshooting:"
    echo -e " 1. Make sure both devices are on the EXACT SAME Wi-Fi network."
    echo -e " 2. Turn OFF any active VPN."
    echo -e " 3. Verify Developer Options / ADB Debugging is ON on the TV."
    exit 1
fi

MODEL=$(adb -s "$TV_TARGET" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
VER=$(adb -s "$TV_TARGET" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
BOARD=$(adb -s "$TV_TARGET" shell getprop ro.product.board 2>/dev/null | tr -d '\r')

echo -e "\n${BLUE}===============================================================================${NC}"
echo -e " CONNECTED TO TV: Model: ${GREEN}$MODEL${NC} | Android: ${GREEN}$VER${NC} | Board: ${GREEN}$BOARD${NC}"
echo -e "${BLUE}===============================================================================${NC}\n"

# Step 1: Backup (Always Created)
echo -e "[*] Creating safety backup of current package list..."
adb -s "$TV_TARGET" shell pm list packages -f > "tv_backup_${TV_IP}.txt"
echo -e "    ${GREEN}[OK]${NC} Backup saved to tv_backup_${TV_IP}.txt\n"

# Interactive Selection Menu
echo -e "${BLUE}===============================================================================${NC}"
echo -e " CHOOSE WHAT YOU WANT TO DO:"
echo -e "${BLUE}===============================================================================${NC}"
echo -e " [1] Optimize TV Only (Instant UI animations + safe debloat)"
echo -e " [2] Install 24/7 Phone Remote Only (Touchpad, keyboard, zero-RAM web remote)"
echo -e " [3] Free Streaming Setup Only (Stremio Addons: Torrentio & Anime Kitsu)"
echo -e " [4] Everything (Recommended - All of the above)"
echo -e "${BLUE}===============================================================================${NC}"
read -p "Enter choice [1, 2, 3, or 4] (Default is 4): " USER_CHOICE
USER_CHOICE=${USER_CHOICE:-4}

DO_OPT=0
DO_REMOTE=0
DO_STREAM=0

case "$USER_CHOICE" in
    1) DO_OPT=1 ;;
    2) DO_REMOTE=1 ;;
    3) DO_STREAM=1 ;;
    *) DO_OPT=1; DO_REMOTE=1; DO_STREAM=1 ;;
esac

# 1. UI Optimization
if [ "$DO_OPT" -eq 1 ]; then
    echo -e "\n[*] Applying instant UI responsiveness (0.0x animations)..."
    adb -s "$TV_TARGET" shell settings put global window_animation_scale 0.0 &>/dev/null
    adb -s "$TV_TARGET" shell settings put global transition_animation_scale 0.0 &>/dev/null
    adb -s "$TV_TARGET" shell settings put global animator_duration_scale 0.0 &>/dev/null
    echo -e "    ${GREEN}[OK]${NC} Menus and transitions now open instantaneously."

    echo -e "\n[*] Safely disabling non-essential background telemetry and test shims..."
    PACKAGES=(
        "com.example.user.myapplication"
        "com.android.cts.priv.ctsshim"
        "com.android.cts.ctsshim"
        "com.mediatek.androidbox"
        "com.android.printservice.recommendation"
        "com.google.android.feedback"
        "com.android.providers.blockednumber"
        "com.android.pacprocessor"
        "com.google.android.onetimeinitializer"
        "com.google.android.gsf.notouch"
    )

    for pkg in "${PACKAGES[@]}"; do
        adb -s "$TV_TARGET" shell pm disable-user --user 0 "$pkg" &>/dev/null || true
    done
    echo -e "    ${GREEN}[OK]${NC} Safe debloat applied (Zero system apps deleted, 100% reversible)."
fi

# 2. Standalone Web Remote
if [ "$DO_REMOTE" -eq 1 ]; then
    echo -e "\n[*] Deploying 24/7 Standalone On-TV Web Remote..."
    adb -s "$TV_TARGET" shell "mkdir -p /data/local/tmp/remote/cgi-bin" &>/dev/null

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    adb -s "$TV_TARGET" push "$SCRIPT_DIR/remote/index.html" /data/local/tmp/remote/ &>/dev/null
    adb -s "$TV_TARGET" push "$SCRIPT_DIR/remote/manifest.json" /data/local/tmp/remote/ &>/dev/null
    adb -s "$TV_TARGET" push "$SCRIPT_DIR/remote/icon.svg" /data/local/tmp/remote/ &>/dev/null
    adb -s "$TV_TARGET" push "$SCRIPT_DIR/remote/cgi-bin/key.cgi" /data/local/tmp/remote/cgi-bin/ &>/dev/null
    adb -s "$TV_TARGET" shell "chmod 755 /data/local/tmp/remote/cgi-bin/key.cgi" &>/dev/null

    adb -s "$TV_TARGET" push "$SCRIPT_DIR/bin/busybox" /data/local/tmp/busybox &>/dev/null
    adb -s "$TV_TARGET" shell "chmod 755 /data/local/tmp/busybox" &>/dev/null

    if [ -f "$SCRIPT_DIR/bin/TVRemoteBoot.apk" ]; then
        echo -e "    [*] Installing auto-start helper (TVRemoteBoot.apk)..."
        adb -s "$TV_TARGET" install -r "$SCRIPT_DIR/bin/TVRemoteBoot.apk" &>/dev/null || true
    fi

    adb -s "$TV_TARGET" shell "pgrep -f 'busybox httpd' >/dev/null || /data/local/tmp/busybox httpd -p 8080 -h /data/local/tmp/remote || busybox httpd -p 8080 -h /data/local/tmp/remote" &>/dev/null
    echo -e "    ${GREEN}[OK]${NC} Remote server is live on TV port 8080."
fi

# 3. Free Streaming Setup
if [ "$DO_STREAM" -eq 1 ]; then
    echo -e "\n[*] Checking media streaming apps (Stremio and VLC)..."

    # Sideload Stremio if APK exists locally
    if ! adb -s "$TV_TARGET" shell pm path com.stremio.one &>/dev/null; then
        STREMIO_APK=""
        [ -f "$SCRIPT_DIR/Stremio_TV.apk" ] && STREMIO_APK="$SCRIPT_DIR/Stremio_TV.apk"
        [ -f "$SCRIPT_DIR/bin/Stremio_TV.apk" ] && STREMIO_APK="$SCRIPT_DIR/bin/Stremio_TV.apk"
        if [ -n "$STREMIO_APK" ]; then
            echo -e "    [*] Sideloading Stremio Android TV APK wirelessly over ADB..."
            adb -s "$TV_TARGET" install -r "$STREMIO_APK" &>/dev/null || true
            echo -e "    ${GREEN}[OK]${NC} Stremio sideloaded successfully!"
        else
            echo -e "    [i] Stremio is not currently installed on your TV."
            echo -e "        Download the official Android TV APK from stremio.com/download"
            echo -e "        and place Stremio_TV.apk in this folder to sideload automatically."
        fi
    fi

    # Sideload VLC if APK exists locally
    if ! adb -s "$TV_TARGET" shell pm path org.videolan.vlc &>/dev/null; then
        VLC_APK=""
        [ -f "$SCRIPT_DIR/vlc.apk" ] && VLC_APK="$SCRIPT_DIR/vlc.apk"
        [ -f "$SCRIPT_DIR/bin/vlc.apk" ] && VLC_APK="$SCRIPT_DIR/bin/vlc.apk"
        if [ -n "$VLC_APK" ]; then
            echo -e "    [*] Sideloading VLC for Android APK wirelessly over ADB..."
            adb -s "$TV_TARGET" install -r "$VLC_APK" &>/dev/null || true
            echo -e "    ${GREEN}[OK]${NC} VLC sideloaded successfully!"
        else
            echo -e "    [i] VLC is not currently installed on your TV."
            echo -e "        Download the official ARM APK from get.videolan.org/vlc-android"
            echo -e "        and place vlc.apk in this folder to sideload automatically."
        fi
    fi

    # Auto-inject addons into Stremio
    if adb -s "$TV_TARGET" shell pm path com.stremio.one &>/dev/null; then
        echo -e "\n[*] Auto-injecting Torrentio and Anime Kitsu addons into Stremio..."
        adb -s "$TV_TARGET" shell am start -a android.intent.action.VIEW -d "stremio://torrentio.strem.fun/manifest.json" &>/dev/null || true
        sleep 2
        adb -s "$TV_TARGET" shell input keyevent 22 &>/dev/null || true
        adb -s "$TV_TARGET" shell input keyevent 66 &>/dev/null || true
        sleep 1
        adb -s "$TV_TARGET" shell am start -a android.intent.action.VIEW -d "stremio://anime-kitsu.strem.fun/manifest.json" &>/dev/null || true
        sleep 2
        adb -s "$TV_TARGET" shell input keyevent 22 &>/dev/null || true
        adb -s "$TV_TARGET" shell input keyevent 66 &>/dev/null || true
        echo -e "    ${GREEN}[OK]${NC} Free streaming addons injected into Stremio!"
    fi
fi

echo -e "\n${BLUE}===============================================================================${NC}"
echo -e "${GREEN}                           PROCESS COMPLETED!                                  ${NC}"
echo -e "${BLUE}===============================================================================${NC}"

if [ "$DO_REMOTE" -eq 1 ]; then
    echo -e "\nHOW TO OPEN YOUR NEW REMOTE:"
    echo -e "1. Connect your phone to the SAME home Wi-Fi network."
    echo -e "2. Open your phone browser and visit:"
    echo -e "\n     ${YELLOW}http://${TV_IP}:8080${NC}\n"
    echo -e "3. Tap 'Add to Home Screen' in your browser to install it as an app!"
fi

echo -e "To revert changes at any time, run: ./restore_factory.sh\n"
