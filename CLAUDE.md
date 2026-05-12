# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A custom Oh-My-ZSH theme called **maniattico**, forked from `agnoster`. It provides a two-line powerline-style prompt with network info, environment color coding, VPN detection, Docker stats, and Git status. Requires **Nerd Fonts** (JetBrainsMono recommended).

## Files

- `maniattico.zsh-theme` — main theme (full version with VPN, Docker, Distrobox, SSH detection)
- `maniattico_simple.zsh-theme` — simplified variant without VPN/Docker/screen checks
- `maniattico.zsh-theme.cfg` — user configuration, sourced at load time by the theme
- `install_zsh_fedora.sh` — interactive installation script for Fedora/RHEL systems

## Installation (manual)

Copy both files to `~/.oh-my-zsh/themes/` and set `ZSH_THEME="maniattico"` in `~/.zshrc`.

For Docker support, add this cron job:
```
* 7-23,0 * * * /usr/bin/docker info | grep 'Running:\|Stopped:' | tr '\n' ' ' | sed "s/ //g" | sed 's/Running:/ /' | sed 's/Stopped:/·/' > /tmp/docker.info
```

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

**Performance pattern**: `get_lan_info()` runs `ip a` once per prompt into `/tmp/ip.a`; all network functions read from this cache. Docker info is populated by cron, not on every prompt render.

## Configuration (`maniattico.zsh-theme.cfg`)

| Variable | Values | Effect |
|---|---|---|
| `ENVIRONMENT` | `PRODUCCIÓN` `PREPRODUCCIÓN` `DESARROLLO` `INTERNO` `CUSTOM` | Changes prompt accent color |
| `CUSTOM_COLOUR` | 256-color index | Used when `ENVIRONMENT="CUSTOM"` |
| `EXTRA_INFO` | any string | Displayed after environment segment |
| `GRADIENT` | `1` `wezterm` or unset | Prompt end style |
| `DOCKER` `WIREGUARD` `OPENVPN` `FORTICLIENT` `ANYCONNECT` `SCREEN` | `y`/`n` | Enables/disables each feature check |

Environment color mapping: `PRODUCCIÓN`→red(001), `PREPRODUCCIÓN`→purple(091), `DESARROLLO`→yellow(220), `INTERNO`→green(042), `CUSTOM`→`$CUSTOM_COLOUR`.

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

There is no test suite. To test: source the theme directly in a running ZSH session:
```zsh
source maniattico.zsh-theme
```
Or reload after copying to Oh-My-ZSH themes directory:
```zsh
source ~/.zshrc
```
