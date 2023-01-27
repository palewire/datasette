Install the dependencies.

```bash
pipenv install
```

Login to fly.io

```bash
flyctl auth login
```

Deploy to fly.io

```bash
pipenv run make deploy
```
