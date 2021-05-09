.PHONY: apache fpm fpm-alpine

apache3:
	docker build --pull -t martialblog/limesurvey:3-apache 3.0/apache
apache3-rootless:
	docker build --pull --build-arg USER=www-data --build-arg LISTEN_PORT=8080 -t martialblog/limesurvey:3-apache-rootless 3.0/apache
apache4:
	docker build --pull -t martialblog/limesurvey:3-apache 3.0/apache
apache4-rootless:
	docker build --pull --build-arg USER=www-data --build-arg LISTEN_PORT=8080 -t martialblog/limesurvey:4-apache-rootless 4.0/apache
fpm-alpine3:
	docker build --pull -t martialblog/limesurvey:3-fpm-alpine 3.0/fpm-alpine
fpm-alpine4:
	docker build --pull -t martialblog/limesurvey:4-fpm-alpine 4.0/fpm-alpine
fpm3:
	docker build --pull -t martialblog/limesurvey:3-fpm 3.0/fpm
fpm4:
	docker build --pull -t martialblog/limesurvey:4-fpm 4.0/fpm
