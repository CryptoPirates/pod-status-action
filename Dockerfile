FROM google/cloud-sdk:latest as base

ARG GKEAPPLICATIONCREDENTIALS
ARG GKENAMESPACE
ARG GKEPROJECTID
ARG GKECLUSTERNAME
ARG GKELOCATIONZONE

RUN apt-get update
RUN apt-get install bash
RUN apt-get install kubectl
RUN kubectl version

RUN echo "${GKEAPPLICATIONCREDENTIALS}" | base64 -d > /tmp/account.json
RUN gcloud auth configure-docker
RUN gcloud auth activate-service-account --key-file=/tmp/account.json
RUN gcloud config set project $GKEPROJECTID
RUN gcloud container clusters get-credentials $GKECLUSTERNAME --zone $GKELOCATIONZONE --project $GKEPROJECTID
ENV KUBECONFIG=/.kube/config

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
