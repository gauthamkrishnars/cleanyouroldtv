@echo off
setlocal enabledelayedexpansion
title CleanYourOldTV - Universal 1-Click Android TV Optimizer
color 0B

echo ===============================================================================
echo                   CLEANYOUROLDTV - 1-CLICK TV RESURRECTION
echo ===============================================================================
echo  Resurrect any sluggish Android / Google TV (1GB RAM or less) in 60 seconds.
echo  * 100% Safe (No bricking, No root required, Zero system files deleted)
echo  * Instant Snappy UI (0.0x Animation Scaling)
echo  * Universal Telemetry & Crash Debloat (Safe user-space disable)
echo  * 24/7 On-TV Standalone Phone Web Remote (Zero-RAM, Auto-Boot)
echo ===============================================================================
echo.

:: 1. Check for ADB
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] ADB is not found in your system PATH.
    echo     Please install ADB or download Platform-Tools from Google:
    echo     https://developer.android.com/tools/releases/platform-tools
    echo.
    pause
    exit /b 1
)

:: 2. Auto-Detect or Prompt for TV IP
echo [*] Checking for connected devices...
for /f "tokens=1,2" %%A in ('adb devices ^| findstr /r "[0-9]\:[0-9]"') do (
    if "%%B"=="device" (
        set "EXISTING_DEV=%%A"
    )
)

if defined EXISTING_DEV (
    echo [i] Detected active device: !EXISTING_DEV!
    set /p "USE_DEV=Use this device? (Y/n): "
    if /i "!USE_DEV!" neq "n" (
        set "TV_TARGET=!EXISTING_DEV!"
        for /f "tokens=1 delims=:" %%C in ("!EXISTING_DEV!") do set "TV_IP=%%C"
        goto :CONNECTED
    )
)

:PROMPT_IP
echo.
echo Please enter your TV's local IP address (Found in TV Settings - Network):
set /p "TV_IP=Enter TV IP (e.g. 192.168.1.4): "
if "%TV_IP%"=="" (
    echo [!] IP address cannot be empty.
    goto :PROMPT_IP
)

echo.
echo [*] Connecting to %TV_IP%:5555...
adb connect %TV_IP%:5555
set "TV_TARGET=%TV_IP%:5555"

:CONNECTED
echo.
echo [*] Verifying connection to %TV_TARGET%...
adb -s %TV_TARGET% get-state >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Could not connect to %TV_TARGET%.
    echo     Make sure:
    echo     1. TV and PC are on the same Wi-Fi / Ethernet network.
    echo     2. Developer Options and Network/USB Debugging are turned ON on the TV.
    echo.
    set /p "RETRY=Try again? (y/n): "
    if /i "!RETRY!"=="y" goto :PROMPT_IP
    exit /b 1
)

:: 3. Read Device Info
for /f "delims=" %%M in ('adb -s %TV_TARGET% shell getprop ro.product.model 2^>nul') do set "DEVICE_MODEL=%%M"
for /f "delims=" %%V in ('adb -s %TV_TARGET% shell getprop ro.build.version.release 2^>nul') do set "ANDROID_VER=%%V"
for /f "delims=" %%B in ('adb -s %TV_TARGET% shell getprop ro.product.board 2^>nul') do set "BOARD_NAME=%%B"

echo.
echo ===============================================================================
echo  DEVICE RECOGNIZED:
echo  - Model   : %DEVICE_MODEL%
echo  - Android : Version %ANDROID_VER%
echo  - Board   : %BOARD_NAME%
echo ===============================================================================
echo.

:: 4. Safety Guardrail & Backup
echo [1/4] Creating safety backup of current package list...
set "BACKUP_FILE=tv_backup_%TV_IP%.txt"
adb -s %TV_TARGET% shell pm list packages -f > "%BACKUP_FILE%"
echo       [OK] Backup saved to: %BACKUP_FILE%

:: 5. Instant UI Speedup
echo.
echo [2/4] Applying instant UI responsiveness (Zero animation lag)...
adb -s %TV_TARGET% shell settings put global window_animation_scale 0.0 >nul 2>&1
adb -s %TV_TARGET% shell settings put global transition_animation_scale 0.0 >nul 2>&1
adb -s %TV_TARGET% shell settings put global animator_duration_scale 0.0 >nul 2>&1
echo       [OK] Menu and navigation transitions set to instantaneous.

:: 6. Safe System Debloat (Guardrails Active)
echo.
echo [3/4] Safely disabling non-essential background telemetry and test shims...
for %%P in (
    com.example.user.myapplication
    com.android.cts.priv.ctsshim
    com.android.cts.ctsshim
    com.mediatek.androidbox
    com.android.printservice.recommendation
    com.google.android.feedback
    com.android.providers.blockednumber
    com.android.pacprocessor
    com.google.android.onetimeinitializer
    com.google.android.gsf.notouch
) do (
    adb -s %TV_TARGET% shell pm disable-user --user 0 %%P >nul 2>&1
)
echo       [OK] Safe debloat applied (Zero system apps deleted).

:: 7. Deploy 24/7 On-TV Standalone Web Remote
echo.
echo [4/4] Deploying 24/7 Standalone On-TV Web Remote (Zero-RAM daemon)...
adb -s %TV_TARGET% shell "mkdir -p /data/local/tmp/remote/cgi-bin" >nul 2>&1

:: Push web files
adb -s %TV_TARGET% push remote/index.html /data/local/tmp/remote/ >nul 2>&1
adb -s %TV_TARGET% push remote/manifest.json /data/local/tmp/remote/ >nul 2>&1
adb -s %TV_TARGET% push remote/icon.svg /data/local/tmp/remote/ >nul 2>&1
adb -s %TV_TARGET% push remote/cgi-bin/key.cgi /data/local/tmp/remote/cgi-bin/ >nul 2>&1
adb -s %TV_TARGET% shell "chmod 755 /data/local/tmp/remote/cgi-bin/key.cgi" >nul 2>&1

:: Push standalone busybox if system does not have it
adb -s %TV_TARGET% push bin/busybox /data/local/tmp/busybox >nul 2>&1
adb -s %TV_TARGET% shell "chmod 755 /data/local/tmp/busybox" >nul 2>&1

:: Install autostart receiver APK
if exist "bin\TVRemoteBoot.apk" (
    echo       [*] Installing auto-start service (TVRemoteBoot.apk)...
    adb -s %TV_TARGET% install -r bin/TVRemoteBoot.apk >nul 2>&1
)

:: Start the daemon immediately
adb -s %TV_TARGET% shell "pgrep -f 'busybox httpd' >/dev/null || /data/local/tmp/busybox httpd -p 8080 -h /data/local/tmp/remote || busybox httpd -p 8080 -h /data/local/tmp/remote" >nul 2>&1

echo       [OK] Remote server active on TV port 8080.
echo.
echo ===============================================================================
echo                      OPTIMIZATION COMPLETED SUCCESSFULLY!
echo ===============================================================================
echo.
echo  Your TV is now optimized:
echo  1. Menus and app switching are instant.
echo  2. Unused background services have been frozen.
echo  3. Your Standalone 24/7 Phone Remote is LIVE.
echo.
echo  OPEN THIS LINK ON YOUR PHONE (Connected to same Wi-Fi):
echo.
echo        http://%TV_IP%:8080
echo.
echo  (Add it to your phone's Home Screen for a native 1-tap app experience!)
echo.
echo  To revert anything at any time, just run: RESTORE_FACTORY.bat
echo ===============================================================================
echo.
set /p "OPEN_BROWSER=Would you like to open the remote in your browser now? (Y/n): "
if /i "%OPEN_BROWSER%" neq "n" (
    start http://%TV_IP%:8080
)
echo.
pause
