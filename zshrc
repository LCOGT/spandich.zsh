xhost + &> /dev/null

plugins=(
  options
  common
  docker
  ant
  gnu-utils
  compleat
  command-not-found
  git
  github
  mercurial
  ssh-agent
  vi-mode
  vundle
  mvn
  wd
  gem
  pip
  tmuxinator
  tmux
  web-search
  colored-man
  svn-fast-info
  debian
  sudo
)

alias mux=tmuxinator

fpath=($HOME/.zsh-completions $fpath)
source $ZSH/oh-my-zsh.sh
power_reset


# OPAM configuration
. ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s ~/.gvm/bin/gvm-init.sh ]] && source ~/.gvm/bin/gvm-init.sh

source /etc/profile.d/rvm.sh
