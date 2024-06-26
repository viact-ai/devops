FROM ghcr.io/actions/actions-runner:latest

USER root

RUN apt update -y && \
    apt install awscli -y
RUN apt autoremove && \
    apt autoclean

USER runner