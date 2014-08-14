ZSH_CUSTOM_DIR=~/.zsh.custom

if [ -d "${ZSH_CUSTOM_DIR}" ]; then
  for f in "${ZSH_CUSTOM_DIR}"/*; do
    source $f
  done
fi
