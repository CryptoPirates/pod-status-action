FROM golang:1.13-alpine as builder

ARG GKEAPPLICATIONCREDENTIALS
ARG GKENAMESPACE
ARG GKEPROJECTID
ARG GKECLUSTERNAME
ARG GKELOCATIONZONE

RUN apk add --update python curl bash

RUN echo "Installing docker"
RUN apk add --update docker

RUN echo "Installing gcloud and kubectl"
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN PATH=$PATH:/root/google-cloud-sdk/bin
RUN source /github/home/google-cloud-sdk/path.bash.inc
RUN gcloud components install kubectl
RUN kubectl version

RUN echo "Getting kubeconfig file from GKE"
RUN echo "${GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
RUN gcloud auth configure-docker
RUN gcloud auth activate-service-account --key-file=/tmp/account.json
RUN gcloud config set project $GKEPROJECTID
RUN gcloud container clusters get-credentials $GKECLUSTERNAME --zone $GKELOCATIONZONE --project $GKEPROJECTID
ENV KUBECONFIG="$HOME/.kube/config"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
