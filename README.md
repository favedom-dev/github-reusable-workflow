# GitHub Reusable Workflow

## TODO

- add [stackhawk](https://docs.stackhawk.com/continuous-integration/github-actions.html)

- create preview environment
  - `preview-env.yaml`
  - options
    - ArgoCD
    - scripts via GH Actions

- update staging GitOps repo version on merge to master
  - `deploy-env.yaml`

---

## Setup repo to use GH Actions

1. First time will need to:
    - authenticate the repo with Google to use GitHub Actions
    - create `./.github/workflows/ci.yaml`
    - See [`setup_repo.sh`](#setupreposh)

1. Create ci workflow
    - See [`setup_ci.sh`](#setupcish)
    - See [Example Workflows](#example-workflows)

---

## [`./.github/workflows`](./.github/workflows)

### `deploy-env.yaml`

- Currently a **placeholder** for deploying a component into an environment (default: staging)
- `yq eval "(.dependencies[] | select(has(\"name\")) | select(.name == \"peeq-sms\")).version = \"1.2.4\"" ./requirements.yaml`

```yaml
  deploy-staging:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/deploy-env.yaml@master
    needs: [workaround-env, maven-docker]
    if: github.event_name == 'pull_request' && github.event.action == 'closed' && github.event.pull_request.merged == true
    with:
      NAME: ${{ needs.workaround-env.outputs.NAME }}
      VERSION: ${{ needs.repo-version.outputs.version }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

### `flyway-docker-build.yaml`

```yaml
  docker:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/flyway-docker-build.yaml@master
    needs: repo-version
    with:
      NAME: 'peeq-tracking-db'
      VERSION: ${{ needs.repo-version.outputs.version }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
      WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
```

### `lint-yaml.yaml`

```yaml
  lint-yaml:
    if: github.event_name == 'pull_request'
    uses: favedom-dev/github-reusable-workflow/.github/workflows/lint-yaml.yaml@master
    with:
      YAML_DIRS: '.github templates'
```

### `maven-docker.yaml`

```yaml
  maven-docker:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/maven-docker.yaml@master
    needs: [repo-version, workaround-env]
    with:
      NAME: ${{ needs.workaround-env.outputs.NAME }}
      VERSION: ${{ needs.repo-version.outputs.version }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
      WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
      NEXUS_FAVEDOM_DEV_PASSWORD: ${{ secrets.NEXUS_FAVEDOM_DEV_PASSWORD }}
```

### `preview-env.yaml`

- Currently a **placeholder** for creating the Preview environment
- OPTIONS: 1) solely GH Actions or 2) GH Actions + Argo CD

```yaml
  preview:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/preview-env.yaml@master
    needs: [workaround-env, maven-docker]
    if: github.event_name == 'pull_request'
    with:
      NAME: ${{ needs.workaround-env.outputs.NAME }}
      VERSION: ${{ needs.repo-version.outputs.version }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

### `preview-stackhawk.yaml`

- Currently a **placeholder**

### `repo-version.yaml`

- typically the first job to be called

```yaml
  repo-version:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/repo-version.yaml@master
    secrets:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

---

## [`./scripts`](./scripts)

### `auto-increment-version.sh`

- used within GH action to set the version and if a merge into master update the repo version

```yaml
      - name: "☁️ Get auto-increment-version.sh"
        if: github.event_name != 'pull_request'
        run: |
          wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/auto-increment-version.sh
          chmod 777 ./auto-increment-version.sh
```

### `preview_copy_secrets.sh`

- copy array of secrets into preview namespace
- Replace
  - `++PR_NUM++` with PR number `${{ github.event.number }}`
  - `++NAME++` with the app name (example `peeq-sms`)
  - `++SECRET_NAMESPACE++` the namespace the secrets in the array reside in
  - `++SECRETS_ARRAY++` array of secrets (example: `("rabbitmq" "peeq-users" "peeq-sms-twilio" "jx-staging-peeq-sms-pg")`)

```bash
export PR_NUM=++PR_NUM++
export APP_NAME=++NAME++

# repeat for all namespaces need to copy secrets from
export SECRET_NAMESPACE=++SECRET_NAMESPACE++
export SECRETS_ARRAY=++SECRETS_ARRAY++
./preview_copy_secrets.sh "${SECRETS_ARRAY[@]}"
```

- need to add a step to the workflow like this

```yaml
      - name: "☁️ Get preview_copy_secrets.sh"
        if: github.event_name != 'pull_request'
        run: |
          wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/preview_copy_secrets.sh
          chmod 777 ./preview_copy_secrets.sh
```

### `setup_ci.sh`

- creates a base `ci.yaml` workflow based on a template
- Replace `++CI_DIR++` with the correct [directory the template is under](https://github.com/favedom-dev/github-reusable-workflow/tree/master/templates)
- See [Example Workflows](#example-workflows)

  ```bash
  wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_ci.sh
  chmod 775 ./setup_ci.sh
  ./setup_ci.sh ++CI_DIR++
    ```

### `setup_repo.sh`

- Only need to run 1 time to setup authentication in a repo that needs to Google Auth and create placeholder for the GitHub workflows
  - copy script to repo adding GH actions
  - run the script
  - do not add the script to the repo (script deletes itself)

  ```bash
  wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_repo.sh
  chmod 775 ./setup_repo.sh
  ./setup_repo.sh
  ```

- If not run the repo GH action step for Google Auth will have an error like this:

  ```bash
  Error: google-github-actions/auth failed with: retry function failed with 0 attempts: failed to generate Google Cloud access token for ***: {
  "error": {
      "code": 403,
      "message": "The caller does not have permission",
      "status": "PERMISSION_DENIED"
      }
  }
  ```

---

## Example Workflows

### flyway [./templates/flyway/ci.yaml](/templates/flyway/ci.yaml)

- flyway (*-db)

  ```bash
  ./setup_ci.sh flyway
  ```

### java shared library [./templates/java-shared-lib/ci.yaml](/templates/java-shared-lib/ci.yaml)

- java shared library
- see [Google doc](https://cloud.google.com/artifact-registry/docs/java/store-java)

  ```bash
  ./setup_ci.sh java-shared-lib
  ```

### maven [./templates/maven/ci.yaml](/templates/maven/ci.yaml)

- Camunda BPM
- Java

  ```bash
  ./setup_ci.sh maven
  ```
