# .PHONY: apache fpm fpm-alpine

apache-lts:
	docker build --pull -t martialblog/limesurvey:3-apache 3.0/apache
apache-latest:
	docker build --pull -t martialblog/limesurvey:5-apache 5.0/apache
fpm-alpine-lts:
	docker build --pull -t martialblog/limesurvey:3-fpm-alpine 3.0/fpm-alpine
fpm-alpine-latest:
	docker build --pull -t martialblog/limesurvey:5-fpm-alpine 5.0/fpm-alpine
fpm-lts:
	docker build --pull -t martialblog/limesurvey:3-fpm 3.0/fpm
fpm-latest:
	docker build --pull -t martialblog/limesurvey:5-fpm 5.0/fpm
