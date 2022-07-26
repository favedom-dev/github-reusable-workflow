# github-reusable-workflow

First time a repo is using GitHub Actions see

- `setup_repo.sh` doc below under [`./scripts`](#scripts)

---

## [`./.github/workflows`](./.github/workflows)

- `flyway-docker-build.yaml`

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

- `maven-docker.yaml`

  ```yaml
    maven-docker:
      uses: favedom-dev/github-reusable-workflow/.github/workflows/maven-docker.yaml@master
      needs: [repo-version, workaround-name]
      with:
        NAME: ${{ needs.workaround-name.outputs.NAME }}
        VERSION: ${{ needs.repo-version.outputs.version }}
      secrets:
        GH_TOKEN: ${{ secrets.GH_TOKEN }}
        WIF_PROVIDER: '${{ secrets.WIF_PROVIDER }}'
        WIF_SERVICE_ACCOUNT: '${{ secrets.WIF_SERVICE_ACCOUNT }}'
        NEXUS_FAVEDOM_DEV_PASSWORD: ${{ secrets.NEXUS_FAVEDOM_DEV_PASSWORD }}
  ```

- `repo-version.yaml`
  - typically the first job to be called

  ```yaml
    repo-version:
      uses: favedom-dev/github-reusable-workflow/.github/workflows/repo-version.yaml@master
      secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }}
  ```

---

## [`./scripts`](./scripts)

- `auto-increment-version.sh`
  - used within GH action to set the version and if a merge into master update the repo version

- `preview_copy_secrets.sh`
  - copy array of secrets into preview namespace

  ```bash
  export PR_NUM=67
  export APP_NAME=peeq-sms

  export SECRET_NAMESPACE=jx-staging
  export SECRETS_STAGING=("rabbitmq" "peeq-users" "peeq-sms-twilio" "jx-staging-peeq-sms-pg")
  ./preview_copy_secrets.sh "${SECRETS_STAGING[@]}"

  export SECRET_NAMESPACE=jx
  export SECRETS_JX=("stackhawk-fan" "stackhawk-preview")
  ./preview_copy_secrets.sh "${SECRETS_JX[@]}"
  ```

- `setup_repo.sh`
  - Only need to run 1 time to setup authentication in a repo that needs to Google Auth
    - copy script to repo adding GH actions
    - run the script
    - do not add the script to the repo
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
