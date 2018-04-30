#!/usr/bin/env bash

IMAGE=$1

if [ ! -f container-structure-test ]; then
   curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test
   chmod +x container-structure-test
fi

./container-structure-test test --image $IMAGE --config tests/image_tests.yaml
