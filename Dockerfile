FROM alpine:3
RUN apk add --update --no-cache curl jq
RUN ["bin/sh", "-c", "mkdir -p /src"]
COPY ["src", "/src/"]
ENTRYPOINT ["/src/entrypoint.sh"]