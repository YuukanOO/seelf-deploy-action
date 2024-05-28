# seelf deploy action

Easily deploy your applications on your own [seelf](https://yuukanoo.github.io/seelf/) instance.

> [!WARNING]
> This is an initial version and it doesn't cover every cases. Feel free to contribute! Check the usage example in the [seelf-go-tutorial repository](https://github.com/YuukanOO/seelf-go-tutorial/blob/deploying/.github/workflows/main.yml).

## Inputs

### `host`

**Required**. Root Url of your seelf instance **without the trailing slash** (ex. https://myseelf.instance.com).

### `token`

**Required**. API Token found on your [profile page](https://yuukanoo.github.io/seelf/reference/api.html#api).

### `appid`

**Required**. ID of the application being deployed. You must create it first and retrieve its ID from the url (ex. `https://myseelf.instance.com/apps/{app id is here}`).

### `environment`

**Optional**. Environment on which to deploy. One of `production`, `staging`, default to `production`.

### `branch`

**Optional**. Branch to deploy, default to the environment variable `GITHUB_REF_NAME`.

### `commit`

**Optional**. Commit to deploy, default to the environment variable `GITHUB_SHA`.

## Outputs

### `url`

Main url of the deployed application if at least one http entrypoint has been exposed.

## Usage example

```yml
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - id: deploy
        name: Deploy to seelf
        uses: YuukanOO/seelf-deploy-action@v1
        with:
          host: ${{ secrets.seelf_url }}
          token: ${{ secrets.seelf_token }}
          appid: ${{ secrets.seelf_appid }}
      - name: Output URL
        run: echo "Check it out at ${{ steps.deploy.outputs.url }}"
```
