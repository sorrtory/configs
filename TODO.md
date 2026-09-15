# TODO

## Config manager setup

Extend the idempotent config manager phase in `scripts/install.sh`.

The current bootstrap flow clones and links config repositories, but some
external runtime assets should be installed or refreshed after the configs are
linked. Update the scripts repo so config-specific manager tasks can be declared
cleanly instead of adding one-off commands throughout `install.sh`.

Consider refactoring `install.sh` with AI assistance before extending it. The
goal is to keep package installation, config linking, and after-clone setup as
separate phases.

## TPM and tmux plugins

- [x] Clone pinned [TPM](https://github.com/tmux-plugins/tpm) and plugin commits
  under `~/.local/share/configs-manager/tmux/plugins`.
- [x] Keep plugin clones and resurrect snapshots outside the configs repository.
- [x] After installing TPM, install plugins declared in `tmux.conf`.
- [x] Add a small baseline of tmux plugins for daily usage:
  - [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
  - [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
  - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
- Review this list before choosing the final baseline:
  [Useful tmux plugins which I frequently use at work](https://medium.com/@dev-in-trenches/useful-tmux-plugins-which-i-frequently-use-at-work-41a9b46f7bcb)

## mpv assets

- [x] Move the documented Lua scripts, mpv-cut, and Anime4K into pinned manager
  checkouts under `~/.local/share/configs-manager/mpv`.
- [x] Replace the broken mpv-cut gitlink and vendored files with ignored runtime
  links.
- Audit whether [ArtCNN](https://github.com/Artoriuz/ArtCNN) shaders should be
  installed as well.

## Yazi plugins

- [x] Restore locked Yazi packages from `yazi/package.toml` during manager
  setup, including Snap installations where `ya` is not on `PATH`.
- [x] Keep generated plugins under `~/.local/share/configs-manager/yazi` and
  link them into the Yazi config.
- Replace the Snap installation with a non-Snap Yazi installation:
  - Prefer the documented `cargo binstall yazi-fm` command or an official
    prebuilt release to avoid compiling on every new machine.
  - Fall back to `cargo install --force yazi-build` when building from source is
    desired.
  - Ensure the matching `yazi` and `ya` binaries are both on `PATH`, verify the
    external preview dependencies, then remove the Snap-specific manager
    fallback once migration is complete.

## Other plugin-managed tools

- Audit the repo for other externally maintained assets that should be restored
  after cloning rather than vendored.
- Keep Neovim plugins managed by `lazy.nvim`; `nvim/lazy-lock.json` already
  records their versions.
- Decide whether Obsidian community plugins belong in automated setup or remain
  an application-level restore step.

## Verification

Test the final bootstrap on a clean environment:

1. Clone configs, scripts, and secrets.
2. Run the existing link phase.
3. Run the new manager phase twice to verify idempotency.
4. Confirm TPM and tmux plugins are installed under
   `~/.local/share/configs-manager/tmux/plugins/`.
5. Confirm mpv shader bindings and scripts work.
6. Confirm Yazi plugins are restored and their keymaps work.
