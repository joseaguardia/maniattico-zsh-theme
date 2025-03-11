#Version 20250311

#Requisitos:
#Fuente nerd fonts: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
# Este crontab para la info de docker:
# */3 7-23,0 * * * /usr/bin/docker info | grep 'Running:\|Stopped:' | tr '\n' ' ' | sed "s/   / /g" | sed 's/Running: /󰧄/' | sed 's/Stopped: /󰦺/' | sed 's/^ //' > /tmp/docker.info

#Cargamos la config del archivo de config
. ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg

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

# Special characters
() {
  local LC_ALL="" LC_CTYPE="es_ES.UTF-8"
  #Other separators: ◣ ◤ ◥ ░ ❯ \ue0b0
  SEGMENT_SEPARATOR='⟩'
  }


# This speeds up pasting w/ autosuggest: https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

#Detectamos si el usuario es root o no, con cambio de prompt y color en cada caso  
[[ $UID -eq 0 ]] && ICONO_PROMPT="%F{$ENVIRONMENT_COLOUR}root#%f" || ICONO_PROMPT='%F{15}%f'
[[ -n $STY ]] && ICONO_PROMPT+="SCREEN"

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
  if [[ -n $CURRENT_BG ]] && [[ $GRADIENT = "1" ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}▓▒░"
  else
    echo -n " %{%k%F{$CURRENT_BG}%}◣"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}


prompt_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    prompt_segment $ENVIRONMENT_COLOUR black "%(!.%{%F{white}%}.)$LINUX_DISTRO$SEGMENT_SEPARATOR"
    prompt_segment $ENVIRONMENT_COLOUR white "%(!.%{%F{white}%}.)☁️ $HOST"
  else
    prompt_segment $ENVIRONMENT_COLOUR black "%(!.%{%F{white}%}.)$LINUX_DISTRO$SEGMENT_SEPARATOR"
    prompt_segment $ENVIRONMENT_COLOUR white "%(!.%{%F{white}%}.)$HOST"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 159 $CURRENT_FG '\uf114 %~'
}


# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi

  local PL_BRANCH_CHAR=$'\ue725'  # Icono de rama Git (Nerd Fonts)
  local ref staged unstaged dirty_icons mode repo_path

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)

    #Contamos el número en cada estado
    dirty_icons=""
    staged=""
    unstaged=""
    deleted=""
     
    git_status=$(git status --porcelain)
    if [[ -n $git_status ]]; then
      unstaged_count=$(echo "$git_status" | cut -c 1 | tr -cd '?' | wc -c)
      added_count=$(echo "$git_status" | cut -c 1-2 | tr -cd 'A' | wc -c)
      staged_count=$(echo "$git_status" | cut -c 1-2 | tr -cd 'M' | wc -c)
      total_staged=$(echo $added_count+$staged_count | bc)
      deleted_count=$(echo "$git_status" | cut -c 1-2 | tr -cd 'D' | wc -c)
    else
        staged_count=0
        unstaged_count=0
        deleted_count=0
    fi

    # Detección manual de cambios staged y unstaged
    
    [[ "$total_staged" -gt 0 ]] && staged=" $total_staged\Uf0b97"   # Icono si hay archivos staged
    [[ "$unstaged_count" -gt 0 ]] && unstaged=" $unstaged_count\uf4d0"  # Icono si hay archivos sin seguimiento o modificados
    [[ "$deleted_count" -gt 0 ]] && deleted=" $deleted_count\uf4d6"  # Icono si hay archivos sin seguimiento o modificados
    # Concatenar ambos iconos si existen
    dirty_icons="${staged}${unstaged}${deleted}"

    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    # Definir color del segmento si hay cambios
    if [[ -n $dirty_icons ]]; then
      prompt_segment 197 white
    else
      prompt_segment 191 $CURRENT_FG
    fi

    # Icono check si el repositorio está limpio
    CLEAN_ICON="\uf00c"
    
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <󰫯>" #B
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" ><" #M
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >󰫿>" #R
    fi

    # Icono de GitHub si el repo tiene remotos en GitHub
    local GIT_ICON=""
    if git remote -v | grep -q "github.com"; then
      GIT_ICON="\ueb00 "
    fi
    # Icono de Gitlab si el repo tiene remotos en Gitlab
    if git remote -v | grep -q "gitlab"; then
      GIT_ICON="\Uf0ba0 "
    fi


    # Si no hay cambios, mostrar icono de repositorio limpio
    local clean_indicator=""
    [[ -z $dirty_icons ]] && clean_indicator=" $CLEAN_ICON"

    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR $GIT_ICON}$dirty_icons$clean_indicator$mode"
  fi
}




# status icons
prompt_status() {
  local -a symbols
  symbols+=""
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}%{%G⌧%}"
  [[ $(ps --no-headers -o pid --ppid=$$ | wc -l) -gt 1 ]] && symbols+="%{%F{cyan}%}%{%G⮔%}"
  [[ $SCREEN = "y" ]] && [[ $(screen -ls | grep '(Detached)' | wc -l) -gt 0 ]] && symbols+="%{%F{green}%}%{%G⎚%}"

  [[ -n "$symbols" ]] && prompt_segment 239 default "$symbols "
}



# Environment name
environment() {
    [[ -z $EXTRA_INFO ]] || prompt_segment $ENVIRONMENT_COLOUR white "$EXTRA_INFO"
}

# Get count of running or stopped docker's containers 
dockerCount() {
    prompt_segment 027 045 "%{%G\ueef6%}$(cat /tmp/docker.info)"
}

#Guardamos los datos de red para usarlo en varias comprobaciones
/usr/sbin/ip a > /tmp/ip.a
LAN_IFACE="$(ip route | grep default | awk '{print $5}')"

# LAN address
local_ip() {
  LOCAL_ADDR="$(grep "$LAN_IFACE" /tmp/ip.a | grep -v "${LAN_IFACE}:" | awk '{print $2}' | cut -d '/' -f1)"
  if [[ -z $LOCAL_ADDR ]]; then
    prompt_segment 196 15 "🗦 🗱 🗧 "
  else
    prompt_segment 248 236 "$LOCAL_ADDR"
  fi
}

# Detects connection to openVPN, wireguard and forticlient and shows the IP of the tunnel
openvpn_status() {    
    openvpn="$(grep ' tun0$' /tmp/ip.a | xargs)"
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

forticlient_status() {    
    forticlient_conn="$(grep -iv "cscotun0" /tmp/ip.a | grep 'global vpn\|POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP' | awk '{print $2}' | cut -d '/' -f1)"
    if [[ -n $forticlient_conn ]];then
      forticlient_ip="$(ip a | grep 'global vpn\|POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP' -A3 | grep inet | awk '{print $2}' | cut -d'/' -f1)"
      prompt_segment 045 254 "%{%G🔌🛡️%} $forticlient_ip"
    fi
}

anyconnect_status() {    
    cisco="$(grep 'cscotun0$' /tmp/ip.a | xargs)"
    if [[ $cisco =~ "cscotun0" ]];then
      ciscoIP="$(cut -d ' ' -f2 <<<$cisco | cut -d '/' -f1)"
      prompt_segment 190 25 "%{%G🔌🌍%}$ciscoIP"
    fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  environment
  local_ip
  [[ $OPENVPN = "y" ]] && openvpn_status
  [[ $ANYCONNECT = "y" ]] && anyconnect_status
  [[ $FORTICLIENT = "y" ]] && forticlient_status
  [[ $WIREGUARD = "y" ]] && wireguard_status
  [[ $DOCKER = "y" ]] && dockerCount
  prompt_dir
  prompt_git
  prompt_end
}


# Write the prompt (two lines)
PROMPT='
%{ %f%b%k%}$(build_prompt)'
PROMPT+='
 $ICONO_PROMPT '



export EDITOR=vim
export VISUAL=vim
bindkey \^U backward-kill-line

#Autocompletado para archivos ocultos
zstyle ':completion:*' file-patterns '%p(^.)' '*'
