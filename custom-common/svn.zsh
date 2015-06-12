#!/usr/bin/env zsh

export SVN_SERVER=versionsba.${LCOGT_DOMAIN}
export SVN=http://${SVN_SERVER}/svn
export SVNLCO=${SVN}/telsoft/Lco
export SVNME=${SVN}/user/${USER}

function svnaddall() {
    if svn info &> /dev/null; then
        svn status | grep -E '^\?' | awk '{ print $2 }' | xargs svn add
    else
        echo 'not an SVN directory'
    fi
}

function svnundo() {
    if [ $# -eq 0 ]; then
        svn revert -R .
    else
        svn revert $@
    fi
}

function svnignore-all() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${0} fitler"
    return
  fi

  local filter="${1}"; shift

  for dir in $(find . -name "${filter}" | xargs -L1 dirname); do
    figlet "${dir}"
    (svn propget svn:ignore ${dir} | grep -v "${filter}" | awk NF ; echo "${filter}") |  svn propset  --non-interactive -F - svn:ignore ${dir}
    svn propget svn:ignore ${dir}
    echo
    echo
  done
}

function visvn() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/svn.zsh
  vi "${SELF}" && source "${SELF}"
} 

function svndiff() {
  svn diff --extensions --ignore-all-space --git $@ | vimdiff -R -
}

function _svnco() {
  local function_name=${1}; shift;
  local base=${1}; shift

  if [ $# -eq  0 ] || [ $# -gt 3 ]; then
    echo "Usage: ${0} project_name [ branch [ dir ] ]"
    return 1
  fi

  local project=${1}; shift
  local branch=${1:=trunk}; shift
  local dir=${1:=${WORKSPACE}}; shift
  [ "${branch}" == 'trunk' ] || branch="branches/${branch}"
  local url=${base}/${project}/${branch}

  (cd ${dir} && svn co ${url} ${project})
}

function svnissue() {
    if [ $# -ne 2 ]; then
        echo "Usage: ${0} project issue_number"
        return 1
    fi

    local project=$1; shift
    local issue=$1; shift

    svn cp ${SVNLCO}/${project}/trunk ${SVNLCO}/${project}/branches/issue-${issue} -m initial && \
    svnco ${project} issue-${issue}
}

function svnco() {
  _svnco ${0} ${SVNLCO} $@
}

function svncome() {
  _svnco ${0} ${SVNME} $@
}

function svnc() {
    svn commit $@ && svn up
}

alias svns='svn status'
alias svnll='svn log --limit 10'

function svnlogme() {
  svn log $@ | grep -B2 ${USER} | sed '/^-\+/d' | paste - - -d:
}

function svnmerge() {
  if [ $# -lt 1 ]; then
    echo "Usage: ${0} target_revision [ path ... ]"
    return 1
  fi
  revision=${1}; shift
  svn merge -r${revision}:$(svn info | grep '^Revision' | cut -d' ' -f2) $(svn info | grep '^URL' | cut -d' ' -f2) $@
}

function sg-clone() {

    local errors=0

    if [ -z "${WORKSPACE}" ]; then
        echo 'Error: the WORKSPACE environment variable is mandatory.'
        errors=1
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: ${0} project_name ..."
        errors=1
    fi

    [ ${errors} -eq 0 ] || return 1

    for project in $@; do
        echo "cloning ${project}..."
        (
            cd ${WORKSPACE} &&
            subgit configure --svn-url ${SVNLCO}/${project} .gitrepos/${project}.git &&
            cat .gitrepos/subgit/config_template | sed "s/{{project.name}}/${project}/g" > .gitrepos/${project}.git/subgit/config &&
            subgit install .gitrepos/${project}.git &&
            git clone .gitrepos/${project}.git
        )
        echo
        echo
    done

}

function svnswitch() {
    local branch
    if [ $# -eq 0 ]; then
        branch=trunk
    else
        branch="branches/${1}"
    fi

    svn info &> /dev/null
    if [ $? -ne 0 ]; then
        echo "This is not a Subversion repository: ${pwd}"
        return 1
    fi

    local base_url=$(svn info | grep -E '^URL:' | awk '{ print $2 }' | sed 's/\/\(trunk\|branches.\+\)$//')
    local new_branch="${base_url}/${branch}"
    
    svn switch "${new_branch}"
}

function svnbranch() {
    if [ $# -ne 2 ]; then
        echo "Usage: ${0} project branch"
        return
    fi
    local project=$1;shift
    local branch=$1;shift
    local branch_url="${SVNLCO}/${project}/branches/${branch}"

    svn cp -m "start of branch: ${branch}" "${SVNLCO}/${project}/trunk" "${branch_url}" && \
    (cd "${WORKSPACE}" && svn co "${branch_url}" "${project}-${branch}")
}

function svnlast() {
    svn log -v --stop-on-copy | grep -E '^r[0-9]+ ' | tail -n1 | cut -d' ' -f1 | sed 's/^r//'
}

function svntrunk() {
    svn info  | grep -E '^URL:' | awk '{ print $2 }' | sed 's/\/\(branches\/.*\|trunk\)$/\/trunk/'
}

function svndifftrunk() {
    svn diff -x --ignore-all-space --patch-compatible "$(svntrunk)" . | vimdiff -R -
}

function svnmergeup() {
    local last_revision=$(svnlast)
    if [ -z "${last_revision}" ]; then
        echo 'Error: no last revision found.' > /dev/stderr
        return
    fi

    local trunk=$(svntrunk)
    if [ -z "${trunk}" ]; then
        echo 'Error: no trunk URL found.' > /dev/stderr
        return
    fi

    echo svn up \&\& svn merge -r"${last_revision}:HEAD" "${trunk}"
}

function svnmergedown() {
    local branch=$(svn info  | grep -E '^URL:' | awk '{ print $2 }')
    echo svn commit -m "'final commit'" \&\& \
    svn switch "$(svntrunk)" \&\& \
    svn merge --reintegrate "${branch}"
}

function svncomparetotrunk() {
    local trunk="$(svntrunk)"
    for f in $@; do
        svn diff --patch-compatible --extensions --ignore-all-space "${trunk}/${f}" "${f}"
    done
}
