# Contributing

Every Pull Request is welcome.

## Upgrading the Version

The versions in this repository should correspond to the [GitHub LimeSurvey Releases](https://github.com/LimeSurvey/LimeSurvey/releases)

To update the version, simply update ARG variables for version and corresponding checksum:

```bash
# Version from GitHub Tags
# sha256 of tar.gz from GitHub Releases

$ grep ARG 4.0/apache/Dockerfile
ARG version='4.3.13+200824'
ARG sha256_checksum='4e9c6f20e'
```

It is best to use the upgrade shell script:

```bash
./upgrade.sh 4.3.13+200824
# Check if sha256 is correct

git add 4.0/ && git commit -m 'Upgrading to Version 4.3.13+200824'
git tag 4.3.13+200824
```

## Testing

In order to make sure the image works as promised, some tests are provided:

```bash
./tests/run.sh
```

For further information:  https://github.com/GoogleContainerTools/container-structure-test
