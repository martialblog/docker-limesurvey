.PHONY: apache fpm fpm-alpine

apache:
	docker build --pull -t limesurvey:apache 3.0/apache
apache4:
	docker build --pull -t limesurvey:apache 4.0/apache
fpm-alpine:
	docker build --pull -t limesurvey:fpm-alpine 3.0/fpm-alpine
fpm-alpine4:
	docker build --pull -t limesurvey:fpm-alpine 4.0/fpm-alpine
fpm:
	docker build --pull -t limesurvey:fpm 3.0/fpm
fpm4:
	docker build --pull -t limesurvey:fpm 4.0/fpm
