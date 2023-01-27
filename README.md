Install the dependencies.

```bash
pipenv install
```

Launch a local test server

```bash
pipenv run datasette
```

Login to fly.io

```bash
flyctl auth login
```

Deploy to fly.io

```bash
pipenv run make deploy
```
