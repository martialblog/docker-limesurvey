#!/usr/bin/env bash
# Upgrade script

set -x

if [ $# -eq 0 ]
  then
      echo 'Pass new LimeSurvey Version tag:'
      echo 'upgrade.sh 3.15.8+190130'
      exit 1
fi

NEW_VERSION=$1

grep -qc $NEW_VERSION apache/Dockerfile fpm/Dockerfile fpm-alpine/Dockerfile

if [ $? -eq 0 ]
   then
       echo "Already at version ${NEW_VERSION}"
       exit 0
fi

# Download, unzip and chmod LimeSurvey from official GitHub repository
wget -P /tmp "https://github.com/LimeSurvey/LimeSurvey/archive/${NEW_VERSION}.tar.gz"

SHA256_CHECKSUM=$(sha256sum "/tmp/${NEW_VERSION}.tar.gz" | awk '{ print $1 }')

# Update lines in the files
sed -r -i -e "s/[0-9]+(\.[0-9]+)+\+[0-9]+/$NEW_VERSION/" apache/Dockerfile fpm/Dockerfile fpm-alpine/Dockerfile
sed -r -i -e "s/[A-Fa-f0-9]{64}/$SHA256_CHECKSUM/" apache/Dockerfile fpm/Dockerfile fpm-alpine/Dockerfile

# After that, check and commit
