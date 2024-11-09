# TODO: 
# * picom settings
# * startship nerdfont settings
# * git diff

task :default do
    sh('rake -AT')
end

namespace :install do
    task :zsh do
        pacman_install('zsh')

        # do this manually: when I run this from here, it goes into a new shell and the following commands are never
        # executed in that shell but only after the user exits it
        # run initial zsh installation to generate .zshrc
        # run_cmd('zsh')

        # run this to list shells
        # run_cmd('chsh', '-l')

        # # run this to change shell permanently
        # run_cmd('chsh', '-s', '/usr/bin/zsh')
    end

    # NOTE: get list of installed packages by user:
    # comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base-devel | sort | uniq)
    # https://unix.stackexchange.com/questions/409895/pacman-get-list-of-packages-installed-by-user
    #
    desc "packages to install that don't need anything special"
    task :pkgs do
        %w[
            base-devel

            atuin
            bluez
            bluez-utils
            cmake
            ctags
            firefox
            fzf
            git
            lsd
            npm
            picom
            pipewire
            pipewire-alsa
            pipewire-audio
            pwvucontrol
            python-pynvim
            ripgrep
            rofi
            starship
            tree
            tree-sitter-cli
            unzip
            xorg-xrandr
            xsel
            zoxide
        ].each do |package_name|
            pacman_install(package_name)
        end
    end

    # TODO: check installed already
    task :rustup do
        run_cmd('curl', '--proto', "'=https'", '--tlsv1.2', '-sSf', 'https://sh.rustup.rs', '|', 'sh')
    end

    # NOTE: depends on rustup
    task :bob_nvim do
        run_cmd('cargo', 'install', 'bob-nvim')
        run_cmd('bob use stable')
    end

    task :yay do
        # sudo pacman -S --needed git base-devel
        # git clone https://aur.archlinux.org/yay-bin.git
        # cd yay-bin
        # makepkg -si
        repos_dir = File.join(Dir.home, 'repos') 
        FileUtils.mkdir_p(repos_dir)
        Dir.chdir("#{Dir.home}/repos") do
            run_cmd('git clone https://aur.archlinux.org/yay-bin.git')
            Dir.chdir("#{Dir.home}/repos/yay-bin") do
                run_cmd('makepkg -si')
            end
        end
    end
end

def pacman(*args, sudo: false)
    cmd = sudo ? ['sudo'] : []
    cmd = cmd + ['pacman'] + args

    run_cmd(cmd)
end

def pacman_installed?(name)
    # `pacman -Qi #{name} > /dev/null`
    pacman("-Qi", name, '>', '/dev/null')
end

def pacman_install(name)
    unless pacman_installed?(name)
        pacman('-S', name, sudo: true)
    end
end

def run_cmd(*cmd)
    puts "Executing cmd: '#{cmd.join(' ')}'"
    system(cmd.join(' '))
    $?.success?
end
