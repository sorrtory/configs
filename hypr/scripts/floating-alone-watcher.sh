#!/usr/bin/env bash
set -euo pipefail

command -v jq >/dev/null || { echo "Install jq"; exit 1; }
command -v socat >/dev/null || { echo "Install socat"; exit 1; }

# Apps to manage
APPS=("kitty" "org.gnome.nautilus")
SIZES=("1000x600" "1200x800")

last_state=""

get_state() {
  wsid=$(hyprctl activeworkspace -j | jq -r '.id // empty')
  [ -z "$wsid" ] && return

  clients_json=$(hyprctl clients -j)

  # Count ALL windows in workspace
  win_count=$(echo "$clients_json" | jq --arg ws "$wsid" \
    '[.[] | select(.workspace.id == ($ws|tonumber))] | length')

  # Count matches for each app
  matches=()
  for app in "${APPS[@]}"; do
    count=$(echo "$clients_json" | jq --arg ws "$wsid" --arg app "$app" \
      '[.[] | select(.workspace.id == ($ws|tonumber) and (.class|ascii_downcase == ($app|ascii_downcase)))] | length')
    matches+=("$count")
  done

  echo "$wsid:$win_count:$(IFS=,; echo "${matches[*]}")"
}

apply_state() {
  wsid=$1
  win_count=$2
  shift 2
  app_counts=(${1//,/ })
#  echo $wsid $win_count $app_counts

  clients_json=$(hyprctl clients -j)

  for idx in "${!APPS[@]}"; do
    app="${APPS[$idx]}"
    size="${SIZES[$idx]}"
    width="${size%x*}"
    height="${size#*x}"

    if [ "${app_counts[$idx]}" -gt 0 ] && [ "$win_count" -eq 1 ]; then
      # Float, resize, center
      echo "$clients_json" | jq -r --arg ws "$wsid" --arg app "$app" \
        '.[] | select(.workspace.id == ($ws|tonumber) and (.class|ascii_downcase == ($app|ascii_downcase))) | .address' |
      while read -r addr; do
        hyprctl dispatch focuswindow address:$addr
        hyprctl dispatch setfloating active
        hyprctl dispatch resizeactive exact $width $height
        hyprctl dispatch centerwindow
      done
  else
    # Tile each matching window (robust: skip empty addrs, re-check existence)
    echo "$clients_json" | jq -r --arg ws "$wsid" --arg app "$app" \
      '.[] | select(.workspace.id == ($ws|tonumber) and (.class|ascii_downcase == ($app|ascii_downcase))) | .address' |
    while IFS= read -r addr; do
      # skip blank lines
      [ -z "$addr" ] && continue
  
      # verify the address still exists (avoid "Window not found")
      if hyprctl clients -j | jq -e --arg a "$addr" '.[] | select(.address == $a)' >/dev/null 2>&1; then
        hyprctl dispatch settiled address:$addr 2>/dev/null || true
      else
        # optionally debug: echo "addr $addr disappeared, skipping"
        :
      fi
  done
fi
  done
}

handle_event() {
  state=$(get_state)
  if [ "$state" != "$last_state" ] && [ -n "$state" ]; then
    last_state="$state"
    IFS=":" read -r wsid win_count app_counts <<<"$state"
    apply_state "$wsid" "$win_count" "$app_counts"
  fi
}

# Initial run
handle_event

# Listen for events
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
  | while read -r event; do
      case "$event" in
        openwindow*|closewindow*|movewindow*|workspace*|workspacev2*|focusedmon*)
          handle_event
          ;;
      esac
    done

