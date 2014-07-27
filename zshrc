plugins=(
  options
  common
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

source $ZSH/oh-my-zsh.sh

# OPAM configuration
. /home/spandich/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/home/spandich/.gvm/bin/gvm-init.sh" ]] && source "/home/spandich/.gvm/bin/gvm-init.sh"
