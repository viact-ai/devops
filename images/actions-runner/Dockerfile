FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt update -y && \
    apt install -y  awscli curl
RUN apt autoremove && \
    apt autoclean

USER runner