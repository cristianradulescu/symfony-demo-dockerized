FROM sfdemo-dockerized:base

ARG USERNAME
WORKDIR /var/www/demo
USER $USERNAME
CMD ["symfony", "serve", "--port=8000", "--no-tls", "--no-interaction"]