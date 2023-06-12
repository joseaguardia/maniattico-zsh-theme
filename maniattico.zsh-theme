#Version 2.7-20230613

. ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg

#Comprobamos servicios para evitar errores
/usr/bin/systemctl status docker > /dev/null 2> /dev/null && SERVICIODOCKER="1" || SERVICIODOCKER="0"
wg-quick -h > /dev/null 2> /dev/null && WIREGUARD="1" || WIREGUARD="0"

#Auto-upgrade
DISABLE_UPDATE_PROMPT=true

ENVIRONMENT_COLOUR="208" #by default
[[ $ENVIRONMENT = "PRODUCCIÓN" ]]     && ENVIRONMENT_COLOUR="001"
[[ $ENVIRONMENT = "PREPRODUCCIÓN" ]]  && ENVIRONMENT_COLOUR="091"
[[ $ENVIRONMENT = "DESARROLLO" ]]     && ENVIRONMENT_COLOUR="220"
[[ $ENVIRONMENT = "INTERNO" ]]        && ENVIRONMENT_COLOUR="042"
[[ $ENVIRONMENT = "CUSTOM" ]]         && ENVIRONMENT_COLOUR="$CUSTOM_COLOUR"


CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="es_ES.UTF-8"
  #Other separators: ◣ ◤ ░ ❯ \ue0b0
  
  SEGMENT_SEPARATOR=$'❯'
  }


# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

#Detectamos si es ROOT o no
  
[[ $UID -eq 0 ]] && ICONO_PROMPT="#" || ICONO_PROMPT='$'


# Begin a segment
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}▓▒░"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}


prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $ENVIRONMENT_COLOUR 236 "%(!.%{%F{white}%}.)$HOST"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 159 $CURRENT_FG '⎘ %~ '
}



# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}


# status icons
prompt_status() {
  local -a symbols
  metrics
  symbols+="%{%F{red}%}%{%G %}"
  [[ $ALERTA -eq 1 ]] && symbols+="%{%F{red}%}%{%G⚠️ %}"
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}%{%G☠ %}"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}%{%G⮔ "%}
  #[[ $UID -eq 0 ]] && symbols+="%{%F{white}%}%{%G#"%}

  [[ -n "$symbols" ]] && prompt_segment 239 default "$symbols"
}

# LAN address
local_ip() {
  LOCAL_ADDR="$(hostname -I | cut -d ' ' -f 1)"
  [[ -z $LOCAL_ADDR ]] && LOCAL_ADDR="🌍❗"
  prompt_segment 248 236 "$LOCAL_ADDR"
}

# Environment name
environment() {
    #[[ -z $ENVIRONMENT ]] || prompt_segment $ENVIRONMENT_COLOUR white "$ENVIRONMENT$EXTRA_INFO"
    [[ -z $EXTRA_INFO ]] || prompt_segment $ENVIRONMENT_COLOUR white "$EXTRA_INFO"
}

# Get count of running or stopped docker's containers 
dockerCount() {
    prompt_segment 027 045 "%{%G🐋%}$(docker info|  grep 'Running:\|Stopped:' | tr \\n ' ' | sed 's/   / /g' | sed 's/Running: /⯈ /' | sed 's/Stopped:/ ■/')"
}


# Detects connection to openVPN and shows the IP of the tunnel
openvpn_status() {    
    openvpn="$(ip a | grep 'tun0$' | xargs)"
    if [[ $openvpn =~ "tun0" ]];then
      vpnIP="$(cut -d ' ' -f2 <<<$openvpn | cut -d '/' -f1)"
      prompt_segment 214 027 "%{%G🔌🔘%}$vpnIP"
    fi
}

wireguard_status() {    
    if sudo wg show | grep 'latest handshake' > /dev/null; then
      wgserver="$(sudo wg show | grep 'interface: ' | cut -d ':' -f2 | tr -d ' ')"
      prompt_segment 088 255 "%{%G🔌🐉%}$wgserver"
    fi
}

metrics() {

  #Right prompt
  LOAD="$(w | grep 'load average:' | awk '{print $10}' | sed 's/,$//' | tr ',' '.')*100/$(nproc)"
  PORCENTAJE_CPU="$(echo $LOAD | bc)"
  DISCO=$(df -h / | awk '/\// {print $5}' | tr -d '%')
  RAM_USADA="$(free -m | awk '/Memoria:/ {print $3}')"
  RAM_TOTAL="$(free -m | awk '/Memoria:/ {print $2}')"
  RAM=`echo "${RAM_USADA}*100/${RAM_TOTAL}" | bc`

  if [[ $PORCENTAJE_CPU -gt 75 ]] || [[ $DISCO -gt 95 ]] || [[ $RAM -gt 90 ]]; then
    ALERTA=1
  else
    ALERTA=0
  fi

}


## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  environment
  local_ip
  openvpn_status
  [[ $WIREGUARD = "1" ]] && wireguard_status
  [[ $SERVICIODOCKER = "1" ]] && dockerCount
  prompt_dir
  prompt_git
  [[ $GRADIENT = "1" ]] && prompt_end
}


# Write the prompt (two lines)
PROMPT='
%{ %f%b%k%}$(build_prompt) '
PROMPT+='
$(prompt_segment null 243 "%n")$(prompt_segment null $ENVIRONMENT_COLOUR "$ICONO_PROMPT ")'


#Aliases and other configurations
alias vi='vim'
bindkey \^U backward-kill-line
