#!/bin/bash

function parse_inputs {
    # required inputs
    if [ "${INPUT_KUSTOMIZE_VERSION}" != "" ]; then
        kustomize_version=${INPUT_KUSTOMIZE_VERSION}
    else
        echo "Input kustomize_version cannot be empty."
        exit 1
    fi

    # optional inputs
    kustomize_build_dir="."
    if [ "${INPUT_KUSTOMIZE_BUILD_DIR}" != "" ] || [ "${INPUT_KUSTOMIZE_BUILD_DIR}" != "." ]; then
        kustomize_build_dir=${INPUT_KUSTOMIZE_BUILD_DIR}
    fi

    kustomize_comment=0
    if [ "${INPUT_KUSTOMIZE_COMMENT}" == "1" ] || [ "${INPUT_KUSTOMIZE_COMMENT}" == "true" ]; then
        kustomize_comment=1
    fi
}

function install_kustomize {
    url="https://github.com/kubernetes-sigs/kustomize/releases/download/v${kustomize_version}/kustomize_${kustomize_version}_linux_amd64"

    echo "Downloading kustomize v${kustomize_version}"
    curl -s -S -L ${url} -o /usr/bin/kustomize
    if [ "${?}" -ne 0 ]; then
        echo "Failed to download kustomize v${kustomize_version}."
        exit 1
    fi
    echo "Successfully downloaded kustomize v${kustomize_version}."
    
    echo "Allowing execute privilege to kustomize."
    chmod +x /usr/bin/kustomize
    if [ "${?}" -ne 0 ]; then
        echo "Failed to update kustomize privilege."
        exit 1
    fi
    echo "Successfully added execute privilege to kustomize."

}

function main {

    scriptDir=$(dirname ${0})
    source ${scriptDir}/kustomize_build.sh
    parse_inputs

    install_kustomize
    kustomize_build
    kubeval
    
}

main "${*}"