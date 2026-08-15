# dotfiles

Chezmoi-managed configuration shared by `home` and `work` machines. Machine-specific credentials and runtime state are intentionally not stored here.

## Initialize a machine

Install `git`, [Git LFS](https://git-lfs.com/), and [chezmoi](https://www.chezmoi.io/), then enable LFS for the current user:

```sh
git lfs install
```

Initialize with the appropriate profile (replace `<repository-url>`):

```sh
# Home PC
chezmoi init --git-lfs <repository-url> --promptChoice "Choose this machine's profile=home"

# Work PC
chezmoi init --git-lfs <repository-url> --promptChoice "Choose this machine's profile=work"
```

Omit `--promptChoice` to select `home` or `work` interactively. The answer is written to the machine-local chezmoi config and controls displays, DPI, themes, and profile-specific exclusions. Do not select `work` on the home PC merely to preview it; render templates with override data instead.

Git LFS stores the wallpaper images. If an existing source checkout contains pointer files rather than images, run:

```sh
git -C "$(chezmoi source-path)" lfs pull
```

## Review and apply safely

Never apply an unreviewed full diff. Prefer a focused target path while unrelated local drift exists:

```sh
chezmoi diff ~/.config/kitty/kitty.conf
chezmoi apply --dry-run --verbose ~/.config/kitty/kitty.conf
chezmoi apply ~/.config/kitty/kitty.conf
```

For a full deployment, use the same sequence without the target path, read the entire diff and dry-run output, and only then run `chezmoi apply`. A dry run is a preview; it does not replace reviewing `chezmoi diff`.

## Refresh the Awesome widget external

`awesome-wm-widgets` is pinned to manual refresh (`refreshPeriod = "0"`) so ordinary applies do not unexpectedly pull upstream changes. Preview and explicitly refresh it with:

```sh
chezmoi --refresh-externals=always apply --dry-run --verbose ~/.config/awesome/awesome-wm-widgets
chezmoi --refresh-externals=always apply ~/.config/awesome/awesome-wm-widgets
```

Keep local widget changes in `~/.config/awesome/custom_widgets/`; do not edit the external checkout.

## Pi coding agent

Install Pi separately on each machine:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Chezmoi deploys the selected Pi settings and extensions under `~/.pi/agent/`. Start `pi` and run `/reload` after applying extension changes.

Authentication is deliberately local. Use `/login` (or a locally configured API-key environment variable) on each machine. Never add `~/.pi/agent/auth.json`, sessions, trust decisions, downloaded models, or package caches to this repository.

## Desktop requirements

The desktop configuration expects Awesome WM, Kitty, Picom, Rofi, XRandR/Xorg utilities, WirePlumber's `wpctl`, Zsh, Starship, Neovim, `nvr`, `less`, and Kvantum. Kitty expects JetBrains Mono SemiBold and SemiBold Italic; prompt icons need a Nerd Font or compatible Font Awesome fallback.

Workrave, NetworkManager and Blueman applets, EasyEffects, and xsettingsd are optional and are started only when installed. Hardware serial aliases additionally require `minicom`, `sudo` access, and the expected `/dev/ttyUSB*` device.
