FROM golang:1.13-alpine as builder

ARG GKEAPPLICATIONCREDENTIALS
ARG GKENAMESPACE
ARG GKEPROJECTID
ARG GKECLUSTERNAME
ARG GKELOCATIONZONE

RUN apk add --update python curl bash docker

WORKDIR /
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH=$PATH:/root/google-cloud-sdk/bin
RUN /bin/bash -c "source /github/home/google-cloud-sdk/path.bash.inc"
RUN gcloud components install kubectl
RUN kubectl version

RUN echo "${GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
RUN gcloud auth configure-docker
RUN gcloud auth activate-service-account --key-file=/tmp/account.json
RUN gcloud config set project $GKEPROJECTID
RUN gcloud container clusters get-credentials $GKECLUSTERNAME --zone $GKELOCATIONZONE --project $GKEPROJECTID
ENV KUBECONFIG=/.kube/config

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
