FROM google/cloud-sdk:latest as base

RUN apt-get update && apt-get install bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
