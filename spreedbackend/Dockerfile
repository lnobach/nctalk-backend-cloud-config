FROM golang:1.13-alpine AS gobuilder

RUN apk add --no-cache python3 git make bash curl && \
    git clone https://github.com/strukturag/nextcloud-spreed-signaling /ncs && \
    cd /ncs && \
    make build

FROM alpine

COPY --from=gobuilder /ncs/bin/signaling /app/signaling
RUN echo "signaling:x:789:789:signaling,,,:/app:/bin/bash" >> /etc/passwd && \
    echo "signaling:x:789:" >> /etc/group

USER signaling

ENTRYPOINT [ "/app/signaling", "--config", "/config/server.conf" ]
