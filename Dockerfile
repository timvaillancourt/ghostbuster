FROM golang:1.21-bullseye

RUN apt-get update && apt-get install -y default-mysql-client

ARG GIT_TAG

ADD entrypoint.sh /entrypoint.sh

RUN git clone -b ${GIT_TAG} https://github.com/slackhq/gh-ost /go/src/github.com/slackhq/gh-ost
WORKDIR /go/src/github.com/slackhq/gh-ost

RUN go build -ldflags "-X main.AppVersion=${GIT_TAG}" -o /usr/local/bin/gh-ost ./go/cmd/gh-ost/main.go

ENTRYPOINT ["/entrypoint.sh"]
