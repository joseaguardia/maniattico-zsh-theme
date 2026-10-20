# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A custom Oh-My-ZSH theme called **maniattico**, forked from `agnoster`. It provides a two-line powerline-style prompt with network info, environment color coding, VPN detection, Docker stats, and Git status. Requires **Nerd Fonts** (JetBrainsMono recommended).

## Files

- `maniattico.zsh-theme` — main theme (full version with VPN, Docker, Distrobox, SSH detection)
- `maniattico_simple.zsh-theme` — simplified variant without VPN/Docker/screen checks
- `maniattico.zsh-theme.cfg` — user configuration, sourced at load time by the theme
- `install_zsh_fedora.sh` — interactive installation script for Fedora/RHEL systems

The two theme files are standalone copies, not a shared base: helpers like `prompt_segment`, `prompt_dir`, `prompt_git` and the environment color mapping are duplicated, so a fix in one usually needs porting to the other. Each file starts with a `#Version YYYYMMDD` line.

## Distribution

Users install by `wget`-ing the files straight from `master` on GitHub (`joseaguardia/maniattico-zsh-theme`), both in `install_zsh_fedora.sh` and in the one-liner at the top of it. That one-liner also installs a daily cron (02:00) that re-downloads `maniattico.zsh-theme` from `master`, so **anything pushed to `master` reaches installed machines automatically**. The `.cfg` is only downloaded once, so new config variables must have a safe fallback in the theme when absent.

Known gotcha: the installer writes the chosen environment with `sed "/^ENTORNO=/..."`, but the `.cfg` key is `ENVIRONMENT`, so that substitution is a no-op.

## Installation (manual)

Copy both files to `~/.oh-my-zsh/themes/` and set `ZSH_THEME="maniattico"` in `~/.zshrc`.

For Docker support, add this cron job:
```
* 7-23,0 * * * /usr/bin/docker info | grep 'Running:\|Stopped:' | tr '\n' ' ' | sed "s/ //g" | sed 's/Running:/ /' | sed 's/Stopped:/·/' > /tmp/docker.info
```

The README's instruction to set `SERVICIODOCKER` in `~/.zshrc` is outdated: neither theme reads that variable any more. Docker is now toggled by `DOCKER="y"` in the `.cfg`.

## Architecture

`build_prompt()` is the main orchestrator. It calls individual `prompt_*` functions in sequence, each appending a colored segment via `prompt_segment(bg_color, fg_color, content)`.

**Prompt build order** (left to right):
1. `prompt_status` — last command exit code, background jobs, detached screen sessions
2. `prompt_context` — Linux distro icon + hostname (adds cloud icon if SSH)
3. `environment` — shows `$EXTRA_INFO` if set, colored by `$ENVIRONMENT`
4. `local_ip` — first IP of default route interface (reads from `/tmp/ip.a` cache)
5. VPN checks: `openvpn_status`, `anyconnect_status`, `forticlient_status`, `wireguard_status` (each toggleable via `.cfg`)
6. `dockerCount` — reads `/tmp/docker.info` written by cron (toggleable via `.cfg`)
7. `prompt_dir` — current directory, truncated to last 45 chars if longer
8. `prompt_git` — branch, staged/unstaged/deleted counts, remote provider icon, clean check
9. `claude_status` — Claude icon (✻) if the current directory has a `CLAUDE.md`/`claude.md`

**Performance pattern**: `get_lan_info()` runs `ip a` once per prompt into `/tmp/ip.a`; all network functions read from this cache. Docker info is populated by cron, not on every prompt render. Exception: `wireguard_status` runs `sudo wg show` on every prompt (needs passwordless sudo).

**Load-time vs per-prompt**: distro icon detection (`/etc/os-release`), Distrobox detection (`$DISTROBOX_ENTER_PATH`) and environment color resolution run once when the theme is sourced. Inside Distrobox, VPN and screen checks are skipped. `PROMPT` is single-quoted so `$(build_prompt)` re-evaluates each render; the second line shows `$ICONO_PROMPT` (not defined by the theme).

**Side effects outside the prompt**: the theme also sets `EDITOR`/`VISUAL=vim`, `DISABLE_UPDATE_PROMPT`, a `^U` keybinding, a completion `zstyle`, and paste hooks (`pasteinit`/`pastefinish`).

**Ordering caveat**: `RETVAL=$?` must stay the very first statement in `build_prompt`; any call before it overwrites `$?` and the failed-command icon in `prompt_status` stops showing.

## Configuration (`maniattico.zsh-theme.cfg`)

| Variable | Values | Effect |
|---|---|---|
| `ENVIRONMENT` | `PRODUCCIÓN` `PREPRODUCCIÓN` `DESARROLLO` `INTERNO` `CUSTOM` | Changes prompt accent color |
| `CUSTOM_COLOUR` | 256-color index | Used when `ENVIRONMENT="CUSTOM"` |
| `EXTRA_INFO` | any string | Displayed after environment segment |
| `GRADIENT` | `1` (`▓▒░`), `wezterm` (``), anything else (`◣`) | Prompt end style (`prompt_end`) |
| `SEGMENT_SEPARATOR` | any glyph | Separator between distro icon and hostname |
| `LINUX_DISTRO` | glyph | Fallback icon; overwritten by autodetection |
| `DOCKER` `WIREGUARD` `OPENVPN` `FORTICLIENT` `ANYCONNECT` `SCREEN` | `y`/`n` | Enables/disables each feature check |

Environment color mapping: `PRODUCCIÓN`→red(001), `PREPRODUCCIÓN`→purple(091), `DESARROLLO`→yellow(220), `INTERNO`→green(042), `CUSTOM`→`$CUSTOM_COLOUR`, unset/other→orange(208). The environment values contain accented characters and must match exactly.

## Git segment color logic

| State | Color |
|---|---|
| Clean, on `main`/`master` | Bright green (190) |
| Clean, other branch | Muted green (048) |
| Dirty, on `main`/`master` | Bright pink (197), bold |
| Dirty, other branch | Muted pink (204), bold |
| Detached HEAD | Orange (202) |

Remote provider icons: GitHub (``), GitLab (`0`), Azure DevOps (` `).

## Testing changes

There is no test suite or linter. The theme sources its config from the hardcoded path `~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg`, so sourcing the repo copy still reads the *installed* `.cfg`, not the repo one. To test edits to both:
```zsh
cp maniattico.zsh-theme maniattico.zsh-theme.cfg ~/.oh-my-zsh/themes/ && source ~/.zshrc
```
For a quick syntax check without loading: `zsh -n maniattico.zsh-theme`.

Network/Docker segments depend on `/tmp/ip.a` (written each prompt) and `/tmp/docker.info` (written by cron); create or edit the latter by hand to test `dockerCount`.
