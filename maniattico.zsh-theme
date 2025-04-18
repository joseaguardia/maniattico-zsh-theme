#Version 20250404

#Requisitos:
# Fuente nerd fonts: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
# Este crontab para la info de docker:
# * 7-23,0 * * * /usr/bin/docker info | grep 'Running:\|Stopped:' | tr '\n' ' ' | sed "s/ //g" | sed 's/Running:/ /' | sed 's/Stopped:/·/' > /tmp/docker.info

#Cargamos la config del archivo .cfg
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

# Detectar la distribución de Linux, solo en la primera carga
if [ -f /etc/os-release ]; then
    #. /etc/os-release
    case $(grep "^ID=" /etc/os-release | cut -d '=' -f2 | tr -d '"') in
        fedora)
            LINUX_DISTRO="" ;;
        ubuntu)
            LINUX_DISTRO="" ;;
        centos)
            LINUX_DISTRO="" ;;
        debian)
            LINUX_DISTRO="" ;;
        raspbian)
            LINUX_DISTRO="" ;;
        rocky)
            LINUX_DISTRO="" ;;
        *)
            LINUX_DISTRO="" ;;
    esac
else
    LINUX_DISTRO=""
fi


#Detectar si estamos en distrobox
if [[ -n "$DISTROBOX_ENTER_PATH" ]]; then
    DISTROBOX=true
else
    DISTROBOX=false
fi

# Special characters
() {
  local LC_ALL="" LC_CTYPE="es_ES.UTF-8" 
  }

get_lan_info() {
  #Guardamos los datos de red para usarlo en varias comprobaciones
  /usr/sbin/ip a > /tmp/ip.a
  LAN_IFACE="$(ip route | grep default | awk '{print $5}')"
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
[[ $DISTROBOX = true ]] && ICONO_PROMPT="DISTROBOX 📦$ICONO_PROMPT"  

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
    prompt_segment $ENVIRONMENT_COLOUR white "%(!.%{%F{white}%}.)$HOST"
  else
    prompt_segment $ENVIRONMENT_COLOUR black "%(!.%{%F{white}%}.)$LINUX_DISTRO$SEGMENT_SEPARATOR"
    prompt_segment $ENVIRONMENT_COLOUR white "%(!.%{%F{white}%}.)$HOST"
  fi
}



prompt_dir() {
  # Convertir $HOME a ~
  local path_pwd="${PWD/#$HOME/~}"
  local path_length=$(wc -c <<< $path_pwd)
  local max_length=45
  
  # Si la ruta es menor o igual a $max_lenght caracteres, mostrarla completa
  if [[ ${#path_pwd} -le $max_length ]]; then
    prompt_segment 159 $CURRENT_FG " $path_pwd"
    return
  fi

  # Mostrar los últimos $max_lenght caracteres con ... al principio
  local shortened_path="${path_pwd: -$max_length}"
  prompt_segment 159 $CURRENT_FG " 󰇘$shortened_path"
}




# Git: branch/detached head, dirty status
prompt_git() {
  [[ $DISTROBOX = true ]] && return

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

    # ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="$PL_BRANCH_CHAR$GIT_ICON ➦ $(git rev-parse --short HEAD 2> /dev/null)"

if ref=$(git symbolic-ref HEAD 2> /dev/null); then
  HEADLESS="0"
else
  ref="$PL_BRANCH_CHAR$GIT_ICON $(git rev-parse --short HEAD 2> /dev/null)"
  HEADLESS="1"
fi



    # Definir color del segmento
    if [[ $HEADLESS -eq "1" ]]; then
      BACKCOLOR=202 #Naranja
      FRONTCOLOR=white
    elif [[ -n $dirty_icons ]]; then
      if [[ "$(cut -d '/' -f3 <<<$ref)" = "master" ]] ||  [[ "$(cut -d '/' -f3 <<<$ref)" = "main" ]] ; then
        BACKCOLOR=197 #Rosa brillante
        FRONTCOLOR=white
      else 
        BACKCOLOR=204 #Rosa apagado
        FRONTCOLOR=white
      fi
    else  # Todo correcto, sin cambios, dependiendo de si es main/master u otra rama
      if [[ "$(cut -d '/' -f3 <<<$ref)" = "master" ]] ||  [[ "$(cut -d '/' -f3 <<<$ref)" = "main" ]] ; then
        BACKCOLOR=190 #191Verde brillante
        FRONTCOLOR=232
      else
        BACKCOLOR=048 #084Verde apagado
        FRONTCOLOR=232
      fi
    fi

    # Generamos el prompt con los colores
    prompt_segment $BACKCOLOR $FRONTCOLOR

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
    # Icono de Azure si el repo tiene remotos en Azure DevOps
    if git remote -v | grep -q "dev.azure.com"; then
      GIT_ICON=" "
    fi


    # Si no hay cambios, mostrar icono de repositorio limpio
    local clean_indicator=""
    [[ -z $dirty_icons ]] && clean_indicator=" $CLEAN_ICON"
    [[ $HEADLESS -eq "1" ]] && clean_indicator=" \Uf071c"

    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR $GIT_ICON}$dirty_icons$clean_indicator$mode"
  fi
}




# status icons
prompt_status() {
  local -a symbols
  symbols+=""
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}%{%G⌧%}"
  [[ $(ps --no-headers -o pid --ppid=$$ | wc -l) -gt 1 ]] && symbols+="%{%F{cyan}%}%{%G⮔%}"
  [[ $DISTROBOX = false ]] && [[ $SCREEN = "y" ]] && [[ $(screen -ls | grep '(Detached)' | wc -l) -gt 0 ]] && symbols+="%{%F{green}%}%{%G⎚%}"

  [[ -n "$symbols" ]] && prompt_segment 239 default "$symbols "
}



# Environment name
environment() {
    [[ -z $EXTRA_INFO ]] || prompt_segment $ENVIRONMENT_COLOUR white "$EXTRA_INFO"
}

# Get count of running or stopped docker's containers 
dockerCount() {
    prompt_segment 031 045 "%{%G\ueef6%}$(cat /tmp/docker.info)"
}



# LAN address
local_ip() {
  LOCAL_ADDR="$(grep "$LAN_IFACE" /tmp/ip.a | grep -v "${LAN_IFACE}:" | head -n1 | awk '{print $2}' | cut -d '/' -f1)"
  if [[ -z $LOCAL_ADDR ]]; then
    prompt_segment 196 15 "🗦 🗱 🗧 "
  else
    prompt_segment 247 239 "$LOCAL_ADDR"
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

# Empty VPN variables
empty_vpn_conn() {
    WIREGUARD_CONN=false
    ANYCONNECT_CONN=false
    FORTICLIENT_CONN=false
}

wireguard_status() {
    [[ $DISTROBOX = true ]] && return    
    if sudo wg show | grep 'latest handshake' > /dev/null; then
      WIREGUARD_CONN=true
      prompt_segment 50 22 "%{%G%} wireguard"
    fi
}

forticlient_status() {
    [[ $DISTROBOX = true ]] && return       
    forticlient_conn="$(grep -iv "cscotun0" /tmp/ip.a | grep 'global vpn\|POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP' | awk '{print $2}' | cut -d '/' -f1)"
    if [[ -n $forticlient_conn ]];then
      FORTICLIENT_CONN=true
      prompt_segment 50 22 "%{%G%} forticlient"
    fi
}

anyconnect_status() {
    [[ $DISTROBOX = true ]] && return       
    cisco="$(grep 'cscotun0$' /tmp/ip.a | xargs)"
    if [[ $cisco =~ "cscotun0" ]];then
      ANYCONNECT_CONN=true
      prompt_segment 50 22 "%{%G%} anyconnect"
    else
      ANYCONNECT_CONN=false
    fi
}

## Main prompt
build_prompt() {
  empty_vpn_conn
  RETVAL=$?
  get_lan_info
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
