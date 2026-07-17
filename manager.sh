#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCK_FILE="${CONFIGS_MANAGER_LOCK:-$ROOT_DIR/manager.lock}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

info() {
	printf '[INFO] %s\n' "$*"
}

ok() {
	printf '[OK]   %s\n' "$*"
}

warn() {
	printf '[WARN] %s\n' "$*" >&2
}

bad() {
	printf '[BAD]  %s\n' "$*" >&2
}

usage() {
	cat <<EOF
Usage: ./manager.sh [sync|check|tmux|nvim|yazi|mpv|help]

Commands:
  sync    Restore/update all config runtime assets from manager.lock.
  check   Print current runtime asset status without changing anything.
  tmux    Bootstrap TPM and install tmux plugins.
  nvim    Run lazy.nvim sync in headless Neovim.
  yazi    Restore Yazi packages when the ya helper is available.
  mpv     Restore mpv git-backed runtime assets from manager.lock.
  help    Show this help.
EOF
}

require_lock() {
	if [[ ! -f "$LOCK_FILE" ]]; then
		bad "Lock file not found: $LOCK_FILE"
		return 1
	fi
}

expand_path() {
	local path="$1"

	path="${path//\$\{XDG_CONFIG_HOME:-\$HOME\/.config\}/$XDG_CONFIG_HOME}"
	path="${path//\$XDG_CONFIG_HOME/$XDG_CONFIG_HOME}"
	path="${path//\$XDG_DATA_HOME/$XDG_DATA_HOME}"
	path="${path//\$XDG_STATE_HOME/$XDG_STATE_HOME}"
	path="${path//\$HOME/$HOME}"
	printf '%s\n' "$path"
}

git_current_ref() {
	local dir="$1"

	git -C "$dir" rev-parse --short HEAD 2>/dev/null || true
}

sync_git_dir() {
	local name="$1"
	local repo="$2"
	local ref="$3"
	local target
	target="$(expand_path "$4")"
	local sparse_paths="${5:-}"

	if [[ -d "$target/.git" ]]; then
		info "$name: updating $target"
		local current_origin
		current_origin="$(git -C "$target" remote get-url origin 2>/dev/null || true)"
		if [[ "$current_origin" != "$repo" ]]; then
			warn "$name: correcting origin $current_origin -> $repo"
			git -C "$target" remote set-url origin "$repo"
		fi
		git -C "$target" fetch --prune origin
	elif [[ -e "$target" ]]; then
		local backup
		backup="$target.bak.$(date +%Y%m%d%H%M%S)"
		warn "$name: target exists but is not a Git clone; moving it to $backup"
		mv -- "$target" "$backup"
		info "$name: cloning $repo -> $target"
		mkdir -p "$(dirname -- "$target")"
		if [[ -n "$sparse_paths" ]]; then
			git clone --filter=blob:none --no-checkout "$repo" "$target"
		else
			git clone "$repo" "$target"
		fi
	else
		info "$name: cloning $repo -> $target"
		mkdir -p "$(dirname -- "$target")"
		if [[ -n "$sparse_paths" ]]; then
			git clone --filter=blob:none --no-checkout "$repo" "$target"
		else
			git clone "$repo" "$target"
		fi
	fi

	if [[ -n "$sparse_paths" ]]; then
		local -a sparse_list
		IFS=',' read -r -a sparse_list <<< "$sparse_paths"
		local index
		for index in "${!sparse_list[@]}"; do
			[[ "${sparse_list[$index]}" == /* ]] || sparse_list[$index]="/${sparse_list[$index]}"
		done
		info "$name: limiting checkout to $sparse_paths"
		git -C "$target" sparse-checkout set --no-cone "${sparse_list[@]}"
	fi

	info "$name: checking out $ref"
	git -C "$target" checkout --quiet "$ref"

	if git -C "$target" symbolic-ref -q HEAD >/dev/null; then
		git -C "$target" pull --ff-only
	fi

	ok "$name: at $(git_current_ref "$target")"
}

check_git_dir() {
	local name="$1"
	local repo="$2"
	local ref="$3"
	local target
	target="$(expand_path "$4")"

	if [[ -e "$target" && ! -d "$target/.git" ]]; then
		warn "$name: target exists but is not a Git clone: $target"
		return 1
	fi

	if [[ ! -d "$target/.git" ]]; then
		warn "$name: missing Git clone at $target"
		return 1
	fi

	local origin current desired
	origin="$(git -C "$target" remote get-url origin 2>/dev/null || true)"
	current="$(git -C "$target" rev-parse HEAD 2>/dev/null || true)"
	desired="$(git -C "$target" rev-parse "$ref^{commit}" 2>/dev/null || true)"

	if [[ "$origin" != "$repo" ]]; then
		warn "$name: origin mismatch: $origin"
		return 1
	fi

	if [[ -z "$desired" || "$current" != "$desired" ]]; then
		warn "$name: installed commit ${current:-unknown} does not match $ref"
		return 1
	fi

	if [[ -n "$(git -C "$target" status --porcelain --untracked-files=no)" ]]; then
		warn "$name: checkout has local modifications: $target"
		return 1
	fi

	ok "$name: installed at ${current:0:7}"
}

ensure_link() {
	local name="$1"
	local source
	local link_path
	source="$(expand_path "$2")"
	link_path="$(expand_path "$3")"

	if [[ ! -e "$source" ]]; then
		bad "$name: link source does not exist: $source"
		return 1
	fi

	if [[ -L "$link_path" ]]; then
		local current
		current="$(readlink "$link_path")"
		if [[ "$current" == "$source" ]]; then
			ok "$name: link already points to $source"
			return 0
		fi

		warn "$name: replacing stale link $link_path -> $current"
		rm -- "$link_path"
	elif [[ -e "$link_path" ]]; then
		bad "$name: link path exists and is not a symlink: $link_path"
		return 1
	fi

	mkdir -p "$(dirname -- "$link_path")"
	ln -s -- "$source" "$link_path"
	ok "$name: linked $link_path -> $source"
}

read_lock_entries() {
	require_lock

	while IFS='|' read -r type name repo ref target link_target; do
		[[ -z "${type:-}" || "$type" == \#* ]] && continue
		if [[ -z "${target:-}" ]]; then
			warn "Skipping malformed lock entry: $type|$name|$repo|$ref|$target|${link_target:-}"
			continue
		fi
		printf '%s\037%s\037%s\037%s\037%s\037%s\n' "$type" "$name" "$repo" "$ref" "$target" "${link_target:-}"
	done < "$LOCK_FILE"
}

sync_locked_assets() {
	local filter="${1:-}"

	while IFS=$'\037' read -r type name repo ref target link_target; do
		[[ -n "$filter" && "$name" != "$filter"* ]] && continue

		case "$type" in
			git-dir)
				sync_git_dir "$name" "$repo" "$ref" "$target" "$link_target"
				;;
			git-dir-link)
				sync_git_dir "$name" "$repo" "$ref" "$target"
				ensure_link "$name" "$target" "$link_target"
				;;
			path-link)
				ensure_link "$name" "$target" "$link_target"
				;;
			*)
				warn "$name: unsupported lock entry type: $type"
				;;
		esac
	done < <(read_lock_entries)
}

check_locked_assets() {
	local filter="${1:-}"
	local failed=0

	while IFS=$'\037' read -r type name repo ref target link_target; do
		[[ -n "$filter" && "$name" != "$filter"* ]] && continue

		case "$type" in
			git-dir)
				check_git_dir "$name" "$repo" "$ref" "$target" || failed=1
				;;
			git-dir-link)
				check_git_dir "$name" "$repo" "$ref" "$target" || failed=1
				if [[ -n "$link_target" && -L "$(expand_path "$link_target")" ]]; then
					ok "$name: runtime link exists"
				else
					warn "$name: runtime link missing: $(expand_path "$link_target")"
					failed=1
				fi
				;;
			path-link)
				local source link_path current
				source="$(expand_path "$target")"
				link_path="$(expand_path "$link_target")"
				current="$(readlink "$link_path" 2>/dev/null || true)"
				if [[ -e "$source" && "$current" == "$source" ]]; then
					ok "$name: runtime link exists"
				else
					warn "$name: runtime link missing or stale: $link_path"
					failed=1
				fi
				;;
			*)
				warn "$name: unsupported lock entry type: $type"
				failed=1
				;;
		esac
	done < <(read_lock_entries)

	return "$failed"
}

sync_tmux() {
	info "tmux: restoring TPM and plugins"
	sync_locked_assets "tmux:"

	local tpm_dir="$XDG_DATA_HOME/configs-manager/tmux/plugins/tpm"
	local resurrect_dir="$XDG_STATE_HOME/tmux/resurrect"
	local tmux_running=0

	mkdir -p "$resurrect_dir"

	if tmux list-sessions >/dev/null 2>&1; then
		tmux_running=1
		info "tmux: loading managed paths in running server"
		tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"
	fi

	if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
		"$tpm_dir/bin/install_plugins"
		ok "tmux: TPM plugins installed"
	else
		bad "tmux: TPM installer missing: $tpm_dir/bin/install_plugins"
		return 1
	fi

	if (( tmux_running )); then
		info "tmux: sourcing config in running server"
		tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.conf" || warn "tmux: source-file failed"
	fi
}

sync_nvim() {
	if ! command -v nvim >/dev/null 2>&1; then
		warn "nvim: command not found; install Neovim first"
		return 0
	fi

	info "nvim: running lazy.nvim sync"
	nvim --headless '+Lazy! sync' +qa
	ok "nvim: lazy.nvim sync complete"
}

find_ya() {
	local candidate

	if command -v ya >/dev/null 2>&1; then
		command -v ya
		return 0
	fi

	if command -v yazi >/dev/null 2>&1; then
		candidate="$(dirname -- "$(command -v yazi)")/ya"
		if [[ -x "$candidate" ]]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	fi

	if [[ -x /snap/yazi/current/ya ]]; then
		printf '%s\n' /snap/yazi/current/ya
		return 0
	fi

	return 1
}

sync_yazi() {
	local ya_cmd
	if ! ya_cmd="$(find_ya)"; then
		warn "yazi: ya helper not found; install Yazi package manager first"
		return 0
	fi

	local runtime_config="$XDG_DATA_HOME/configs-manager/yazi"
	local runtime_plugins="$runtime_config/plugins"
	local runtime_manifest="$runtime_config/package.toml"
	local config_plugins="$XDG_CONFIG_HOME/yazi/plugins"

	mkdir -p "$runtime_config"
	if ! cmp -s "$ROOT_DIR/yazi/package.toml" "$runtime_manifest"; then
		cp -- "$ROOT_DIR/yazi/package.toml" "$runtime_manifest"
		info "yazi: updated managed package manifest"
	fi

	info "yazi: restoring locked packages with $ya_cmd"
	YAZI_CONFIG_HOME="$runtime_config" "$ya_cmd" pkg install --discard
	ensure_link "yazi:plugins" "$runtime_plugins" "$config_plugins"
	ok "yazi: packages restored"
}

check_yazi() {
	local ya_cmd
	if ! ya_cmd="$(find_ya)"; then
		warn "yazi: ya helper not found"
		return 0
	fi

	ok "yazi: ya helper available at $ya_cmd"

	local runtime_config="$XDG_DATA_HOME/configs-manager/yazi"
	local runtime_manifest="$runtime_config/package.toml"
	local source="$runtime_config/plugins"
	local link_path="$XDG_CONFIG_HOME/yazi/plugins"
	local current

	if ! cmp -s "$ROOT_DIR/yazi/package.toml" "$runtime_manifest"; then
		warn "yazi: managed package manifest is missing or stale"
		return 1
	fi

	current="$(readlink "$link_path" 2>/dev/null || true)"
	if [[ -d "$source" && "$current" == "$source" ]]; then
		ok "yazi: managed plugin link exists"
	else
		warn "yazi: managed plugin link missing or stale: $link_path"
		return 1
	fi
}

sync_mpv() {
	info "mpv: restoring git-backed assets"
	sync_locked_assets "mpv:"
	ok "mpv: scripts and shaders restored"
}

check_all() {
	local failed=0

	check_locked_assets || failed=1

	if command -v nvim >/dev/null 2>&1; then
		ok "nvim: command available"
	else
		warn "nvim: command not found"
	fi

	check_yazi || failed=1

	return "$failed"
}

sync_all() {
	sync_tmux
	sync_nvim
	sync_yazi
	sync_mpv
}

main() {
	case "${1:-sync}" in
		sync)
			sync_all
			;;
		check)
			check_all
			;;
		tmux)
			sync_tmux
			;;
		nvim)
			sync_nvim
			;;
		yazi)
			sync_yazi
			;;
		mpv)
			sync_mpv
			;;
		help|-h|--help)
			usage
			;;
		*)
			bad "Unknown command: $1"
			usage
			exit 1
			;;
	esac
}

main "$@"
