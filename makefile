.PHONY: apache fpm fpm-alpine

apache3:
	docker build --pull -t martialblog/limesurvey:3-apache 3.0/apache
apache4:
	docker build --pull -t martialblog/limesurvey:4-apache 4.0/apache
fpm-alpine3:
	docker build --pull -t martialblog/limesurvey:3-fpm-alpine 3.0/fpm-alpine
fpm-alpine4:
	docker build --pull -t martialblog/limesurvey:4-fpm-alpine 4.0/fpm-alpine
fpm3:
	docker build --pull -t martialblog/limesurvey:3-fpm 3.0/fpm
fpm4:
	docker build --pull -t martialblog/limesurvey:3-fpm 4.0/fpm
