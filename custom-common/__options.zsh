setopt no_auto_cd
setopt auto_pushd
setopt pushd_silent
setopt auto_list
setopt auto_menu
setopt auto_param_slash
setopt auto_remove_slash
setopt no_list_beep
setopt list_types
setopt extended_glob
setopt numeric_glob_sort
setopt append_history
setopt extended_history
setopt no_hist_beep
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt no_share_history
setopt rm_star_silent
setopt no_nomatch
setopt correct
setopt interactive_comments
setopt no_mail_warning
setopt no_path_dirs
setopt notify
setopt transient_rprompt
setopt prompt_subst
setopt no_beep
setopt hist_verify
setopt no_rm_star_silent
setopt print_exit_value
#setopt long_list_jobs
autoload -U compinit

zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
