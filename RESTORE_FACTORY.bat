@echo off
setlocal enabledelayedexpansion
title CleanYourOldTV - 1-Click Factory Restore
color 0C

echo ===============================================================================
echo                   CLEANYOUROLDTV - FACTORY RESTORE TOOL
echo ===============================================================================
echo  This script cleanly undoes all optimizations and restores factory defaults:
echo  * Restores default animation scales (1.0x)
echo  * Re-enables all disabled system packages
echo  * Stops and removes the TV remote daemon
echo ===============================================================================
echo.

if exist "adb.exe" set "PATH=%CD%;%PATH%"
if exist "bin\adb.exe" set "PATH=%CD%\bin;%PATH%"

:: Detect or Prompt for TV IP
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
        goto :DO_RESTORE
    )
)

:PROMPT_IP
set /p "TV_IP=Enter TV IP address: "
if "%TV_IP%"=="" goto :PROMPT_IP
adb connect %TV_IP%:5555
set "TV_TARGET=%TV_IP%:5555"

:DO_RESTORE
echo.
echo [*] Restoring animation scales to 1.0x (Stock Android Default)...
adb -s %TV_TARGET% shell settings put global window_animation_scale 1.0 >nul 2>&1
adb -s %TV_TARGET% shell settings put global transition_animation_scale 1.0 >nul 2>&1
adb -s %TV_TARGET% shell settings put global animator_duration_scale 1.0 >nul 2>&1

echo [*] Re-enabling all previously disabled packages...
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
    adb -s %TV_TARGET% shell pm enable %%P >nul 2>&1
)

echo [*] Stopping on-TV remote server and uninstalling helper...
adb -s %TV_TARGET% shell "pkill -f 'busybox httpd' >/dev/null 2>&1"
adb -s %TV_TARGET% shell "rm -rf /data/local/tmp/remote /data/local/tmp/busybox >/dev/null 2>&1"
adb -s %TV_TARGET% uninstall com.lloyd.tvremote.boot >nul 2>&1

echo.
echo ===============================================================================
echo                         RESTORE COMPLETED SUCCESSFULLY!
echo ===============================================================================
echo  Your TV has been cleanly returned to its stock state.
echo ===============================================================================
echo.
pause
