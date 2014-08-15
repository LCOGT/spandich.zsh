#!/usr/bin/env zsh

function hgbounce { hg commit $@ && hg pull --rebase & hg push }
function hgbounceifgood { mvn -U clean test integration-test install && hgbounce $@ }
function hgvd { hg diff $* | vimdiff -R - }

function hgall {
  local command=$1; shift
  local regex=$1; shift
  (cd "$(hg root)" && hg status -S | grep -E "${regex}" | cut -c3- | xargs -I{} -L1 hg ${command} '{}')
}

function hgaddall {
  hgall add '^[\?]'
}

function hgforgetall {
  hgall forget '^[\!]'
}

function hgdelall {
  hgforgetall
  (cd "$(hg root)" && hg status -S | grep -E '^[\!]' | cut -c3- | xargs -I{} -L1 rm '{}')
}
