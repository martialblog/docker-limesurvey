# Contributing

Every Pull Request is welcome.

## Branches
Choosing a proper name for a branch helps us identify its purpose and possibly find an associated bug or feature. Generally a branch name should include a topic such as `fix` or `feature` followed by a description. Branches should have only changes relevant to a specific issue.

```
git checkout -b fix/bug-in-connection
git checkout -b feature/improved-config-handling
git checkout -b doc/fix-typo
```

## Upgrading the Version

The versions in this repository should correspond to the [GitHub LimeSurvey Releases](https://github.com/LimeSurvey/LimeSurvey/releases)

To update the version, simply update ARG variables for version and corresponding checksum:

```bash
# Version from GitHub Tags
# sha256 of tar.gz from GitHub Releases

$ grep ARG 7.0/apache/Dockerfile
ARG version='7.0.0+260526'
ARG sha256_checksum='31574d9eb76afe237208e838b2cb2a66b440d673d084afcab0f52cb2772fc090'
```

It is best to use the upgrade shell script:

```bash
./upgrade.sh 7.0.0+260526
# Check if sha256 is correct

git add 7.0/ && git commit -m 'Upgrading to Version 7.0.0+260526'
git tag 7.0.0-260526
```

## Testing

In order to make sure the image works as promised, some container-structure-tests are provided. The tests require the `container-structure-test` tool to be installed.

For further information:  https://github.com/GoogleContainerTools/container-structure-test

```bash
make apache-latest

container-structure-test test --image docker.io/martialblog/limesurvey:7-apache --config tests/apache-tests.yaml
```

```bash
make fpm-latest

container-structure-test test --image  docker.io/martialblog/limesurvey:7-fpm --config tests/fpm-tests.yaml
```

```bash
make fpm-alpine-latest

container-structure-test test --image  docker.io/martialblog/limesurvey:7-fpm-alpine --config tests/fpm-alpine-tests.yaml
```

### ARM Platform

Changes related to the ARM platform should use branches starting with the `arm/` prefix, this ensures the GitHub Actions are triggered.

Background: ARM builds take a long time to finish on the GitHub Runners.
