function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# use adb logcat to log the output of the exoplayer demo app to a log file in cwd
function adb_exo_log() {
    package='androidx.media3.demo.main'
    test_name='androidx.media3.demo.main.log'

    app_pid=$(adb shell pidof -s "$package" | tr -d '\r')
    log_file="${test_name}_$(date +%Y-%m-%d_%H-%M-%S).log"

    if [ -z "$app_pid" ]; then
        echo "Open the app first, then run this again."
    else
        echo "Recording to $log_file — press Ctrl+C when finished."
        adb logcat --pid="$app_pid" -T 1 -v threadtime '*:V' > "$log_file"
    fi
}
