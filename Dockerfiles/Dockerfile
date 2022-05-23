# syntax=docker/dockerfile:1
ARG GOLANG_IMG=golang:1.16-alpine
ARG ALPINE_IMG=alpine:latest

FROM $GOLANG_IMG AS builder
LABEL maintainer="Orange team"
ARG SERVICE_NAME=hello_app

WORKDIR /src

COPY . .
RUN go get github.com/prometheus/client_golang/prometheus/promhttp \
    && go mod download \
    && go build -o /app/$SERVICE_NAME



FROM $ALPINE_IMG
LABEL maintainer="Orange team"
ARG SERVICE_NAME=hello_app
ENV SERVICE_NAME=$SERVICE_NAME

WORKDIR /app

RUN adduser --disabled-password -H web_service
COPY --chown=web_service:web_service --from=builder /app .

EXPOSE 8080
EXPOSE 9000

USER web_service:web_service

CMD ["sh", "-c", "./${SERVICE_NAME}"]

