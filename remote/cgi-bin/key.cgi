#!/system/bin/sh
printf "Content-Type: text/plain\r\nAccess-Control-Allow-Origin: *\r\n\r\n"

# Parse query string
key=""
app=""
text=""
mouse=""
dx=""
dy=""

saveIFS=$IFS
IFS='&'
set -- $QUERY_STRING
IFS=$saveIFS

for param in "$@"; do
    case "$param" in
        code=*) key="${param#code=}" ;;
        app=*) app="${param#app=}" ;;
        text=*) text="${param#text=}" ;;
        mouse=*) mouse="${param#mouse=}" ;;
        dx=*) dx="${param#dx=}" ;;
        dy=*) dy="${param#dy=}" ;;
    esac
done

# Detect primary pointer device if available
POINTER_DEV="/dev/input/event2"
if [ ! -e "$POINTER_DEV" ]; then
    for ev in /dev/input/event*; do
        if [ -e "$ev" ]; then
            POINTER_DEV="$ev"
            break
        fi
    done
fi

# Handle Mouse Movement & Clicks
if [ -n "$mouse" ]; then
    case "$mouse" in
        move)
            if [ -n "$dx" ] && [ -n "$dy" ]; then
                sendevent "$POINTER_DEV" 2 0 "$dx" 2>/dev/null
                sendevent "$POINTER_DEV" 2 1 "$dy" 2>/dev/null
                sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
                printf "OK\n"
                exit 0
            fi
            ;;
        click|left)
            sendevent "$POINTER_DEV" 1 272 1 2>/dev/null
            sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
            sendevent "$POINTER_DEV" 1 272 0 2>/dev/null
            sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
            printf "OK\n"
            exit 0
            ;;
        right)
            sendevent "$POINTER_DEV" 1 273 1 2>/dev/null
            sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
            sendevent "$POINTER_DEV" 1 273 0 2>/dev/null
            sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
            printf "OK\n"
            exit 0
            ;;
    esac
fi

# Handle Key Events
if [ -n "$key" ]; then
    case "$key" in
        recents)
            input keyevent 187
            printf "RECENTS\n"
            exit 0
            ;;
        close_all|clear_all)
            printf "ALL_CLOSED\n"
            (
                sendevent "$POINTER_DEV" 1 172 1 2>/dev/null
                sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
                sendevent "$POINTER_DEV" 1 172 0 2>/dev/null
                sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
                am kill-all
                am force-stop com.stremio.one 2>/dev/null
                am force-stop org.videolan.vlc 2>/dev/null
                am force-stop com.phlox.tvwebbrowser 2>/dev/null
                echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
            ) </dev/null >/dev/null 2>&1 &
            exit 0
            ;;
        power)
            input keyevent 26
            printf "POWER\n"
            exit 0
            ;;
    esac

    hw_code=""
    case "$key" in
        up) hw_code=103 ;;
        down) hw_code=108 ;;
        left) hw_code=105 ;;
        right) hw_code=106 ;;
        enter|ok) hw_code=28 ;;
        back) hw_code=158 ;;
        home) hw_code=172 ;;
        volup) hw_code=115 ;;
        voldn) hw_code=114 ;;
        mute) hw_code=113 ;;
        playpause) hw_code=164 ;;
    esac

    if [ -n "$hw_code" ] && [ -e "$POINTER_DEV" ]; then
        sendevent "$POINTER_DEV" 1 "$hw_code" 1 2>/dev/null
        sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
        sendevent "$POINTER_DEV" 1 "$hw_code" 0 2>/dev/null
        sendevent "$POINTER_DEV" 0 0 0 2>/dev/null
        printf "HW_KEY\n"
        exit 0
    fi

    # Universal fallback for any Android TV
    case "$key" in
        up) input keyevent 19 ;;
        down) input keyevent 20 ;;
        left) input keyevent 21 ;;
        right) input keyevent 22 ;;
        enter|ok) input keyevent 66 ;;
        back) input keyevent 4 ;;
        home) input keyevent 3 ;;
        volup) input keyevent 24 ;;
        voldn) input keyevent 25 ;;
        mute) input keyevent 164 ;;
        playpause) input keyevent 85 ;;
        *) input keyevent "$key" ;;
    esac
    printf "KEY\n"
    exit 0
fi

# Handle App Launching
if [ -n "$app" ]; then
    case "$app" in
        stremio) monkey -p com.stremio.one -c android.intent.category.LAUNCHER 1 2>/dev/null ;;
        vlc) monkey -p org.videolan.vlc -c android.intent.category.LAUNCHER 1 2>/dev/null ;;
        tvbro) monkey -p com.phlox.tvwebbrowser -c android.intent.category.LAUNCHER 1 2>/dev/null ;;
        youtube) am start -n com.google.android.youtube.tv/com.google.android.apps.youtube.tv.activity.ShellActivity 2>/dev/null || am start -a android.intent.action.VIEW "https://www.youtube.com" 2>/dev/null ;;
    esac
    printf "APP\n"
    exit 0
fi

# Handle Typing
if [ -n "$text" ]; then
    input text "$text"
    printf "TEXT\n"
    exit 0
fi

printf "OK\n"
