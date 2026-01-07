# Some things to remember
# =======================

# Set alternative compiler
# sudo update-alternatives --config c++

# Install into certain folder
# make DESTDIR=/usr/bin install

# TODO: cleanup, remove things and/or move things to other files

#vi mode cli editing
set -o vi

alias senv='source env/bin/activate && if [ -f "requirements.txt" ]; then pip install -r requirements.txt; else touch requirements.txt; fi'
alias mkenv='python3 -m venv env && senv && pip install --upgrade pip'

# alias cls='clear && clear'
# got this here https://github.com/kovidgoyal/kitty/issues/268
alias cls="printf '\033[2J\033[3J\033[1;1H'"
alias cr='cls && rake'
alias perf_event_paranoid="sudo sh -c 'echo 1 >/proc/sys/kernel/perf_event_paranoid'"
alias sba='echo "source ~/.bash_aliases"; source ~/.bash_aliases'
alias gba='echo "gvim ~/.bash_aliases &"; gvim ~/.bash_aliases &'
alias garc='gvim ~/.config/awesome/rc.lua &'
alias r='echo "ranger"; ranger'
alias nv='nvim'
alias sshk='kitty +kitten ssh'

alias r='echo "ranger"; ranger'
#alias e='gvim --remote-tab-silent'
#g --graph --decorate --pretty=oneline --abbrev-commit()
alias gc='echo "git clone --recursive -j 24"; git clone --recursive -j 24'
alias gcaamend='echo "git commit -a --amend"; git commit -a --amend'
alias gcam='echo "git commit -am"; git commit -am'
alias gcamend='echo "git commit --amend"; git commit --amend'
alias gcav='echo "git commit -av"; git commit -av'
alias gcm='echo "git commit -m"; git commit -m'
alias gco='echo "git checkout"; git checkout'
alias gcv='echo "git commit -v"; git commit -v'
alias gd='echo "git diff"; git diff'
alias gdn='echo nvim -c ":G"; nvim -c ":G"'
alias gdt='echo "git difftool"; git difftool'
alias gdc='echo "git diff --cached"; git diff --cached'
alias gdf='echo "git diff --color | diff-so-fancy | less --tabs=4 -RFX"; git diff --color | diff-so-fancy | less --tabs=4 -RFX'
alias gdcf='echo "git diff --color --cached | diff-so-fancy | less --tabs=4 -RFX"; git diff --color --cached | diff-so-fancy | less --tabs=4 -RFX'
alias gdi='echo "git icdiff | less"; git icdiff | less'
alias gp='echo "git push"; git push'
alias gpr='echo "git pull --rebase"; git pull --rebase'
alias gpf='echo "git pull --ff-only"; git pull --ff-only'
alias gprp='echo "git pull --rebase && git push"; git pull --rebase && git push'
alias gl='echo "git lg"; git lg'
alias gll='echo "git lg2"; git lg2'
alias s='echo "git status -u -s"; git status -u -s'
alias sl='echo "git status -u"; git status -u'
alias si='echo "git status --ignore-submodules=untracked --untracked-files=no"; git status --ignore-submodules=untracked --untracked-files=no'
# alias ss='echo "git submodule foreach "git status || true""; git submodule foreach "git status || true"'
alias ss='echo "rake git:status"; rake git:status'
alias ssc='echo "rake git:status[changes]"; rake git:status[changes]'
alias ssu='echo "rake git:status[untracked]"; rake git:status[untracked]'
alias gss='echo "git submodule status"; git submodule status'
alias gssu='echo "git submodule summary"; git submodule summary'
alias gsam='echo "git submodule add -b master"; git submodule add -b master'
alias gsu='git submodule update --init --recursive --jobs 24'
alias gc.='echo "git checkout ."; git checkout .'
alias gs='echo "git stash"; git stash'
alias gsc='echo "git stash clear"; git stash clear'
alias gsl='echo "git stash list"; git stash list'
alias gsa='echo "git stash apply"; git stash apply'
alias gsp='echo "git stash pop"; git stash pop'

alias rqs='echo "rake qc:single"; rake qc:single'

alias fix_mic="amixer -c 2 set 'Input Source' 'Line' && amixer -c 2 set 'Input Source' 'Rear Mic'"

# from https://wiki.archlinux.org/title/Fzf#Pacman
alias yays="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"
alias yayr="yay -Qq | fzf --multi --preview 'yay -Qi {1}' | xargs -ro yay -Rns"


alias update_kitty="curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"

alias nvimr="nvim --listen ~/.cache/nvim/server.pipe"

# connect to bluetooth devices
# Device 98:AF:65:53:5B:BE EMILE-SURFACE7
# Device F0:F7:3F:1E:DA:9B MX Master
# Device F8:4E:17:E8:62:A1 WF-1000XM4
# Device 98:8E:79:00:9B:D7 Qudelix-5K
alias bt_q='echo "connect to Qudelix-5K (98:8E:79:00:9B:D7)"; bluetoothctl connect 98:8E:79:00:9B:D7'
alias bt_s='echo "connect to Sony WF-1000XM4 (F8:4E:17:E8:62:A1)"; bluetoothctl connect F8:4E:17:E8:62:A1'
alias bt_s5='echo "connect to Sony WH-1000XM5 (AC:80:0A:CB:55:C6)"; bluetoothctl connect AC:80:0A:CB:55:C6'
alias bt_m4='echo "connect to MOMENTUM 4 (80:C3:BA:81:45:23)"; bluetoothctl connect 80:C3:BA:81:45:23'
alias btd_m4='echo "disconnect to MOMENTUM 4 (80:C3:BA:81:45:23)"; bluetoothctl disconnect 80:C3:BA:81:45:23'

# remove branch locally and remotely
function grmb() {
    # https://stackoverflow.com/questions/2003505/how-do-i-delete-a-git-branch-locally-and-remotely

    # only works when no new commits on master exist (locally?)
    echo "git branch -d $@"
    git branch -d "$@"

    #assumes remote is named origin
    echo "git push -d origin $@"
    git push -d origin "$@"
}

alias ts='echo "tig status"; tig status'

alias uth='rake uth'
alias gsubp="echo 'git submodule foreach git push ||:'; git submodule foreach 'git push ||:'"
alias gsubup='git submodule --update --recursive --jobs 8'

alias ru='echo "rake ut"; rake ut'
alias rq='echo "rake qc:single;" rake qc:single'

# alias rcb='echo "rake cbs:build"; rake cbs:build'
# alias rcc='echo "rake cbs:clean"; rake cbs:clean'
# alias rcbt='echo "rake cbs:build[test-"; rake cbs:build[test-'
# alias rcut='echo "rake cbs:test[ut]"; rake cbs:test[ut]'
# alias rct='echo "rake cbs:test["; rake cbs:test['

alias ct='echo "ctags -R *"; ctags -R *'
alias ctc='echo "ctags --languages=C++ -f ctags_cpp -R *"; ctags --languages=C++ -f ctags_cpp -R *'
alias ctr='echo "ctags --languages=Ruby -f ctags_ruby -R *"; ctags --languages=Ruby -f ctags_ruby -R *'

if [ -x "$(command -v lsd)" ]; then
    alias l='echo "lsd -lFh"; lsd -lFh'
    alias ll='echo "lsd -AlFh"; lsd -AlFh'
    alias lt='echo "lsd -ltFh -> sort by date/time"; lsd -ltFh'
    alias ltr='echo "lsd -ltFh --tree -> sort by date/time"; lsd -ltFh --tree'
    alias lrd='echo "lsd -lFh --tree --depth <n>"; lsd -lFh --tree --depth'
else
    alias l='echo "ls -lFh"; ls -lFh'
    alias ll='echo "ls -AlFh"; ls -AlFh'
    alias la='echo "ls -A"; ls -A'
    alias lt='echo "ls -ltFh -> sort by date/time"; ls -ltFh'
fi

# alias ll='ls -all'

alias f='echo "find . -name"; find . -name'

#show gitk like overview
alias gt='echo "git log --graph --decorate --pretty=oneline --abbrev-commit --date=relative"; git log --graph --decorate --pretty=oneline --abbrev-commit --date=relative'
#alias gtt = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
#alias gttt = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"

# after changing settings, restart samba
alias samba_restart='echo "sudo systemctl restart smbd.service nmbd.service"; sudo systemctl restart smbd.service nmbd.service'
# arch manjaro
alias network_restart='echo "systemctl restart NetworkManager"; systemctl restart NetworkManager'

# list all available hdds to mount
alias hdd_list='echo "sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL"; sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL'

alias e='vim'
alias nv='nvim'

# alias isoviewer='~/Downloads/jre1.8.0_121/bin/java -jar ~/Downloads/isoviewer-1.11-SNAPSHOT.jar'

alias isoviewer='java -jar ~/bin/isoviewer-2.0.2-jfx.jar'

alias watch_cpu='echo "sudo watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq";sudo watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq'
alias sys_info='inxi -Fza --no-host'


alias mp4box='MP4Box'
alias mp4d='mp4dump --format json'

function imhexd() {
    # read env variable if it exists, otherwise use default
    if [ -z "${AURO_IMHEX_MP4}" ]; then
        AURO_IMHEX_MP4="/home/emile/repos/root-all/comp/cx/int-mp4/imhex/imhex_mp4_with_auro.hexpat"
    fi

    imhex --pl format --pattern "$AURO_IMHEX_MP4" "$@"
}

# zsh does this
# alias ..='cd ..'
# alias ...='cd ../..'

# start gvim quietly
function g() {
    nohup gvim "$@" > /dev/null 2>&1 & disown
}

#open in tab
function gt() {
    nohup gvim --remote-tab-silent "$@" > /dev/null 2>&1 & disown
}

if [ -f /home/emile/Downloads/cdargs-1.35/contrib/cdargs-bash.sh ]; then
    . /home/emile/Downloads/cdargs-1.35/contrib/cdargs-bash.sh
elif [ -f /usr/share/doc/cdargs/examples/cdargs-bash.sh ]; then
    . /usr/share/doc/cdargs/examples/cdargs-bash.sh
elif [ -f /usr/share/cdargs/cdargs-bash.sh ]; then
    . /usr/share/cdargs/cdargs-bash.sh
fi

# https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

alias c='cdb'

# export ANDROID_NDK=/opt/NDK/android-ndk-r14

[[ -f ~/.bash_auro_compiler ]] && source ~/.bash_auro_compiler

function useclang {
    export CC=clang
    export CXX=clang++
    auro_clang
}

function nouseclang {
    unset CC
    unset CXX
    auro_gcc
}

function ccmds {
    rm CMakeLists.txt
    rm compile_commands.json
    echo "noglob rake gen:cmake[$1]"
    noglob rake gen:cmake["$1"]
    echo "\ngenerating compile commands"
    rm -rf build_compile_commands
    mkdir build_compile_commands
    cd build_compile_commands
    cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    cp compile_commands.json ..
    cd ..
    rm -rf build_compile_commands
    # for rtags
    # rc -J
    echo "\nupdating ccls index:"
    ccls -index=.
}
alias ccmds='noglob ccmds'

# at least this is documentation on how to do this.
function reset_pci_network {
    echo "1" > /sys/bus/pci/devices/0000\:00\:19.0/reset
    ip link set eno1 down
    ip link set eno1 up
}

# function use_icecc {
#     PATH=/usr/lib/icecream/libexec/icecc/bin:$PATH
#     /usr/lib/icecream/sbin/iceccd -d &
# }

function use_ccache_icecc {
    # In this folder there are wrappers for gcc and clang that need to come
    # first in the path
    export PATH=/usr/lib/ccache/bin/:$PATH
    # Tell ccache to use icecc (gcc clang wrapper) in stead of gcc/clang
    export CCACHE_PREFIX=/usr/lib/icecream/bin/icecc
    export auro_j=50
}

function use_ccache {
    # In this folder there are wrappers for gcc and clang that need to come
    # first in the path
    # for linux/manjaro
    export PATH=/usr/lib/ccache/bin/:$PATH
    # for macosx homebrew
    export PATH=/usr/local/opt/ccache/libexec:$PATH
    unset CCACHE_PREFIX
}

use_ccache

function use_no_ccache {
    # TODO: remove /usr/lib/ccache/bin/ from $PATH if it is in it
    directories=(${(s/:/)PATH})

    # Initialize a new PATH variable without the ccache bin directory
    new_path=""

    # Loop through each directory in the PATH array
    for dir in $directories; do
        # echo "dir: $dir"
        # Check if the current directory is not the ccache bin directory
        if [[ "$dir" != "/usr/lib/ccache/bin/" ]]; then
            # If it's not, add it to the new PATH with a colon separator
            new_path+="$dir:"
            fi
        done

    # Remove the trailing colon from the new PATH
    new_path="${new_path::-1}"

    # Export the new PATH environment variable
    export PATH="$new_path"

    # Print a message indicating the change
    echo "Removed /usr/lib/ccache/bin/ from \$PATH"
    echo "PATH is now: $PATH"
}

alias connect_mouse='bluetoothctl power on && bluetoothctl connect F0:F7:3F:1E:DA:9B'
alias connect_hp='bluetoothctl power on && bluetoothctl connect F8:4E:17:E8:62:A1'

#.local/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh
# need to make powerline config
#powerline-daemon -q
#POWERLINE_BASH_CONTINUATION=1
#POWERLINE_BASH_SELECT=1
#/home/emile/.local/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh

function teensy_gaming {
    cp ~/.teensy_gaming ~/.teensy
    call "/home/emile/Teensy loader/teensy"
    /home/emile/"Teensy loader"/teensy&
}

alias tg='teensy_gaming'

function teensy_typing {
    cp ~/.teensy_typing ~/.teensy
    /home/emile/"Teensy loader"/teensy&
}

alias tt='teensy_typing'


alias logout=awesome-client 'awesome.quit()'

