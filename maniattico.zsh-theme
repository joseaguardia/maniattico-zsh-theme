CURRENT_BG='NONE'
ENTORNO="INTERNO"
[[ $ENTORNO = "PRODUCCIÓN" ]] && COLOR_ENTORNO="160"
[[ $ENTORNO = "PREPRODUCCIÓN" ]] && COLOR_ENTORNO="099"
[[ $ENTORNO = "DESARROLLO" ]] && COLOR_ENTORNO="208"
[[ $ENTORNO = "INTERNO" ]] && COLOR_ENTORNO="042"

#Información que se muestra después del entorno
EXTRA_INFO=""

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="es_ES.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
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
  prompt_segment 039 $CURRENT_FG '%~'
  #prompt_segment blue $CURRENT_FG '%~'
}


prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}%{%G⚠️ %}"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}%{%G🧵"%}
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}%{%G🦸"%}

  [[ -n "$symbols" ]] && prompt_segment 239 default "$symbols"
}

entorno_sdos() {

    prompt_segment 248 black "$(hostname -I | cut -d ' ' -f 1)"
    prompt_segment $COLOR_ENTORNO white "$ENTORNO $EXTRA_INFO"

}


dockerCount() {
    prompt_segment 027 045 "%{%G🐋%}$(docker info|  grep 'Running:\|Stopped:' | tr \\n ' ' | sed 's/   / /g' | sed 's/Running: /⯈ /' | sed 's/Stopped:/ ■/')"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  entorno_sdos
  [[ $SERVICIODOCKER = "1" ]] && dockerCount
  prompt_dir
# prompt_end
}

PROMPT='
%{%f%b%k%}$(build_prompt) ⤶ '
PROMPT+='
$(prompt_segment null 243 "%n")$(prompt_segment null $COLOR_ENTORNO "〉")'
