#!/usr/bin/env zsh

export SVN_SERVER=versionsba.${LCOGT_DOMAIN}
export SVN=http://${SVN_SERVER}/svn
export SVNLCO=${SVN}/telsoft/Lco
export SVNME=${SVN}/user/${USER}


function svnundo() {
    if [ $# -eq 0 ]; then
        svn revert -R .
    else
        svn revert $@
    fi
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

  if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo "Usage: ${0} project_name [ branch ]"
    return 1
  fi

  local project=${1}; shift
  local branch=${1:=trunk}; shift
  [ "${branch}" == 'trunk' ] || branch="branches/${branch}"
  local url=${base}/${project}/${branch}

  (cd ${WORKSPACE} && svn co ${url} ${project})
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
