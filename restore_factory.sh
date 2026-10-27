#!/bin/bash
# CleanYourOldTV - Factory Restore Script for Linux, macOS & Android Termux
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===============================================================================${NC}"
echo -e "${RED}                  CLEANYOUROLDTV - 1-CLICK FACTORY RESTORE                     ${NC}"
echo -e "${BLUE}===============================================================================${NC}"

if ! command -v adb &> /dev/null; then
    echo -e "${RED}[!] ADB is not installed or not in PATH.${NC}"
    exit 1
fi

EXISTING_DEV=$(adb devices | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | awk '{print $1}' | head -n 1)

if [ -n "$EXISTING_DEV" ]; then
    echo -e "${YELLOW}[i] Detected connected TV: $EXISTING_DEV${NC}"
    read -p "Use this device? (Y/n): " USE_EXISTING
    if [[ "$USE_EXISTING" =~ ^[Nn]$ ]]; then
        EXISTING_DEV=""
    else
        TV_TARGET="$EXISTING_DEV"
    fi
fi

if [ -z "$EXISTING_DEV" ]; then
    read -p "Enter your TV's local IP address: " TV_IP
    adb connect "$TV_IP:5555"
    TV_TARGET="$TV_IP:5555"
fi

echo -e "\n[*] Restoring default animation scales (1.0x)..."
adb -s "$TV_TARGET" shell settings put global window_animation_scale 1.0 &>/dev/null
adb -s "$TV_TARGET" shell settings put global transition_animation_scale 1.0 &>/dev/null
adb -s "$TV_TARGET" shell settings put global animator_duration_scale 1.0 &>/dev/null

echo -e "[*] Re-enabling all previously disabled packages..."
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
    adb -s "$TV_TARGET" shell pm enable "$pkg" &>/dev/null || true
done

echo -e "[*] Stopping on-TV remote server and uninstalling helper..."
adb -s "$TV_TARGET" shell "pkill -f 'busybox httpd' >/dev/null 2>&1" || true
adb -s "$TV_TARGET" shell "rm -rf /data/local/tmp/remote /data/local/tmp/busybox >/dev/null 2>&1" || true
adb -s "$TV_TARGET" uninstall com.lloyd.tvremote.boot &>/dev/null || true

echo -e "\n${GREEN}[OK] Your TV has been cleanly restored to factory state.${NC}\n"
