# GitHub Reusable Workflow

## TODO

- update staging GitOps repo version on merge to master
  - `deploy-env.yaml`
  - should be done, but will need to make sure it works with Argo CD

---

## Setup repo to use GH Actions

1. First time will need to:
    - authenticate the repo with Google to use GitHub Actions
    - create `./.github/workflows/ci.yaml`
    - See [`setup_repo.sh`](#setup_reposh)

1. Create ci workflow
    - See [`setup_ci.sh`](#setup_cish)
    - See [Example Workflows](#example-workflows)

Example:

```bash
export REPO_TYPE= # bpm | flyway | helm-charts | java-shared-lib | keycloak-themes | maven | node
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

# wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_github_autolinks.sh
wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_repo.sh
wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_ci.sh

# setup_github_autolinks.sh
setup_repo.sh
setup_ci.sh ${REPO_TYPE}

git add .; git commit -a -m "feat: GitHub Actions CI"; git push
```

```bash
wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/setup_branch_protection.sh

setup_branch_protection.sh ${REPO_TYPE}
```

---

## [`./.github/workflows`](./.github/workflows)

### `app-setup.yaml`

- defaults `NAME` to repo name, can be overridden by passing int `OVERRIDE_NAME`

```yaml
  app-setup:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/app-setup.yaml@master
    # with:
    #   OVERRIDE_NAME: 'some-new-name'
    #   OVERRIDE_API_PATH: '/api/++SERVICE++'
```

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

### `docker.yaml`

```yaml
  docker:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/docker.yaml@master
    needs: repo-version
    with:
      NAME: 'peeq-tracking-db'
      VERSION: ${{ needs.repo-version.outputs.version }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
      WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
```

### `helm-charts.yaml`

```yaml
  helm-charts:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/helm-charts.yaml@master
    needs: [app-setup, repo-version, maven-docker]
    with:
      NAME: ${{ needs.app-setup.outputs.NAME }}
      VERSION: ${{ needs.repo-version.outputs.version }}
      PREVIEW_NAMESPACE: ${{ needs.app-setup.outputs.PREVIEW_NAMESPACE }}
      API_PATH: ${{ needs.app-setup.outputs.API_PATH }}
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
      WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
      CHARTMUSEUM_PASSWORD: '${{ secrets.JX_CHARTMUSEUM_PASSWORD }}'
```

### `lint-sql.yaml`

- Currently a **placeholder** for SQL linting (flyway projects)
  - SQLFluff
    - [GitHub Actions](https://github.com/sqlfluff/sqlfluff-github-actions)
    - [Docs](https://docs.sqlfluff.com/en/stable/)
    - [Rules](https://docs.sqlfluff.com/en/stable/rules.html)
    - [cli](https://docs.sqlfluff.com/en/stable/cli.html)
    - repo [sqlfluff](https://github.com/sqlfluff/sqlfluff)

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

### `node-docker.yaml`

```yaml
  node-docker:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/node-docker.yaml@master
    needs: [repo-version, workaround-env]
    with:
      NAME: ${{ needs.workaround-env.outputs.NAME }}
      VERSION: ${{ needs.repo-version.outputs.version }}
      # UPLOAD_GS: true
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
      WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
      WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
```

### `preview-env-cleanup.yaml`

- Common workflow to used to clean up PR environments
- See `preview-cleanup.yaml` [doc](#pr_cleanupyaml) or [file](./templates/preview-cleanup.yaml)

### `repo-version.yaml`

- typically the first job to be called

```yaml
  repo-version:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/repo-version.yaml@master
    secrets:
    GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

### `stackhawk.yaml`

```yaml
  stackhawk:
    uses: favedom-dev/github-reusable-workflow/.github/workflows/stackhawk.yaml@master
    needs: [app-setup, repo-version, maven-docker, helm-charts]
    if: github.event_name == 'pull_request' && needs.app-setup.outputs.IS_STACKHAWK_READY == 'true'
    with:
      NAME: ${{ needs.app-setup.outputs.NAME }}
      NAMESPACE: ${{ needs.app-setup.outputs.PREVIEW_NAMESPACE }}
      API_PATH: ${{ needs.app-setup.outputs.API_PATH }}
      # JOBS_TIMEOUT: 15
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
      HAWK_API_KEY: ${{ secrets.HAWK_API_KEY }}
      TEST_PASSWORD: ${{ secrets.STACKHAWK_TEST_PASSWORD }}
```

---

## [`./.m2`](./.m2)

### `settings.xml`

- Used for maven builds

**NOTE:** pom.xml may need to be updated to include shared libraries [example](https://github.com/favedom-dev/peeq-query/pull/756/files)

```xml
<project>
  <distributionManagement>
    <snapshotRepository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/favedom-dev/peeq-java</url>
    </snapshotRepository>
    <repository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/favedom-dev/peeq-java</url>
    </repository>
  </distributionManagement>

  <repositories>
    <repository>
      <id>artifact-registry</id>
      <url>artifactregistry://us-central1-maven.pkg.dev/favedom-dev/peeq-java</url>
      <releases>
        <enabled>true</enabled>
      </releases>
      <snapshots>
        <enabled>true</enabled>
      </snapshots>
    </repository>
  </repositories>

  <build>
    <extensions>
      <extension>
        <groupId>com.google.cloud.artifactregistry</groupId>
        <artifactId>artifactregistry-maven-wagon</artifactId>
        <version>2.1.0</version>
      </extension>
    </extensions>
  </build>
</project>
```

---

## ['./samples'](./samples)

- some sample files from GitHub actions for reference

---

## [`./scripts`](./scripts)

### `auto_increment_version.sh`

- used within GH action to set the version and if a merge into master update the repo version

```yaml
      - name: "☁️ Get auto_increment_version.sh"
        if: github.event_name != 'pull_request'
        run: |
          wget https://raw.githubusercontent.com/favedom-dev/github-reusable-workflow/master/scripts/auto_increment_version.sh
          chmod 777 ./auto_increment_version.sh
```

### `helm_add_repos.sh`

- add custom repos, typically only done with PR builds

### `helm_add_repos.txt`

- example of the file consumed by `helm_add_repos.sh`

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

### `preview_secrets.sh`

- this is an example starter for copying secrets
- copy into `++REPO++/scripts/`
- update with array of secret names

### `preview_secrets.txt`

- example of the file consumed by `preview_secrets.sh`

### `setup_branch_protection.sh`

- setup GitHub branch protection for rules before merging

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

### `update_component_version.sh`

- **placeholder** to update version number for components

### `update_tag.sh`

- used by peeq-keycloak to update version in tag element

### `update_themes.sh`

- used by Keycloak themes to update version in keycloak config yaml

---

## [`./stackhawk`](./stackhawk)

- files to run stackhawk with GitHub reusable actions

---

## [`./templates`](./templates)

- standard files for types of repositories

---

## [`./yamllint`](./yamllint)

- lint rules for yaml

---

## Example Workflows

### `preview-cleanup.yaml`

- common to be used with any project that creates a PR environment.  This will remove the namespace
- `++REPO_TYPE++` is equal to the sub directory

  ```bash
  ./setup_ci.sh ++REPO_TYPE++
  ```

### bpm [./templates/bpm/ci.yaml](/templates/bpm/ci.yaml)

- Camunda BPM

### flyway [./templates/flyway/ci.yaml](/templates/flyway/ci.yaml)

- flyway (*-db)

### helm-charts [./templates/helm-charts/ci.yaml](/templates/helm-charts/ci.yaml)

- repos that just build helm charts
  - examples:
    - [jitsi-helm-chart](https://github.com/favedom-dev/jitsi-helm-chart)
    - [nginx-rtmp-helm-chart](https://github.com/favedom-dev/nginx-rtmp-helm-chart)

### java-shared-lib [./templates/java-shared-lib/ci.yaml](/templates/java-shared-lib/ci.yaml)

- java shared library
- see [Google doc](https://cloud.google.com/artifact-registry/docs/java/store-java)

### keycloak-themes [./templates/keycloak-themes/ci.yaml](/templates/keycloak-themes/ci.yaml)

### maven [./templates/maven/ci.yaml](/templates/maven/ci.yaml)

- Java

### node [./templates/node/ci.yaml](/templates/node/ci.yaml)

- front ends
