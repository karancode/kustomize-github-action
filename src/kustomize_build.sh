#!/bin/bash

function kustomize_build {
    # gather output
    echo "build: info: kustomize build in directory ${kustomize_build_dir}."
    build_output=$(kustomize build ${*} 2>&1)
    build_exit_code=${?}
    

    # exit code 0 - success
    if [ ${build_exit_code} -eq 0 ];then
        build_comment_status="Success"
        echo "build: info: successfully executed kustomzie build in ${kustomize_build_dir}."
        echo "${build_output}"
        echo
    fi

    # exit code !0 - failure
    if [ ${build_exit_code} -ne 1 ]; then
        build_comment_status="Failed"
        echo "build: error: failed to execute kustomize build in ${kustomize_build_dir}."
        echo "${build_output}"
        echo
    fi

    # comment
    if [ "${GITHUB_EVENT_NAME}" == "pull_request" ] && ([ "${kustomize_comment}" == "1" || "${kustomize_comment}" == "true" ]); then
        build_comment_wrapper="####\`kustomize build\` ${build_comment_status}
<details><summary>Show Output</summary>

\`\`\`
${build_output}
 \`\`\`
</details>

*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Build Directory: \`${kustomize_build_dir}\`*"
    
        echo "build: info: creating json"
        build_payload=$(echo "${build_comment_wrapper}" | jq -R --slurp '{body: .}')
        build_comment_url=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
        echo "build: info: commenting on the pull request"
        echo "${build_payload}" | curl -s -S -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" --header "Content-Type: application/json" --data @- "${build_comment_url}" > /dev/null
    fi

    echo ::set-output name=kustomize_build_output::${build_output}
    exit ${build_exit_code}
}