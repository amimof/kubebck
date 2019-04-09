#!/bin/bash

function log {
    m_time=`date "+%F %T"`
    printf "%s %s\n" "${m_time}" "${1}"
}

function info {
  log "[INFO] ${1}"
}

function error {
  log "[ERROR] ${1}"
}

# Set some variables to be used later on
DATE=`date "+%F_%H%M"`
KUBECONFIG="${KUBECONFIG:-"/config"}"
export KUBECONFIG=$KUBECONFIG
CONTEXTS=$(kubectl config get-contexts --no-headers -o name)
CONTEXTS_COUNT=$(echo $CONTEXTS | wc -w)
OUTPUT_DIR="${OUTPUT_DIR:-"/kubebck"}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-"yaml"}"
KUBEBCK_ARCHIVE="${KUBEBCK_ARCHIVE:-"false"}"

# Print out some informative info
info "Output path is: ${OUTPUT_DIR}"
info "KUBECONFIG=${KUBECONFIG}"
info "Contexts in kubeconfig: ${CONTEXTS_COUNT}"

for CONTEXT in $CONTEXTS; do 

  info "Begin exporting ${CONTEXT}"

  CONTEXT_OUTPUT_DIR="${OUTPUT_DIR}/${CONTEXT}/${DATE}"
  info "Context output path is ${CONTEXT_OUTPUT_DIR}"
  mkdir -p $CONTEXT_OUTPUT_DIR
  info "Using context ${CONTEXT}"
  kubectl config use-context $CONTEXT > /dev/null

  # Error out if unable to connect to the apiserver
  info "Retrieving cluster-info"
  CLUSTER_INFO="$(kubectl cluster-info 2>&1 > /dev/null)"
  if [ $? -ne 0 ]; then
    error "$CLUSTER_INFO"
    continue
  else 
    info "Successfully connected to cluster"
  fi

  GLOBAL_APIS=$(kubectl api-resources --no-headers --namespaced=false | awk '{print $1}')
  SCOPED_APIS=$(kubectl api-resources --no-headers --namespaced=true | awk '{print $1}')
  GLOLBAL_APIS_COUNT=$(echo $GLOBAL_APIS | wc -w)
  SCOPED_APIS_COUNT=$(echo $SCOPED_APIS | wc -w)
  NAMESPACES=$(kubectl get ns --no-headers --ignore-not-found | awk '{print $1}')
  
  info "api-versions: ${GLOBAL_APIS_COUNT} namespaced / ${SCOPED_APIS_COUND} scoped"

  # Export global resources
  info "Begin exporting global APIs\n"
  set +e
  for API in $GLOBAL_APIS; do
    info "/${CONTEXT}/${API}"
    FILE_NAME="${CONTEXT_OUTPUT_DIR}/${API}.${OUTPUT_FORMAT}"
    kubectl get $API --no-headers --ignore-not-found -o $OUTPUT_FORMAT > $FILE_NAME
  done

  # Export namespaced resources
  info "Begin exporting namespaced APIs\n"
  for NAMESPACE in $NAMESPACES; do
    for API in $SCOPED_APIS; do
      info "${CONTEXT}/${NAMESPACE}/${API}"
      NAMESPACE_OUTPUT_DIR="${CONTEXT_OUTPUT_DIR}/namespaces/${NAMESPACE}"
      mkdir -p $NAMESPACE_OUTPUT_DIR
      FILE_NAME="${NAMESPACE_OUTPUT_DIR}/${API}.${OUTPUT_FORMAT}"
      kubectl get $API -n ${NAMESPACE} --no-headers --ignore-not-found -o $OUTPUT_FORMAT > $FILE_NAME
    done
  done

  # Tar context output dir if desired
  if [ "$KUBEBCK_ARCHIVE" == "true" ]; then
    ARCHIVE_FILE_NAME="${OUTPUT_DIR}/${CONTEXT}/${CONTEXT}_${DATE}.tar.gz"
    info "Creating archive ${ARCHIVE_FILE_NAME}"
    tar -zcf "${ARCHIVE_FILE_NAME}" "${CONTEXT_OUTPUT_DIR}"
    chmod +x ${ARCHIVE_FILE_NAME}
    rm -r "${CONTEXT_OUTPUT_DIR}"
  fi

  info "Done exporting ${CONTEXT}"

done

info "All done"