#!/usr/bin/env zsh

  
function vitomcat() {
  SELF=${ZSH_CUSTOM_COMMON_DIR}/tomcat.zsh
  vi "${SELF}" && source "${SELF}"
}

export KEYTOOL_STOREPASS=changeit
export TOMCAT_HOME=/opt/tomcat/current

SELF=${0}

function tc-generate-cert {
  ALIAS=tomcat

  KEYSTORE_FILE=${JAVA_HOME}/jre/lib/security/cacerts
  [ -f "${KEYSTORE_FILE}" ] || (echo "${KEYSTORE_FILE} not found" ; return)

  CN=127.0.0.1
  [ $# -eq 0 ] || (CN=$1; shift)
  CERT_FILE=${TOMCAT_HOME}/${CN}.crt

  sudo keytool -delete -alias ${ALIAS} -keypass ${KEYTOOL_STOREPASS} -storepass ${KEYTOOL_STOREPASS} -keystore ${KEYSTORE_FILE} &> /dev/null 
  sudo keytool -genkey -keyalg RSA -alias ${ALIAS} -keystore ${KEYSTORE_FILE} -keypass ${KEYTOOL_STOREPASS} -storepass ${KEYTOOL_STOREPASS} -validity 360 -keysize 2048 -dname "C=US,ST=California,L=Nowhere,O=Generic,CN=${CN}"
  sudo keytool -export -alias ${ALIAS} -file ${CERT_FILE} -keystore ${KEYSTORE_FILE} -keypass ${KEYTOOL_STOREPASS} -storepass ${KEYTOOL_STOREPASS}
}


alias tc-start="${TOMCAT_HOME}/bin/startup.sh"

alias tc-start-jpda="${TOMCAT_HOME}/bin/catalina.sh jpda start"

tc-stop() {
  "${TOMCAT_HOME}"/bin/shutdown.sh
  sleep 5
  pkill -9 -f 'java.*tomcat.*start'

  echo 'Tomcat Stopped'
} 
tc-edit-context() {
  vi "${TOMCAT_HOME}"/conf/context.xml
}

tc-edit-setenv() {
  vi "${TOMCAT_HOME}"/bin/setenv.sh
}

tc-cleanup() {
  (cd "${TOMCAT_HOME}" && rm -rf webapps/insight (work|logs|temp)/* conf/Catalina/*)
}

tc-tail() { 
  clear && multitail --mergeall -iw ${TOMCAT_HOME}/logs/* 5 -t ${TOMCAT_HOME} --follow-all -cT ANSI -b 2 --retry-all
}

tc-run() {
  tc-stop && tc-cleanup && tc-start && tc-tail
}

tc-run-jpda() {
  tc-stop && tc-cleanup && tc-jpda && tc-tail
}
