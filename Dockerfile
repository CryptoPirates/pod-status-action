FROM alpine as base

RUN apk add --update python curl bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
