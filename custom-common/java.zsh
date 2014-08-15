#!/usr/bin/env zsh

export JAVA_OPTS="-Xms2048m -Xmx2048m -XX:MaxPermSize=384m"
export MAVEN_OPTS="${MAVEN_OPTS} ${JAVA_OPTS} -XX:NewRatio=1"
