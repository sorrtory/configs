# Configs

This is the storage of configs, that I always use.

My dotfiles are splitted into 3 repos:

- secrets(private)
- [configs](https://github.com/sorrtory/configs)
- [scripts](https://github.com/sorrtory/scripts)

## Installation

### Dotfile managers I hate

> - [dotbot](https://github.com/anishathalye/dotbot) is useless imho
> - [chezmoi](https://github.com/twpayne/chezmoi) is better but still not that
> - Ansible is probably better than the current workflow, but it's actually kind of all the same
> - My [install.sh](https://github.com/sorrtory/scripts?tab=readme-ov-file#installsh) with a [link.sh](https://github.com/sorrtory/scripts?tab=readme-ov-file#linksh--bootstrap)

### Step by step

Here is also a brand new Ubuntu bootstraping flow

0. Clone configs, scripts and especially secrets, that keeps ssh key for github, etc. For example, use [scripts/sharekey.sh](https://github.com/sorrtory/scripts?tab=readme-ov-file#sharekeysh) and [scripts/get_secrets.sh](https://github.com/sorrtory/scripts?tab=readme-ov-file#get_secretssh) to share github secrets repo PAT to new machine.

   There is also a script that automates that (You're only need to sharekey.sh before)
   ```bash
   # On old computer
   cd ~/Documents/scripts && ./sharekey.sh --secret ../secrets/secrets.token create 
   ```

   ```bash
   # On fresh computer
   bash -c "$(wget -qO- https://raw.githubusercontent.com/sorrtory/scripts/refs/heads/master/bootstrap.sh)"
   ```

0. Edit a `install.conf`
1. Install programs (I need to automate reboots too somehow)

```bash
./install.sh all
reboot
```

3. Setup system

```bash
./install.sh setup
reboot
```

As the result, the script with the default installation config should download software, link configs, setup gnome, wireguard and then some.

## Dotfiles list

### vimrc

- Set some default behaviour options
- Add `Tab` completion
- Add closing brackets/quotes by presing just an opening one
- Move lines up/down by `ctrl+shift+up / ctrl+shift+down`
- Add beautiful statusline
- Toggle numbers by `F3`
- Add ctrl+/ comments (file type : comment symbols)

### zshrc

#### 1

- Oh my zsh
- powerlevel10k
- `plugins=(git command-not-found zsh-autosuggestions zsh-syntax-highlighting)`
- Aliases
- Meslo NG (See vs code font [problem](./backups/backups.md#vs-code))

#### 2

Arch-designed. Pretty the same, but have no powerkevek10k

#### Useful links

- [Plugins](https://timjames.dev/blog/overhaul-your-terminal-with-zsh-plugins-more-3oag)
- [Fish](https://i.pinimg.com/736x/cf/a3/e3/cfa3e38571b79a9f6b424dfc22e3f07c.jpg)

### mpv

- **scripts**
  - [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua). Load the playlist
  - [fuzzydir](https://github.com/sibwaf/mpv-scripts/blob/master/fuzzydir.lua). Find audio next to the video file
  - [reload](https://github.com/sibwaf/mpv-scripts/blob/master/reload.lua). `shift+r` to reload (useful for YT videos) (better [alternative](https://github.com/4e6/mpv-reload))
  - [show_filename](https://github.com/yuukidach/mpv-scripts?tab=readme-ov-file#show_filenamelua). `shift+enter` to show the filename
  - [thumbfast](https://github.com/po5/thumbfast). Display previews of the video moment ([alternatime](https://github.com/TheAMM/mpv_thumbnail_script))
  - [osc](https://github.com/po5/thumbfast/blob/vanilla-osc/player/lua/osc.lua). thumbfast depandance (default mpv osc with thumbfast support)
  - [SmartCopyPaste](https://github.com/Eisa01/mpv-scripts?tab=readme-ov-file#smartcopypaste). Paste URI to mpv
- **shaders**
  - [anime4k](https://github.com/bloc97/Anime4K). `ctrl+1` to optimized 1080p autoscale, `ctrl+0` to disalbe
  - [ArtCNN](https://github.com/Artoriuz/ArtCNN). ???
- **mpv.conf** setup for high quality
- **input.conf** setup for shaders and list of input default

### obsidian

- Plugins
  - Calendar
  - Charts
  - Dataview
  - Git
  - Templater
  - Excalidraw
- Hotkeys

  | Action                                                     | Hotkey           |
  | ---------------------------------------------------------- | ---------------- |
  | Add cursor above                                           | Alt + ↑          |
  | Add cursor below                                           | Alt + ↓          |
  | Files: Reveal current file in navigation                   | Alt + F          |
  | Git: Commit-and-sync                                       | Ctrl + Shift + S |
  | Git: Commit-and-sync and then close Obsidian               | Ctrl + Escape    |
  | Move line up                                               | Ctrl + Shift + ↑ |
  | Move line down                                             | Ctrl + Shift + ↓ |
  | Show in system explorer                                    | Ctrl + Alt + R   |
  | Table: Add row after                                       | Ctrl + R         |
  | Table: Delete row                                          | Ctrl + Shift + R |
  | Templater: Insert Assets/Templates/Dictionary. New word.md | Alt + W          |
  | Toggle Live Preview/Source mode                            | Ctrl + Shift + E |
  | Toggle right sidebar                                       | Ctrl + '         |

### backups

This is the folder with autosynced configs

- VS code
- ublock

## Arch

Actually this can be used on any distro, but no one will

### Hypr

- `hyprland.conf` has everything
- `hypridle.conf + hyprlidle.conf` power the hypr_lockscreen.sh
- `hyprpaper.conf` sets the wallpaper path

#### Hyprland scripts

They have a little doc inside

- `app-togle.sh` helps to open only one instance of app
- `floating-alone-watcher.sh` allows to modify single window size
- [BROKEN] `hypr_lockscreen.sh` is planned to play screensaver

### Dunst

[Fist](https://github.com/ericmurphyxyz/dotfiles) color scheme that I googled upon. Can I add dynamic clicks for this notifications?

### Kitty

Piece of shit ^^

Despite yazi, bad good TERM=xterm-kitty sucks.

Vim on crutches, ssh needs a plugin[!](https://sw.kovidgoyal.net/kitty/faq/)

Use alacritty (xterm-256color)

Hotkeys

- Ctrl+Shift+F = fzf search

### Wofi

Lean and blue

## MFW never used then

![Tight and blue](https://i.pinimg.com/736x/31/af/4a/31af4aa48effe217c831fcbc24d4d51e.jpg)
