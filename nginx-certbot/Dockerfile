FROM nginx:stable
LABEL maintainer="markus@martialblog.de"

RUN set -ex; \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive \
        apt-get install --no-install-recommends -y \
        certbot curl python3-certbot-nginx && \
        apt-get -y autoclean; apt-get -y autoremove; \
        rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
CMD ["/entrypoint.sh"]
