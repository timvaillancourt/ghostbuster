FROM golang:1.21-bullseye AS build

ARG GIT_TAG

RUN git clone -b ${GIT_TAG} https://github.com/slackhq/gh-ost /go/src/github.com/slackhq/gh-ost
WORKDIR /go/src/github.com/slackhq/gh-ost

RUN go build -ldflags "-X main.AppVersion=${GIT_TAG}" -o /usr/local/bin/gh-ost ./go/cmd/gh-ost/main.go


FROM debian:bullseye

RUN apt-get update && apt-get install -y default-mysql-client

COPY --from=build /usr/local/bin/gh-ost /usr/local/bin/gh-ost

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
