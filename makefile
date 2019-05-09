.PHONY: apache fpm fpm-alpine

apache:
	docker build --pull -t limesurvey:apache apache
fpm-alpine:
	docker build --pull -t limesurvey:fpm-alpine fpm-alpine
fpm:
	docker build --pull -t limesurvey:fpm fpm
