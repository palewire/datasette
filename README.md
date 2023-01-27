A Datasette instance hosted at [palewi.re/docs](https://palewi.re/docs/)

## Installation

Install the dependencies.

```bash
pipenv install
make install_plugins
```

Create our databases.

```bash
make
```

Launch a local test server

```bash
make serve
```

## Deployment

Every push to the main branch is deploy automatically via a GitHub Action. You can do it manually with the following commands.

Login to fly.io

```bash
flyctl auth login
```

Deploy to fly.io

```bash
make deploy
```
