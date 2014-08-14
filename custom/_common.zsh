#!/usr/bin/env zsh

for f in $(ls -X ${ZSH_CUSTOM_COMMON_DIR}/*.zsh | LC_COLLATE=C sort); do
  source $f
done
