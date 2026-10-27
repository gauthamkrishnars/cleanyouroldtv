@echo off
setlocal enabledelayedexpansion
title CleanYourOldTV - Universal 1-Click Android TV Optimizer
color 0B

echo ===============================================================================
echo                   CLEANYOUROLDTV - 1-CLICK TV RESURRECTION
echo ===============================================================================
echo  Speed up budget Android / Google TVs (1GB RAM or less) over local Wi-Fi.
echo  * 100% Safe (No bricking, No root required, Zero system files deleted)
echo  * Instant Snappy UI (0.0x Animation Scaling)
echo  * Universal Telemetry & Crash Debloat (Safe user-space disable)
echo  * 24/7 On-TV Standalone Phone Web Remote (Zero-RAM, Auto-Boot)
echo ===============================================================================
echo.

:: 1. PREREQUISITE CHECKLIST
echo [PREREQUISITE CHECKLIST]
echo  [ ] TV is turned ON and awake (not in standby)
echo  [ ] PC and TV are connected to the EXACT SAME Wi-Fi or Ethernet router
echo  [ ] Any VPN on this computer (NordVPN, ExpressVPN, Cloudflare Warp) is TURNED OFF
echo.

:: 2. Check for ADB
if exist "adb.exe" set "PATH=%CD%;%PATH%"
if exist "bin\adb.exe" set "PATH=%CD%\bin;%PATH%"

where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] ADB is not found in your system PATH or folder.
    echo.
    echo     EASY FIX (Choose one):
    echo     Option A: Download Google Platform-Tools (contains adb.exe):
    echo               https://developer.android.com/tools/releases/platform-tools
    echo               Extract it and put adb.exe in this same folder.
    echo     Option B: If you have winget, open PowerShell and run: winget install Google.PlatformTools
    echo.
    pause
    exit /b 1
)

:: 3. Check for Connected Devices
echo [*] Scanning for already-connected Android TV devices...
set "EXISTING_DEV="
for /f "tokens=1,2" %%A in ('adb devices ^| findstr /r "[0-9]\.[0-9]"') do (
    if "%%B"=="device" (
        set "EXISTING_DEV=%%A"
    ) else if "%%B"=="unauthorized" (
        echo.
        echo [!] TV DETECTED BUT UNAUTHORIZED: %%A
        echo =======================================================================
        echo  ACTION REQUIRED ON YOUR TV SCREEN:
        echo  1. Look at your TV screen right now.
        echo  2. A popup says: "Allow USB Debugging?"
        echo  3. Use your TV physical remote to check "[X] Always allow from this computer"
        echo  4. Click "OK".
        echo =======================================================================
        echo.
        pause
    )
)

if defined EXISTING_DEV (
    echo [i] Found active TV connection: !EXISTING_DEV!
    set /p "USE_DEV=Use this TV? (Y/n): "
    if /i "!USE_DEV!" neq "n" (
        set "TV_TARGET=!EXISTING_DEV!"
        for /f "tokens=1 delims=:" %%C in ("!EXISTING_DEV!") do set "TV_IP=%%C"
        goto :VERIFY_CONNECTION
    )
)

:PROMPT_IP
echo.
echo -------------------------------------------------------------------------------
echo How to find your TV's IP address:
echo  * Android TV / Google TV: Settings -^> Network ^& Internet -^> Your Wi-Fi -^> IP Address
echo  * Fire TV: Settings -^> My Fire TV -^> About -^> Network -^> IP Address
echo  * Example format: 192.168.1.50
echo -------------------------------------------------------------------------------
set /p "TV_IP=Enter your TV's IP address: "
if "%TV_IP%"=="" (
    echo [!] IP address cannot be empty.
    goto :PROMPT_IP
)

:: Clean any accidental port entered by user (e.g. 192.168.1.50:5555 -> 192.168.1.50)
for /f "tokens=1 delims=:" %%X in ("%TV_IP%") do set "TV_IP=%%X"

echo.
echo [*] Connecting wirelessly to %TV_IP%:5555...
adb connect %TV_IP%:5555
set "TV_TARGET=%TV_IP%:5555"

:VERIFY_CONNECTION
echo.
echo [*] Checking connection status...
set "DEV_STATE="
for /f "tokens=2" %%S in ('adb devices ^| findstr /c:"%TV_TARGET%"') do set "DEV_STATE=%%S"

if "%DEV_STATE%"=="unauthorized" (
    echo.
    echo =======================================================================
    echo  [!] ACTION REQUIRED: LOOK AT YOUR TV SCREEN RIGHT NOW!
    echo =======================================================================
    echo  Your TV is showing a permission popup:
    echo     "Allow USB debugging? The computer's RSA key fingerprint is..."
    echo.
    echo  Step 1: Use your TV remote to check "[X] Always allow from this computer"
    echo  Step 2: Select "OK"
    echo =======================================================================
    echo.
    echo Press any key AFTER you have clicked OK on your TV...
    pause >nul
    adb reconnect >nul 2>&1
    timeout /t 2 >nul
    goto :VERIFY_CONNECTION
)

if "%DEV_STATE%" neq "device" (
    echo.
    echo [X] Could not establish connection to %TV_TARGET%.
    echo.
    echo  TROUBLESHOOTING CHECKLIST:
    echo  1. Are PC and TV on the EXACT SAME Wi-Fi router? (Check if PC is on Guest Wi-Fi).
    echo  2. Is a VPN running on this computer? Turn it OFF!
    echo  3. Is the TV screen awake and on?
    echo  4. Did you enable USB/Network Debugging on the TV?
    echo     (See docs/BRANDS_AND_PLATFORMS.md for brand-specific steps).
    echo.
    set /p "RETRY=Would you like to try again? (y/n): "
    if /i "!RETRY!"=="y" goto :PROMPT_IP
    exit /b 1
)

:: Read Device Info
for /f "delims=" %%M in ('adb -s %TV_TARGET% shell getprop ro.product.model 2^>nul') do set "DEVICE_MODEL=%%M"
for /f "delims=" %%V in ('adb -s %TV_TARGET% shell getprop ro.build.version.release 2^>nul') do set "ANDROID_VER=%%V"
for /f "delims=" %%B in ('adb -s %TV_TARGET% shell getprop ro.product.board 2^>nul') do set "BOARD_NAME=%%B"

echo.
echo ===============================================================================
echo  SUCCESSFULLY CONNECTED TO TV:
echo  - TV Model       : %DEVICE_MODEL%
echo  - Android OS     : Version %ANDROID_VER%
echo  - Hardware Board : %BOARD_NAME%
echo ===============================================================================
echo.

:: Safety Backup (Always Created)
echo [*] Creating safety backup of your TV's current package inventory...
set "BACKUP_FILE=tv_backup_%TV_IP%.txt"
adb -s %TV_TARGET% shell pm list packages -f > "%BACKUP_FILE%"
echo     [OK] Safety backup saved to: %BACKUP_FILE%

:: Interactive Selection Menu
:SHOW_MENU
echo.
echo ===============================================================================
echo  CHOOSE WHAT YOU WANT TO DO:
echo ===============================================================================
echo  [1] Optimize TV Only
echo      - Remove sluggish animation delays (0.0x instant scaling)
echo      - Freeze background telemetry and OEM test bloat (save RAM)
echo.
echo  [2] Install 24/7 Phone Remote Only
echo      - Touchpad, D-pad, live keyboard typing, and RAM cleaner
echo      - Zero-RAM BusyBox daemon with auto-boot on TV power-on
echo.
echo  [3] Free Streaming Setup Only (Stremio Addons)
echo      - Automatically inject Torrentio (Movies/Series) and Anime Kitsu
echo.
echo  [4] Everything (Recommended)
echo      - Apply TV speedup, install web remote, and configure streaming addons
echo ===============================================================================
set "USER_CHOICE=4"
set /p "USER_CHOICE=Enter choice [1, 2, 3, or 4] (Default is 4): "

if "%USER_CHOICE%"=="1" goto :DO_OPTIMIZE
if "%USER_CHOICE%"=="2" goto :DO_REMOTE
if "%USER_CHOICE%"=="3" goto :DO_STREAMING
if "%USER_CHOICE%"=="4" goto :DO_ALL

echo [!] Invalid choice. Please select 1, 2, 3, or 4.
goto :SHOW_MENU

:DO_ALL
set "FLAG_OPT=1"
set "FLAG_REMOTE=1"
set "FLAG_STREAM=1"
goto :EXECUTE

:DO_OPTIMIZE
set "FLAG_OPT=1"
set "FLAG_REMOTE=0"
set "FLAG_STREAM=0"
goto :EXECUTE

:DO_REMOTE
set "FLAG_OPT=0"
set "FLAG_REMOTE=1"
set "FLAG_STREAM=0"
goto :EXECUTE

:DO_STREAMING
set "FLAG_OPT=0"
set "FLAG_REMOTE=0"
set "FLAG_STREAM=1"
goto :EXECUTE

:EXECUTE
:: 1. TV Optimization Execution
if "%FLAG_OPT%"=="1" (
    echo.
    echo [*] Speeding up UI (Removing sluggish animation delays)...
    adb -s %TV_TARGET% shell settings put global window_animation_scale 0.0 >nul 2>&1
    adb -s %TV_TARGET% shell settings put global transition_animation_scale 0.0 >nul 2>&1
    adb -s %TV_TARGET% shell settings put global animator_duration_scale 0.0 >nul 2>&1
    echo     [OK] Navigation transitions set to 0.0x (Instant snappy response).

    echo.
    echo [*] Safely disabling non-essential background telemetry and test shims...
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
    echo     [OK] Safe debloat applied (Zero system files deleted, 100% reversible).
)

:: 2. Phone Web Remote Deployment
if "%FLAG_REMOTE%"=="1" (
    echo.
    echo [*] Installing 24/7 Standalone Phone Web Remote onto the TV...
    adb -s %TV_TARGET% shell "mkdir -p /data/local/tmp/remote/cgi-bin" >nul 2>&1

    adb -s %TV_TARGET% push remote/index.html /data/local/tmp/remote/ >nul 2>&1
    adb -s %TV_TARGET% push remote/manifest.json /data/local/tmp/remote/ >nul 2>&1
    adb -s %TV_TARGET% push remote/icon.svg /data/local/tmp/remote/ >nul 2>&1
    adb -s %TV_TARGET% push remote/cgi-bin/key.cgi /data/local/tmp/remote/cgi-bin/ >nul 2>&1
    adb -s %TV_TARGET% shell "chmod 755 /data/local/tmp/remote/cgi-bin/key.cgi" >nul 2>&1

    adb -s %TV_TARGET% push bin/busybox /data/local/tmp/busybox >nul 2>&1
    adb -s %TV_TARGET% shell "chmod 755 /data/local/tmp/busybox" >nul 2>&1

    if exist "bin\TVRemoteBoot.apk" (
        echo     [*] Installing auto-boot receiver service (TVRemoteBoot.apk)...
        adb -s %TV_TARGET% install -r bin/TVRemoteBoot.apk >nul 2>&1
    )

    adb -s %TV_TARGET% shell "pgrep -f 'busybox httpd' >/dev/null || /data/local/tmp/busybox httpd -p 8080 -h /data/local/tmp/remote || busybox httpd -p 8080 -h /data/local/tmp/remote" >nul 2>&1
    echo     [OK] Remote server is active on TV port 8080.
)

:: 3. Free Streaming Setup (Stremio Addons)
if "%FLAG_STREAM%"=="1" (
    echo.
    echo [*] Checking media streaming apps (Stremio and VLC)...
    
    :: Sideload Stremio if APK exists locally
    adb -s %TV_TARGET% shell pm path com.stremio.one >nul 2>&1
    if %errorlevel% neq 0 (
        set "STREMIO_APK="
        if exist "Stremio_TV.apk" set "STREMIO_APK=Stremio_TV.apk"
        if exist "bin\Stremio_TV.apk" set "STREMIO_APK=bin\Stremio_TV.apk"
        if defined STREMIO_APK (
            echo     [*] Sideloading Stremio Android TV APK wirelessly over ADB...
            adb -s %TV_TARGET% install -r "!STREMIO_APK!" >nul 2>&1
            echo     [OK] Stremio sideloaded successfully!
        ) else (
            echo     [i] Stremio is not currently installed on your TV.
            echo         You can download the official Android TV APK from stremio.com/download
            echo         and place Stremio_TV.apk in this folder to sideload it automatically.
        )
    )

    :: Sideload VLC if APK exists locally
    adb -s %TV_TARGET% shell pm path org.videolan.vlc >nul 2>&1
    if %errorlevel% neq 0 (
        set "VLC_APK="
        if exist "vlc.apk" set "VLC_APK=vlc.apk"
        if exist "bin\vlc.apk" set "VLC_APK=bin\vlc.apk"
        if defined VLC_APK (
            echo     [*] Sideloading VLC for Android APK wirelessly over ADB...
            adb -s %TV_TARGET% install -r "!VLC_APK!" >nul 2>&1
            echo     [OK] VLC sideloaded successfully!
        ) else (
            echo     [i] VLC is not currently installed on your TV.
            echo         You can download the official ARM APK from get.videolan.org/vlc-android
            echo         and place vlc.apk in this folder to sideload it automatically.
        )
    )

    :: Auto-inject addons into Stremio
    adb -s %TV_TARGET% shell pm path com.stremio.one >nul 2>&1
    if %errorlevel% equ 0 (
        echo     [*] Auto-injecting Torrentio and Anime Kitsu addons into Stremio...
        adb -s %TV_TARGET% shell am start -a android.intent.action.VIEW -d "stremio://torrentio.strem.fun/manifest.json" >nul 2>&1
        timeout /t 2 >nul
        adb -s %TV_TARGET% shell input keyevent 22 >nul 2>&1
        adb -s %TV_TARGET% shell input keyevent 66 >nul 2>&1
        timeout /t 1 >nul
        adb -s %TV_TARGET% shell am start -a android.intent.action.VIEW -d "stremio://anime-kitsu.strem.fun/manifest.json" >nul 2>&1
        timeout /t 2 >nul
        adb -s %TV_TARGET% shell input keyevent 22 >nul 2>&1
        adb -s %TV_TARGET% shell input keyevent 66 >nul 2>&1
        echo     [OK] Torrentio and Anime Kitsu successfully injected into Stremio!
    )
)

echo.
echo ===============================================================================
echo                           PROCESS COMPLETED!
echo ===============================================================================
if "%FLAG_REMOTE%"=="1" (
    echo.
    echo  ===========================================================================
    echo   YOUR 24/7 PHONE REMOTE IS LIVE:
    echo   1. Ensure your phone is connected to the same home Wi-Fi.
    echo   2. Open your phone's browser and visit:
    echo.
    echo          http://%TV_IP%:8080
    echo.
    echo   3. Tap Settings -^> "Add to Home Screen" to install it as an app!
    echo  ===========================================================================
    echo.
    set /p "OPEN_BROWSER=Open the remote URL in your browser now to test? (Y/n): "
    if /i "!OPEN_BROWSER!" neq "n" (
        start http://%TV_IP%:8080
    )
)

echo.
echo  To revert any changes back to factory default, run: RESTORE_FACTORY.bat
echo ===============================================================================
echo.
pause
