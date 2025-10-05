# source this from ~/.zshrc if you want the Ctrl-B burst
_fb_os="$(uname -s)"

_fb_list_pids_in_pgid() { ps -o pid= --pgroup "$1" 2>/dev/null | awk '{print $1}'; }

_fb_boost_pid() {
  if [[ "$_fb_os" == "Darwin" ]]; then
    command -v taskpolicy >/dev/null && taskpolicy -p -g user_interactive "$1" 2>/dev/null || true
    renice -5 -p "$1" >/dev/null 2>&1 || true
  else
    renice -5 -p "$1" >/dev/null 2>&1 || true
    command -v ionice >/dev/null 2>&1 && ionice -c2 -n0 -p "$1" >/dev/null 2>&1 || true
  fi
}

_fb_revert_pid() {
  if [[ "$_fb_os" == "Darwin" ]]; then
    command -v taskpolicy >/dev/null && taskpolicy -p -g user_initiated "$1" 2>/dev/null || true
    renice 0 -p "$1" >/dev/null 2>&1 || true
  else
    renice 0 -p "$1" >/dev/null 2>&1 || true
    command -v ionice >/dev/null 2>&1 && ionice -c2 -n4 -p "$1" >/dev/null 2>&1 || true
  fi
}

_fb_log_file_default="$HOME/.cache/focus-burst.log"
[[ -d "$HOME/.cache" ]] || _fb_log_file_default="$HOME/.focus-burst.log"

# focus-burst [job] [--adaptive|--pulse] [--min 0.3] [--max 5] [--idle 0.35]
#             [--on 0.4] [--off 0.2] [--file path]
focus-burst() {
  emulate -L zsh
  setopt localoptions no_monitor no_notify

  local job="%+" mode="adaptive" min_win=0.4 max_win=6.0 idle_thresh=0.35
  # Pulse defaults: on for 0.6s, off for 0.3s (≈ 67% duty cycle)
  local pulse_on=0.6 pulse_off=0.3
  local log_file="$_fb_log_file_default"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      %*|-j|--job) job="$1"; shift ;;
      --adaptive) mode="adaptive"; shift ;;
      --pulse) mode="pulse"; shift ;;
      --min) min_win="$2"; shift 2 ;;
      --max) max_win="$2"; shift 2 ;;
      --idle) idle_thresh="$2"; shift 2 ;;
      --on) pulse_on="$2"; shift 2 ;;
      --off) pulse_off="$2"; shift 2 ;;
      --file) log_file="$2"; shift 2 ;;
      --) shift; break ;;
      *) job="$1"; shift ;;
    esac
  done

  local line pid pgid
  line="$(jobs -l "$job" 2>/dev/null | head -n1)" || { print -r -- "No such job: $job" >&2; return 1; }
  pid="$(print -r -- "$line" | awk '{print $2}')"
  [[ -z "$pid" ]] && { print -r -- "Could not parse PID for $job" >&2; return 1; }
  pgid="$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ')" || return 1

  _fb_group_cpu() {
    ps -o %cpu= -o pgid= -ax 2>/dev/null | awk -v G="$1" '$2 == G {sum += $1} END {printf("%.3f", sum+0)}'
  }

  local p; for p in $(_fb_list_pids_in_pgid "$pgid"); do _fb_boost_pid "$p"; done

  (
    exec >/dev/null 2>&1
    local start_ts end_ts elapsed=0.0 cpu cycles=0 pulses=0
    start_ts="$(date +%s.%N 2>/dev/null || date +%s)"
    case "$mode" in
      adaptive)
        sleep "$min_win"; elapsed="$min_win"
        while :; do
          if printf '%s %s\n' "$elapsed" "$max_win" | awk '{exit !($1>=$2)}'; then break; fi
          cpu="$(_fb_group_cpu "$pgid")"; cycles=$((cycles+1))
          if printf '%s %s\n' "$cpu" "$idle_thresh" | awk '{exit !($1 <= $2*100)}'; then break; fi
          sleep 0.2
          elapsed=$(printf '%.3f' "$(printf '%s %s\n' "$elapsed" 0.2 | awk '{printf $1+$2}')")
        done
        ;;
      pulse)
        local on="$pulse_on" off="$pulse_off"
        sleep "$min_win"; elapsed="$min_win"
        while :; do
          if printf '%s %s\n' "$elapsed" "$max_win" | awk '{exit !($1>=$2)}'; then break; fi
          # Off phase (revert), check CPU during off to decide continuing
          for p in $(_fb_list_pids_in_pgid "$pgid"); do _fb_revert_pid "$p"; done
          sleep "$off"; elapsed=$(printf '%.3f' "$(printf '%s %s\n' "$elapsed" "$off" | awk '{printf $1+$2}')")
          cpu="$(_fb_group_cpu "$pgid")"; cycles=$((cycles+1)); pulses=$((pulses+1))
          if printf '%s %s\n' "$cpu" "$idle_thresh" | awk '{exit !($1 <= $2*100)}'; then break; fi
          # On phase (boost again)
          for p in $(_fb_list_pids_in_pgid "$pgid"); do _fb_boost_pid "$p"; done
          sleep "$on"; elapsed=$(printf '%.3f' "$(printf '%s %s\n' "$elapsed" "$on" | awk '{printf $1+$2}')")
        done
        ;;
    esac
    for p in $(_fb_list_pids_in_pgid "$pgid"); do _fb_revert_pid "$p"; done
    end_ts="$(date +%s.%N 2>/dev/null || date +%s)"
    {
      printf '[%s] pgid=%s mode=%s min=%.2f max=%.2f idle=%.2f on=%.2f off=%.2f elapsed=%.2f cycles=%d pulses=%d\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$pgid" "$mode" "$min_win" "$max_win" "$idle_thresh" "$pulse_on" "$pulse_off" "$elapsed" "$cycles" "$pulses"
    } >>"$log_file" 2>/dev/null
  ) &
}

# Ctrl-B: suspend → burst (adaptive pulse) → resume
bindkey -s '^B' '^Zfocus-burst --pulse %+\\nfg\\n'
