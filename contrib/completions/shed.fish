complete -c shed -n "__fish_use_subcommand" -f -a "bg" -d "deprioritize pattern or run command"
complete -c shed -n "__fish_use_subcommand" -f -a "work" -d "normal tier for pattern or command"
complete -c shed -n "__fish_use_subcommand" -f -a "focus" -d "interactive tier for pattern or command"
complete -c shed -n "__fish_use_subcommand" -f -a "bump" -d "temporarily boost a PID"
complete -c shed -n "__fish_use_subcommand" -f -a "version" -d "show version"

# bump PID completion
complete -c shed -n "__fish_seen_subcommand_from bump" -a "(ps -o pid= -ax 2>/dev/null)" -d PID

# basic process names for bg/work/focus
for sub in bg work focus
  complete -c shed -n "__fish_seen_subcommand_from $sub" -a "(ps -o comm= -ax 2>/dev/null | awk '{print $1}' | sort -u)" -d process
end

