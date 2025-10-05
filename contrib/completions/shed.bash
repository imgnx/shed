# bash completion for shed

_shed()
{
  local cur prev words cword
  _init_completion -n : || return

  local subcmds="bg work focus bump version --help -h help"

  if [[ ${cword} -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${subcmds}" -- "$cur") )
    return
  fi

  case ${words[1]} in
    bump)
      # suggest PIDs
      local pids
      pids=$(ps -o pid= -ax 2>/dev/null)
      COMPREPLY=( $(compgen -W "$pids" -- "$cur") )
      ;;
    bg|work|focus)
      # suggest running process names (simple)
      local procs
      procs=$(ps -o comm= -ax 2>/dev/null | awk '{print $1}' | sort -u)
      COMPREPLY=( $(compgen -W "$procs" -- "$cur") )
      ;;
    *)
      COMPREPLY=()
      ;;
  esac
}

complete -F _shed shed

