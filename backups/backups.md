# Information about backups

## vs code

- Settings

  - Autosave on delay
  - Terminal font `MesloLGS NF`

    ```bash
    # Install MesloLGS NF fonts (one line):
    sudo wget -P /usr/local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    # Probably you need to update the cache
    fc-cache -fv
    ```

    The problem is vs code doesn't see default `/usr/share/fonts` but `/usr/share/local/fonts`

  - HTTP proxy adress that isn't shared

- Extensions
  View with `code --list-extensions`
  - Code Runner
  - SQL Tools
  - SVG preview
  - vscode-pdf
  - markdownlint
  - ...
- Hotkeys
  | Action | Hotkey |
  |---------------------------------|------------|
  | Toggle line wrap | Alt+Z |
  | Toggle left panel | Ctrl+B |
  | Toggle terminal | Ctrl+J |
  | Toggle terminal maximize | Ctrl+' |
  | Toggle minimap | Ctrl+M |
  | Focus code | Ctrl+Shift+W E |
  | Focus terminal | Ctrl+Shift+W T |
  | Focus file explorer / File Manager | Ctrl+Shift+W F |
  | Focus copilot (side panel) | Ctrl+Shift+W C |

## uBlock

There are some static rules I commonly use to keep the concentration

> [+] means add a link to "I am an advanced user"/userResourcesLocation

- Blocking YT shorts, homepage, recommendations and other bloat
- Blocking VK feed ([+](https://github.com/sorrtory/scripts?tab=readme-ov-file#ublockjs))
- Twitch adverts ([+](https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/master/video-swap-new/video-swap-new-ublock-origin.js))

Thanks to

- this [dude](https://github.com/gijsdev/ublock-hide-yt-shorts)
- this [reddit post](https://www.reddit.com/r/uBlockOrigin/wiki/solutions/youtube/)
- this [blog](https://stiobhart.net/2022-12-01-ublockoriginsync/)
- this [video](https://www.youtube.com/live/UL6QnhhV-Jk?si=w0AYGtWWJLNB9Nb6)
