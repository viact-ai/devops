FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt update -y && \
    apt install -y  awscli curl git \
	make g++
RUN apt autoremove && \
    apt autoclean

USER runner

# Install node JS 18
ENV NODE_VERSION=18.20.3
ENV NVM_DIR=/home/runner/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/home/runner/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN npm install -g yarn

