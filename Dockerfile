FROM alpine:3.20
RUN apk add --update-cache curl jq && \
    rm -rf /var/cache/apk/*
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
