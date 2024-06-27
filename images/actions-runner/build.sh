#!/usr/bin/env bash
set -e
IMAGE=public.ecr.aws/a8b3v2c8/actions-runner:latest

docker build -t $IMAGE .
docker push $IMAGE
