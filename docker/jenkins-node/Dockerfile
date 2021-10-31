FROM sfdemo-dockerized:base

COPY ./docker/jenkins-node/docker-php-entrypoint.sh /usr/local/bin/docker-php-entrypoint

ARG USERNAME

RUN apt-get install -y openjdk-11-jre ca-certificates gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

RUN groupadd docker || echo 0
RUN usermod -aG docker $USERNAME
USER $USERNAME

ENTRYPOINT ["docker-php-entrypoint"]
