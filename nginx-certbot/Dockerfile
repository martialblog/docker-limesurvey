FROM nginx
RUN apt-get update && \
    apt-get install -y certbot curl python-certbot-nginx && \
    apt-get -y autoclean; apt-get -y autoremove; \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

CMD ["/entrypoint.sh"]
