FROM golang:1.13-alpine AS gobuilder

RUN apk add --no-cache python3 git make bash curl && \
    git clone https://github.com/strukturag/nextcloud-spreed-signaling /ncs && \
    cd /ncs && \
    make build

FROM alpine

COPY --from=gobuilder /ncs/bin/signaling /

ENTRYPOINT [ "/signaling",  "--config", "/config/server.conf"]
