function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# use adb logcat to log the output of the exoplayer demo app to a log file in cwd
function adb_exo_log_lnav() {
    package='androidx.media3.demo.main'
    test_name='androidx.media3.demo.main.log'

    app_pid=$(adb shell pidof -s "$package" | tr -d '\r')
    log_file="${test_name}_$(date +%Y-%m-%d_%H-%M-%S).log"

    if [ -z "$app_pid" ]; then
        echo "Open the app first, then run this again."
    else
        echo "Recording to $log_file — press Ctrl+C when finished."
        # adb logcat --pid="$app_pid" -T 1 -v threadtime -v color '*:V' |
        #     tee >(sed -u 's/\x1B\[[0-9;]*m//g' > "$log_file")
        adb logcat --pid="$app_pid" -T 1 -v threadtime '*:V' |
            tee "$log_file" |
            lnav
    fi
}

function adb_exo_log() {
    package='androidx.media3.demo.main'
    test_name='androidx.media3.demo.main.log'

    app_pid=$(adb shell pidof -s "$package" | tr -d '\r')
    log_file="${test_name}_$(date +%Y-%m-%d_%H-%M-%S).log"

    if [ -z "$app_pid" ]; then
        echo "Open the app first, then run this again."
    else
        echo "Recording to $log_file — press Ctrl+C when finished."
        adb logcat --pid="$app_pid" -T 1 -v threadtime -v color '*:V' |
            tee >(sed -u 's/\x1B\[[0-9;]*m//g' > "$log_file")
    #     adb logcat --pid="$app_pid" -T 1 -v threadtime '*:V' |
    #         tee "$log_file" |
    #         lnav
    fi
}

# copy the full path of a file to the clipboard
cppath() {
    if [[ -z "$1" ]]; then
        echo "Usage: cppath <filename>"
        return 1
    fi
    local filepath
    filepath=$(realpath "$1")
    
    if command -v wl-copy &> /dev/null; then
        echo -n "$filepath" | wl-copy >/dev/null 2>&1 &!
        echo "Copied (Wayland): $filepath"
    elif command -v xclip &> /dev/null; then
        echo -n "$filepath" | xclip -selection clipboard >/dev/null 2>&1 &!
        echo "Copied (X11): $filepath"
    else
        echo "Error: Neither xclip nor wl-copy is installed."
        return 1
    fi
}

cpfa() {
    local file
    file=$(fzf --walker=file) || return
    print -rn -- "${file:a}" | xclip -selection clipboard
}

cpf() {
    local selected
    # Use fzf to interactively select a file
    selected=$(fzf)
    
    # Exit gracefully if the user pressed Esc or cancelled
    if [[ -z "$selected" ]]; then
        return 0
    fi
    
    local filepath
    filepath=$(realpath "$selected")
    
    if command -v wl-copy &> /dev/null; then
        echo -n "$filepath" | wl-copy >/dev/null 2>&1 &!
        echo "Copied (Wayland): $filepath"
    elif command -v xclip &> /dev/null; then
        echo -n "$filepath" | xclip -selection clipboard >/dev/null 2>&1 &!
        echo "Copied (X11): $filepath"
    else
        echo "Error: Neither xclip nor wl-copy is installed."
        return 1
    fi
}
