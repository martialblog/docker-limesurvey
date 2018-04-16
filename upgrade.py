#!/usr/bin/env python3


import feedparser
import sys
import subprocess

dockerfile_apache = 'apache/Dockerfile'
dockerfile_fpm = 'fpm/Dockerfile'

limesv_feed_url = 'https://github.com/LimeSurvey/LimeSurvey/releases.atom'
docker_feed_url = 'https://github.com/martialblog/docker-limesurvey/releases.atom'

limesv_feed = feedparser.parse(limesv_feed_url)
docker_feed = feedparser.parse(docker_feed_url)

limesv_current_release = limesv_feed.entries[0].title_detail.value
docker_current_release = docker_feed.entries[0].title_detail.value

if limesv_current_release == docker_current_release:
    print('Nothing to do.')
    sys.exit(0)

print('New Version {} available. Upgrading...'.format(limesv_current_release))
commit_message = 'Update to Version {}'.format(limesv_current_release)

# Dockerfiles
regexp = 's/[0-9]\.[0-9]\.[0-9]+[0-9]*/{new_version}/'.format(new_version=limesv_current_release)
subprocess.call(['sed', '-i', '-e',  regexp, dockerfile_apache])
subprocess.call(['sed', '-i', '-e',  regexp, dockerfile_fpm])
print('> Updated Dockerfiles')

# Git Commit/Tag
# subprocess.call(['git', 'checkout', '-b', limesv_current_release])
subprocess.call(['git', 'add',  dockerfile_apache])
subprocess.call(['git', 'add',  dockerfile_fpm])
subprocess.call(['git', 'commit',  '-m', commit_message])
subprocess.call(['git', 'tag', limesv_current_release])
print('> Created new Commit and Tag')

# Git Push
# subprocess.call(['git', 'push', 'origin', limesv_current_release])
subprocess.call(['git', 'push'])
subprocess.call(['git', 'push', 'origin', '--tags'])
print('> Pushed to new Branch')

sys.exit(0)
