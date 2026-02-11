##### Zsh parameters #####

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="flazz"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

##### Plugins #####
# Add wisely, as too many plugins slow down shell startup.
plugins=(git copypath copyfile command-not-found zsh-autosuggestions zsh-syntax-highlighting zsh-lazyload)


##### Aliases #####

# Networking

## vpn
VPN_PROFILE="desktop-ubuntu"
alias vpn-up="sudo wg-quick up $VPN_PROFILE"
alias vpn-down="sudo wg-quick down $VPN_PROFILE"

## proxy
### remember about proxychains, torsocks for tcp proxying
PROXY="http://127.0.0.1:3128"
PROXY_SOCKS="socks5://127.0.0.1:1080"
### socks5h for dns resolution through proxy, but it doesn't work with all applications
alias proxy-on="export http_proxy=$PROXY; export https_proxy=$PROXY; export all_proxy=$PROXY_SOCKS"
alias proxy-off="unset http_proxy; unset https_proxy; unset all_proxy"

### lxd wifi interface
init_wifi_proxy(){
    INTEFACE=wlp1s0
    sudo iptables -t nat -A POSTROUTING -o $INTEFACE -j MASQUERADE
    sudo iptables -A FORWARD -i lxdbr0 -o $INTEFACE -j ACCEPT
    sudo iptables -A FORWARD -i $INTEFACE -o lxdbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
}
alias iwp=init_wifi_proxy

# Editors
alias bat="batcat"
alias p!="PAGER=less"

# Media

## ffmpeg
convert-to-mp3() {
    # Convert given media files to mp3
    for f in "$@"; do
        ffmpeg -i "$f" -vn -acodec libmp3lame -qscale:a 0 -ar 48000 "${f%.*}.mp3"
    done
}

## yt-dlp
alias download-mp3="yt-dlp --proxy $PROXY -x --audio-format mp3 --audio-quality 0"
alias download-mp4="yt-dlp --proxy $PROXY -S res,ext:mp4:m4a --recode mp4"




##### Load #####
# zsh
source $ZSH/oh-my-zsh.sh

# lazyload
## Nvm autocompletion plugin, because zsh-nvm plugin isn't working
lazyload nvm node npm npx -- '
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  autoload -U +X bashcompinit && bashcompinit
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
'

# powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


##### Env #####

## ptyxis/horizon theme support
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

## go bin
export PATH="$HOME/go/bin:$PATH"

# Created by `pipx` on 2026-01-06 10:48:50
export PATH="$PATH:$HOME/.local/bin"

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env" # cargo

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
