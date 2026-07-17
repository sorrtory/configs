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
> - GNU stow is ok, but i need more
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

1. Edit a `install.conf`
2. Install programs (I need to automate reboots too somehow)

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

### External assets

The tracked config files are linked into place by
[`scripts/install.sh`](https://github.com/sorrtory/scripts/blob/master/install.sh).
The scripts repo clones this configs repo when it is missing. After linking, it
runs [`manager.sh`](./manager.sh) to restore mutable third-party runtime assets
such as TPM.

Keep these assets out of the configs repository when the upstream tool already
manages installation and updates. This keeps fresh setup reproducible without
committing downloaded files or pinning them as Git submodules.

Run the manager directly when needed:

```bash
~/Documents/configs/manager.sh sync
```

`manager.lock` pins external runtime repositories by commit. `manager.sh sync`
restores those pinned versions; updating the lock should be a deliberate step.

For a small local change, edit the managed checkout under
`~/.local/share/configs-manager`, save it as a patch in this repository, and
reapply it after syncing:

```bash
mkdir -p ~/Documents/configs/patches/mpv-cut
git -C ~/.local/share/configs-manager/mpv/mpv-cut diff > \
  ~/Documents/configs/patches/mpv-cut/local.patch
git -C ~/.local/share/configs-manager/mpv/mpv-cut restore .
~/Documents/configs/manager.sh mpv
git -C ~/.local/share/configs-manager/mpv/mpv-cut apply \
  ~/Documents/configs/patches/mpv-cut/local.patch
```

Patch application is intentionally manual for now. Before changing a pinned
commit, first preserve the diff as above. Then restore the managed checkout,
update `manager.lock`, sync, and reapply the patch. `manager.sh check` reports a
patched checkout as locally modified; that warning is expected until patch
application becomes a lock-managed operation. Use a fork when the change grows
into a maintained branch rather than a small local adjustment.

## Dotfiles list

### vimrc

- Set some default behaviour options
- Add `Tab` completion
- Add closing brackets/quotes by presing just an opening one
- Move lines up/down by `ctrl+shift+up / ctrl+shift+down`
- Add beautiful statusline
- Toggle numbers by `F3`
- Add ctrl+/ comments (file type : comment symbols)

#### Cheatsheat

https://vim.rtorr.com/

> TODO: refactor into table

- use c indtead of d + i
- ciB / yiB = remove / copy everything inside curvy brackets
- ciw = remove word
- ct. = remove everything up to dot
- use vimdiff:

  ```
  ]c   next diff
  [c   previous diff
  do   get other version into current window
  dp   put current version into other window
  :diffget LOCAL   keep local/current branch version
  :diffget REMOTE  take incoming branch version
  :diffget BASE    take base version
  ```

### nvim

- Nice [article](https://lazyvim-ambitious-devs.phillips.codes/) about LazyVim and vim basics

- lazy.nvim

General editing:

```
Ctrl+Shift+Up    move current line / selection up
Ctrl+Shift+Down  move current line / selection down
```

#### Installation steps

```
Step 1: lazy.nvim + theme ([onedark:darker](https://github.com/navarasu/onedark.nvim))
Step 2: add telescope
Step 3: add treesitter
Step 4: add LSP
Step 5: then add Mason
```

- telescope

```
Ctrl+p      find files
Ctrl+f      search inside current file

Space fg    search whole project
Space fb    buffers
Space fr    recent files
Space fc    commands
```

- treesitter is kinda broken + slow (really? can't see that). But we configure it to support all major langs
- [TODO comments](https://github.com/folke/todo-comments.nvim)

```
Space ft   search TODOs with Telescope
Space tq   put TODOs into quickfix
```

- oil

```
-          open parent directory
Space e    open Oil

-- inside oil
Enter      open file/directory
-          go up by dir
q          close Oil
:w         apply filesystem edits
```

- neotree

```
Ctrl+b     toggle Neo-tree sidebar
```

- vim-tmux-navigator

in accord with `tmux` config

```
Ctrl+h  left
Ctrl+j  down
Ctrl+k  up
Ctrl+l  right
```

- gitsigns

```
h          previous change

Space hp    preview hunk
Space hs    stage hunk
Space hu    undo stage hunk
Space hr    reset hunk

Space hS    stage whole buffer
Space hR    reset whole buffer
Space hb    blame current line
Space hd    diff current file
```

- lualine

- LSP
  - mason
  - mason-lspconfig
  - nvim-lspconfig

```
K           hover
gd          definition
gD          declaration
gi          implementation
gr          references
gt          type definition

Space rn    rename
Space ca    code action
Space ls    signature help
Space lo    organize imports for TS/JS
Space li    toggle inlay hints

[d          previous diagnostic
]d          next diagnostic
Space ld    show full line diagnostics in a floating window
Ctrl+w d    show diagnostic under cursor in a floating window (built into Neovim)
Space lq    diagnostics list
```

- conform - formatter

```
Space lf    format buffer
```

- blink - complitions

```
Tab         accept completion / snippet next / normal tab
Shift+Tab   snippet previous / normal shift-tab
Enter       insert newline
Ctrl+Space  manually open completion
Ctrl+e      close completion
```

- markview - Markdown preview

```
Space mt    toggle preview for current buffer
Space ms    toggle split view
Space mh    toggle hybrid mode for current buffer
```

- lint - nvim-lint

```
Space ll    lint current file
```

### tmux

- [tpm](https://github.com/tmux-plugins/tpm) - tmux plugin manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - conservative defaults
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) - save and restore sessions
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) - periodic saves
- [tmuxinator](https://github.com/tmuxinator/tmuxinator) - deterministic project sessions

TPM and its plugins are pinned in `manager.lock` and installed under
`~/.local/share/configs-manager/tmux/plugins/`.
Continuum automatically saves the tmux environment every 15 minutes.
Resurrect stores machine-specific snapshots under
`~/.local/state/tmux/resurrect/`, outside the configs repository.
Automatic restore on tmux server startup is disabled. Use `t` to intentionally
restore the last global snapshot, or `tp` to open a project session through
tmuxinator.

Tmuxinator project configs live under `~/.config/tmuxinator/`, linked from this
repo's `tmuxinator/` directory. `tp` discovers those configs directly, so there
is no separate project registry to keep in sync.

On a fresh system there is no snapshot to restore yet. Start tmux and press
`Ctrl+a Ctrl+s` once to create the initial `last` snapshot. Until then,
`t` starts a plain `main` session.

Resurrect restores sessions, windows, panes, layouts, working directories, and
a conservative set of running programs. Optional pane-content restoration is
not enabled.

```
t              attach to tmux, or restore the last global snapshot if no server exists
tp             pick a tmuxinator project with fzf
tp configs     open/switch to the configs project session
Ctrl+a I      install plugins
Ctrl+a U      update plugins
Ctrl+a Alt+u  remove plugins no longer listed in tmux.conf
Ctrl+a r      reload tmux config
Ctrl+a Ctrl+s save tmux environment now
Ctrl+a Ctrl+r restore tmux environment now
Ctrl+a Ctrl+d save tmux environment now, then detach
```

### zshrc

#### 1

- Oh my zsh
- powerlevel10k
- `plugins=(git command-not-found zsh-autosuggestions zsh-syntax-highlighting)`
- Aliases
- Meslo NG (See vs code font [problem](./backups/backups.md#vs-code))

##### Aliases

```
c      # cd fuzzy
cc     # cd fuzzy from current dir

e      # edit with default editor
ee     # edit from current dir

ec     # edit with VS Code
es     # edit with Sublime
ev     # edit with nvim
evim   # edit with vim

o      # open any file
oi     # open image
ov     # open video
om     # open music
```

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
  - [mpv cut](https://github.com/familyfriendlymikey/mpv-cut). Just cut video by `c` key
- **shaders**
  - [anime4k](https://github.com/bloc97/Anime4K). `ctrl+1` to optimize 1080p autoscaling, `ctrl+0` to disable
  - [ArtCNN](https://github.com/Artoriuz/ArtCNN). Not installed until an ArtCNN profile is configured.
- Script and shader repositories are pinned in `manager.lock`, cloned under `~/.local/share/configs-manager/mpv`, and selectively linked into the mpv config by `manager.sh mpv`.
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

  | Action                                                     | Hotkey                           |
  | ---------------------------------------------------------- | -------------------------------- |
  | Add cursor above                                           | Alt + ↑                          |
  | Add cursor below                                           | Alt + ↓                          |
  | Files: Reveal current file in navigation                   | Alt + F                          |
  | Git: Commit-and-sync                                       | Ctrl + Shift + S                 |
  | Git: Commit-and-sync and then close Obsidian               | Ctrl + Escape                    |
  | Move line up                                               | Ctrl + Shift + ↑                 |
  | Move line down                                             | Ctrl + Shift + ↓                 |
  | Show in system explorer                                    | Ctrl + Alt + R                   |
  | Table: Add row after                                       | Ctrl + R                         |
  | Table: Delete row                                          | Ctrl + Shift + R                 |
  | Templater: Insert Assets/Templates/Dictionary. New word.md | Alt + W                          |
  | Toggle Live Preview/Source mode                            | Ctrl + Shift + E                 |
  | Toggle right sidebar                                       | Ctrl + '                         |
  | Paste `Assets/Thought` template                            | Alt + T                          |
  | Navigate back                                              | Alt + <-                         |
  | Navigate forward                                           | Alt + ->                         |
  | Quick switcher: Open                                       | Ctrl + Tab                       |
  | Go to next tab                                             | Ctrl + PgUp                      |
  | Go to previous tab                                         | Ctrl + Shift + Tab / Ctrl + PgDn |

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

### yazi

[Plugins](https://yazi-rs.github.io/docs/resources):

- `Alt + y` = [copy file contents](https://yazi-rs.github.io/docs/resources/#:~:text=copy%2Dfile%2Dcontents%2Eyazi%20%2D%20A%20simple%20plugin%20to%20copy%20file%20contents%20just%20from%20Yazi%20without%20going%20into%20editor)

Plugins are locked in `yazi/package.toml`. `manager.sh yazi` locates the `ya`
helper, including Snap installations, restores the locked packages under
`~/.local/share/configs-manager/yazi/`, and links them into the Yazi config.

```bash
~/Documents/configs/manager.sh yazi
```

[## MFW never used then ![Tight and blue](https://i.pinimg.com/736x/31/af/4a/31af4aa48effe217c831fcbc24d4d51e.jpg)]: #
