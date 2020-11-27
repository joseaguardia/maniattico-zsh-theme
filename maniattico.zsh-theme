CURRENT_BG='NONE'

# Set environment options
ENVIRONMENT="PREPRODUCCIÓN"

# Extra information after environment name
EXTRA_INFO=""

ENVIRONMENT_COLOUR="026" #by default
[[ $ENVIRONMENT = "PRODUCCIÓN" ]]     && ENVIRONMENT_COLOUR="001"
[[ $ENVIRONMENT = "PREPRODUCCIÓN" ]]  && ENVIRONMENT_COLOUR="091"
[[ $ENVIRONMENT = "DESARROLLO" ]]     && ENVIRONMENT_COLOUR="014"
[[ $ENVIRONMENT = "INTERNO" ]]        && ENVIRONMENT_COLOUR="036"

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="es_ES.UTF-8"
  #Other separators: ◣ ◤ ░ ❯ \ue0b0
  SEGMENT_SEPARATOR=$'░❯'
  #SEGMENT_SEPARATOR=$'◤' #Works fine (full height) in Kali2020.3, however it doesn't in Debian10  
  }

  
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
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}


prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment 243 default "%(!.%{%F{white}%}.)$HOST"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 039 $CURRENT_FG '⎘ %~ '
}


# status icons
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}%{%G✖%}"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}%{%G⮔ "%}
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}%{%G🦸"%}

  [[ -n "$symbols" ]] && prompt_segment 239 default "$symbols"
}

# LAN address
local_ip() {
  prompt_segment 248 black "$(hostname -I | cut -d ' ' -f 1)"
}

# Environment name
environment() {
    [[ -z $ENVIRONMENT ]] || prompt_segment $ENVIRONMENT_COLOUR white "$ENVIRONMENT$EXTRA_INFO"
}

# Get count of running or stopped docker's containers 
dockerCount() {
    prompt_segment 027 045 "%{%G🐋%}$(docker info|  grep 'Running:\|Stopped:' | tr \\n ' ' | sed 's/   / /g' | sed 's/Running: /⯈ /' | sed 's/Stopped:/ ■/')"
}


# Detects connection to openVPN and shows the IP of the tunnel
vpn() {    
    openvpn="$(ip a | grep 'tun0$' | xargs)"
    if [[ $openvpn =~ "tun0" ]];then
      vpnIP="$(cut -d ' ' -f2 <<<$openvpn | cut -d '/' -f1)"
      prompt_segment 119 034 "%{%G🔐%} $vpnIP"
    fi
}



## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  local_ip
  vpn
  environment
  [[ $SERVICIODOCKER = "1" ]] && dockerCount
  prompt_dir
  #prompt_end
}

# Write the prompt (two lines)
PROMPT='
%{%f%b%k%}$(build_prompt) '
PROMPT+='
$(prompt_segment null 243 "%n")$(prompt_segment null $ENVIRONMENT_COLOUR "〉")'
