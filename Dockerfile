FROM google/cloud-sdk:latest as base

ARG GKEAPPLICATIONCREDENTIALS
ARG GKENAMESPACE
ARG GKEPROJECTID
ARG GKECLUSTERNAME
ARG GKELOCATIONZONE

WORKDIR /
RUN echo "${GKEAPPLICATIONCREDENTIALS}"
RUN echo "${GKEAPPLICATIONCREDENTIALS}" | base64 -d > /account.json
RUN gcloud auth configure-docker
RUN gcloud auth activate-service-account --key-file=/account.json
RUN gcloud config set project $GKEPROJECTID
RUN gcloud container clusters get-credentials $GKECLUSTERNAME --zone $GKELOCATIONZONE --project $GKEPROJECTID
ENV KUBECONFIG=/.kube/config

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
