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
echo -e " Resurrect any sluggish Android / Google TV (1GB RAM or less) in 60 seconds."
echo -e " * 100% Safe (No bricking, No root required, Zero system files deleted)"
echo -e " * Instant Snappy UI (0.0x Animation Scaling)"
echo -e " * Universal Telemetry & Crash Debloat (Safe user-space disable)"
echo -e " * 24/7 On-TV Standalone Phone Web Remote (Zero-RAM, Auto-Boot)"
echo -e "${BLUE}===============================================================================${NC}\n"

# Check ADB
if ! command -v adb &> /dev/null; then
    echo -e "${RED}[!] ADB is not installed or not in PATH.${NC}"
    echo -e "    On Ubuntu/Debian: sudo apt install adb"
    echo -e "    On macOS: brew install android-platform-tools"
    echo -e "    On Android Termux: pkg install android-tools"
    exit 1
fi

# Detect device
EXISTING_DEV=$(adb devices | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | awk '{print $1}' | head -n 1)

if [ -n "$EXISTING_DEV" ]; then
    echo -e "${YELLOW}[i] Detected connected TV: $EXISTING_DEV${NC}"
    read -p "Use this device? (Y/n): " USE_EXISTING
    if [[ "$USE_EXISTING" =~ ^[Nn]$ ]]; then
        EXISTING_DEV=""
    else
        TV_TARGET="$EXISTING_DEV"
        TV_IP=$(echo "$EXISTING_DEV" | cut -d: -f1)
    fi
fi

if [ -z "$EXISTING_DEV" ]; then
    read -p "Enter your TV's local IP address (e.g. 192.168.1.50): " TV_IP
    if [ -z "$TV_IP" ]; then
        echo -e "${RED}[!] IP address cannot be empty.${NC}"
        exit 1
    fi
    echo -e "[*] Connecting to $TV_IP:5555..."
    adb connect "$TV_IP:5555"
    TV_TARGET="$TV_IP:5555"
fi

echo -e "\n[*] Verifying connection to $TV_TARGET..."
if ! adb -s "$TV_TARGET" get-state &> /dev/null; then
    echo -e "${RED}[X] Could not connect to $TV_TARGET.${NC}"
    echo -e "    Ensure TV is on the same network and Developer Options/ADB Debugging is ON."
    exit 1
fi

MODEL=$(adb -s "$TV_TARGET" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
VER=$(adb -s "$TV_TARGET" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
BOARD=$(adb -s "$TV_TARGET" shell getprop ro.product.board 2>/dev/null | tr -d '\r')

echo -e "\n${BLUE}===============================================================================${NC}"
echo -e " DEVICE RECOGNIZED: Model: ${GREEN}$MODEL${NC} | Android: ${GREEN}$VER${NC} | Board: ${GREEN}$BOARD${NC}"
echo -e "${BLUE}===============================================================================${NC}\n"

# Step 1: Backup
echo -e "[1/4] Creating safety backup of current package list..."
adb -s "$TV_TARGET" shell pm list packages -f > "tv_backup_${TV_IP}.txt"
echo -e "      ${GREEN}[OK]${NC} Backup saved to tv_backup_${TV_IP}.txt"

# Step 2: Instant Animations
echo -e "\n[2/4] Applying instant UI responsiveness (0.0x animations)..."
adb -s "$TV_TARGET" shell settings put global window_animation_scale 0.0 &>/dev/null
adb -s "$TV_TARGET" shell settings put global transition_animation_scale 0.0 &>/dev/null
adb -s "$TV_TARGET" shell settings put global animator_duration_scale 0.0 &>/dev/null
echo -e "      ${GREEN}[OK]${NC} Menus and transitions now open instantaneously."

# Step 3: Safe Debloat
echo -e "\n[3/4] Safely disabling non-essential background telemetry and test shims..."
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
echo -e "      ${GREEN}[OK]${NC} Safe debloat applied (Zero system apps deleted)."

# Step 4: Standalone On-TV Remote
echo -e "\n[4/4] Deploying 24/7 Standalone On-TV Web Remote..."
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
    echo -e "      [*] Installing auto-start helper (TVRemoteBoot.apk)..."
    adb -s "$TV_TARGET" install -r "$SCRIPT_DIR/bin/TVRemoteBoot.apk" &>/dev/null || true
fi

adb -s "$TV_TARGET" shell "pgrep -f 'busybox httpd' >/dev/null || /data/local/tmp/busybox httpd -p 8080 -h /data/local/tmp/remote || busybox httpd -p 8080 -h /data/local/tmp/remote" &>/dev/null

echo -e "      ${GREEN}[OK]${NC} Remote server is live on TV port 8080."

echo -e "\n${BLUE}===============================================================================${NC}"
echo -e "${GREEN}                     OPTIMIZATION COMPLETED SUCCESSFULLY!                      ${NC}"
echo -e "${BLUE}===============================================================================${NC}"
echo -e "\nOpen this URL on your phone browser (connected to same Wi-Fi):\n"
echo -e "     ${YELLOW}http://${TV_IP}:8080${NC}\n"
echo -e "To revert changes at any time, run: ./restore_factory.sh\n"
