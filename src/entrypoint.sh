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

    kustomize_install=1
    if [ "${INPUT_KUSTOMIZE_INSTALL}" == "0" ] || [ "${INPUT_KUSTOMIZE_INSTALL}" == "false" ]; then
        kustomize_install=0
    fi

    kustomize_output_file=""
    if [ -n "${INPUT_KUSTOMIZE_OUTPUT_FILE}" ]; then
      kustomize_output_file=${INPUT_KUSTOMIZE_OUTPUT_FILE}
    fi

    kustomize_build_options=""
    if [ -n "${INPUT_KUSTOMIZE_BUILD_OPTIONS}" ]; then
      kustomize_build_options=${INPUT_KUSTOMIZE_BUILD_OPTIONS}
    fi

    enable_alpha_plugins=""
   if [ "${INPUT_ENABLE_ALPHA_PLUGINS}" == "1" ] || [ "${INPUT_ENABLE_ALPHA_PLUGINS}" == "true" ]; then
       enable_alpha_plugins="--enable_alpha_plugins"
    fi
}

function install_kustomize {

    echo "getting download url for kustomize ${kustomize_version}"

    for i in {1..100}; do
      url=$(curl --retry-all-errors --fail --retry 30 --retry-max-time 120 -s "https://api.github.com/repos/kubernetes-sigs/kustomize/releases?per_page=100&page=$i" | jq -r '.[].assets[] | select(.browser_download_url | test("kustomize(_|.)?(v)?'$kustomize_version'_linux_amd64"))  | .browser_download_url')
      if [ ! -z $url ]; then
        break
      fi
    done

    if [ ! -z $url ]; then
      echo "Download URL found in $url"
    else
      echo "Failed to find download URL for ${kustomize_version}"
      exit 1
    fi

    echo "Downloading kustomize v${kustomize_version}"
    if [[ "${url}" =~ .tar.gz$ ]]; then
      curl --retry 30 --retry-max-time 120 -s -S -L ${url} | tar -xz -C /usr/bin
    else
      curl --retry 30 --retry-max-time 120 -s -S -L ${url} -o /usr/bin/kustomize
    fi
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

    if  [ "${kustomize_install}" == "1" ]; then
      install_kustomize
    fi

    kustomize_build

}

main "${*}"
