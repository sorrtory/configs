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
ZSH_THEME="powerlevel10k/powerlevel10k"

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
plugins=(git copypath copyfile command-not-found zsh-autosuggestions zsh-syntax-highlighting)

# Nvm autocompletion plugin, because zsh-nvm plugin isn't working
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


##### Aliases #####

# Editors
alias bat="batcat"
alias p!="PAGER=less"

# Media

## ffmpeg
convert-to-mp3() {
    for f in "$@"; do
        ffmpeg -i "$f" -vn -acodec libmp3lame -qscale:a 0 -ar 48000 "${f%.*}.mp3"
    done
}

## yt-dlp
alias download-mp3="yt-dlp --proxy http://127.0.0.1:3128 -x --audio-format mp3 --audio-quality 0"
alias download-mp4="yt-dlp --proxy http://127.0.0.1:3128 -S res,ext:mp4:m4a --recode mp4"

# Download best available, then convert to WebM (VP9+Opus)
download_webm() {
  local url="$1"; shift || true
  local proxy="http://127.0.0.1:3128"

  # Capture ONLY the final filepath (one line)
  local in
  in="$(yt-dlp \
    --proxy "$proxy" \
    --no-playlist \
    -f "bv*+ba/b" \
    --merge-output-format mkv \
    -o "%(title).200s [%(id)s].%(ext)s" \
    --print after_move:filepath \
    "$url" "$@" \
    | tail -n 1
  )" || return 1

  if [ -z "$in" ] || [ ! -f "$in" ]; then
    echo "Could not determine downloaded file path."
    return 1
  fi

  local out="${in%.*}.webm"

  ffmpeg -y -i "$in" \
    -map 0 \
    -c:v libvpx-vp9 -crf 32 -b:v 0 -row-mt 1 \
    -c:a libopus -b:a 128k \
    "$out" || return 1

  echo "Wrote: $out"
}
alias download-webm='download_webm'

download_webm_stream_best() {
  local url="$1"; shift || true
  local proxy="http://127.0.0.1:3128"

  local base out tmp vpipe apipe vpid apid rc
  base="$(yt-dlp --proxy "$proxy" --skip-download --print "%(title).120s [%(id)s]" "$url" | head -n 1)"
  out="${base}.webm"

  tmp="$(mktemp -d)"
  vpipe="$tmp/video.pipe"
  apipe="$tmp/audio.pipe"
  mkfifo "$vpipe" "$apipe"

  cleanup() { rm -rf "$tmp"; }
  trap cleanup EXIT

  # Pump video+audio into pipes
  yt-dlp --proxy "$proxy" --no-playlist -f "bv*" -o - "$url" "$@" >"$vpipe" & vpid=$!
  yt-dlp --proxy "$proxy" --no-playlist -f "ba"  -o - "$url" "$@" >"$apipe" & apid=$!

  # Encode
  ffmpeg -y \
    -i "$vpipe" -i "$apipe" \
    -map 0:v:0 -map 1:a:0 \
    -c:v libvpx-vp9 -crf 32 -b:v 0 -row-mt 1 \
    -c:a libopus -b:a 128k \
    "$out"
  rc=$?

  # Stop downloaders if ffmpeg exits early
  kill "$vpid" "$apid" 2>/dev/null
  wait "$vpid" "$apid" 2>/dev/null

  [ $rc -eq 0 ] && echo "Wrote: $out"
  return $rc
}
alias download-webm-stream='download_webm_stream_best'


# vpn
alias vpn-up="sudo wg-quick up desktop-ubuntu"
alias vpn-down="sudo wg-quick down desktop-ubuntu"

##### Load #####
source $ZSH/oh-my-zsh.sh
export PATH="$HOME/go/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2026-01-06 10:48:50
export PATH="$PATH:/home/chinalap/.local/bin"

[ -f "/home/chinalap/.ghcup/env" ] && . "/home/chinalap/.ghcup/env" # ghcup-env
