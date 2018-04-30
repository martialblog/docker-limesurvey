# Contributing

Every Pull Request is welcome.

## Upgrading the Version

To upgrade the LimeSurvey Version the ARG variable needs to be changed.

```bash
$ grep Agrep ARG apache/Dockerfile
ARG version='3.7.0+180418'
```

Since this is a reoccuring and boring task, a script is provided.

```bash
# Dependencies
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt

# Upgrades to latest Limesurvey version
./upgrade.py
```

## Testing

In order to make sure the image works as promised, some tests are provided:

```bash
./tests/run.sh
```

For further information:  https://github.com/GoogleContainerTools/container-structure-test
