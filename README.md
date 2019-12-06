# kustomize-github-action
Kustomize GitHub Actions allow you to execute Kustomize Build command within GitHub Actions.

The output of the actions can be viewed from the Actions tab in the main repository view. If the actions are executed on a pull request event, a comment may be posted on the pull request.

Kustomize GitHub Actions is a single GitHub Action that can be executed on different overlays directories depending on the content of the GitHub Actions YAML file.


## Success Criteria
An exit code of `0` is considered a successful execution.

## Usage
The most common usage is to run `kustomize build` on an overlays directory, where one overlays directory represents k8s configs for one environment. A comment will be posted to the pull request depending on the output of the Kustomize build command being executed. This workflow can be configured by adding the following content to the GitHub Actions workflow YAML file. 
```yaml
name: 'Kustomize GitHub Actions'
on:
  - pull_request
jobs:
  kustomize:
    name: 'Kustomize'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Kustomize Build'
        uses: karancode/kustomize-github-action@master
        with:
          kustomize_version: '3.0.0'
          kustomize_build_dir: '.'
          kustomize_comment: true
        env:
          GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_ACCESS_TOKEN }}
```
This was a simplified example showing the basic features of these Kustomize rraform GitHub Actions. More examples, coming soon!

# Inputs

Inputs configure Kustomize GitHub Actions to perform build action.

* `kustomize_version` - (Required) The Kustomize version to use for `kustomize build`.
* `kustomize_build_dir` - (Optional) The directory to run `kustomize build` on (assumes that the directory contains a kustomization yaml file). Defaults to `.`.
* `kustomize_comment` - (Optional) Whether or not to comment on GitHub pull requests. Defaults to `false`.


## Outputs

Outputs are used to pass information to subsequent GitHub Actions steps.

* `kustomize_build_output` - The Kustomize build outputs.

## Secrets

Secrets are similar to inputs except that they are encrypted and only used by GitHub Actions. It's a convenient way to keep sensitive data out of the GitHub Actions workflow YAML file.

* `GITHUB_ACCESS_TOKEN` - (Optional) The GitHub API token used to post comments to pull requests. Not required if the `kustomize_comment` input is set to `false`.

