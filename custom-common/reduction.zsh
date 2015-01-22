#!/usr/bin/env zsh

function vireduction() {
    SELF=${ZSH_CUSTOM_COMMON_DIR}/reduction.zsh
    vi "${SELF}" && source "${SELF}"
}

export REDUCTION_HOME=${WORKSPACE}/reduction

function generate-reduction-wiki() {
    pandoc --from=markdown --to=mediawiki ${REDUCTION_HOME}/docs/wiki/reduction_server_analysis.md | pbcopy
}

function reddeploy() {
    pkill -f 'java.+reduction'
    rm /lco/log/**/*(.)

    z wsc
    mvn clean install

    z redc
    mvn clean install

    z red
    local version=$(grep -A1 '<artifactId>reduction</artifactId>' pom.xml | grep version | cut -d\> -f2 | cut -d\< -f1)
    mvn clean install $@ && z bplrun && ./runReductionService.sh -u ${version}
    z red
}

function reddeploybpl() {
    clear

    for project in redc red; do
        z ${project}
        figlet "$(mvn-artifact)"
        echo "Version: $(mvn-version)"
        echo "#######################################################################"
        echo "\n"
        mvn clean deploy || (say failure && return 1)
    done
    if [ $? -ne 0 ]; then
        return 1
    fi

    say launching
    z red
    ssh -t cc1bpl bash -l bin/_runReductionService.sh $(mvn-version)
}

function reduce() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 filename"
        return 1
    fi

    local file=$1; shift
    curl "http://localhost:8585/ReductionService?/mnt/data/fl01/${file}?outdir=/mnt/data/fl01"
}

function extract() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 filename"
        return 1
    fi

    local file=$1; shift
    curl "http://reduction-server:8585/SourceExtractionService?/mnt/data/fl01/${file}?outdir=/mnt/data/fl01&outfile=test2-01.guide.xml"
}

function preprocess() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 filename"
        return 1
    fi

    local file=$1; shift
    curl "http://reduction-server:8585/Preprocess?/mnt/data/fl01/${file}?outfile=/mnt/data/fl01/${file:s/fits/guide.xml}"
}

function redtail() {
    cd /lco/log && clear && tail -F *reduction*.log
}
